#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub priority {
	my ($item) = @_;

	my $ord = ord($item);

	if (65 <= $ord && $ord <= 90) {
		return $ord - 64 + 26;
	}

	if (97 <= $ord && $ord <= 122) {
		return $ord - 96;
	}

	die "unknown priority for $item";
}

sub itemCounts {
	my ($list) = @_;

	my %ret;

	map { $ret{$_}++ } @$list;

	return \%ret;
}

sub duplicates {
	my ($list) = @_;

	my $counts = itemCounts($list);

	print Dumper($list, $counts);

	return [grep { $counts->{$_} > 1 } keys %$counts];
}

sub solveOne {
	my ($lines) = @_;



	return reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		my @sack = split //, $line;
		#my @fst = splice @sack, 0, scalar @sack/2;
		#my @scd = splice @sack, scalar @sack/2;
		my @fst = @sack[0 .. scalar @sack / 2 - 1];
		my @scd = @sack[scalar @sack / 2 .. $#sack];

		die "you fucked up: " . Dumper($line, \@fst, \@scd) unless (scalar @fst == scalar @scd and scalar @fst + scalar @scd == scalar @sack);

		my $both = intersection(\@fst, \@scd);

		my $total = sum(map { priority($_) } @$both);

		print Dumper($both, $total);

		return $acc + $total;

		my $fstDupes = duplicates(\@fst);
		my $scdDupes = duplicates(\@scd);

		#print Dumper($fstDupes, $scdDupes);

		$acc += map { priority($_) } @$fstDupes;
		$acc += map { priority($_) } @$scdDupes;

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

		my ($previous, $total) = @$acc;

		my @thisLine = split //, $line;

		if ($i % 3 == 0) {
			return [\@thisLine, $total];
		}

		my $both = intersection($previous, \@thisLine);

		if ($i % 3 == 1) {
			return [$both, $total];
		}

		return [[], $total + sum(map { priority($_) } @$both)];
	},
	$lines,
	[[], 0],
	)->[1];
}

main(\&solveOne, \&solveTwo);
