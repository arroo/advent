#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub key {
	return join(',', @_);
}

sub coord {
	return split /,/, $_[0];
}

sub parse {
	my ($lines) = @_;

	return reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		my @chars = split //, $line;
		for my $j (0 .. $#chars) {
			if ($chars[$j] eq '#') {
				$acc->{key($j, $i)} = undef;
			}
		}

		return $acc;
	},
	$lines,
	{},
	);
}

sub solveOne {
	my ($lines) = @_;

	my $map = parse($lines);

	return Dumper($map);

	return reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		return $acc;
	},
	$lines,
	0,
	);
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
