#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub hash {
	my ($s) = @_;

	return reduce(
		sub {
			my ($acc, $n) = @_;

			return ($acc + $n) * 17 % 256;
		},
		[map { ord } split //, $s],
		0,
	);
}

sub solveOne {
	my ($lines) = @_;

	return reduce(
		sub {
			my ($acc, $ins) = @_;

			return $acc + hash($ins);
		},
		[ split /,/, $lines->[0] ],
		0,
	);
}

sub removeFn {
	my ($label) = @_;

	return sub {
		my ($arr) = @_;

		for my $i (0 .. $#$arr) {
			if ($arr->[$i][0] eq $label) {
				splice @$arr, $i, 1;

				last;
			}
		}
	};
}

sub upsertFn {
	my ($label, $value) = @_;

	return sub {
		my ($arr) = @_;

		for my $i (0 .. $#$arr) {
			if ($arr->[$i][0] eq $label) {
				$arr->[$i][1] = $value;

				return;
			}
		}

		push @$arr, [$label, $value];
	};
}

sub solveTwo {
	my ($lines) = @_;

	my @instructions = split /,/, $lines->[0];

	my @boxes;
	my %deleted;

	for (my $i = $#instructions; $i >= 0; $i--) {
		my $ins = $instructions[$i];

		my $label;
		if (($label) = $ins =~ /\A(.+)-\z/) {
			$deleted{$label} = undef;

		} elsif (($label, my $focalLength) = $ins =~ /\A(.+)=([1-9])\z/) {
			next if (exists $deleted{$label});

			my $b = hash($label);

			# delete it from the list
			for my $j (0 .. $#{$boxes[$b]}) {
				next unless ($boxes[$b][$j][0] eq $label);

				# store later value to put in earlier position
				$focalLength = $boxes[$b][$j][1];
				splice @{$boxes[$b]}, $j, 1;

				last;
			}


			# put it first into the list
			unshift @{$boxes[$b]}, [$label, $focalLength];

		} else {
			die "unrecognized instruction: $ins\n";
		}
	}

	# calculate focusing power
	return reduce(
		sub {
			my ($acc, $box, $i) = @_;

			return $acc + ($i+1) * reduce(
				sub {
					my ($acc, $lens, $j) = @_;

					return $acc + ($j+1) * ($lens->[1]);
				},
				$box,
				0,
			);
		},
		\@boxes,
		0,
	);
}

main(\&solveOne, \&solveTwo);
