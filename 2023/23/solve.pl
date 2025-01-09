#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);
use AOC::Text qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my $forest = '#';
my $path = '.';
my $up = '^';
my $dn = 'v';
my $lf = '<';
my $rt = '>';

sub neighbours {
	my ($x, $y, $grid, $seen) = @_;

	my @dirs = (
		[$x, $y-1, $up],
		[$x, $y+1, $dn],
		[$x-1, $y, $lf],
		[$x+1, $y, $rt],
	);

	my @neighbours;

	for my $dir (@dirs) {
		my ($x, $y, $allowed) = @$dir;

		my $key = "$x,$y";

		if (not exists $seen->{$key} and
			defined $grid->{$key} and
			($grid->{$key} eq $path or $grid->{$key} eq $allowed)) {

			push @neighbours, [$x, $y];
		}
	}

	return \@neighbours;
}

sub parseEdges {
	my ($grid) = @_;

	my ($maxX, $maxY);
	for my $k (keys %$grid) {
		my ($x, $y) = split /,/, $k;

		$maxX = (not defined $maxX or $x > $maxX) ? $x : $maxX;
		$maxY = (not defined $maxY or $y > $maxY) ? $y : $maxY;
	}

	my ($startX, $startY) = (1,0);
	my ($targetX, $targetY) = ($maxX-1, $maxY); # from input

	my %edges;
	my %seen;
	my @queue = ([$startX, $startY, $startX, $startY, 0, {}]);
	while (scalar @queue) {
		my $node = shift @queue;
		my ($cX, $cY, $pX, $pY, $cost, $seen) = @$node;

		$seen->{"$cX,$cY"} = undef;

		if ($cX == $targetX and $cY == $targetY) {
			# a winner is you
			$edges{"$pX,$pY"}{"$cX,$cY"}{$cost} = undef;
			next;
		}

		$cost++;
		my $nbrs = neighbours($cX, $cY, $grid, $seen);

		if (scalar @$nbrs > 1) {

			print "splitting ($cX,$cY) into " . (scalar @$nbrs) . "\n";

			$edges{"$pX,$pY"}{"$cX,$cY"}{$cost} = undef;
			$cost = 0;
			($pX, $pY) = ($cX, $cY);
		}


		for my $nbr (@$nbrs) {
			my ($nx, $ny) = @$nbr;

			my %seen;
			for my $nd (keys %$seen) {
				$seen{$nd} = undef;
			}

			push @queue, [@$nbr, $pX, $pY, $cost, \%seen];
		}
	}

	return (\%edges, "$targetX,$targetY");
}

sub solveOne {
	my ($lines) = @_;

	my $fake = [
		'#.#########',
		'#.........#',
		'#.#######.#',
		'#.........#',
		'#.#######.#',
		'#.........#',
		'#########.#',
	];

	if (0) {
		$lines = $fake;
	}

	my $grid = parseGrid($lines);

	my ($edges, $target) = parseEdges($grid);

	print Dumper($edges);

	my @queue = (["1,0", 0, [], {}]);
	my @walks;
	while (scalar @queue) {
		my $node = shift @queue;
		my ($name, $cost, $path, $seen) = @$node;

		push @$path, $name;
		next if (exists $seen->{$name});
		$seen->{$name} = undef;

		if ($name eq $target) {
			push @walks, [$path, $cost];
			next;
		}

		for my $nbr (keys %{$edges->{$name}}) {
			for my $ncost (keys %{$edges->{$name}{$nbr}}) {

				my @path = map { $_ } @$path;
				my %seen = map { $_ => undef } keys %$seen;

				print "$name -> $nbr($ncost)\n";

				push @queue, [$nbr, $cost + $ncost, \@path, \%seen];
			}
		}
	}

	return Dumper([sort { $a->[1] <=> $b->[1] } @walks]);
}

sub solveTwo {
	my ($lines) = @_;

	my $parsed = parseGrid($lines);
}

main(\&solveOne, \&solveTwo);
