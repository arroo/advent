#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub isNumeric {
	my ($c) = @_;

	return $c =~ /[0-9]+/;
}

sub lookAround {
	my ($line, $x) = @_;

	# look left
	my $left = '';
	for (my $i = $x - 1; $i >= 0 and isNumeric(substr($line, $i, 1)); $i--) {
		$left = substr($line, $i, 1) . $left;
	}

	# lok right
	my $right = '';
	for (my $i = $x + 1; $i < length($line) and isNumeric(substr($line, $i, 1)); $i++) {
		$right .= substr($line, $i, 1);
	}

	return ($left, $right);
}

sub parse {
	my ($lines) = @_;

	my %out;

	for my $j (0 .. $#$lines) {
		my $line = $lines->[$j];

		for my $i (0 .. length($line) - 1) {
			my $char = substr($line, $i, 1);

			next if ($char eq '.');
			next if (isNumeric($char));

			# symbol so look around

			my @lines = ($line); # look at same line
			push @lines, $lines->[$j-1] if ($j > 0); # look above
			push @lines, $lines->[$j+1] if ($j < scalar @$lines); # look below

			my @neighbours;

			for my $line (@lines) {
				my ($left, $right) = lookAround($line, $i);
				my $mid = substr($line, $i, 1);
				if (isNumeric($mid)) {
					push @neighbours, "$left$mid$right"+0;
				} else {
					if ($left ne '') {
						push @neighbours, $left+0;
					}
					if ($right ne '') {
						push @neighbours, $right+0;
					}
				}
			}

			$out{"$i,$j"} = [$char, \@neighbours];
		}
	}

	return \%out;
}

sub solveOne {
	my ($lines) = @_;


	my $grid = parse($lines);

	print Dumper($grid);

	return reduce(
		sub {
			my ($acc, $symbolNeighbours) = @_;

			my ($symbol, $neighbours) = @$symbolNeighbours;

			return $acc + sumRef($neighbours);
		},
		[values %$grid],
		0,
	);
}

sub solveTwo {
	my ($lines) = @_;

	my $grid = parse($lines);

	return reduce(
		sub {
			my ($acc, $symbolNeighbours) = @_;

			my ($symbol, $neighbours) = @$symbolNeighbours;

			return $acc if ($symbol ne '*');
			return $acc if (scalar @$neighbours != 2);

			return $acc + prodRef($neighbours);
		},
		[values %$grid],
		0,
	);
}

main(\&solveOne, \&solveTwo);
