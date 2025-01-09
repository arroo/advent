#!/usr/bin/env perl

use warnings;
use strict;

use Time::HiRes qw(usleep);
use POSIX qw(floor);

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);
use AOC::Text qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub parse {
	my ($lines) = @_;

	return reduce(
		sub {
			my ($acc, $line, $i) = @_;

			if (my ($lx, $ly, $lz, $rx, $ry, $rz) = $line =~ /\A(\d+),(\d+),(\d+)~(\d+),(\d+),(\d+)\z/) {
				push @$acc, [[$lx, $ly, $lz], [$rx, $ry, $rz], toBase26($i)];

			} else {
				die "malformed line($i): $line\n";
			}

			return $acc;
		},
		$lines,
		[],
	);
}

sub parse2 {
	my ($parsed) = @_;

	return reduce(
		sub {},
		$parsed,
		{},
	);
}

sub sortByZ {
	# my ($a, $b) = @_;

	return min($a->[0][2], $a->[1][2]) <=> min($b->[0][2], $b->[1][2]);
}

my $minZ = 1;

sub solveOne {
	my ($lines) = @_;

	my $parsed = parse($lines);

	# find the set of blocks that are not the sole supporter of any other block

	for my $brick (@$parsed) {
		for my $other (@$parsed) {

		}
	}

	# drop to ground positions
	my @sorted = sort sortByZ @$parsed;
	my %bricks;

	my %occupied;
	for my $brick (@sorted) {

		$bricks{$brick->[2]} = $brick;

		my ($l, $r) = @$brick;

		my ($lx, $ly, $lz) = @$l;
		my ($rx, $ry, $rz) = @$r;

		my $title = "$lx,$ly,$lz~$rx,$ry,$rz ($brick->[2])";


		my %topCoords;
		my %occCoords;

		#print Dumper([$lx, $ly, $lz,'~',$rx, $ry, $rz]);
		if ($lz != $rz) { # vertical

			if ($lx != $rx or $ly != $ry) {
				die "not vertical block with Z diff: " . Dumper($brick);
			}

			my ($x, $y) = ($lx, $ly);

			my $bottom = min($lz, $rz);

			my $z;
			#for $dz ($minZ-1 .. $bottom-1) {
			for ($z = $bottom-1; $z >= $minZ; $z--) {

				#print "$z\n";
				last if (exists $occupied{"$x,$y,$z"});
			}

			# went 1 past
			$z++;
			my $tz;
			print "$title (vertical): drops down to $z\n";
			for my $offset (0 .. abs($lz-$rz)) {

				my $dz = $z+$offset;
				$tz = $dz;

				$occCoords{"$x,$y,$dz"} = undef;
			}

			$topCoords{"$x,$y,$tz"} = undef;

		} else { # horizontal

			my $mx = min($lx, $rx);
			my $Mx = max($lx, $rx);
			my $my = min($ly, $ry);
			my $My = max($ly, $ry);

			if ($lz != $rz) {
				die "not horizontal block: " . Dumper($brick);
			}

			my $z;
			HZ: for ($z = $lz-1; $z >= $minZ; $z--) {
				#print "\$z:$z\n";
				for my $x ($mx .. $Mx) {
					for my $y ($my .. $My) {
						print "\tcheck '$x,$y,$z'\n";
						last HZ if (exists $occupied{"$x,$y,$z"});
					}
				}
			}

			#print "post: $z\n";

			# went 1 past
			$z++;
			print "$title (horizontal): drops down to $z\n";
			# found correct level to drop to
			for my $x ($mx .. $Mx) {
				for my $y ($my .. $My) {

					$topCoords{"$x,$y,$z"} = undef;
					$occCoords{"$x,$y,$z"} = undef;
				}
			}
		}

		push @$brick, [sort keys %topCoords];

		for my $k (keys %occCoords) {
			$occupied{$k} = $brick;
		}
		#print Dumper(\%occupied);
	}

	print Dumper(\%occupied);
	print Dumper(\%bricks);

	# check which ones are not supporting exactly 1 other brick
	my $total = 0;
	BRICK: for my $brick (@$parsed) {
		my @spots = @{$brick->[3]};
		my $name = $brick->[2];

		my %above;

		for my $k (@spots) {
			my ($x, $y, $z) = split /,/, $k;
			my $az = $z+1;
			my $A = "$x,$y,$az";

			next unless (exists $occupied{$A});

			#die $occupied{$A};

			$above{$occupied{$A}[2]} = undef;
		}


		print "$name is under " . (join(',', keys %above)) . "\n";
		print "\t" . Dumper(\%above);

		for my $A (keys %above) {
			# find only 1 below

			print "$name ^ $bricks{$A}[2]\n";

			my @spots = @{$bricks{$A}[3]};
			my %below;

			for my $s (@spots) {
				my ($x, $y, $z) = split /,/, $s;
				my $bz = $z-1;


				if (exists $occupied{"$x,$y,$bz"}) {
					my $k = $occupied{"$x,$y,$bz"}[2];

					print "$name ^ $bricks{$A}[2] v $bricks{$k}[2]\n";

					$below{$k} = undef;
				}
			}

			

			next BRICK if (scalar keys %below == 1);
		}

		print "$name is disintegratable\n";
		$total++;
	}

	return $total;
}

sub toBase26 {
	my ($n) = @_;

	my $base = 26;
	my $A = ord('A');

	my $i = 0;
	my $out = '';

	while ($n > 0) {
		$out = chr(($n % $base) + $A) . $out;
		$n = int($n / $base);
	}

	return $out || 'A';
}

sub solveTwo {
	my ($lines) = @_;

	for my $i (0 .. 26 * 4) {
		print toBase26($i) . "\n";
	}

	return -1;

}
main(\&solveOne, \&solveTwo);
