#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

use Time::HiRes qw(usleep);

sub destinationHasSpace {
	my ($graph, $from, $to) = @_;

	my (undef, undef, $size, undef, undef) = @{$graph->{$from}};
	my (undef, undef, undef, undef, $avail) = @{$graph->{$to}};

	return $size <= $avail;
}

sub adjacent {
	my ($graph, $from, $to) = @_;

	my ($x1, $y1, undef, undef, undef) = @{$graph->{$from}};
	my ($x2, $y2, undef, undef, undef) = @{$graph->{$to}};

	return ($x1 == $x2 and abs($y1 - $y2) == 1 or abs($x1 - $x2) == 1 and $y1 == $y2);

}

sub canMove {
	my ($graph, $from, $to) = @_;

	return (
		adjacent($graph, $from, $to)
		and destinationHasSpace($graph, $from, $to)
	);
}

sub neighbours {
	my ($graph, $src) = @_;

	my ($x, $y, undef, undef, undef) = @{$graph->{$src}};

	my @order = (
		[$x-1, $y],
		[$x+1, $y],
		[$x, $y-1],
		[$x, $y+1],
	);

	my @out;
	for my $pt (@order) {
		my $key = join(',', @$pt);
		push @out, $key if exists $graph->{$key};
	}

	return \@out;
}

sub move {
	my ($graph, $from, $to) = @_;


	my ($fx, $fy, $fsize, $fused, $favail) = @{$graph->{$from}};
	my ($tx, $ty, $tsize, $tused, $tavail) = @{$graph->{$to}};

	#print "\tmove: '$from' $fused/$fsize => '$to' $tused/$tsize\n";

	$graph->{$from} = [ $fx, $fy, $fsize,               0, $fsize           ];
	$graph->{$to}   = [ $tx, $ty, $tsize, $tused + $fused, $tavail - $fused ];
}

sub clone {
	my ($graph) = @_;


	return { map { $_ => [@{$graph->{$_}}] } keys %$graph };

	return reduce(
		sub {
			my ($acc, $key) = @_;

			$acc->{$key} = [@{$graph->{$key}}];

			return $acc;
		},
		[keys %$graph],
		{},
	);
}

sub viablePairs {
	my ($graph, $neighFn) = @_;

	return reduce(
		sub {
			my ($acc, $base) = @_;

			my ($baseX, $baseY, $baseSize, $baseUsed, $baseAvail, $basePct) = @{$graph->{$base}};
			if ($baseUsed == 0) {
				return $acc;
			}

			my $possible = reduce(
				sub {
					my ($acc, $comp) = @_;

					my ($x, $y, $size, $used, $avail) = @{$graph->{$comp}};

					if ($avail >= $baseUsed) {

						#print "\tviablePairs: '$base' $baseUsed/$baseSize can move to '$comp' $used/$size\n";

						push @$acc, $comp;
					}

					return $acc;

				},
				$neighFn->($graph, $baseX, $baseY),
				[],
			);

			if (scalar @$possible > 0) {
				$acc->{$base} = $possible;
			}

			return $acc;
		},
		[keys %$graph],
		{},
	);
}

sub parse {
	my ($lines) = @_;

	shift @$lines; # df -h
	shift @$lines; # headers

	my $graph = reduce(
		sub {
			my ($acc, $line, $i, $lines) = @_;

			my ($x, $y, $size, $used, $avail, $pct) = $line =~ m|^/dev/grid/node-x(\d+)-y(\d+)\s+(\d+)T\s+(\d+)T\s+(\d+)T\s+(\d+)%$|;


			$acc->{"$x,$y"} = [$x, $y, $size, $used, $avail];

			return $acc;
		},
		$lines,
		{},
	);

	return $graph;
}

sub solveOne{
	my ($lines) = @_;

	my $graph = parse($lines);

	my $viablePairs = viablePairs(
		$graph,
		sub {
			my ($graph, $x, $y) = @_;
			return [keys %$graph];
		},
	);

	my $ret = reduce(
		sub {
			my ($acc, $base) = @_;

			return $acc + scalar @{$viablePairs->{$base}};
		},
		[keys %$viablePairs],
		0,
	);

	return $ret;
}

sub distanceSquared {
	my ($A, $B) = @_;

	my ($xA,$yA) = split /,/, $A;
	my ($xB,$yB) = split /,/, $B;

	my $dX = $xA-$xB;
	my $dY = $yA-$yB;

	return $dX * $dX + $dY * $dY;
}

