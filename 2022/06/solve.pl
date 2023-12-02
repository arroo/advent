#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub uniqueChars {
	my ($str) = @_;

	my %str = map { $_ => 0 } @$str;

	return keys %str == scalar @$str;
}

sub solve {
	my ($line, $sequential) = @_;

	$sequential--;

	my @chars = split //, $line;
	for my $i ($sequential .. $#chars) {

		my @sequence = @chars[$i-$sequential .. $i];
		my %s = map { $_ => 0 } @sequence;

		if (scalar keys %s == scalar @sequence) {
			return $i + 1;
		}
	}

	die "could not find it";
}

sub solveOne {
	my ($lines) = @_;

	return solve($lines->[0], 4);
}

sub solveTwo {
	my ($lines) = @_;

	return solve($lines->[0], 14);
}

main(\&solveOne, \&solveTwo);
