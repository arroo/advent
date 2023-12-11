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
			my ($acc, $line, $i) = @_;


			#print "processing: $line\n";

			if (my ($node, $left, $right) = ($line =~ m/\A(.+) = \((.+), (.+)\)\z/)) {
				$acc->{'eqs'}{$node} = [$left, $right];

			} elsif (my ($dirs) = ($line =~ m/\A([LR]+)\z/)) {
				$acc->{'dirs'} = [map { $_ eq 'L' ? 0 : 1 } split //, $dirs];

			} elsif ($line ne '') {
				die "unknown line($i): $line\n";
			}

			return $acc;
		},
		$lines,
		{},
	);
}

sub solveOne {
	my ($lines) = @_;

	my $parsed = parse($lines);

	#print Dumper($parsed);

	my ($dirs, $map) = @$parsed{qw(dirs eqs)};

	#print Dumper($dirs);

	my $i = 0;
	my $node = 'AAA';
	my $steps = 0;
	while ($node ne 'ZZZ') {
		$steps++;

		$node = $map->{$node}[$dirs->[$i]];
		$i = ($i + 1) % scalar @$dirs;
	}

	return $steps;
}



sub solveTwo {
	my ($lines) = @_;

	my $parsed = parse($lines);

	my ($dirs, $map) = @$parsed{qw(dirs eqs)};

	my $i = 0;
	my @nodes = grep {$_ =~ m/A\z/} keys %$map;

	print Dumper(\@nodes);

	my %cycles;

	for my $node (@nodes) {
		# find cycle lengths
		my $i = 0;
		my $steps = 0;
		my $base = $node;
		my %seen;
		my @zs;
		while (not defined $seen{"$node$i"}) {
			$seen{"$node$i"} = $steps++;


			$node = $map->{$node}[$dirs->[$i]];
			$i = ($i + 1) % scalar @$dirs;

			print "step $steps to $node\n";
			if ($node =~ m/Z\z/) {
				push @zs, [$node,$steps];
			}

		}

		my $cycleTime = $steps - $seen{"$node$i"};

		$cycles{$base} = [$cycleTime, @zs];
	}


	print Dumper(\%cycles);

	return lcm(map {$_->[0]} values %cycles);
}

main(\&solveOne, \&solveTwo);
