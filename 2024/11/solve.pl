#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub blink {
	my ($stone) = @_;

	if ($stone == 0) {
		return 1;
	}

	if (length($stone+0) % 2 == 0) {

		my $midpoint = length($stone) / 2;
		my $left = substr $stone, 0, $midpoint, '';

		return $left+0, $stone+0;
	}

	return $stone * 2024;
}

sub solve {
	my ($stones, $times) = @_;

	my %seen;

	my $f;
	$f = sub {
		my ($n, $i) = @_;

		my $key = "$i,$n";

		if (exists $seen{$key}) {
			return $seen{$key};
		}

		if ($i == 0) {
			return 1;
		}

		$seen{$key} = sum(map { $f->($_, $i-1) } blink($n));
	};

	return sum(map { $f->($_, $times) } @$stones);
}

sub solveOne {
	my ($lines) = @_;

	return solve([$lines->[0] =~ m/(\d+)/g], 25);
}

sub solveTwo {
	my ($lines) = @_;

	return solve([$lines->[0] =~ m/(\d+)/g], 75);
}

main(\&solveOne, \&solveTwo);
