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

			my ($id, @game) = split /[;:] /, $line;

			my @rounds = map { [ split /, / ] } @game;

			my @out;
			for my $round (@rounds) {
				my %r;
				for my $pull (@$round) {
					my ($count, $colour) = split / /, $pull;

					$r{$colour} += $count;
				}

				push @out, \%r;
			}

			push @$acc, \@out;

			return $acc;
		},
		$lines,
		[],
	);
}

sub solveOne {
	my ($lines) = @_;

	my %balls = (
		'red'   => 12,
		'green' => 13,
		'blue'  => 14,
	);

	return reduce(
		sub {
			my ($acc, $game, $i) = @_;

			for my $round (@$game) {
				for my $colour (keys %$round) {
					if ($round->{$colour} > $balls{$colour}) {
						return $acc;
					}
				}
			}

			return $acc + $i + 1;
		},
		parse($lines),
		0,
	);
}

sub solveTwo {
	my ($lines) = @_;

	return reduce(
		sub {
			my ($acc, $game) = @_;

			my %maxCols;

			for my $round (@$game) {
				for my $colour (keys %$round) {
					$maxCols{$colour} = max($round->{$colour}, $maxCols{$colour} // 0);
				}
			}

			return $acc + prod(values %maxCols);
		},
		parse($lines),
		0,
	);
}

main(\&solveOne, \&solveTwo);
