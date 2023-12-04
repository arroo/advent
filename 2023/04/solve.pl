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

			my ($id, $winningStr, $haveStr) = split / *[:|] +/, $line;

			my %winning = map {$_=>undef} split / +/, $winningStr;
			my %have = map{$_=>undef} split / +/, $haveStr;

			push @$acc, [\%winning, \%have, 1];

			return $acc;
		},
		$lines,
		[],
	);
}

sub solveOne {
	my ($lines) = @_;


	my $games = parse($lines);

	print Dumper($games);

	return reduce(
		sub {
			my ($acc, $game) = @_;

			my ($winning, $have) = @$game;

			my $points = 0;
			for my $n (keys %$have) {
				if (exists $winning->{$n}) {
					if ($points) {
						$points *= 2;
					} else {
						$points = 1;
					}
				}
			}

			return $acc + $points;
		},
		$games,
		0,
	);
}

sub solveTwo {
	my ($lines) = @_;

	my $games = parse($lines);

	forEach(
		$games,
		sub {
			my ($game, $i, $arr) = @_;

			my ($winning, $have, $copies) = @$game;

			my $matched = 0;
			for my $n (keys %$have) {
				if (exists $winning->{$n}) {
					$arr->[$i+ ++$matched][2]+=$copies;
				}
			}

			return;
		},
	);

	return reduce(
		sub {
			my ($acc, $game) = @_;

			return $acc + $game->[2];
		},
		$games,
		0,
	)
}

main(\&solveOne, \&solveTwo);
