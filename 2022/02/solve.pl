#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my ($Rock, $Paper, $Scissors) = ('Rock', 'Paper', 'Scissors');
my ($Win, $Lose, $Draw) = ('Win', 'Lose', 'Draw');

my %Defeats = (
	$Rock => $Scissors,
	$Paper => $Rock,
	$Scissors => $Paper,
);

my %Succumbs = (
	$Rock => $Paper,
	$Paper => $Scissors,
	$Scissors => $Rock,
);

my %Scores = (
	$Rock => 1,
	$Paper => 2,
	$Scissors => 3,

	$Lose => 0,
	$Draw => 3,
	$Win => 6,
);

sub RPS {
	my ($opp, $me) = @_;

	if ($opp eq $me) {
		return $Draw;
	}

	if ($Defeats{$opp} eq $me) {
		return $Lose;
	}

	if ($Defeats{$me} eq $opp) {
		return $Win;
	}

	die "unknown result: $opp $me\n";

	if (
		$opp eq 'Rock' and $me eq 'Paper' or
		$opp eq 'Paper' and $me eq 'Scissors' or
		$opp eq 'Scissors' and $me eq 'Rock') {
		return 'Win';
	}

	return 'Lose';
}

sub solve {
	my ($lines, $rps) = @_;

	return reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		my ($oppSig, $meSig) = $line =~ /(.) (.)/;

		my $opp = $rps->{$oppSig};
		my $me = $rps->{$meSig};

		my $result = RPS($opp, $me);

		return $acc + $Scores{$me} + $Scores{$result};
	},
	$lines,
	0,
	);
}

sub solveOne {
	my ($lines) = @_;

	my %rps = (
		'A' => $Rock,
		'B' => $Paper,
		'C' => $Scissors,
		'X' => $Rock,
		'Y' => $Paper,
		'Z' => $Scissors,
	);

	return solve($lines, \%rps);
}

sub solveTwo {
	my ($lines) = @_;

	my %rps = (
		'A' => 'Rock',
		'B' => 'Paper',
		'C' => 'Scissors',
		'X' => 'Lose',
		'Y' => 'Draw',
		'Z' => 'Win',
	);

	return reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		my ($oppSig, $resSig) = $line =~ /(.) (.)/;

		# result needed
		my $res = $rps{$resSig};

		# i need to throw
		my $throw;
		my $opp = $rps{$oppSig};
		if ($res eq 'Draw') {
			$throw = $rps{$oppSig};
		} elsif ($res eq 'Win') {
			if ($opp eq 'Rock') {
				$throw = 'Paper';
			} elsif ($opp eq 'Paper') {
				$throw = 'Scissors';
			} elsif ($opp eq 'Scissors') {
				$throw = 'Rock';
			} else {
				die "unknown opponent throw to win: $oppSig\n";
			}

		} elsif ($res eq 'Lose') {
			if ($opp eq 'Rock') {
				$throw = 'Scissors';
			} elsif ($opp eq 'Paper') {
				$throw = 'Rock';
			} elsif ($opp eq 'Scissors') {
				$throw = 'Paper';
			} else {
				die "unknown opponent throw to lose: $oppSig\n";
			}
		} else {
			die "unknown instruction: $resSig\n";
		}

		return $acc + $Scores{$res} + $Scores{$throw};
	}, $lines, 0);

	return 0;
}

main(\&solveOne, \&solveTwo);
