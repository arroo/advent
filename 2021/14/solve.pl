#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub process {
	my ($rules, $state) = @_;

	my %newState;

	for my $k (keys %$state) {
		my $mid = $rules->{$k};

		my ($l, $r) = split //, $k;


		$newState{"$l$mid"} += $state->{$k};
		$newState{"$mid$r"} += $state->{$k};
	}

	return \%newState;
}

sub solve {
	my ($lines, $it) = @_;

	my $target = $lines->[0];
	shift @$lines;
	shift @$lines;

	my $rules = reduce(
		sub {
			my ($acc, $line) = @_;

			my ($src, $dst) = split / -> /, $line;

			my ($l,$r) = split //, $src;

			$acc->{$src} = $dst;

			return $acc;
		},
		$lines,
		{},
	);

	my $state = {};
	for my $i (1 .. length($target)-1) {
		$state->{substr($target, $i - 1, 2)}++;
	}

	for my $i (1 .. $it) {
		$state = process($rules, $state);
	}

	# since every pair gets grouped in processing, that means every character will exist twice in state
	# EXCEPT the first & last characters.
	# so add them here to start.
	my %chars = map { $_ => 1 } substr($target, 0, 1),substr($target, length($target)-1, 1) ;
	for my $c (keys %$state) {
		$chars{$_} += $state->{$c} for split //, $c;
	}

	my @sorted = sort { $chars{$a} <=> $chars{$b} } keys %chars;

	my $most = $sorted[-1];
	my $least = $sorted[0];

	# / 2 since all characters counted twice
	return ($chars{$most} - $chars{$least}) >> 1;
}

sub solveOne {
	my ($lines) = @_;

	return solve($lines, 10)
}

sub solveTwo{
	my ($lines) = @_;

	return solve($lines, 40);
}

main(\&solveOne, \&solveTwo);
