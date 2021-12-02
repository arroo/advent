#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Utils qw(slurp reduce);

use Data::Dumper;

sub solveOne {
	my ($input) = @_;

	my $horizontal = 0;
	my $depth = 0;

	for my $line (@$input) {
		my ($direction, $amount) = $line =~ m/(.+) (\d+)/;

		if ($direction eq 'forward') {
			$horizontal += $amount;
		} elsif ($direction eq 'down') {
			$depth += $amount;
		} elsif ($direction eq 'up') {
			$depth -= $amount;
		} else {
			print "unknown direction for line '$line'\n";
		}
	}

	return $horizontal * $depth;
}

sub solveTwo {
	my ($input) = @_;

	my $horizontal = 0;
	my $depth = 0;
	my $aim = 0;

	for my $line (@$input) {
		my ($direction, $amount) = $line =~ m/(.+) (\d+)/;

		if ($direction eq 'forward') {
			$horizontal += $amount;
			$depth += $aim * $amount;
		} elsif ($direction eq 'down') {
			$aim += $amount;
		} elsif ($direction eq 'up') {
			$aim -= $amount;
		} else {
			print "unknown direction for line '$line'\n";
		}
	}

	return $horizontal * $depth;
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
