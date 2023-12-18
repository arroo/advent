#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my $up = 'U';
my $down = 'D';
my $left = 'L';
my $right = 'R';

sub parse {
	my ($lines) = @_;

	my @dirs = ($right, $down, $left, $up);

	return reduce(
		sub {
			my ($acc, $line, $i) = @_;

			if (my ($dir, $count, $count2, $dir2) = $line =~ /\A([UDLR]) (\d+) \(#([0-9a-f]{5})([0-3])\)\z/) {

				push @$acc, [$dir, $count, $dirs[$dir2], hex($count2)];

			} else {
				die "unparseable line ($i): $line\n";
			}

			return $acc;
		},
		$lines,
		[],
	);
}

sub goDir {
	my ($x, $y, $dir, $count) = @_;

	$count //= 1;

	if ($dir eq $up) {
		return ($x, $y-$count);
	}

	if ($dir eq $down) {
		return ($x, $y+$count);
	}

	if ($dir eq $left) {
		return ($x-$count,$y);
	}

	if ($dir eq $right) {
		return ($x+$count,$y);
	}
}

sub printDitch {
	my ($dug, $minX, $minY, $maxX, $maxY, $inside) = @_;

	for my $y ($minY .. $maxY) {
		for my $x ($minX .. $maxX) {

			if (exists $inside->{"$x,$y"}) {
				print '?';

			} elsif (exists $dug->{"$x,$y"}) {
				print '#';

			} else {
				print '.';
			}
		}

		print "\n";
	}

}

sub solveOne {
	my ($lines) = @_;

	my $parsed = parse($lines);

	return solve($parsed);
}

sub solve {
	my ($instructions) = @_;

	# https://www.reddit.com/r/adventofcode/comments/18l2tap/2023_day_18_the_elves_and_the_shoemaker/kdv5bzi/

	my $total = 0;
	my ($x,$y) = (0,0);
	my @lines;
	for my $i (0 .. $#$instructions) {
		my ($nx, $ny) = goDir($x, $y, @{$instructions->[$i]}[0,1]);

		$total += $instructions->[$i][1];

		push @lines, [[$x,$y],[$nx,$ny]];
		($x,$y) = ($nx,$ny);
	}

	die "not at origin ($x, $y)\n" unless ($x == 0 and $y == 0);

	# why only half the perimeter?
	$total /= 2;

	# ??
	$total++;

	# shoelace algo
	for my $line (@lines) {
		my ($s, $e) = @$line;
		$total += determinant(@$s, @$e) / 2;
	}

	return $total;
}

sub solve2 {
	my ($parsed) = @_;


	my ($x, $y) = (0, 0);
	my ($minX, $minY) = (0, 0);
	my ($maxX, $maxY) = (0, 0);
	my %dug;

	for my $mvmt (@$parsed) {
		my ($dir, $count) = @$mvmt;

		for my $j (1 .. $count) {
			($x,$y) = goDir($x, $y, $dir);

			$maxX = $maxX < $x ? $x : $maxX;
			$maxY = $maxY < $y ? $y : $maxY;
			$minX = $minX > $x ? $x : $minX;
			$minY = $minY > $y ? $y : $minY;

			$dug{"$x,$y"} = undef;
		}
	}

	print Dumper($minX, $minY, $maxX, $maxY);

	my %inside;

	my $total = 0;
	for my $y ($minY .. $maxY) {

		my $aboveY = $y-1;

		my $inside = 0;
		# start on outside
		for my $x ($minX .. $maxX) {

			if (exists $dug{"$x,$y"}) {
				if (exists $dug{"$x,$aboveY"}) {
				$inside = ($inside + 1) % 2;}
			} elsif ($inside) {
				$inside{"$x,$y"} = undef;
			}

		}
	}

	printDitch(\%dug, $minX, $minY, $maxX, $maxY, \%inside);
	return (scalar keys %inside) + (scalar keys %dug);
	return Dumper(\%dug, $total);
}

sub solveTwo {
	my ($lines) = @_;

	my $parsed = parse($lines);

	my @reproc = map { [ @$_[2,3]]} @$parsed;

	return solve(\@reproc);
}


main(\&solveOne, \&solveTwo);
