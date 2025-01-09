#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my %costs = (
	'A' => 3,
	'B' => 1,
);

sub parse {
	my ($lines) = @_;

	return reduce(
		sub {
			my ($acc, $line) = @_;

			if ($line eq '') {
				push @$acc, {};

			} elsif (my ($button, $dX, $dY) = $line =~ m/\AButton ([AB]): X\+(\d+), Y\+(\d+)\z/) {
				$acc->[-1]{$button} = [$dX,$dY];

			} elsif (my ($x, $y) = $line =~ m/\APrize: X=(\d+), Y=(\d+)\z/) {
				$acc->[-1]{'Prize'} = [$x, $y];

			} else {
				die "unparseable line: $line\n";
			}

			return $acc;
		},
		$lines,
		[{}],
	);
}

sub pressesToPrize {
	my ($machine) = @_;

	my %soln;
	print Dumper($machine);

	my ($xa, $ya) = @{$machine->{'A'}};
	my ($xb, $yb) = @{$machine->{'B'}};
	my ($xp, $yp) = @{$machine->{'Prize'}};

	print Dumper($xa, $ya,$xb, $yb,$xp, $yp);
	for my $a (1 .. 100) {
		for my $b (1 .. 100) {

			if ($a * $xa + $b * $xb == $xp and $a * $ya + $b * $yb == $yp) {
				return {'A'=>$a,'B'=>$b};
			}
		}
	}

	return undef;

	return \%soln;
}

sub solveOne {
	my ($lines) = @_;

	my $machines = parse($lines);

	my $tokens = 0;
	for my $machine (@$machines) {

		my $soln = pressesToPrize($machine);
		next unless (defined $soln);

		# only allow 100 presses per button
		next if (scalar grep { $_ > 100 } values %$soln);

		print Dumper($soln);

		for my $button (keys %$soln) {
			$tokens += $soln->{$button} * $costs{$button};
		}

		last;
	}

	#print Dumper($machines);
	return $tokens;
}

sub solveTwo {
	my ($lines) = @_;

	return -2;
}

main(\&solveOne, \&solveTwo);
