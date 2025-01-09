#!/usr/bin/env perl

use warnings;
use strict;

use Time::HiRes qw(gettimeofday tv_interval);

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub timeit {
	my ($fn) = @_;

	my $start = [gettimeofday];
	$fn->();
	return tv_interval($start);
}

sub timeWithCache {
	my %cache;

	my $time = sub {
		my ($title, $fn) = @_;

		if (not defined $cache{$title}) {
			$cache{$title} = [0, 0];
		}

		$cache{$title}[0]++;
		$cache{$title}[1] += timeit($fn);
	};

	return \%cache, $time;
}

sub parse {
	my ($lines) = @_;

	return reduce(
		sub {
			my ($acc, $line, $y) = @_;

			my @line = split //, $line;
			for my $x (0 .. $#line) {
				$acc->{"$x,$y"} = $line[$x];
			}

			return $acc;
		},
		$lines,
		{},
	);
}

sub load {
	my ($map) = @_;

	my $maxY;
	my @roundRockYCoords;

	for (my $y = 0; exists $map->{"0,$y"}; $y++) {
		for (my $x = 0; exists $map->{"$x,$y"}; $x++) {
			if ($map->{"$x,$y"} eq 'O') {
				push @roundRockYCoords, $y;
			}
		}

		$maxY = $y;
	}

	return sum(map { $maxY - $_ + 1 } @roundRockYCoords);
}


sub printMap {
	my ($map) = @_;

	for (my $y = 0; exists $map->{"0,$y"}; $y++) {
		for (my $x = 0; exists $map->{"$x,$y"}; $x++) {
			my $val = $map->{"$x,$y"} // "|$x,$y undefined|";
			print $val;
		}

		print "\n";
	}
}

sub tiltNorth {
	my ($map) = @_;

	for (my $x = 0; exists $map->{"$x,0"}; $x++) {

		my $minY = 0;

		for (my $y = 0; exists $map->{"$x,$y"}; $y++) {
			my $val = $map->{"$x,$y"};
			if ($val eq '.') {

			} elsif ($val eq 'O') {
				($map->{"$x,$y"}, $map->{"$x,$minY"}) = ($map->{"$x,$minY"}, $map->{"$x,$y"});

				$minY++;

			} elsif ($val eq '#') {
				$minY = $y+1;
			}
		}
	}
}

sub transpose {
	my ($map) = @_;

	my %seen;

	for (my $x = 0; exists $map->{"$x,0"}; $x++) {
		for (my $y = 0; exists $map->{"$x,$y"}; $y++) {
			my $from = "$x,$y";
			my $to = "$y,$x";
			next if (exists $seen{$from} or $x == $y);

			$seen{$to} = undef;
			($map->{$from}, $map->{$to}) = ($map->{$to}, $map->{$from});
		}
	}
}

sub flipVertical {
	my ($map, $maxY) = @_;

	for (my $x = 0; exists $map->{"$x,0"}; $x++) {
		for my $y (0 .. int($maxY / 2)) {
			my $oppY = $maxY-$y;
			($map->{"$x,$y"}, $map->{"$x,$oppY"}) = ($map->{"$x,$oppY"}, $map->{"$x,$y"})
		}
	}
}

sub solveOne {
	my ($lines) = @_;

	my $map = parse($lines);

	tiltNorth($map);

	return load($map);
}

sub copy {
	my ($map) = @_;

	return { map { $_ => $map->{$_} } keys %$map };
}

sub solveTwo {
	my ($lines) = @_;

	my $map = parse($lines);

	my $maxY = 0;

	for (my $y = 0; exists $map->{"0,$y"}; $y++) {
		$maxY = $y;
	}

	my $revs = 1_000_000_000;

	my ($cache, $timer) = timeWithCache();

	my %seen;
	my @seen;

	for (my $i = 0; $i < $revs; $i++) {

		# north
		$timer->("tilt", sub {tiltNorth($map)});

		# west
		$timer->("transpose", sub {transpose($map)});
		$timer->("tilt", sub {tiltNorth($map)});

		# south
		$timer->("transpose", sub {transpose($map)});
		$timer->("flipV", sub {flipVertical($map, $maxY);});
		$timer->("tilt", sub {tiltNorth($map)});

		# east
		$timer->("transpose", sub {transpose($map)});
		$timer->("flipV", sub {flipVertical($map, $maxY);});
		$timer->("tilt", sub {tiltNorth($map)});

		# reset to north
		$timer->("flipV", sub {flipVertical($map, $maxY);});
		$timer->("transpose", sub {transpose($map)});
		$timer->("flipV", sub {flipVertical($map, $maxY);});

		my $key = Dumper($map);
		if (exists $seen{$key}) {

			my $remaining = $revs - $i;
			my $cycle = $i - $seen{$key};

			$map = $seen[$seen{$key} - 1 + $remaining % $cycle];
			last;
		}

		$timer->("copy", sub {push @seen, copy($map);});
		$seen{$key} = $i;
	}

	print Dumper($cache);

	return load($map);
}

main(\&solveOne, \&solveTwo);
