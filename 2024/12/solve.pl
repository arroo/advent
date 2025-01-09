#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub findRegions {
	my ($keys) = @_;

	my %keys = map { $_ => undef } @$keys;

	my @regions;

	my %seen;
	for my $start (@$keys) {
		next if (exists $seen{$start});

		push @regions, [];

		my @queue = ($start);
		while (scalar @queue) {
			my $key = pop @queue;
			next if (exists $seen{$key});
			$seen{$key} = undef;
			push @{$regions[-1]}, $key;

			push @queue, grep { exists $keys{$_} } @{cardinalNeighbourKeys($key)};
		}
	}

	return \@regions;
}

sub areaPerim {
	my ($map, $region) = @_;

	my $area = scalar @$region;

	my $perim = 0;
	for my $key (@$region) {
		for my $n (@{cardinalNeighbourKeys($key)}) {
			if (not (exists $map->{$n} and $map->{$n} eq $map->{$key})) {
				$perim++;
			}
		}
	}

	return $area,$perim;
}

sub areaSides {
	my ($map, $region) = @_;

	my $crop = $map->{$region->[0]};

	my $area = scalar @$region;
	my $sides = 0;
	my %fences;
	my ($minX, $minY);
	my ($maxX, $maxY);

	for my $key (@$region) {

		my ($x, $y) = keyCoords($key);
		{
			$minX = (not defined $minX or $x < $minX) ? $x : $minX;
			$maxX = (not defined $maxX or $x > $maxX) ? $x : $maxX;
			$minY = (not defined $minY or $y < $minY) ? $y : $minY;
			$maxY = (not defined $maxY or $y > $maxY) ? $y : $maxY;
		}

		for my $n (@{cardinalNeighbourKeys($key)}) {
			next if (exists $map->{$n} and $map->{$n} eq $map->{$key});

			# find where fence is

			my ($nX, $nY) = keyCoords($n);
			my $fX = ($x + $nX) / 2;
			my $fY = ($y + $nY) / 2;


			my $dir;
			if ($x < $nX) {
				$dir = 'l';

			} elsif ($x > $nX) {
				$dir = 'r';

			} elsif ($y<$nY) {
				$dir = 'u';

			} elsif ($y > $nY) {
				$dir = 'd';

			} else {
				die "what the fujc\n";
			}

			$fences{coordsKey($fX, $fY, $dir)} = undef;
		}
	}

	# check horizontal fences
	for my $dir (split //, 'ud') {
		for (my $y = $minY - 0.5; $y <= $maxY + 0.5; $y++) {

			my $last = 0;

			for my $x ($minX .. $maxX) {
				if (exists $fences{coordsKey($x, $y, $dir)}) {

					$sides++ if ($last == 0);
					$last = 1;

				} else {$last = 0;}
			}
		}
	}

	# check vertical fences
	for my $dir (split //, 'lr') {
		for (my $x = $minX - 0.5; $x <= $maxX + 0.5; $x++) {
			my $last = 0;

			for my $y ($minY .. $maxY) {
				if (exists $fences{coordsKey($x, $y, $dir)}) {
					$sides++ if ($last == 0);
					$last = 1;
				} else {$last = 0;}
			}
		}
	}

	#print Dumper($crop, \%fences, [[$minX, $minY],[$maxX,$maxY]]);

	return $area, $sides;
}

sub solveOne {
	my ($lines) = @_;

	my $map = parseGrid($lines);

	my %crops = map {$_=>[]} values %$map;
	for my $key (keys %$map) {
		push @{$crops{$map->{$key}}}, $key;
	}

	my $total = 0;
	for my $crop (keys %crops) {
		my $set = $crops{$crop};
		my $regions = findRegions($set);

		for my $reg (@$regions) {
			my ($area, $perim) = areaPerim($map, $reg);
			my $fenceCost = $area * $perim;

			print "($crop) region containing ($reg->[0]) has area:$area, perimeter:$perim, fence:$fenceCost\n";

			$total += $area * $perim;
		}
	}

	return $total;
}

# 862350 too low

sub solveTwo {
	my ($lines) = @_;

	my $map = parseGrid($lines);

	my %crops = map {$_=>[]} values %$map;
	for my $key (keys %$map) {
		push @{$crops{$map->{$key}}}, $key;
	}

	my $total = 0;
	for my $crop (sort keys %crops) {

		# TODO: remove
		#next unless ($crop eq 'I');

		my $set = $crops{$crop};
		my $regions = findRegions($set);

		for my $reg (@$regions) {
			my ($area, $perim) = areaSides($map, $reg);
			my $fenceCost = $area * $perim;

			print "($crop) region containing ($reg->[0]) has area:$area, perimeter:$perim, fence:$fenceCost\n";

			$total += $area * $perim;
		}
	}

	return $total;
}

main(\&solveOne, \&solveTwo);
