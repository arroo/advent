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
			my ($acc, $line) = @_;

			my ($id, $winningStr, $have) = split / *[:|] +/, $line;

			my %winning = map {$_=>undef} split / +/, $winningStr;

			my $won = 0;
			for my $num (split / +/, $have) {
				$won++ if (exists $winning{$num});
			}

			push @$acc, [$won, 1];

			return $acc;
		},
		$lines,
		[],
	);
}

sub solveOne {
	my ($lines) = @_;

	return reduce(
		sub {
			my ($acc, $game) = @_;

			my ($won) = @$game;

			return $acc + ($won > 0 ? 2**($won-1) : 0);
		},
		parse($lines),
		0,
	);
}

sub solveTwo {
	my ($lines) = @_;

	return reduce(
		sub {
			my ($acc, $game, $i, $arr) = @_;

			my ($won, $copies) = @$game;

			for my $n (0 .. $won-1) {
				$arr->[++$i][1]+=$copies;
			}

			return $acc + $copies;
		},
		parse($lines),
		0,
	);
}

main(\&solveOne, \&solveTwo);
