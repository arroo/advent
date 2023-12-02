#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub solve {
	my ($lines) = @_;

	return reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		if ($line eq '') {
			push @$acc, 0;
		} else {
			$acc->[$#$acc] += $line;
		}

		return $acc;

	},
	$lines,
	[0],
	);
}

sub solveOne {
	my ($lines) = @_;

	my $calories = solve($lines);

	return maxRef($calories);
}

sub solveTwo {
	my ($lines) = @_;

	my $calories = solve($lines);

	my @ordered = reverse sort @$calories;

	return sum(@ordered[0..2]);
}

main(\&solveOne, \&solveTwo);
