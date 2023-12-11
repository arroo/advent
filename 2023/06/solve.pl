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

	return solve(reduce(
		sub{
			my ($acc, $line, $i, $arr) = @_;

			my $j = 0;
			for my $n ($line =~ /(\d+)/g) {
				$acc->[$j++][$i] = $n;
			}

			return $acc;
		},
		$lines,
		[],
	));
}

sub solveTwo {
	my ($lines) = @_;

	return solve([reduce(
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
	)]);
}



sub solve {
	my ($races) = @_;

	my $total = 1;

	for my $race (@$races) {
		my $ways = 0;

		my ($time, $record) = @$race;

		for my $chargeTime (0 .. $time) {
			my $distance = $chargeTime * ($time - $chargeTime);


			if ($distance > $record) {
				$ways++;

				print green;
			} else {
				print reset;
			}

			print "$distance\n";
		}

		$total *= $ways;
	}

	return $total;
}

main(\&solveOne, \&solveTwo);
