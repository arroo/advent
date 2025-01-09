#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub draw {
	my ($positions, $maxX, $maxY) = @_;

	my %pos;
	for my $p (@$positions) {
		$pos{coordsKey(@$p)}++;
	}

	print Dumper(\%pos);

	for my $y (0 .. $maxY-1) {
		for my $x (0 .. $maxX-1) {

			#if ($x == ($maxX-1)/2 or $y == ($maxY-1)/2) {
			#	print ' ';
			#} else {
				print $pos{coordsKey($x,$y)} // '.';
			#}
		}

		print "\n";
	}

}

sub parse {
	my ($lines) = @_;

	return reduce(
		sub {
			my ($acc, $line) = @_;

			if (my ($pX,$pY,$vX,$vY) = $line =~ m/\Ap=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)\z/) {
				push @$acc, [$pX, $pY, $vX, $vY];

			} else {
				die "line doesn't match:$line\n";
			}

			return $acc;
		},
		$lines,
		[],
	);
}

sub move {
	my ($robots, $maxX, $maxY, $steps) = @_;

	my @positions;
	for my $r (@$robots) {
		my ($pX, $pY, $vX, $vY) = @$r;

		my $x = ($pX + $vX * $steps) % $maxX;
		my $y = ($pY + $vY * $steps) % $maxY;

		push @positions, [$x, $y, $vX, $vY];
	}

	return \@positions;
}

sub quads {
	my ($positions, $maxX, $maxY) = @_;

	my $quads = reduce(
		sub {
			my ($acc, $pos) = @_;

			my ($x, $y) = @$pos;

			my $lr;
			if ($x > ($maxX-1)/2) {
				$lr = 'r';

			} elsif ($x < ($maxX-1)/2) {
				$lr = 'l';
			}

			my $ud;
			if ($y > ($maxY-1)/2) {
				$ud = 'd';

			} elsif ($y < ($maxY-1)/2) {
				$ud = 'u';
			}

			if (defined $lr and defined $ud) {
				$acc->{"$lr$ud"}++;
			}

			return $acc;
		},
		$positions,
		{},
	);

	print Dumper($quads);

	return values %$quads;
}

sub solveOne {
	my ($lines) = @_;

	my $robots = parse($lines);

	my ($width, $height) = (101, 103);
	#($width, $height) = (11, 7); # sample input

	$robots = move($robots, $width, $height, 100);


	my @positions = map {[$_->[0], $_->[1]]} @$robots;
	print Dumper(\@positions);
	
	draw(\@positions, $width, $height);

	return prod(quads(\@positions, $width, $height));
}

sub allUniqueLocations {
	my ($robots) = @_;

	my %seen;
	for my $r (@$robots) {
		my $key = coordsKey(@$r[0 .. 1]);
		if (exists $seen{$key}) {
			return 0;
		}

		$seen{$key} = undef;
	}

	return 1;
}

sub solveTwo {
	my ($lines) = @_;

	my $robots = parse($lines);

	my ($width, $height) = (101, 103);

	my $steps = 0;
	while (not allUniqueLocations($robots)) {
		$steps++;
		$robots = move($robots, $width, $height, 1);
	}

	my @positions = map {[$_->[0], $_->[1]]} @$robots;
	draw(\@positions, $width, $height);

	return $steps;

	#while (1) { # ???
	#	my @positions = map { [ $_->[0], $_->[1] ] } @$robots;
	#
	#	system 'clear';
	#	draw(\@positions, $width, $height);
	#	sleep 1;
	#
	#	$robots = move($robots, $width, $height, 1);
	#}


	return -2;
}

main(\&solveOne, \&solveTwo);
