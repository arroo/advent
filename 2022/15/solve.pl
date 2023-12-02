#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my $SEP = ',';

sub key {
	return join($SEP, @_);
}

sub coords {
	return [split /$SEP/, $_[0]];
}

sub parse {
	my ($lines) = @_;

	return reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		if (my ($x, $y, $cX, $cY) = $line =~ /^Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)$/) {
			push @{$acc}, [[$x, $y], [$cX, $cY]];

		} else {
			die "malformed line: $line";
		}

		return $acc;
	},
	$lines,
	[],
	);
}

sub tooClose {
	my ($sensor, $beacon, $target) = @_;


	return manhattan(@$sensor, @$beacon) >= manhattan(@$sensor, @$target);
}

sub solveLine {
	my ($sensors, $targetRow, $bounds) = @_;

	#my $targetRow = 2_000_000;
	#$targetRow=10;

	#my $sensors = parse($lines);

	my %cant;
	for my $i (0 .. $#$sensors) {
		my $s = $sensors->[$i];

		#print "looking at sensor $i: " .join(' ',flatten($s)). "\n";

		# find vertical distance to targetRow
		my $td = manhattan(@{$s->[0]}, $s->[0][0], $targetRow);
		my $md = manhattan(flatten($s));
		#next if ($td > $md);

		my $slack = $md - $td;

		#next if ($slack < 0);

		my $b = key(@{$s->[1]});

		my $lower = defined $bounds ? max($s->[0][0] - $slack, $bounds->[0]) : $s->[0][0] - $slack;
		my $higher = defined $bounds ? min($s->[0][0] + $slack, $bounds->[1]) : $s->[0][0] + $slack;

		for my $x ($lower .. $higher) {
			my $k = key($x, $targetRow);

			$cant{$k} = undef if ($b ne $k);
		}
	}

	return \%cant;
}

sub solveOne {
	my ($lines) = @_;

	my $sensors = parse($lines);

	my $cant = solveLine($sensors, 2_000_000);

	return scalar keys %$cant;
}

sub nothing {
	my ($lines) = @_;

	my $beacons = parse($lines);

	my $targetRow = 2_000_000;
	# sample
	#$targetRow = 10;

	# find all things that cannot be there
	# very naive approach is to find the left- and right-most possible on any row,
	# then iterate between those and each beacon to see if it can go there

	my %beacons;
	for my $b (@$beacons) {
		$beacons{key(@{$b->[1]})} = undef;
	}

	my $left = $beacons->[0][0];
	my $right = $beacons->[0][0];

	for my $b (@$beacons) {
		my $md = manhattan(@{$b->[0]}, @{$b->[1]});

		$left = min($left, $b->[0][0] - $md);
		$right = max($left, $b->[0][0] + $md);
	}

	my $cant = 0;
	my $seen = 0;
	my $interval = 10_000;
	my $y = $targetRow;
	OUTERMOST: for my $x ($left .. $right) {
		if ($seen++ % $interval == 0) {
			print "( left:$left, right:$right ) checking $x cant:$cant\n";
		}

		my @c = ($x, $y);

		#print "checking $x\n";
		if (exists $beacons{key(@c)}) {
			next;
		}


		for my $b (@$beacons) {
			if (tooClose(@$b, \@c)) {
				$cant++;
				next OUTERMOST;
			}
		}
	}

	#return Dumper($left, $right);


	return $cant;
}

sub solveTwo2 {
	my ($lines) = @_;

	my $sensors = parse($lines);

	my %beacons;
	for my $s (@$sensors) {
		$beacons{key(@{$s->[1]})} = undef;
	}

	my $multiplier = 4000000;

       	my $bound = 4000000;
	#$bound = 20; # sample

	my $maxY = $bound;
	my $maxX = $bound;

	my $seen = 0;
	my $interval = 100_000;

	my @bounds = (0, $bound);

	for my $y (0 .. $maxY) {
		my $cant = solveLine($sensors, $y, \@bounds);
		#my $cant = {};

		#print Dumper($cant);
		print "$y\n" if ($seen++ % $interval == 0);

		for my $x (0 .. $maxX) {
			my $k = key($x, $y);
			#next;
			next if exists $cant->{$k} or exists $beacons{$k};

			print Dumper($x, $y);

			return $x * $multiplier + $y;
		}
	}

	die "not found";
}

