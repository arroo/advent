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

	my $latest = '';


	my $info = reduce(
		sub {
			my ($acc, $line) = @_;

			if ($line eq '') {

			} elsif ($line =~ /\Aseeds:/) {
				$acc->{'seeds'} = [split / /, $line];

				shift @{$acc->{'seeds'}};

			} elsif (my ($pair) = $line =~ m/\A(\w+-to-\w+) map:\z/) {

				$latest = $pair;

			} elsif (my (@coords) = $line =~ m/\A(\d+) (\d+) (\d+)\z/) {
				push @{$acc->{$latest}}, \@coords;

			} else {
				die "unexpected line: $line\n";
			}

			return $acc;
		},
		$lines,
		{},
	);

	for my $k (keys %$info) {
		next if ($k eq 'seeds');

		my @out;
		$info->{$k} = [sort { $a->[1] <=> $b->[1] } @{$info->{$k}}];
		my $i = 0;
		for my $entry (@{$info->{$k}}) {
			my ($dst, $src, $range) = @$entry;

			if ($i < $src) {
				push @out, [$i, $i, $src-$i];
			}
			$i = $src + $range;
			push @out, $entry;
		}

		push @out, [$i, $i, undef];
		$info->{$k} = [sort { $a->[1] <=> $b->[1] } @out];
		print Dumper($k, $i, $info->{$k});
	}

	return $info;
}

sub solveOne {
	my ($lines) = @_;

	my $game = parse($lines);

	print Dumper($game);

	my $lowest;

	for my $seed (@{$game->{'seeds'}}) {
		print "$seed\n";

		my $loc = $seed;
		MAP: for my $map (qw(seed-to-soil soil-to-fertilizer fertilizer-to-water water-to-light light-to-temperature temperature-to-humidity humidity-to-location)) {
			for my $entry (sort { $a->[1] <=> $b->[1] } @{$game->{$map}}) {
				my ($dst, $src, $range) = @$entry;

				if ($loc < $src) {

					print "seed: $seed $map low loc: $loc src: $src\n";

					next MAP;
				}

				if ($src <= $loc and $loc < $src + $range) {

					$loc = $dst + $loc - $src;
					print "seed: $seed $map fit loc: $loc src: $src dst:$dst\n";

					next MAP;
				}
			}

			print "using too-high $map entry of $loc\n";
		}

		if (not defined $lowest or $loc < $lowest) {
			$lowest = $loc;
		}

		print "\n";
	}

	return $lowest;
}

my %next = (
	'seeds' => 'seed-to-soil',
	'seed-to-soil' => 'soil-to-fertilizer',
	'soil-to-fertilizer' => 'fertilizer-to-water',
	'fertilizer-to-water' => 'water-to-light',
	'water-to-light' => 'light-to-temperature',
	'light-to-temperature' => 'temperature-to-humidity',
	'temperature-to-humidity' => 'humidity-to-location',
	#'humidity-to-location',
);

my %symbols = (
	'seeds' => '🌱',
	'seed-to-soil' => '🌎',
	'soil-to-fertilizer' => '💩',
	'fertilizer-to-water' => '🌊',
	'water-to-light' => '☀️',
	'light-to-temperature' => '🌡️',
	'temperature-to-humidity' => '💦',
	'humidity-to-location' => '🧭',
);

