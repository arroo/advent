#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub parse {
	my ($lines, $preprocess) = @_;

	return reduce(
		sub {
			my ($acc, $line, $i, $arr) = @_;

			my ($hand, $bid) = $line =~ /\A(.+) (\d+)\z/;

			push @$acc, [$hand, $bid, getHandRank($preprocess->($hand))];

			return $acc;
		},
		$lines,
		[],
	);
}



my @orderedHands = split //, qw(54F321H);
my %orderedHands = map { $orderedHands[$_] => $_ } (0 .. $#orderedHands);

sub getHandRank {
	my ($hand) = @_;

	my %hand;
	for my $c (split //, $hand) {
		$hand{$c}++;
	}

	if (scalar keys %hand == 1) { # five of a kind
		return 5;
	}

	if (scalar keys %hand == 2) { # 4 of a kind or full house
		if ((reverse sort values %hand)[0] == 4) {
			return 4;
		}

		return 'F';
	}

	if (scalar keys %hand == 3) { # trips or two pair
		if ((reverse sort values %hand)[0] == 3) {
			return 3;
		}

		return 2;
	}

	if (scalar keys %hand == 4) {
		return 1;
	}

	return 'H'; # high card
}

sub sortHands {
	my ($orderedRank) = @_;

	return sub {
		# my ($a, $b) = @_;

		my ($aH, $aR) = @$a[0,2];
		my ($bH, $bR) = @$b[0,2];

		if ($aR ne $bR) {
			return $orderedHands{$aR} <=> $orderedHands{$bR};
		}

		my @aHS = split //, $aH;
		my @bHS = split //, $bH;

		for my $i (0 .. $#aHS) {
			if ($aHS[$i] ne $bHS[$i]) {
				return $orderedRank->{$aHS[$i]} <=> $orderedRank->{$bHS[$i]};
			}
		}
	};
}

sub solveOne {
	my ($lines) = @_;
	my @orderedRank = split //, qw(AKQJT98765432);
	my %orderedRank = map { $orderedRank[$_] => $_ } (0 .. $#orderedRank);

	return solve(
		parse($lines, sub{return @_}),
		sortHands(\%orderedRank),
	);
}



sub solveTwo {
	my ($lines) = @_;

	my @orderedRank = split //, qw(AKQT98765432J); # joker last
	my %orderedRank = map { $orderedRank[$_] => $_ } (0 .. $#orderedRank);

	my $preprocess = sub  {
		my ($hand) = @_;

		my %hand;
		for my $c (split //, $hand) {
			$hand{$c}++;
		}

		my $jokers = delete $hand{'J'} // 0;

		if (0 < $jokers and $jokers < 5) {

			my $mostFrequent = (reverse sort { $a->[1] <=> $b->[1] } map { [$_, $hand{$_}] } keys %hand)[0][0];

			$hand =~ s/J/$mostFrequent/g;
		}
		return $hand;
	};

	return solve(
		parse($lines, $preprocess),
		sortHands(\%orderedRank),
	);
}

sub solve {
	my ($hands, $sortFn) = @_;

	return reduce(
		sub {
			my ($acc, $bid, $i) = @_;

			return $acc + ($i+1) * $bid;
		},
		[map { $_->[1] } reverse sort $sortFn @$hands],
		0,
	);
}

main(\&solveOne, \&solveTwo);
