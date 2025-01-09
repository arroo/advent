#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub trailHeads {
	my ($map, $node) = @_;

	my %found;
	my @queue = ($node);
	my %seen;
	while (scalar @queue) {
		my $node = shift @queue;
		my $height = $map->{$node};

		$seen{$node} = undef;
		if ($height == 9) {
			$found{$node} = undef;
			next;
		}

		my $neighbours = cardinalNeighbours(keyCoords($node));
		my @neighbourKeys = grep { exists $map->{$_} } map { coordsKey(@$_) } @$neighbours;
		my @stepNeighbours = grep { $map->{$_} == $height+1 } @neighbourKeys;
		my @unseenNeighbours = grep { not exists $seen{$_} } @stepNeighbours;

		#print "neighbours of $node: @neighbourKeys\n";

		push @queue, @unseenNeighbours;
	}

	#print Dumper($node, (scalar keys %found), \%found);

	return scalar keys %found;
}

sub rating {
	my ($map, $node) = @_;

	my $found;
	my @queue = ($node);

	while (scalar @queue) {
		my $node = shift @queue;

		my $height = $map->{$node};
		if ($height == 9) {
			$found++;
			next;
		}

		my $neighbours = cardinalNeighbours(keyCoords($node));
		my @neighbourKeys = map { coordsKey(@$_) } @$neighbours;
		my @existingNeighbours = grep { exists $map->{$_} } @neighbourKeys;
		my @stepNeighbours = grep { $map->{$_} == $height+1 } @existingNeighbours;

		push @queue, @stepNeighbours;
	}

	return $found;
}

sub trails {
	my ($lines, $solveF) = @_;

	my $map = parseGrid($lines);

	return reduce(
		sub {
			my ($acc, $node) = @_;
			return $acc + $solveF->($map, $node);
		},
		[sort grep { $map->{$_} == 0 } keys %$map],
		0,
	);
}

sub solveOne {
	my ($lines) = @_;

	return trails($lines, \&trailHeads);
}

sub solveTwo {
	my ($lines) = @_;

	return trails($lines, \&rating);
}

main(\&solveOne, \&solveTwo);
