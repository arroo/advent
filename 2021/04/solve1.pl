#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Utils qw(:all);

use Data::Dumper;

sub boardSum {
	my ($board) = @_;

	my $total = 0;

	my %seen;

	for my $x (0 .. $#$board) {
		my $row = $board->[$x];
		for my $y (0 .. $#$row) {
			my $val = $row->[$y];
			$total += $val;

			$seen{$val}++;
		}
	}

	return ($total, \%seen);
}

sub getWinningSequences {
	my ($board) = @_;

	my @sequences;

	# easy is horizontal
	for my $row (@$board) {
		push @sequences, [@$row];
	}

	for my $i (0 .. 4) {
		my @seq;
		for my $j (0 .. 4) {
			push @seq, $board->[$j][$i];
		}

		push @sequences, [@seq];
	}

	return \@sequences;
}

sub getWinningLength {
	my ($seq, $nums) = @_;

	my %notSeen = map { $_ => 1 } @$seq;

	for my $i (0 .. $#$nums) {
		my $n = $nums->[$i];

		next unless defined $notSeen{$n};

		delete $notSeen{$n};

		if (scalar keys %notSeen == 0) {
			return $i;
		}
	}

	return undef;
}

sub score {
	my ($board, $nums) = @_;

	my ($total, $seen) = boardSum($board);
	print Dumper($total, $seen);

	my $winningSequences = getWinningSequences($board);
	print Dumper($winningSequences);

	my $score;
	my $seqLen = 1+scalar @$nums;

	for my $seq (@$winningSequences) {
		my $len = getWinningLength($seq, $nums);

		# not defined means this sequence never wins
		next unless defined $len;

		# another sequence has a shorter length
		next unless ($seqLen > $len);

		print "@$nums\nsequence '@$seq' wins in $len moves\n";

		die "board has multiple winning lengths:\n" . Dumper($board, $nums) if $seqLen == $len;

		my $seqTotal = $total;
		for my $i (0 .. $len) {
			my $val = $nums->[$i];

			$seqTotal -= ($seen->{$val} // 0) * $val;
		}

		$score = $seqTotal * $nums->[$len];
		$seqLen = $len;
	}

	return ($score, $seqLen);
}

sub solveOne {
	my ($lines) = @_;

	my @selected = split /,/, $lines->[0];

	print "@selected\n";


	my @games;
	my $game = [];

	for my $i (2 .. $#$lines) {
		my $line = $lines->[$i];

		if ($line eq '') {
			push @games, $game;
			$game = [];

			next;
		}

		$line =~ s/  / /g;

		my @nums = grep {$_ ne ''} split / /, $line;

		# sanity check
		die "bad parsing of line $line\n" if scalar @nums != 5;

		push @$game, \@nums;
	}

	# last game
	push @games, $game;

	my $score;
	my $seqLen = 1 + scalar @selected;
	for $game (@games) {
		my ($gameScore, $len) = score($game, \@selected);

		next unless defined $len;

		next unless ($seqLen > $len);

		$seqLen = $len;
		$score = $gameScore;
	}

	return $score;
}

sub solveTwo {
	my ($lines) = @_;

	my $res = reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		return $acc;
	},
	$lines,
	[]);

	return $res;
}

sub main {

	my $input = slurp();

	my $solver = \&solveTwo;

	if (scalar @ARGV >= 1 and $ARGV[0] eq '1') {
		$solver = \&solveOne;
	}

	my $solution = $solver->($input);

	print "$solution\n";
}

main();
