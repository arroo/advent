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

	my $_boxes = 'boxes';
	my $_keys  = 'keys';

	# attach instructions to boxes
	my $instructions = reduce(
		sub {
			my ($acc, $ins) = @_;

			my $label;
			if (($label) = $ins =~ /\A(.+)-\z/) {
				my $box = $acc->{$_keys}{$label} //= hash($label);

				push @{$acc->{$_boxes}[$box]}, removeFn($label);

			} elsif (($label, my $focalLength) = $ins =~ /\A(.+)=([1-9])\z/) {
				my $box = $acc->{$_keys}{$label} //= hash($label);

				push @{$acc->{$_boxes}[$box]}, upsertFn($label, $focalLength);

			} else {
				die "unrecognized instruction: $ins\n";
			}

			return $acc;
		},
		[ split /,/, $lines->[0] ],
		{ $_boxes => [], $_keys => {} },
	)->{$_boxes};

	# follow instructions on each box
	my $boxes = reduce(
		sub {
			my ($acc, $ins, $i) = @_;

			# follow instructions on this box
			my $box = reduce(
				sub {
					my ($acc, $fn) = @_;

					$fn->($acc);

					return $acc;
				},
				$ins,
				[],
			);

			push @$acc, $box;

			return $acc;
		},
		$instructions,
		[],
	);

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
		$boxes,
		0,
	);
}

main(\&solveOne, \&solveTwo);
