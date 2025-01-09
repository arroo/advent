#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my $flipflop = '%';
my $conjunction = '&';
my $broadcast = 'broadcaster';
my $button = 'button';

my $target = 'rx';

my $hi = 'high';
my $lo = 'low';

my $on = 1;
my $off = 0;

sub parse {
	my ($lines) = @_;

	my $modules = reduce(
		sub {
			my ($acc, $line, $i) = @_;

			my ($module, @dst) = split /(?: ->|,) /, $line;

			if ($module ne $broadcast) {
				my $type = substr($module, 0, 1, '');
				if ($type eq $flipflop) {
					$acc->{$module} = [$type, $off, \@dst];
				} elsif ($type eq $conjunction) {
					$acc->{$module} = [$type, {}, \@dst];
				} else {
					die;
				}
			} else {
				$acc->{$module} = [$broadcast, $lo, \@dst];
			}

			return $acc;
		},
		$lines,
		{ $button => [$button, undef, [$broadcast]] },
	);

	# set all conjunction modules to low memory for all inputs
	for my $from (keys %$modules) {
		for my $to (@{$modules->{$from}[2]}) {
			next unless (defined $modules->{$to} and
				$modules->{$to}[0] eq $conjunction);

			$modules->{$to}[1]{$from} = $lo;
		}
	}

	return $modules;
}

sub solveOne {
	my ($lines) = @_;

	my $parsed = parse($lines);

	my %sent;

	for (1 .. 1_000) {
		my @queue = ([$button, $lo, undef]);
		while (scalar @queue) {
			my $q = shift @queue;
			my ($module, $signal, $from) = @$q;
			next unless (defined $parsed->{$module});

			my ($type, $state, $dst) = @{$parsed->{$module}};
			my $outgoing;

			if ($type eq $flipflop) {
				next unless ($signal eq $lo);

				($parsed->{$module}[1], $outgoing) = $state == $on ? ($off, $lo) : ($on, $hi);

			} elsif ($type eq $conjunction) {
				$parsed->{$module}[1]{$from} = $signal;

				$outgoing = $lo;
				for my $m (values %{$parsed->{$module}[1]}) {
					if ($m eq $lo) {
						$outgoing = $hi;
						last;
					}
				}

			} elsif ($type eq $broadcast) {
				$outgoing = $signal;

			} elsif ($type eq $button) {
				$outgoing = $signal;

			} else {
				die "unknown module type\n";
			}

			for my $to (@$dst) {
				print "$module -$outgoing-> $to\n";
				$sent{$outgoing}++;
				push @queue, [$to, $outgoing, $module];
			}
		}
	}

	return prod(values %sent);
}

sub solveTwo {
	my ($lines) = @_;

	my $parsed = parse($lines);

	# assume rx fed by exactly 1 conjunction module
	my ($targetFeeder) = grep { scalar grep { $_ eq $target } @{$parsed->{$_}[2]} } keys %$parsed;

	# assume rf feeder fed by some number of conjunction modules
	my %feederFeeders = map { $_ => undef } grep { scalar grep { $_ eq $targetFeeder } @{$parsed->{$_}[2]} } keys %$parsed;

	my %seen;

	for (my $i = 1; 1; $i++) {

		my @queue = ([$button, $lo, undef]);
		while (scalar @queue) {
			my $q = shift @queue;
			my ($module, $signal, $from) = @$q;
			next unless (defined $parsed->{$module});

			return $i if ($module eq $target and $signal eq $lo);

			if ($module eq $targetFeeder and $signal eq $hi) {
				$seen{$from}++;

				if (not defined $feederFeeders{$from}) {
					$feederFeeders{$from} = $i;
				}

				return lcm (values %feederFeeders) unless (scalar grep { not defined $_ } values %feederFeeders);
			}

			my ($type, $state, $dst) = @{$parsed->{$module}};
			my $outgoing;

			if ($type eq $flipflop) {
				next unless ($signal eq $lo);

				($parsed->{$module}[1], $outgoing) = $state == $on ? ($off, $lo) : ($on, $hi);

			} elsif ($type eq $conjunction) {
				$parsed->{$module}[1]{$from} = $signal;

				$outgoing = $lo;
				for my $m (values %{$parsed->{$module}[1]}) {
					if ($m eq $lo) {
						$outgoing = $hi;
						last;
					}
				}


			} elsif ($type eq $broadcast) {
				$outgoing = $signal;

			} elsif ($type eq $button) {
				$outgoing = $signal;

			} else {
				die "unknown module type\n";
			}

			for my $to (@$dst) {
				#print "$module -$outgoing-> $to\n";
				push @queue, [$to, $outgoing, $module];
			}
		}
	}

	return -1;
}

main(\&solveOne, \&solveTwo);
