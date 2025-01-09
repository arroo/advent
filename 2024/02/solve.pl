#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub sameArrs {
	my ($A, $B) = @_;

	return unless ($#$A == $#$B);

	for my $i (0 .. $#$A) {
		return unless ($A->[$i] eq $B->[$i]);
	}

	return 1;
}

sub increasing {
	my ($arr) = @_;

	for my $i (1 .. $#$arr) {
		return if ($arr->[$i] <= $arr->[$i-1]);
	}

	return 1;
}

sub maxSpread {
	my ($arr) = @_;

	my $spread;
	for my $i (1 .. $#$arr) {

		my $diff = abs($arr->[$i] - $arr->[$i-1]);

		if (not defined $spread or $diff > $spread) {
			$spread = $diff;
		}
	}

	return $spread;
}

sub safe {
	my ($arr) = @_;

	if (not increasing($arr) and not increasing([reverse @$arr])) {

		#print Dumper("not monotonic", $arr);

		return;
	}

	my $spread = maxSpread($arr);
	#print Dumper("spread: $spread", $arr);
	if ($spread < 1 or $spread > 3) {
		return;
	}

	return 1;
}

sub solveOne {
	my ($lines) = @_;

	my $lists = reduce(
		sub {
			my ($acc, $line) = @_;

			my @reports = split / /, $line;

			return $acc + (safe(\@reports) // 0);
		},
		$lines,
		0,
	);

}

sub solveTwo {
	my ($lines) = @_;

	return reduce(
		sub {
			my ($acc, $line) = @_;

			my @reports = split / /, $line;

			# safe as-is
			if (safe(\@reports)) {
				return $acc + 1;
			}

			# try with numbers missing
			for my $i (0 .. $#reports) {
				my $item = splice(@reports, $i, 1);

				if (safe(\@reports)) {
					return $acc + 1;
				}

				splice(@reports, $i, 0, $item);
			}

			# unsafe
			return $acc;
		},
		$lines,
		0,
	);
}

main(\&solveOne, \&solveTwo);
