#!/usr/bin/env perl

use warnings;
use strict;

use bigint;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub makeFn {
	my ($left, $op, $right) = @_;

	return sub {
		my ($old) = @_;

		my $l = $left eq 'old' ? $old : $left;
		my $r = $right eq 'old' ? $old : $right;

		if ($op eq '+') {
			return $l + $r;
		}

		if ($op eq '*') {
			return $l * $r;
		}

		die "unknown op: $op";
	}
}

sub parse {
	my ($lines) = @_;

	my %monkeys;
	my $cMonkey;

	my $lcm = 1;

	for my $line (@$lines) {
		if (my ($id) = $line =~ /^Monkey (\d+):$/) {
			$monkeys{$id} = {'seen'=>0};
			$cMonkey = $monkeys{$id};

		} elsif (my ($items) = $line =~ /^  Starting items: (.+)$/) {
			$cMonkey->{'items'} = [split /, /, $items];

		} elsif (my ($left, $op, $right) = $line =~ /^  Operation: new = (\w+) (.) (\w+)$/) {
			$cMonkey->{'op'} = makeFn($left, $op, $right);

		} elsif (my ($test) = $line =~ /^  Test: divisible by (\d+)$/) {
			$cMonkey->{'test'} = $test;

			$lcm = lcm($lcm, $test);

		} elsif (my ($condition, $receiver) = $line =~ /^    If (true|false): throw to monkey (\d+)$/) {
			$cMonkey->{$condition} = $receiver;

		} elsif ($line =~ /^$/) {
			$cMonkey = undef;

		} else {
			die "unparseable line: $line";
		}
	}


	return (\%monkeys, $lcm);
}

sub turn {
	my ($id, $monkeys, $boredom) = @_;

	my $m = $monkeys->{$id};

	while (scalar @{$m->{'items'}} > 0) {
		$m->{'seen'}++;

		my $item = shift @{$m->{'items'}};

		$item = $m->{'op'}->($item);
		$item = $boredom->($item);
		my $test = $item % $m->{'test'} == 0;


		my $recipient = $m->{($test?'true':'false')};
		push @{$monkeys->{$recipient}{'items'}}, $item;
	}
}

sub round {
	my ($monkeys, $boredom) = @_;

	for my $m (sort { $a <=> $b } keys %$monkeys) {
		turn($m, $monkeys, $boredom);
	}
}

sub solve {
	my ($monkeys, $bored, $rounds) = @_;

	for (1 .. $rounds) {
		round($monkeys, $bored);
	}

	# find 2 biggest 'seen's
	my @seen = reverse sort { $a <=> $b } map { $_->{'seen'} } values %$monkeys;

	#print Dumper(\@seen);

	return $seen[0] * $seen[1];
}

sub solveOne {
	my ($lines) = @_;

	my ($monkeys, $lcm) = parse($lines);

	my $bored = sub {
		my ($x) = @_;
		return int($x / 3);
	};

	return solve($monkeys, $bored, 20);
}

sub solveTwo {
	my ($lines) = @_;

	my ($monkeys, $lcm) = parse($lines);

	my $bored = sub {
		my ($x) = @_;
		return $x % $lcm;
	};

	return solve($monkeys, $bored, 10000);
}

main(\&solveOne, \&solveTwo);
