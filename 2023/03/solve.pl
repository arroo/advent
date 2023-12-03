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
			my @neighbours;

			# look left
			my $k;
			for ($k = $i; $k-1 >=0 and isNumeric(substr($line, $k-1, 1)); $k--) {}
			if ($k != $i) {
				push @neighbours, substr($line, $k, $i-$k)+0;
			}

			# look right
			for ($k = $i; $k+1 < length($line) and isNumeric(substr($line, $k+1, 1)); $k++) {}
			if ($k != $i) {
				push @neighbours, substr($line, $i+1, $k-$i)+0;
			}

			# look above
			my ($x, $y) = ($i, $j-1);
			if ($y >= 0) {

				# look up-left
				my $tl = '';
				my $k;
				for ($k = $x; $k-1 >= 0 and isNumeric(substr($lines->[$y], $k-1, 1)); $k--) {}
				if ($k != $x) { # found
					$tl = substr($lines->[$y], $k, $x-$k);
				}

				# look up-right
				my $tr = '';
				for ($k = $x; $k+1 < length($lines->[$y]) and isNumeric(substr($lines->[$y],$k+1,1)); $k++) {}
				if ($k != $x) {
					$tr = substr($lines->[$y], $x+1, $k-$x);
				}

				if (isNumeric(substr($lines->[$y], $x, 1))) { # one number above

					my $m = substr($lines->[$y], $x, 1);
					push @neighbours, "$tl$m$tr"+0;

				} else { # 0 or 2 numbers above
					if ($tl ne '') {
						push @neighbours, $tl+0;
					}
					if ($tr ne '') {
						push @neighbours, $tr+0;
					}
				}
			}

			# look below
			($x, $y) = ($i, $j+1);
			if ($y < scalar @$lines) {
				# look down-left
				my $dl = '';
				my $k;
				for ($k = $x; $k-1 >= 0 and isNumeric(substr($lines->[$y], $k-1, 1)); $k--) {}
				if ($k != $x) { # found
					$dl = substr($lines->[$y], $k, $x-$k);
				}

				# look down-right
				my $dr = '';
				for ($k = $x; $k+1 < length($lines->[$y]) and isNumeric(substr($lines->[$y],$k+1,1)); $k++) {}
				if ($k != $x) {
					$dr = substr($lines->[$y], $x+1, $k-$x);
				}

				if (isNumeric(substr($lines->[$y], $x, 1))) { # one number below

					my $m = substr($lines->[$y], $x, 1);
					push @neighbours, "$dl$m$dr"+0;

				} else { # 0 or 2 numbers below
					if ($dl ne '') {
						push @neighbours, $dl+0;
					}
					if ($dr ne '') {
						push @neighbours, $dr+0;
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
