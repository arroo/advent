#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;

my %closing = (
	'(' => ')',
	'[' => ']',
	'{' => '}',
	'<' => '>',
);

sub solveOne {
	my ($lines) = @_;

	my %points = (
		')' => 3,
		']' => 57,
		'}' => 1197,
		'>' => 25137,
	);

	return reduce(
		sub {
			my ($acc, $line, $i, $lines) = @_;

			my @tokens = split //, $line;

			my @pairs;
			for my $t (@tokens) {
				if (defined $closing{$t}) {
					push @pairs, $t;

					next;
				}

				my $expected = $closing{pop @pairs};

				if ($t ne $expected) {
					$acc += $points{$t};
				}
			}

			return $acc;
		},
		$lines,
		0,
	);
}

sub solveTwo {
	my ($lines) = @_;

	my %points = (
		')' => 1,
		']' => 2,
		'}' => 3,
		'>' => 4,
	);

	my $ret = reduce(
		sub {
			my ($acc, $line, $i, $lines) = @_;

			my @tokens = split //, $line;

			my @pairs;
			for my $t (@tokens) {
				if (defined $closing{$t}) {
					push @pairs, $t;

					next;
				}

				my $expected = $closing{pop @pairs};

				if ($t ne $expected) {
					return $acc;
				}
			}

			my $score = 0;
			for my $t (reverse @pairs) {
				$score = $score * 5 + $points{$closing{$t}};
			}

			push @$acc, $score;

			return $acc;
		},
		$lines,
		[],
	);

	my @sorted = sort { $a <=> $b } @$ret;
	my $mid = int(@sorted) >> 1; # problem statement guarantees odd number of values
	return $sorted[$mid];
}


main(\&solveOne, \&solveTwo);
