#!/usr/bin/env perl

use warnings;
use strict;

use Time::HiRes qw(usleep);

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub draw {
	my ($map) = @_;

	my ($x, $y) = (0, 0);
	for (; exists $map->{coordsKey($x, $y)}; $y++) {
		for (; exists $map->{coordsKey($x, $y)}; $x++) {
			print $map->{coordsKey($x, $y)};
		}
		$x = 0;

		print "\n";
	}
}

sub solveOne {
	my ($lines) = @_;

	my $map = parseGrid($lines);

	my ($start) = grep { not exists {'.' => undef, '#' => undef}->{$map->{$_}} } keys %$map;

	print Dumper($map, $start, $map->{$start});

	# start north
	my $dir = 0;
	my @orderedDirections = (
		\&upWhile,
		\&rightWhile,
		\&downWhile,
		\&leftWhile,
	);

	my @orderedFaces = qw(^ > v <);

	my $done;
	my $path;
	my $sleep = 1_000_000;

	while (not $done) {
		$path = $orderedDirections[$dir]->(keyCoords($start), sub {
				my ($x, $y) = @_;
				my $key = coordsKey($x, $y);

				if (not defined $map->{$key}) {
					$done = 1;
					return 0;
				}

				if ($map->{$key} ne '#') {
					$map->{$key} = 'X';
					return 1;
				}

				return 0;
			});

		$start = coordsKey(@{$path->[-1]});
		$dir = ($dir + 1) % scalar @orderedDirections;

		system 'clear';
		draw($map);
		usleep($sleep);
	}

	print Dumper($path, $start, $dir);

	return scalar grep { $_ eq 'X' } values %$map;
}

my @orderedDirections = (
	\&upWhile,
	\&rightWhile,
	\&downWhile,
	\&leftWhile,
);

my @orderedFaces = qw(^ > v <);

sub detectCycle {
	my ($map, $x, $y, $dir) = @_;

	my %seen;
	my $cycle;
	while (not defined $cycle) {
		my $path = $orderedDirections[$dir]->($x, $y, sub {
				my ($x, $y) = @_;
				my $key = coordsKey($x, $y);

				if (not defined $map->{$key}) {
					$cycle = 0;
					return 0;
				}

				my $val = $map->{$key};

				if ($val eq '#') {
					return 0;
				}

				if (exists $seen{$key}{$dir}) {
					$cycle = 1;
					return 1;
				}

				$seen{$key}{$dir} = undef;

				return 1;
			});

		($x, $y) = @{$path->[-1]};
		$dir = ($dir + 1) % scalar @orderedDirections;
	}

	return $cycle;
}

sub solveTwo {
	my ($lines) = @_;

	my $map = parseGrid($lines);

	my ($start) = grep { not exists {'.' => undef, '#' => undef}->{$map->{$_}} } keys %$map;

	print Dumper($map, $start, $map->{$start});

	# start north
	my $startDir = index(join('', @orderedFaces), $map->{$start});
	my $dir = $startDir;

	my $done;
	my $path;
	my $sleep = 1_000_000;

	my %seen;
	my %potentialObstaclePoints;
	my ($x, $y) = keyCoords($start);

	while (not $done) {

		$path = $orderedDirections[$dir]->($x, $y, sub {
				my ($x, $y) = @_;
				my $key = coordsKey($x, $y);

				if (not defined $map->{$key}) {
					$done = 1;
					return 0;
				}

				if ($map->{$key} eq '#') {
					return 0;
				}

				if ($key ne $start) {
					$potentialObstaclePoints{$key} = undef;
				}
				#$map->{$key} = 'X';

				return 1;
			});

		($x, $y) = @{$path->[-1]};
		$dir = ($dir + 1) % scalar @orderedDirections;

		if (1 > 1) {
			system 'clear';
			#print "---------------------------------------\n";
			draw($map);
			usleep($sleep);
		}
	}

	#print Dumper($path, $start, $dir);
	print Dumper(\%potentialObstaclePoints);

	# brute force
	my %obstacles;
	for my $newObstacle (keys %potentialObstaclePoints) {
		$map->{$newObstacle} = '#';

		if (1 > 10) {
			system 'clear';
			draw($map);
			#usleep($sleep);
		}

		if (detectCycle($map, keyCoords($start), $startDir)) {
			$obstacles{$newObstacle} = undef;
		}

		$map->{$newObstacle} = '.';
	}

	return scalar keys %obstacles;
}

main(\&solveOne, \&solveTwo);
