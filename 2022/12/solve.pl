#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my $SEP = ',';

sub key {
	return join($SEP, @_);
}

sub Pos {
	return split /$SEP/, $_[0];
}

sub elevation {
	my ($v) = @_;

	if ($v eq 'S') {
		$v = 'a';

	} elsif ($v eq 'E') {
		$v = 'z';
	}

	return ord($v);
}

sub canGo {
	my ($start, $target) = @_;

	return elevation($target) <= elevation($start) + 1;
}

sub neighbours {
	my ($nodes, $pos) = @_;

	my ($pX, $pY) = Pos($pos);

	my @out;

	my @toCheck = (
		[$pX, $pY+1], # up
		[$pX, $pY-1], # down
		[$pX+1, $pY], # left
		[$pX-1, $pY], # right
	);

	for my $p (@toCheck) {
		my $key = key(@$p);

		if (not exists $nodes->{$key}) {
			next;
		}

		if (not canGo($nodes->{$pos}, $nodes->{$key})) {
			next;
		}

		push @out, $key;
	}

	return \@out;
}

sub parse {
	my ($lines) = @_;

	return reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		my ($nodes, $y) = @$acc;

		my @pts = split //, $line;
		for my $x (0 .. $#pts) {

			my $key = key($x, $y);

			$nodes->{'nodes'}{$key} = $pts[$x];
			$nodes->{'start'} = $key if ($pts[$x] eq 'S');
			$nodes->{'end'} = $key if ($pts[$x] eq 'E');
		}

		return [$nodes, $y+1];
	},
	$lines,
	[{
		'nodes' => {},
	}, 0],
	)->[0];
}

sub solve {
	my ($nodes, $starts, $end) = @_;

	my %seen = map { $_ => undef} @$starts;
	my @search = map { [$_, 0] } @$starts;
	while (scalar @search > 0) {
		my $cur = shift @search;

		my ($pos, $steps) = @$cur;

		if ($pos eq $end) {
			return $steps;
		}

		my $neighbours = neighbours($nodes, $pos);

		my @fresh = grep { not exists $seen{$_} } @$neighbours;

		$seen{$_} = undef for @$neighbours;

		for my $p (@fresh) {
			push @search, [$p, $steps+1];
		}
	}

	die "unable to find endpoint";
}

sub solveOne {
	my ($lines) = @_;

	my $map = parse($lines);

	return solve($map->{'nodes'}, [$map->{'start'}], $map->{'end'});
}

sub solveTwo {
	my ($lines) = @_;

	my $map = parse($lines);



	my $al = elevation('a');
	my @starts = grep { elevation($map->{'nodes'}{$_}) == $al } keys %{$map->{'nodes'}};

	return solve($map->{'nodes'}, \@starts, $map->{'end'});
}


main(\&solveOne, \&solveTwo);
