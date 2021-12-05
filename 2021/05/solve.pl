#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;


sub extrapolateHorizontalLine {
	my ($x, $y1, $y2) = @_;

	my @coords = map { [ $x, $_ ] } min($y1, $y2) .. max($y1, $y2);

	return \@coords;
}

sub extrapolateVerticalLine {
	my ($x1, $x2, $y) = @_;

	my @coords = map { [ $_, $y ] } min($x1, $x2) .. max($x1, $x2);

	return \@coords;
}

sub extrapolate45Line {
	my ($x1, $y1, $x2, $y2) = @_;

	my @coords;

	my $stepX = $x2 > $x1 ? 1 : -1;
	my $stepY = $y2 > $y1 ? 1 : -1;

	my $diffX = $x2 - $x1;
	$diffX = $diffX < 0 ? -$diffX : $diffX;

	my $diffY = $y2 - $y1;
	$diffY = $diffY < 0 ? -$diffY : $diffY;

	die "not 45: $x1, $y1, $x2, $y2\n" unless ($diffX == $diffY);

	for my $i (0 .. $diffX) {
		push @coords, [$x1 + $stepX * $i, $y1 + $stepY * $i];
	}

	return \@coords;
}

sub solveOne {
	my ($lines) = @_;

	my $ret = reduce(sub {
			my ($acc, $line, $i, $lines) = @_;

			my ($x1, $y1, $x2, $y2) = $line =~ /^(\d+),(\d+) -> (\d+),(\d+)$/;

			my $coords;

			if ($x1 == $x2) {
				$coords = extrapolateHorizontalLine($x1, $y1, $y2);

			} elsif ($y1 == $y2) {
				$coords = extrapolateVerticalLine($x1, $x2, $y1);

			} else {
				return $acc;
			}

			for my $coord (@$coords) {
				my ($x, $y) = @$coord;

				$acc->{"$x,$y"}++;
			}

			return $acc;
		},
		$lines,
		{},
	);

	return scalar grep { $ret->{$_} >= 2 } keys %$ret;
}

sub solveTwo {
	my ($lines) = @_;

	my $ret = reduce(sub {
			my ($acc, $line, $i, $lines) = @_;

			my ($x1, $y1, $x2, $y2) = $line =~ /^(\d+),(\d+) -> (\d+),(\d+)$/;

			my $coords;

			if ($x1 == $x2) {
				$coords = extrapolateHorizontalLine($x1, $y1, $y2);

			} elsif ($y1 == $y2) {
				$coords = extrapolateVerticalLine($x1, $x2, $y1);

			} else {
				$coords = extrapolate45Line($x1, $y1, $x2, $y2);
			}

			for my $coord (@$coords) {
				my ($x, $y) = @$coord;

				$acc->{"$x,$y"}++;
			}

			return $acc;
		},
		$lines,
		{},
	);

	return scalar grep { $ret->{$_} >= 2 } keys %$ret;
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
