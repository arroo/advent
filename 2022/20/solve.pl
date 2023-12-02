#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub parse {
	my ($lines) = @_;


}

sub solveOne {
	my ($lines) = @_;

	my @lines = @$lines;

	reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		return $acc;
	},
	$lines,
	0,
	);
}

sub solveTwo {
	my ($lines) = @_;

	return reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		return $acc;
	},
	$lines,
	0,
	);
}

main(\&solveOne, \&solveTwo);
