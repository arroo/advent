#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);
use AOC::Text qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub parse {
	my ($lines) = @_;

	return reduce(
		sub {
			my ($acc, $line, $i) = @_;

			my ($posStr, $velStr) = split / @ /, $line;

			my ($px, $py, $pz) = split /, /, $posStr;
			my ($vx, $vy, $vz) = split /, /, $velStr;

			$acc->{"$px,$py,$pz"} = [$vx, $vy, $vz];

			return $acc;
		},
		$lines,
		{},
	);
}

my $min = 200000000000000;
my $max = 400000000000000;

sub solveOne {
	my ($lines) = @_;

	my $parsed = parse($lines);

	if (0) {
		($min, $max) = (7, 27);
	}

	print Dumper($parsed, $min, $max);

	my $res = 0;

	my %seen;
	for my $hail (keys %$parsed) {
		my ($x0, $y0, $z0) = split /,/, $hail;

		my $velHail = $parsed->{$hail};
		my ($vx0, $vy0, $vz0) = @$velHail;

		my ($x1, $y1, $z1) = ($x0 + $vx0, $y0 + $vy0, $z0 + $vz0);


		for my $other (keys %$parsed) {
			next if ($hail eq $other);

			next if (exists $seen{"$hail:$other"});
			$seen{"$other:$hail"} = undef;

			my ($ox0, $oy0, $oz0) = split /,/, $other;

			my ($vx1, $vy1, $vz1) = @{$parsed->{$other}};
			my ($x3, $y3, $z3) = ($ox0+$vx1, $oy0+$vy1, $oz0+$vz1);

			my $intersection = lineLineIntersection($x0, $y0, $x1, $y1, $ox0, $oy0, $x3, $y3);
			if (not defined $intersection) {
				#print "$hail and $other do not intersect\n";

				next;
			}

			my ($ix, $iy) = @$intersection;

			unless ($min <= $ix and $ix <= $max and
				$min <= $iy and $iy <= $max) {

				#print "$hail and $other intersect outside boundary ($ix,$iy)\n";
				next;
			}


			print "$hail and $other cross at ($ix,$iy)\n";

			my $dotBase = dotProd([$x1, $y1], [$x0-$ix, $y0-$iy]);
			my $dotOther = dotProd([$x3, $y3], [$ox0-$ix, $oy0-$iy]);
			#print "\tdot(base):$dotBase dot(other):$dotOther\n";

			unless ($dotBase > 0 and $dotOther > 0) {
				next;
			}

			$res++;
		}
	}

	# 7025 too low
	return $res;
}

sub solveTwo {
	my ($lines) = @_;
}

main(\&solveOne, \&solveTwo);
