#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;

sub solve {
	my ($lines, $dfsFn) = @_;

	my $start = 'start';

	my $edges = reduce(
		sub {
			my ($acc, $line, $i, $lines) = @_;

			my ($src, $dst) = $line =~ /^([^-]+)-([^-]+)$/;

			if ($dst ne $start) {
				push @{$acc->{$src}}, $dst;
			}

			if ($src ne $start) {
				push @{$acc->{$dst}}, $src;
			}

			return $acc;
		},
		$lines,
		{},
	);

	return $dfsFn->($edges, $start, 'end');
}

sub solveOne {
	my ($lines) = @_;

	return solve(
		$lines,
		sub {
			my ($edges, $start, $end) = @_;

			my $total = 0;
			my %seen = map { $_ => 0 } keys %$edges;

			my $fn;
			$fn = sub {
				my ($node) = @_;

				if ($node eq $end) {
					$total++;

					return;
				}

				if (uc($node) ne $node) {
					$seen{$node}++;
				}

				for my $n (grep { $seen{$_} == 0 } sort { $a cmp $b } @{$edges->{$node}}) {
					$fn->($n);
				}

				if (uc($node) ne $node) {
					$seen{$node}--;
				}
			};

			$fn->($start);

			return $total;
		});
}

sub solveTwo {
	my ($lines) = @_;

	return solve(
		$lines,
		sub {
			my ($edges, $start, $end) = @_;

			my $total = 0;
			my %seen = map { $_ => 0 } keys %$edges;

			my $doubleSeen = undef;

			my $fn;
			$fn = sub {
				my ($node) = @_;

				if ($node eq $end) {
					$total++;

					return;
				}

				my $amDoubleSeen = 0;

				if ($seen{$node} > 0) {
					if (defined $doubleSeen) {
						return;
					}

					$doubleSeen = $node;
					$amDoubleSeen = 1;
				}

				if (uc($node) ne $node) {
					$seen{$node}++;
				}

				for my $n (sort { $a cmp $b } @{$edges->{$node}}) {
					$fn->($n);
				}


				if (uc($node) ne $node) {
					if ($amDoubleSeen) {
						$doubleSeen = undef;

					} else {
						$seen{$node}--;
					}
				}
			};

			$fn->($start);

			return $total;
		});
}

main(\&solveOne, \&solveTwo);
