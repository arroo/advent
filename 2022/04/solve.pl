#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

# returns 1 if $check is within $base
sub contained {
	my ($base, $check) = @_;

	my ($sb, $eb) = @$base;
	my ($sc, $ec) = @$check;


	if ($sb <= $sc and $ec <= $eb) {
		return 1;
	}

	return 0;
}

sub solveOne {
	my ($lines) = @_;

	return reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		my ($s1, $e1, $s2, $e2) = $line =~ /^(\d+)-(\d+),(\d+)-(\d+)$/;

		#print Dumper([$s1, $e1, $s2, $e2]);
		# find the higher end
		my @one = ($s1, $e1);
		my @two = ($s2, $e2);

		if (contained(\@one, \@two) or contained(\@two, \@one)) {
			$acc++;
		}

		return $acc;
	},
	$lines,
	0,
	);
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