sub compare {
	my ($A, $B) = @_;

	my ($graphA, $ctA, $targetA) = @$A;
	my ($graphB, $ctB, $targetB) = @$B;

	#	if ($ctA < $ctB) {
	#		return -1;
	#	}
	#
	#	if ($ctA > $ctB) {
	#		return 1;
	#	}


	# next check distance from empty node to target
	my $eA = min( map { distanceSquared($targetA, $_) } grep { $graphA->{$_}[3] == 0 } keys %$graphA);
	my $eB = min( map { distanceSquared($targetB, $_) } grep { $graphB->{$_}[3] == 0 } keys %$graphB);
	if ($eA < $eB) {
		return -1;
	}

	if ($eA > $eB) {
		return 1;
	}

	# first check distance of targets from origin
	my $dA = distanceSquared($targetA, '0,0');
	my $dB = distanceSquared($targetB, '0,0');
	if ($dA < $dB) {
		return -1;
	}

	if ($dA > $dB) {
		return 1;
	}

	# last check fewer moves
	return $ctA <=> $ctB;
}

sub findEmptyNode {
	my ($graph) = @_;

	return [grep { $graph->{$_}[3] == 0 } keys %$graph];
}

sub draw {
	my ($graph, $target, $ct, $t, $p) = @_;

	my $maxX = max(map { (split /,/, $_)[0] } keys %$graph);
	my $maxY = max(map { (split /,/, $_)[1] } keys %$graph);

	my $immovable = 100;

	my $string = "\033[2J\033[0;0H";
	for my $y (0 .. $maxY) {
		for my $x (0 .. $maxX) {
			my $pos = "$x,$y";

			if (exists $p->{$pos}) {
				$string .= "\e[31m";
			}

			# target
			if ($pos eq $target) {
				$string .= 'G';

			# empty
			} elsif ($graph->{$pos}[3] == 0) {
				$string .= '_';

			# normal
			} elsif ($graph->{$pos}[3] <= $immovable) {
				$string .= '.';

			# too big to move
			} elsif ($graph->{$pos}[3] > $immovable) {
				$string .= '#';

			# ???
			} else {
				$string .= '?';
			}

			if (exists $p->{$pos}) {
				$string .= "\e[0m";
			}
		}

		$string .= "\n";
	}

	print "$string$t : $ct\n";
}

sub hash {
	my ($graph, $target) = @_;

	# all that matters is where is the goal and where is the empty slot
	return join(':', $target, sort { $a cmp $b } grep { $graph->{$_}[3] == 0 } keys %$graph);


	return md5(Dumper($graph));
}

sub solveTwo {
	my ($lines) = @_;

	my $graph = parse($lines);

	#my $cl = clone($graph);
	#print Dumper($graph, $cl, Dumper($graph) eq Dumper($cl));

	my $neighFn = sub {
		my ($graph, $x, $y) = @_;

		my @neighs = map { join(',', @$_) } (
			[$x-1,$y],
			[$x+1,$y],
			[$x,$y-1],
			[$x,$y+1],
		);

		my @exist = grep { exists $graph->{$_} } @neighs;

		return \@exist;
	};

	# find highest x value
	my $tX = max(map { $_->[0] } values %$graph);
	my $tY = max(map { $_->[1] } values %$graph);
	$tY = 0;
	my $target = sprintf('%d,%d', $tX, $tY);

	my %seen;

	my @path = ([$graph, 0, $target, {}]);
	my $i = 0;
	while (scalar @path > 0) {

		#print "$target\n";

		my $node = shift @path;

		#print Dumper($node);

		my ($graph, $ct, $target, $p) = @$node;

		draw($graph, $target, $ct, $i++, $p);
		#usleep(500000);
		#sleep 1;
		$seen{hash($graph, $target)} = undef;
		#

		#print Dumper(\%seen);

		# data has been moved to top-left
		if ($target eq '0,0') {
			return $ct;
		}

		# find possible moves
		my $moves = viablePairs($graph, $neighFn);

		#print Dumper($moves);

		# add them to queue
		#my @queue;
		for my $from (sort { $a cmp $b } keys %$moves) {

			for my $to (@{$moves->{$from}}) {

				# make move
				my $newGraph = clone($graph);
				move($newGraph, $from, $to);

				# follow target
				my $newTarget = ($from eq $target) ? $to : $target;

				if (exists $seen{hash($newGraph, $newTarget)}) {
					next;
				}

				$seen{hash($newGraph, $newTarget)} = undef;

				my $newNode = [$newGraph, $ct+1, $newTarget, {%$p, $to => undef}];

				#print "move $from -> $to ($target)\n";
				#push @queue, $newNode;

				# inset into sorted queue
				my $j = 0;
				$j++ while ( $j < $#path and compare($newNode, $path[$j]) >= 0 );

				splice @path, $j, 0, $newNode;
			}
		}

		# slow
		#@path = sort { compare($a, $b) } @queue, @path;

	}


	return -1;
}

main(\&solveOne, \&solveTwo);