sub quadtree {
	my ($points) = @_;

	# assume all points have same diminsionality
	my $diminsionality = scalar @{$points->[0]};
	print "diminsionality: $diminsionality\n";

	my $f;
	$f = sub {
		my ($points, $dimensionIndex) = @_;

		if (scalar @$points == 0) {
			return undef;
		}

		if (scalar @$points == 1) {
			return $points;
		}

		# sort by dimension
		my @sorted = sort { $a->[$dimensionIndex] <=> $b->[$dimensionIndex] } @$points;

		# find median
		my $medianIndex = int(scalar $#sorted / 2);

		my @left = @sorted[0 .. $medianIndex-1];
		my @right = @sorted[$medianIndex+1 .. $#sorted];

		my $nd = ($dimensionIndex + 1) % $diminsionality;

		return [$sorted[$medianIndex], $f->(\@left, $nd), $f->(\@right, $nd)];

	};

	return $f->($points, 0);
}

sub sensorsToPoints {
	my ($sensors) = @_;

	my @out = map { $_->[0] } @$sensors;

	return \@out;
}

sub solveTwo3 {
	my ($lines) = @_;

	my $sensors = parse($lines);

	my $points = sensorsToPoints($sensors);
	#return Dumper($points);

	# turn into point quadtree
	my $quadtree = quadtree($points);

	return Dumper($quadtree);
}

sub withinBoundingBox {
	my ($bounds) = @_;

	my ($lX, $lY, $hX, $hY) = flatten($bounds);

	return sub {
		my ($x, $y) = @_;

		if ($lX <= $x and $x <= $hX and $lY <= $y and $y <= $hY) {

			#print "($x, $y) within ($lX, $lY) -> ($hX, $hY)\n";

			return 1;
		}

		return 0;
	};
}

sub outsidePoints {
	my ($sensor, $boundingBox) = @_;

	my $radius = manhattan(flatten($sensor));
	my @centre = @{$sensor->[0]};
	my $within = withinBoundingBox($boundingBox);

	#print Dumper($sensor, $boundingBox, $radius);

	my @out;

	# start right, go up
	for (my ($x, $y) = ($centre[0]+$radius+1, $centre[1]); $x >= $centre[0] ; $x--,$y++) {
		if ($within->($x, $y)) {
			push @out, [$x, $y];
		}
	}

	# start right, go down
	for (my ($x, $y) = ($centre[0]+$radius+1, $centre[1]); $x >= $centre[0] ; $x--,$y--) {
		if ($within->($x, $y)) {
			push @out, [$x, $y];
		}
	}

	# start left, go up
	for (my ($x, $y) = ($centre[0]-$radius-1, $centre[1]); $x <= $centre[0] ; $x++,$y++) {
		if ($within->($x, $y)) {
			push @out, [$x, $y];
		}
	}

	# start left, go down
	for (my ($x, $y) = ($centre[0]-$radius-1, $centre[1]); $x <= $centre[0] ; $x++,$y--) {
		if ($within->($x, $y)) {
			push @out, [$x, $y];
		}
	}

	return \@out;
}

sub solveTwo {
	my ($lines) = @_;

	my $sensors = parse($lines);

	my @radii;
	for my $s (@$sensors) {
		push @radii, manhattan(flatten($s));
	}

	my $multiplier = 4_000_000;

	my $max = 4_000_000;
	#$max = 20;

	my @boundingBox = ([0,0],[$max, $max]);

	# get all points just outside radius of each sensor
	my $totS = scalar @$sensors;

	for my $i (0 .. $#$sensors) {

		my $s = $sensors->[$i];

		#print "sensor $i/$totS (x=$s->[0][0], y=$s->[0][1], r=$radii[$i])\n";

		my $points = outsidePoints($s, \@boundingBox);
		my $totP = scalar @$points;

		print "sensor $i/$totS has $totP points\n";

		POINT: for my $k (0 .. $#$points) {

			my $p = $points->[$k];

			#print " - point $k/$totP (x=$p->[0], y=$p->[1]) \n";

			for my $j (0 .. $#$sensors) {
				next if ($i == $j);

				my $s2 = $sensors->[$j];
				my $r = $radii[$j];
				my $d = manhattan(@{$sensors->[$j][0]}, @$p);

				#print "  - compare $j/$totS (x=$s2->[0][0], y=$s2->[0][1], r=$r) = $d\n";

				# point is not possible to be distress signal if it's within
				# another sensor's radius
				next POINT if ($d <= $r);
			}

			return $p->[0] * $multiplier + $p->[1];

			#return Dumper($p);
		}

		#return Dumper($points);
	}

	die "not found";
}

main(\&solveOne, \&solveTwo);
