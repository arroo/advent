#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my $RAT = 'rate';
my $NBR = 'neighbour';

sub parse {
	my ($lines) = @_;

	return reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		if (my ($name, $rate, $connections) = $line =~ /^Valve (.+) has flow rate=(-?\d+); tunnels? leads? to valves? (.+)$/) {
			$acc->{$name} = {
				$RAT => $rate,
				$NBR => [split /, /, $connections],
			};

		} else {
			die "malformed line ($i): $line\n";
		}

		return $acc;
	},
	$lines,
	{},
	);
}

# inserts into sorted list
sub insert {
	my ($list, $item, $cmp) = @_;

	#print Dumper(@_);

	my $i=0;
	for $i (0 .. $#$list) {
		if ($cmp->($list->[$i], $item) >= 0) {
			last;
		}
	}

	splice @$list, $i, 0, $item;

	return $list;
}

sub cmpRates {
	my ($A, $B) = @_;

	return $A->{'relief'} <=> $B->{'relief'};
}

sub solveOne {
	my ($lines) = @_;

	my $valves = parse($lines);

	#return Dumper($valves);

	my $timeLimit = 30;
	my $startRoom = 'AA';

	my %start = (
		'room' => $startRoom,
		'timeLeft' => $timeLimit,
		'relief' => 0,
		'opened' => {},
		'steps' => [],
	);

	my $max = -1;

	my @list = \%start;
	while (scalar @list > 0) {
		my $node = pop @list;

		my ($room, $remaining, $relief, $opened, $steps) =
			@$node{qw(room timeLeft relief opened steps)};

		print Dumper($steps);

		$remaining--; # time ticks down
		if ($remaining <= 0) {
			if ($relief > $max->{'relief'}) {
				print "increasing max to $relief\n";
				$max = $node;
			}

			next;
		}

		my $roomRate = $valves->{$room}{$RAT};
		if ($roomRate > 0 and not exists $opened->{$room}) {
			# open current room valve

			my $additionalRelief = $roomRate * $remaining;
			my $newRelief = $relief + $additionalRelief;

			my %next = (
				'room' => $room,
				'timeLeft' => $remaining,
				'relief' => $newRelief,
				'opened' => {%$opened, $room => undef},
				'steps' => [@$steps, "o $room (r=$roomRate * t=$remaining + r=$relief) = $newRelief t=$remaining"],
			);

			insert(\@list, \%next, \&cmpRates);
		}

		# explore adjacent rooms
		for my $n (@{$valves->{$room}{$NBR}}) {
			my %next =  (
				'room' => $n,
				'timeLeft' => $remaining,
				'relief' => $relief,
				'opened' => {%$opened},
				'steps' => [@$steps, "m (s=$room -> d=$n) r=$relief t=$remaining"],
			);

			insert(\@list, \%next, \&cmpRates);
		}

		#print Dumper($room, $remaining, $relief, $opened);
	}

	return Dumper($max);
}

sub solveTwo {
	my ($lines) = @_;

	return reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		return $acc;
	},
	$lines,
	0,
	);
}

main(\&solveOne, \&solveTwo);
