#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Utils qw(slurp reduceFn);

use Data::Dumper;

sub solve {
	my ($lines, $fn, $init) = @_;

	my $result = reduceFn(
		sub {
			my ($line) = @_;

			return $line =~ m/(.+) (\d+)/;
		},
		$fn,
		$lines,
		$init,
	);

	return $result->[0] * $result->[1];
}

sub solveOne {
	my ($lines) = @_;

	return solve($lines,
		sub {
			my ($acc, $direction, $amount) = @_;


			my ($horizontal, $depth) = @$acc;

			if ($direction eq 'forward') {
				$horizontal += $amount;
			} elsif ($direction eq 'down') {
				$depth += $amount;
			} elsif ($direction eq 'up') {
				$depth -= $amount;
			} else {
				print "unknown direction $direction\n";
			}

			return [$horizontal, $depth];
		},
		[0, 0],
	);
}

sub solveTwo {
	my ($lines) = @_;

	return solve($lines,
		sub {
			my ($acc, $direction, $amount) = @_;

			my ($horizontal, $depth, $aim) = @$acc;

			if ($direction eq 'forward') {
				$horizontal += $amount;
				$depth += $aim * $amount;
			} elsif ($direction eq 'down') {
				$aim += $amount;
			} elsif ($direction eq 'up') {
				$aim -= $amount;
			} else {
				print "unknown direction $direction\n";
			}

			return [$horizontal, $depth, $aim];
		},
		[0, 0, 0],
	);
}

sub main {

	my $input = slurp();

	my $solver = \&solveTwo;

	if (scalar @ARGV >= 1 and $ARGV[0] eq '1') {
		$solver = \&solveOne;
	}

	my $solution = $solver->($input);

	print "$solution\n";
}

main();
