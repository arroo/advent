#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

use constant ash  => '.';
use constant rock => '#';

sub parse2 {
	my ($lines) = @_;

	my $y = 0;

	return reduce(
		sub {
			my ($acc, $line, $i) = @_;

			if ($line eq '') {
				push @$acc, {};
				$y = 0;
				return $acc;
			}

			my @line = split //, $line;

			for my $j (0 .. $#line) {
				$acc->[-1]{"$j,$y"} = $line[$j];
			}

			$y++;

			return $acc;
		},
		$lines,
		[{}],
	);
}

sub parse {
	my ($lines) = @_;

	return reduce(
		sub {
			my ($acc, $line) = @_;

			if ($line eq '') {
				push @$acc, [];
				return $acc;
			}

			push @{$acc->[-1]}, $line;

			return $acc;
		},
		$lines,
		[[]],
	);
}

sub findReflection {
	my ($frame) = @_;

	BASE: for my $i (0 .. $#$frame - 1) {
		for my $j (0 .. $i) {

			my $lower = $i - $j;
			my $upper = $i + $j + 1;

			if ($upper > $#$frame) {
				last;
			}

			if ($frame->[$upper] ne $frame->[$lower]) {
				next BASE;
			}
		}

		return $i+1;
	}

	return -1;
}

sub findReflection2 {
	my ($frame) = @_;

	BASE: for my $i (0 .. $#$frame - 1) {
		my $foundDiff = 0;
		for my $j (0 .. $i) {

			my $lower = $i - $j;
			my $upper = $i + $j + 1;

			if ($upper > $#$frame) {
				last;
			}

			# stringwise ^ will turn matching characters into a null byte
			# https://stackoverflow.com/questions/4709537/fast-way-to-find-difference-between-two-strings-of-equal-length-in-perl
			my $diff = scalar grep { $_ != 0 } unpack("c*", $frame->[$upper] ^ $frame->[$lower]);

			if ($diff == 1) {
				$foundDiff++;
			}

			if ($diff > 1) {
				next BASE;
			}
		}

		if ($foundDiff == 1) {
			return $i+1;
		}
	}

	return -1;
}

sub solve {
	my ($lines, $reflectionFn) = @_;

	return reduce(
		sub {
			my ($acc, $frame, $i) = @_;

			my $row = $reflectionFn->($frame);
			if ($row > 0) {
				$acc += 100*$row;
			} else {
				my $col = $reflectionFn->(transposeLines($frame));
				if ($col > 0) {
					$acc += $col;
				} else {
					die "frame $i has no reflection: " . Dumper($frame, transposeLines($frame));
				}
			}


			return $acc;
		},
		parse($lines),
		0,
	);
}

sub solveOne {
	my ($lines) = @_;

	return solve($lines, \&findReflection);
}

sub solveTwo {
	my ($lines) = @_;

	return solve($lines, \&findReflection2);
}

main(\&solveOne, \&solveTwo);
