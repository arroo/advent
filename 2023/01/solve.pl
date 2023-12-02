#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my $digits = sub {
	my @in = @_;

	my %out;

	for my $i (0 .. $#in) {
		$out{$in[$i]} = $i;
	}

	return \%out;
}->(qw/zero one two three four five six seven eight nine/);


sub solveOne {
	my ($lines) = @_;

	return reduce(
		sub {
			my ($acc, $line) = @_;

			$line =~ s/[^0-9]//g;

			my @digits = split //, $line;

			my $calibrationValue = 10 * $digits[0] + $digits[-1];

			return $acc+$calibrationValue;
		},
		$lines,
		0,
	);
}

sub solveTwo {
	my ($lines) = @_;

	my $toDigit = sub {
		my ($in) = @_;

		if ($in =~ m/[0-9]/) { return $in }

		return $digits->{$in} // die "invalid digit: $in\n";
	};

	return reduce(
		sub {
			my ($acc, $line) = @_;

			my $digits = reduce(
				sub {
					my ($acc, $d) = @_;

					push(@$acc, $toDigit->($d));

					return $acc;
				},
				[$line =~ m/([0-9]|one|two|three|four|five|six|seven|eight|nine|zero)/g],
				[],
			);

			return $acc + 10 * $digits->[0] + $digits->[-1];
		},
		$lines,
		0,
	);
}

main(\&solveOne, \&solveTwo);
