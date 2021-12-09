#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;

sub neighbours {
	my ($map, $width, $height, $x0, $y0) = @_;

	my @out;

	my @order = (
		[$x0-1, $y0],
		[$x0+1, $y0],

		[$x0, $y0-1],
		[$x0, $y0+1],
	);

	for my $o (@order) {
		my ($x, $y) = @$o;

		next if ($x == $x0 and $y == $y0);
		next if ($x < 0 or $y < 0 or $x >= $width or $y >= $height);

		push @out, [$x, $y];
	}

	return \@out;
}

sub get {
	my ($map, $x, $y) = @_;

	return $map->[$y][$x];
}

sub solveOne {
	my ($lines) = @_;

	my $heightMap = reduce(
		sub {
			my ($acc, $line, $i, $lines) = @_;

			push @$acc, [split //, $line];

			return $acc;
		},
		$lines,
		[],
	);

	my $height = scalar @$heightMap;
	my $width = scalar @{$heightMap->[0]};

	my @risky;
	for my $y (0 .. $#$heightMap) {
		my $row = $heightMap->[$y];
		for my $x (0 .. $#$row) {
			my $neighbours = neighbours($heightMap, $width, $height, $x, $y);

			my $me = get($heightMap, $x, $y);

			my @lower = grep { get($heightMap, @$_) <= $me } @$neighbours;

			push @risky, $me unless scalar @lower;
		}
	}

	return sum(map { $_ + 1 } @risky);
}

sub solveTwo {
	my ($lines) = @_;

	my $heightMap = reduce(
		sub {
			my ($acc, $line, $i, $lines) = @_;

			push @$acc, [split //, $line];

			return $acc;
		},
		$lines,
		[],
	);

	my $height = scalar @$heightMap;
	my $width = scalar @{$heightMap->[0]};

	my @risky;

	for my $y (0 .. $#$heightMap) {
		my $row = $heightMap->[$y];
		for my $x (0 .. $#$row) {
			my $neighbours = neighbours($heightMap, $width, $height, $x, $y);

			my $me = get($heightMap, $x, $y);

			my @lower = grep { get($heightMap, @$_) <= $me } @$neighbours;

			push @risky, [$x, $y] unless scalar @lower;
		}
	}

	my $basins = reduce(
		sub {
			my ($acc, $point) = @_;

			# find basin
			my %seen;
			my @search = ([@$point]);
			while (scalar @search) {
				my $p = shift @search;
				my $name = join(',', @$p);

				if (get($heightMap, @$p) == 9
					or exists $seen{$name}) {

					next;
				}

				$seen{$name} = undef;

				push @search, @{neighbours($heightMap, $width, $height, @$p)};
			}

			# this assumes each (or at least the 3 biggest) basins
			# drain into unique "risky" points
			push @$acc, scalar keys %seen;

			return $acc;
		},
		\@risky,
		[],
	);

	my @ordered = reverse sort { $a <=> $b } @$basins;
	return prod(@ordered[0 .. 2]);
}

main(\&solveOne, \&solveTwo);
