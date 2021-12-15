#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub neighbours {
	my ($graph, $pt) = @_;

	my ($x, $y) = split /,/, $pt;

	my @check = (
		[$x-1,$y],
		[$x+1,$y],
		[$x,$y-1],
		[$x,$y+1],
	);

	my @out;
	for my $ct (@check) {
		my $pos = join(',', @$ct);
		if (exists $graph->{$pos}) {
			push @out, $pos;
		}
	}

	#print "neighbours of $pt are @out\n";

	return \@out;

	return [sort { $graph->{$a} <=> $graph->{$b} } @out];
}

sub distanceSquared {
	my ($A, $B) = @_;

	my ($xA,$yA) = split /,/, $A;
	my ($xB,$yB) = split /,/, $B;

	my $dX = $xA-$xB;
	my $dY = $yA-$yB;

	return $dX * $dX + $dY * $dY;
}

sub manhattanDistance {
	my ($A, $B) = @_;

	my ($xA,$yA) = split /,/, $A;
	my ($xB,$yB) = split /,/, $B;

	my $dX = abs($xA-$xB);
	my $dY = abs($yA-$yB);

	return $dX + $dY;
}

sub compare {
	my ($A, $B, $target) = @_;

	if (not defined $B) {
		return -1;
	}

	if (not defined $A) {
		return 1;
	}

	my ($posA, $ctA) = @$A;
	my ($posB, $ctB) = @$B;

	return (
		$ctA <=> $ctB
		or manhattanDistance($posA, $target) <=> manhattanDistance($posB, $target)
	);

	if ($ctA < $ctB) {
		return -1;
	}

	if ($ctA > $ctB) {
		return 1;
	}


	#my $dA = distanceSquared($posA, $target);
	#my $dB = distanceSquared($posB, $target);
	my $dA = manhattanDistance($posA, $target);
	my $dB = manhattanDistance($posB, $target);

	if ($dA < $dB) {
		return -1;
	}

	if ($dA > $dB) {
		return 1;
	}

	return 0;
}

sub makeCompare {
	my ($target) = @_;

	return sub {
		my ($A, $B) = @_;

		return compare($A, $B, $target);
	};
}

sub display {
	my ($graph, $visited) = @_;

	my $maxX = max(map { (split /,/, $_)[0] } keys %$graph);
	my $maxY = max(map { (split /,/, $_)[1] } keys %$graph);

	#my $string = "\033[2J\033[0;0H";
	my $string = '';
	for my $y (0 .. $maxY) {
		for my $x (0 .. $maxX) {
			my $pos = "$x,$y";

			$string .= "\e[31m" if (exists $visited->{$pos});
			$string .= $graph->{$pos};
			$string .= "\e[0m" if (exists $visited->{$pos});
		}

		$string .= "\n";
	}

	return $string;
}

sub solveOne {
	my ($lines) = @_;

	my $graph = reduce (
		sub {
			my ($acc, $line, $i) = @_;

			my @split = split //, $line;

			$acc->{"$_,$i"} = $split[$_] for (0 .. $#split);

			return $acc;
		},
		$lines,
		{},
	);

	return solve($graph);
}

sub binsearch {
	my ($compareFn, $elem, $list) = @_;

	# Returns the index of the position before
	# the one where $s would be found, when $s
	# is not found.

	my $i = 0;
	my $j = $#$list;

	for (;;) {
		my $k = int(($j-$i)/2) + $i;

		my $c = $compareFn->($elem, $list->[$k]);

		if ($c == 0) {
			return $k;
		}

		if ($c < 0) {
			$j = $k - 1;

			if ($i > $j) {
				return $j;
			}

		} else {
			$i = $k + 1;

			if ($i > $j) {
				return $k;
			}
		}
	}
}

sub solve {
	my ($graph) = @_;

	#print Dumper($graph);

	my $targetX = max(map { (split /,/)[0] } keys %$graph);
	my $targetY = max(map { (split /,/)[1] } keys %$graph);
	my $target = "$targetX,$targetY";

	my @search = (['0,0', 0, {}]);
	my %seen = ('0,0' => 0);
	my $it = 0;

	#my $compareFn = makeCompare($target);
	my $compareFn = sub {
		my ($A, $B) = @_;
		return compare($A, $B, $target);
	};

	while (scalar @search > 0) {
		$it++;
		my $node = shift @search;

		my ($pt, $total, $path) = @$node;


		my $string = "\033[2J\033[0;0H";
		#$string .= display($graph, $path);
		#$string .= "it:$it pt:$pt tot:$total len:".scalar(%$path)."\n";
		#print $string;

		#print "pt:$pt tot:$total\n";
		#print Dumper($path);

		if ($pt eq $target) {
			return $total;
		}

		my $moves = neighbours($graph, $pt);

		for my $n (@$moves) {
			my $newTotal = $total + $graph->{$n};
			#my $newNode = [$n, $newTotal, {%$path, $n => undef}];
			my $newNode = [$n, $newTotal];

			if (exists $seen{$n} and $seen{$n} <= $newTotal) {
				next;
			}

			$seen{$n} = $newTotal;


			my $j = 0;
			# slow insertion
			#$j++ while ($j <= $#search and compare($newNode, $search[$j], $target) >= 0);

			#if ($j <= $#search) {
				$j = binsearch($compareFn, $newNode, \@search);
			#}


			splice @search, $j+1, 0, $newNode;
		}

		#print Dumper(\@search);
	}

	return -1;
}

sub solveTwo{
	my ($lines) = @_;

	my $graph = reduce (
		sub {
			my ($acc, $line, $i) = @_;

			my @split = split //, $line;

			$acc->{"$_,$i"} = $split[$_] for (0 .. $#split);

			return $acc;
		},
		$lines,
		{},
	);

	my $maxX = max(map { (split /,/, $_)[0] } keys %$graph)+1;
	my $maxY = max(map { (split /,/, $_)[1] } keys %$graph)+1;

	# expand!
	$graph = reduce(
		sub {
			my ($acc, $k) = @_;

			my ($baseX, $baseY) = split /,/, $k;
			my $v = $acc->{$k}; # guaranteed to exist since acc is graph

			for my $mY (0 .. 4) {
				my $posY = $baseY + $maxY * $mY;

				my $vY = $v;
				for (my $j = 0; $j < $mY; $j++) {
					if (++$vY > 9) {
						$vY = 1;
					}
				}

				for my $mX (0 .. 4) {

					my $vX = $vY;
					for (my $j = 0; $j < $mX; $j++) {
						if (++$vX > 9) {
							$vX = 1;
						}
					}

					my $posX = $baseX + $maxX * $mX;
					my $pos = "$posX,$posY";

					$acc->{$pos} = $vX;
				}
			}

			return $acc;
		},
		[keys %$graph],
		$graph,
	);

	#print Dumper($graph);
	#return -1;

	return solve($graph);
}

main(\&solveOne, \&solveTwo);
