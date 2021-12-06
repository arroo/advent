#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;

sub solve {
	my ($lines, $iterations) = @_;

	my %today;
	for my $f (split /,/, $lines->[0]) {
		$today{$f}++;
	}

	for my $i (1 .. $iterations) {
		my %tomorrow;
		for my $days (keys %today) {
			my $count = $today{$days};
			$days--;

			if ($days < 0) {
				$tomorrow{6} += $tomorrow{8} = $count;
			} else {
				$tomorrow{$days} += $count;
			}
		}

		%today = %tomorrow;
	}

	return sum(values %today);
}

sub solveOne {
	my ($lines) = @_;

	return solve($lines, 80);
}

sub solveTwo {
	my ($lines) = @_;

	return solve($lines, 256);
}

main(\&solveOne, \&solveTwo);
