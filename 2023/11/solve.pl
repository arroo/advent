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

	my %blankRows;
	my %blankCols;
	my %galaxies;

	for my $y (0 .. $#$lines) {

		if ($lines->[$y] !~ m/#/) {
			$blankRows{$y} = undef;
			next;
		}


		my @line = split //, $lines->[$y];

		for my $x (0 .. $#line) {
			if ($line[$x] eq '#') {
				$galaxies{"$x,$y"} = undef;
			}
		}
	}

	my $transposed = transposeLines($lines);
	for my $x (0 .. $#$transposed) {
		if ($transposed->[$x] !~ m/#/) {
			$blankCols{$x} = undef;
		}
	}

	for my $g (keys %galaxies) {
		my ($x, $y) = split /,/, $g;

		for my $k (keys %blankCols) {
			$galaxies{$g}{'cols'}{$x < $k ? 'under' : 'over'}{$k} = undef;
		}

		for my $k (keys %blankRows) {
			$galaxies{$g}{'rows'}{$y < $k ? 'under' : 'over'}{$k} = undef;
		}
	}

	return \%galaxies;
}

sub solveOne {
	my ($lines) = @_;

	return solve($lines, 2);
}

sub solveTwo {
	my ($lines) = @_;

	return solve($lines, 1000000);
}

sub solve {
	my ($lines, $skip) = @_;
	my $galaxies = parse($lines);

	my %pairs;

	for my $start (keys %$galaxies) {
		my ($sx, $sy) = split /,/, $start;

		for my $end (keys %$galaxies) {
			next if ($start eq $end);
			next if (exists $pairs{"$end;$start"});

			my ($ex, $ey) = split /,/, $end;

			my $dist = manhattan($sx, $sy, $ex, $ey);

			my $blankCrosses = 0;
			$blankCrosses += scalar @{intersectionHash($galaxies->{$start}{'cols'}{'over'}, $galaxies->{$end}{'cols'}{'under'})};
			$blankCrosses += scalar @{intersectionHash($galaxies->{$start}{'cols'}{'under'}, $galaxies->{$end}{'cols'}{'over'})};
			$blankCrosses += scalar @{intersectionHash($galaxies->{$start}{'rows'}{'over'}, $galaxies->{$end}{'rows'}{'under'})};
			$blankCrosses += scalar @{intersectionHash($galaxies->{$start}{'rows'}{'under'}, $galaxies->{$end}{'rows'}{'over'})};

			$pairs{"$start;$end"} = {
				'dist' => $dist,
				'blanks' => $blankCrosses,
			};
		}
	}

	return reduce(
		sub {
			my ($acc, $key) = @_;

			my ($dist, $blanks) = @{$pairs{$key}}{qw(dist blanks)};

			return $acc + $dist + $blanks * ($skip - 1);
		},
		[keys %pairs],
		0,
	);

	return Dumper(\%pairs);
}

main(\&solveOne, \&solveTwo);
