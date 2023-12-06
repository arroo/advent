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

	return reduce(
		sub {
			my ($acc, $line, $i, $arr) = @_;

			my $j = 0;
			for my $n ($line =~ /(\d+)/g) {
				$acc->[$j++][$i] = $n;
			}


			return $acc;
		},
		$lines,
		[],
	);
}

sub solveOne {
	my ($lines) = @_;

	return reduce(
		sub {
			my ($acc, $race) = @_;

			my ($time, $record) = @$race;

			my $ways = 0;
			for my $chargeTime (0 .. $time) {
				my $distance = $chargeTime * ($time - $chargeTime);

				$ways++ if ($distance > $record);
			}

			return $acc * $ways;
		},
		parse($lines),
		1,
	);
}

sub solveTwo {
	my ($lines) = @_;

	my $race = reduce(
		sub {
			my ($acc, $line) = @_;

			my $num = '';
			for my $n ($line =~ /(\d+)/g) {
				$num .= $n;
			}

			push @$acc, $num+0;

			return $acc;
		},
		$lines,
		[],
	);


	my ($time, $record) = @$race;

	my $ways = 0;
	for my $chargeTime (0 .. $time) {
		my $distance = $chargeTime * ($time - $chargeTime);

		$ways++ if ($distance > $record);
	}

	return $ways;

}

main(\&solveOne, \&solveTwo);
