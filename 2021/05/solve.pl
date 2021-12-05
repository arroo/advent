#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;

sub solve {
	my ($lines, $processFn) = @_;

	my $ret = reduceRegex(
		qr/^(\d+),(\d+) -> (\d+),(\d+)$/,
		sub {
			my ($acc, $matches) = @_;
			my ($x1, $y1, $x2, $y2) = @$matches;

			my $stepX = $x2 <=> $x1;
			my $stepY = $y2 <=> $y1;

			return $acc unless $processFn->($stepX, $stepY);

			my $steps = max(abs($x2 - $x1), abs($y2 - $y1));

			for my $i (0 .. $steps) {
				my $x = $x1 + $stepX * $i;
				my $y = $y1 + $stepY * $i;

				$acc->{"$x,$y"}++;
			}

			return $acc;
		},
		$lines,
		{},
	);

	return scalar grep { $ret->{$_} >= 2 } keys %$ret;
}

sub solveOne {
	my ($lines) = @_;

	return solve($lines, sub {
		my ($stepX, $stepY) = @_;
		return $stepX * $stepY == 0;
	});
}

sub solveTwo {
	my ($lines) = @_;

	return solve($lines, sub { return 1 });
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
