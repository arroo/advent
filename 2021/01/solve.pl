#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Utils;

use Data::Dumper;

sub solve {
	my ($input, $windowSize) = @_;

	my $incs = 0;

	for my $i ($windowSize .. $#$input) {
		if ($input->[$i] > $input->[$i - $windowSize]) {
			$incs++;
		}
	}

	return $incs;
}

sub solveOne {
	my ($input) = @_;

	return solve($input, 1);
}

sub solveTwo {
	my ($input) = @_;

	return solve($input, 3);
}

sub main {

	my $input = AOC::Utils::slurp();

	my $solver = \&solveTwo;

	if (scalar @ARGV >= 1 and $ARGV[0] eq '1') {
		$solver = \&solveOne;
	}

	my $solution = $solver->($input);

	print "$solution\n";
}

main();
