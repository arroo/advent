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

	return reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		if (my ($n, $robots) = $line =~ /^Blueprint (\d+): (.+)$/) {
			my @costs = split /(?<=\.) /, $robots;
			#print Dumper(\@costs);

			my %thing;

			for my $l (@costs) {
				chop $l;
				my ($kind) = $l =~ /^Each (\S+) /;
				#print "$kind\n";

				$thing{$kind} = {};

				my @c = $l =~ /(\d+ \S+)/g;
				for my $ll (@c) {
					my ($amount, $resource) = split / /, $ll;

					$thing{$kind}{$resource} = $amount;
				}

			}


			#die Dumper(\%thing);

			push @$acc, \%thing;

		} else {
			die "unparseable line: $line\n";
		}

		return $acc;
	},
	$lines,
	[],
	);
}

sub solveOne {
	my ($lines) = @_;

	my $something = parse($lines);

	my $timeLimit = 24;

	my %have = ('ore' => 1);

	return Dumper($something);
}

sub solveTwo {
	my ($lines) = @_;

	return reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		my ($s1, $e1, $s2, $e2) = $line =~ /^(\d+)-(\d+),(\d+)-(\d+)$/;

		if ($s1 > $e1 or $s2 > $e2) {
			die "$line does not follow assumptions";
		}

		if (
			$s1 <= $s2 and $s2 <= $e1 or
			$s1 <= $e2 and $e2 <= $e1 or
			$s2 <= $s1 and $s1 <= $e2 or
			$s2 <= $e1 and $e1 <= $e2
		) {
			$acc++;
		}

		return $acc;
	},
	$lines,
	0,
	);
}

main(\&solveOne, \&solveTwo);
