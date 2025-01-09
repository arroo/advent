#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub inBounds {
	my ($minX, $maxX, $minY, $maxY) = @_;

	return sub {
		my ($x, $y) = @_;

		return (($minX <= $x and $x <= $maxX) and ($minY <= $y and $y <= $maxY));
	};
}

sub manhattanKeys {
	my ($start, $end) = @_;

	return manhattanXY(keyCoords($start), keyCoords($end));
}

sub solveOne {
	my ($lines) = @_;

	my ($map, $maxX, $maxY) = parseGrid($lines);

	print Dumper($map, $maxX, $maxY);

	my $ib = inBounds(0, $maxX, 0, $maxY);

	my %freqs;
	for my $node (grep { $map->{$_} ne '.' } keys %$map) {
		push @{$freqs{$map->{$node}}}, $node;
	}

	print Dumper(\%freqs);

	my %antinodes;
	for my $freq (keys %freqs) {

		for my $node1 (@{$freqs{$freq}}) {
			my ($x, $y) = keyCoords($node1);

			for my $node2 (@{$freqs{$freq}}) {
				next if ($node1 eq $node2);

				my ($dX, $dY) = manhattanKeys($node1, $node2);

				my $antinode = coordsKey($x - $dX, $y - $dY);
				
				if (defined $map->{$antinode}) {
					$antinodes{$antinode} = undef;
				}
			}
		}
	}

	print Dumper(\%antinodes);

	return scalar keys %antinodes;
}

sub solveTwo {
	my ($lines) = @_;

	my ($map, $maxX, $maxY) = parseGrid($lines);

	#print Dumper($map, $maxX, $maxY);

	my $ib = inBounds(0, $maxX, 0, $maxY);

	my %freqs;
	for my $node (grep { $map->{$_} ne '.' } sort keys %$map) {
		push @{$freqs{$map->{$node}}}, $node;
	}

	#print Dumper(\%freqs);

	my %antinodes;
	for my $freq (sort keys %freqs) {

		for my $node1 (@{$freqs{$freq}}) {
			my ($x, $y) = keyCoords($node1);

			# add the originating for some reason
			$antinodes{$node1} = undef;

			for my $node2 (@{$freqs{$freq}}) {
				next if ($node1 eq $node2);

				print "comparing ($freq) ($node1) and ($node2)\n";

				my ($dX, $dY) = manhattanKeys($node1, $node2);

				while (1) {
					my $antinode = coordsKey($x - $dX, $y - $dY);
					print "\t\ttesting $antinode\n";

					if (defined $map->{$antinode}) {
						print "\t$antinode\n";
						$antinodes{$antinode} = undef;

					} else {
						($x, $y) = keyCoords($node1);
						last;
					}

					($x, $y) = keyCoords($antinode);
				}
			}
		}
	}

	for my $y (0 .. $maxY) {
		for my $x (0 .. $maxX) {
			my $key = coordsKey($x, $y);

			if ($map->{$key} ne '.') {
				print $map->{$key};

			} elsif (exists $antinodes{$key}) {
				print '#';

			} else {
				print '.';
			}
		}

		print "\n";
	}

	#print Dumper(\%antinodes);

	return scalar keys %antinodes;
}

main(\&solveOne, \&solveTwo);
