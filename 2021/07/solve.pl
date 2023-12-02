#!/usr/bin/env perl

use warnings;
use strict;

use POSIX;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;

sub fuelUsage {
	my ($target, $positions, $fuelFn) = @_;

	return sum(map { $fuelFn->(abs($target - $_)) } @$positions);
}

sub solve {
	my ($lines, $targetFn, $fuelFn) = @_;

	my @values = split /,/, $lines->[0];

	my @targets = $targetFn->(\@values);

	return min(map { fuelUsage($_, \@values, $fuelFn) } @targets);
}

sub solveOne {
	my ($lines) = @_;

	return solve(
		$lines,
		sub {
			my ($values) = @_;

			my @sorted = sort { $a <=> $b } @$values;

			my $mid = int(@sorted) >> 1;
			if (scalar @sorted % 2) {
				return $sorted[$mid];
			}

			my $median = ($sorted[$mid-1] + $sorted[$mid]) >> 1;

			return ceil($median), floor($median);
		},
		sub {
			my ($dist) = @_;

			return $dist;
		});
}

sub solveTwo {
	my ($lines) = @_;

	return solve(
		$lines,
		sub {
			my ($values) = @_;

			my $mean = sumRef($values) / scalar @$values;

			return ceil($mean), floor($mean);
		},
		sub {
			my ($dist) = @_;

			return ($dist * $dist + $dist) >> 1;
		},
	);
}

main(\&solveOne, \&solveTwo);