sub round {
	my ($game, $location, $lo, $hi) = @_;

	# don't have anywhere to go next therefore we're at the last location and since it's sorted,
	# the lowest is the lowest possible
	if (not defined $next{$location}) {
		return $lo;
	}

	my $prev = $location;
	my $next = $next{$location};

	my @split;

	for my $entry (@{$game->{$next}}) {
		my ($dst, $src, $range) = @$entry;

		my $srcTop = defined $range ? $src+$range : 'inf';
		print "$symbols{$prev} -> $symbols{$next} ($lo-$hi) vs ($src-$srcTop) ";

		if (not defined $range) { # above tests
			push @split, [$next, $lo, $hi];
			print emojis()->{GREEN} . "\n";
			return \@split;
		}

		# check outside

		if ($lo > $src + $range) { # below
			print emojis()->{RED} ."\n";
			next;

		} elsif ($hi < $src) { # above

			die "should not happen";

			next;
		}

		# some overlap
		# $lo  -> $hi
		# $src -> $src+$range

		if ($src <= $lo) {
			if ($hi <= $src+$range) { # fully encompassed
				push @split, [$next, $dst+$lo-$src, $dst+$hi-$src];
				print emojis()->{GREEN} . "\n";
				return \@split;
			}

			print emojis()->{YELLOW} ."\n";
			push @split, [$next, $dst+$lo-$src, $dst+$range];

			$lo = $src+$range;

			next;
		} elsif ($hi <= $src+$range) {
			#push @split, [$next, $dst+];
		}



	}

	die "fell off round loop\n";
}

my @ordered = qw(seeds seed-to-soil soil-to-fertilizer fertilizer-to-water water-to-light light-to-temperature temperature-to-humidity humidity-to-location);

my %ordered = map { $ordered[$_] => $_ } 0 .. $#ordered;
print Dumper(\%ordered);

sub sortPlants {
	#my ($a, $b) = @_;

	#print Dumper('sort',[$a, $b]);

	return ($a->[0] eq $b->[0]) ? ($a->[1] <=> $b->[1]) : ($ordered{$a->[0]} <=> $ordered{$b->[0]});
}

sub play {
	my ($game, $round) = @_;


	my @queue = ($round);
	while (1) {

		my $round = shift @queue;

		my $results = round($game, @$round);

		print Dumper('results', $results);
		if (ref $results eq '') {
			return $results;
		}

		@queue = sort sortPlants @queue, @$results;
		print Dumper('post sort', \@queue);
	}
}

sub solveTwo {
	my ($lines) = @_;

	my $game = parse($lines);

	my @queue;

	for (my $i = 0; $i < scalar @{$game->{'seeds'}}; $i+=2) {
		my $base = $game->{'seeds'}[$i];
		my $range = $game->{'seeds'}[$i+1];
		push @queue, ['seeds', $base, $base + $range];
	}

	print Dumper(\@queue);

	my $lowest;
	for my $round (@queue) {

		my $found = play($game, $round);

		if (not defined $lowest or $found < $lowest) {
			$lowest = $found;
		}
	}

	return $lowest;
}

sub solveTwoA {
	my ($lines) = @_;

	my $game = parse($lines);

	print Dumper($game);

	my $lowest;

	for (my $i = 0; $i < scalar @{$game->{'seeds'}}; $i+=2) {
		my $base = $game->{'seeds'}[$i];
		my $range = $game->{'seeds'}[$i+1];
		for my $seed ($base .. $base+$range) {
			#print "$seed\n";

			my $loc = $seed;
			MAP: for my $map (qw(seed-to-soil soil-to-fertilizer fertilizer-to-water water-to-light light-to-temperature temperature-to-humidity humidity-to-location)) {
				for my $entry (sort { $a->[1] <=> $b->[1] } @{$game->{$map}}) {
					my ($dst, $src, $range) = @$entry;

					if ($loc < $src) {

						#print "seed: $seed $map low loc: $loc src: $src\n";

						next MAP;
					}

					if ($src <= $loc and $loc < $src + $range) {

						$loc = $dst + $loc - $src;
						#print "seed: $seed $map fit loc: $loc src: $src dst:$dst\n";

						next MAP;
					}
				}

				#print "using too-high $map entry of $loc\n";
			}

			if (not defined $lowest or $loc < $lowest) {
				$lowest = $loc;
			}

			#print "\n";
		}
}

	return $lowest;
}

main(\&solveOne, \&solveTwo);
