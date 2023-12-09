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
			my ($acc, $line, $i) = @_;

			my @history = split / /, $line;

			push @$acc, \@history;

			return $acc;
		},
		$lines,
		[],
	);
}

sub solve1 {
	my ($history) = @_;

	my $seenNonzero;
	for my $h (@$history) {
		if ($h != 0) {
			$seenNonzero = 1;
			last;
		}
	}

	return 0 unless ($seenNonzero);

	my @diffs;
	for (my $i = 1; $i < scalar @$history; $i++) {
		push @diffs, $history->[$i] - $history->[$i-1];
	}

	return $history->[-1] + solve1(\@diffs);
}

sub solveOne {
	my ($lines) = @_;

	my $parsed = parse($lines);

	print Dumper($parsed);

	return reduce(
		sub {
			my ($acc, $history) = @_;

			return $acc + solve1($history);
		},
		$parsed,
		0,
	);
}


sub solve2 {
	my ($history) = @_;

	my $seenNonzero;
	for my $h (@$history) {
		if ($h != 0) {
			$seenNonzero = 1;
			last;
		}
	}

	return 0 unless ($seenNonzero);

	my @diffs;
	for (my $i = 1; $i < scalar @$history; $i++) {
		push @diffs, $history->[$i] - $history->[$i-1];
	}

	return $history->[0] - solve2(\@diffs);
}

sub solveTwo {
	my ($lines) = @_;

	my $parsed = parse($lines);

	return reduce(
		sub {
			my ($acc, $history) = @_;

			return $acc + solve2($history);
		},
		$parsed,
		0,
	);;
}

main(\&solveOne, \&solveTwo);
