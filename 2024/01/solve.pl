#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;


sub solveOne {
	my ($lines) = @_;

	my $lists = reduce(
		sub {
			my ($acc, $line) = @_;

			my ($first, $second) = split(/\W+/, $line);

			push (@{$acc->[0]}, $first);
			push (@{$acc->[1]}, $second);

			return $acc;
		},
		$lines,
		[[],[]],
	);

	#print Dumper($lists);

	my @sorted = map { [sort { $a <=> $b } @$_] } @$lists;

	#print Dumper(\@sorted);

	my @paired;
	for my $i (0 .. $#{$sorted[0]}) {

		push @paired, [$sorted[0][$i], $sorted[1][$i]];
	}

	#print Dumper(\@paired);

	return reduce(
		sub {
			my ($acc, $pair) = @_;

			return $acc + abs($pair->[0] - $pair->[1]);
		},
		\@paired,
		0,
	);
}

sub solveTwo {
	my ($lines) = @_;

	my $info = reduce(
		sub {
			my ($acc, $line) = @_;

			my ($first, $second) = split(/\W+/, $line);

			$acc->[0]{$first}++;
			$acc->[1]{$second}++;

			return $acc;
		},
		$lines,
		[{},{}],
	);

	#print Dumper($info);

	return reduce(
		sub {
			my ($acc, $n) = @_;

			return $acc + $n * $info->[0]{$n} * ($info->[1]{$n} // 0);
		},
		[keys %{$info->[0]}],
		0,
	);
}

main(\&solveOne, \&solveTwo);
