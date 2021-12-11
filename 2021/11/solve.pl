#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;

sub sweep {
	my ($field, $fn) = @_;

	 for my $row (0 .. $#$field) {
		for my $col (0 .. $#{$field->[$row]}) {
			$fn->($field,$row,$col);
		}
	 }
}

sub neighbours {
	my ($field, $row, $col) = @_;

	my @neighs;

	for my $r ($row - 1 .. $row + 1) {
		next if ($r < 0 or $r > $#$field); # out of bounds

		for my $c ($col - 1 .. $col + 1) {
			next if ($c < 0 or $c > $#{$field->[$r]}); # out of bounds

			next if ($c == $col and $r == $row); # self isn't neighbour

			push @neighs, [$r,$c];
		}
	}

	return \@neighs;
}

my $max = 10;

sub makeSweep {
	my ($flashes) = @_;

	return sub {
		my ($field, $row, $col) = @_;

		if (++$field->[$row][$col] == $max) {
			push @$flashes, [$row, $col];
		}

		return;
	};
}

sub solveOne {
	my ($lines) = @_;

	my @field = map { [split //, $_] } @$lines;

	my $totalFlashes = 0;

	for (1 .. 100) {
		my @flashes;
		my $sweepFn = makeSweep(\@flashes);
		# First, the energy level of each octopus increases by 1.
		# Then, any octopus with an energy level greater than 9 flashes.
		sweep(
			\@field,
			$sweepFn,
		);

		# This increases the energy level of all adjacent octopuses by 1, including octopuses that are diagonally adjacent. If this causes an octopus to have an energy level greater than 9, it also flashes. This process continues as long as new octopuses keep having their energy level increased beyond 9. (An octopus can only flash at most once per step.)
		while (scalar @flashes) {
			my ($row, $col) = @{pop @flashes};

			$totalFlashes++;

			my $neighs = neighbours(\@field, $row, $col);



			for my $coords (@$neighs) {
				my ($row, $col) = @$coords;

				$field[$row][$col]++;

				if ($field[$row][$col] == $max) {
					push @flashes, [$row, $col];
				}
			}
		}

		# Finally, any octopus that flashed during this step has its energy level set to 0, as it used all of its energy to flash.
		sweep(
			\@field,
			sub {
				my ($field, $row, $col) = @_;

				if ($field->[$row][$col] >= $max) {
					$field->[$row][$col] = 0;
				}
			},
		);
	}

	return $totalFlashes;
}

sub solveTwo {
	my ($lines) = @_;

	my @field = map { [split //, $_] } @$lines;

	my $totalFlashes = 0;

	for (my $i = 1; ;$i++) {
		my @flashes;
		# add 1
		sweep(
			\@field,
			sub {
				my ($field, $row, $col) = @_;

				$field->[$row][$col]++;

				if ($field->[$row][$col] == $max) {
					$totalFlashes++;
					push @flashes, [$row, $col];
				}

				return;
			},
		);

		while (scalar @flashes) {
			my ($row, $col) = @{pop @flashes};

			#print "flash $row $col\n";

			my $neighs = neighbours(\@field, $row, $col);

			for my $coords (@$neighs) {
				my ($row, $col) = @$coords;

				#print "\tneigh $row $col\n";

				$field[$row][$col]++;

				if ($field[$row][$col] == $max) {
					$totalFlashes++;
					push @flashes, [$row, $col];
				}
			}
		}

		# reset to 0 all flashes
		# check if all flashed this round
		my $notFlashed = 0;
		sweep(
			\@field,
			sub {
				my ($field, $row, $col) = @_;

				if ($field->[$row][$col] >= $max) {
					$field->[$row][$col] = 0;
				} else {
					$notFlashed = 1;
				}
			},
		);

		if (not $notFlashed) {
			return $i;
		}
	}

	return $totalFlashes;
}

main(\&solveOne, \&solveTwo);
