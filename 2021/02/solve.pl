#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Utils qw(slurp reduceFn);

use Data::Dumper;

sub solveOne {
	my ($lines) = @_;

	my $status = reduceFn(
		sub {
			my ($line) = @_;

			return $line =~ m/(.+) (\d+)/;
		},
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
		$lines,
		[0, 0],
	);

	return $status->[0] * $status->[1];
}

sub solveTwo {
	my ($lines) = @_;

	my $status = reduceFn(
		sub {
			my ($line) = @_;

			return $line =~ m/(.+) (\d+)/;
		},
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
		$lines,
		[0, 0, 0],
	);

	return $status->[0] * $status->[1];

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
