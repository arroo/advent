#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub solveOne {
	my ($lines) = @_;

	return reduce(
		sub {
			my ($acc, $line) = @_;

			while ($line =~ /mul\((\d{1,3}),(\d{1,3})\)/g) {
				$acc += $1 * $2;
			}

			return $acc;
		},
		$lines,
		0,
	);
}

sub solveTwo {
	my ($lines) = @_;

	return reduce(
		sub {
			my ($acc, $line) = @_;
			my ($total, $do) = @$acc;

			while ($line =~ /
				(do(?:n't)?\(\))
				|mul\((\d{1,3}),(\d{1,3})\)
				/gx) {

				if (defined $1) {
					$do = $1 eq 'do()';

				} elsif ($do) {
					$total += $2 * $3;
				}
			}

			return [$total, $do];
		},
		$lines,
		[0, 1],
	)->[0];
}

main(\&solveOne, \&solveTwo);
