#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Utils qw(slurp reduceFn);

use Data::Dumper;

sub solve {
	my ($lines, $fn, $init) = @_;

	my $result = reduceFn(
		sub {
			my ($line) = @_;

			return $line =~ m/(.+) (\d+)/;
		},
		$fn,
		$lines,
		$init,
	);

	return $result->[0] * $result->[1];
}

sub solveOne {
	my ($lines) = @_;

	my $powerConsumption;

	my $total = scalar @$lines;

	# assume each line has same length
	my $bucketSize = length($lines->[0]);
	my @ones = split(//, '0'x$bucketSize);
	my @zeroes = split(//, '0'x$bucketSize);

	for my $i (0 .. $#$lines) {
		my $line = $lines->[$i];

		my @c = split(//, $line);
		for my $j (0 .. $#c) {
			my $c = $c[$j];
			if ($c eq '1') {
				$ones[$j]++;
			} elsif ($c eq '0') {
				$zeroes[$j]++;
			} else {
				die "unknown character on line $i $line\n";
			}
		}
	}

	my $gammaRate = '';
	my $epsilonRate = '';

	for my $i (0 .. $bucketSize-1) {
		if ($ones[$i] > $zeroes[$i]) {
			$gammaRate .= '1';
			$epsilonRate .= '0';
		} elsif ($zeroes[$i] > $ones[$i]) {
			$gammaRate .= '0';
			$epsilonRate .= '1';
		} else {
			die "bad bucket";
		}
	}

	my $g = oct("0b$gammaRate");
	my $e = oct("0b$epsilonRate");

	return $g*$e;
}

sub charPositionCounts {
	my ($lines, $i) = @_;

	my %buckets;

	for my $line (@$lines) {
		$buckets{(substr $line, $i, 1)}++;
	}

	return \%buckets;
}

sub toMatrix {
	my ($lines) = @_;

	my $cols = length($lines->[0]);
	my @matrix = map { [] } split(//, '.'x$cols);

	for my $i (0 .. $#$lines) {
		my $line = $lines->[$i];

		my @c = split //, $line;
		for my $j (0 .. $#c) {
			push @{$matrix[$j]}, $c[$j];
		}
	}

	return \@matrix;
}

sub filter {
	my ($lines, $selectFn) = @_;

	# assume all strings have the same length...
	my $len = length($lines->[0]);

	for my $i (0 .. $len-1) {

		my $counts = charPositionCounts($lines, $i);

		my $needle = $selectFn->($counts);

		$lines = [grep { (substr($_, $i, 1) eq $needle) } @$lines];

		return $lines->[0] if scalar @$lines == 1;
	}

	die ("wrong number chosen: " . Dumper($lines)) if scalar @$lines != 1;

	return $lines->[0];
}

sub solveTwo {
	my ($lines) = @_;

	my @lines;

	@lines = @$lines;
	my $co2 = filter(\@lines, sub {
		my ($counts) = @_;
		return $counts->{1} < $counts->{0} ? 1 : 0;
	});

	@lines = @$lines;
	my $o2 = filter(\@lines, sub {
		my ($counts) = @_;

		return $counts->{0} > $counts->{1} ? 0 : 1;
	});

	return oct("0b$o2") * oct("0b$co2");
}

sub main {

	my $input = slurp();

	my $solver = \&solveTwo;

	if (scalar @ARGV >= 1 and $ARGV[0] eq '1') {
		$solver = \&solveOne;
	}

	my $solution = $solver->($input);

	print "$solution\n";
}

main();
