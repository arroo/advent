#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub genPoints {
	my ($start, $end) = @_;

	my ($sX, $sY) = @$start;
	my ($eX, $eY) = @$end;

	if ($sX != $eX and $sY != $eY) {
		die "bad pair of points: " . Dumper($start, $end);
	}

	my %out;

	if ($sX == $eX) {
		my $s = $sY < $eY ? $sY : $eY;
		my $e = $sY < $eY ? $eY : $sY;

		for my $i ($s .. $e) {
			$out{"$sX,$i"} = undef;
		}

	} elsif ($sY == $eY) {
		my $s = $sX < $eX ? $sX : $eX;
		my $e = $sX < $eX ? $eX : $sX;

		for my $i ($s .. $e) {
			$out{"$i,$sY"} = undef;
		}

	} else {
		die "not in a line: " . Dumper($start, $end);
	}

	return \%out;
}

sub key {
	return join(',', @_);
}

sub fall {
	my ($map, $point, $lowest) = @_;

	my ($x, $y) = @$point;

	while (1) {

		# will fall forever
		if ($y > $lowest) {
			return [undef, $y];
		}

		# look down
		if (not exists $map->{key($x, $y+1)}) {
			$y++;
			next;
		}

		# look down-left
		if (not exists $map->{key($x-1, $y+1)}) {
			$x--;
			$y++;
			next;
		}

		# look down-right
		if (not exists $map->{key($x+1, $y+1)}) {
			$x++;
			$y++;
			next;
		}

		# grain has come to a rest
		return [$x, $y];
	}
}

sub fall2 {
	my ($map, $point, $lowest) = @_;

	my ($x, $y) = @$point;

	while (1) {

		# always floor
		$map->{key($x, $lowest+2)} = undef;
		$map->{key($x+1, $lowest+2)} = undef;
		$map->{key($x-1, $lowest+2)} = undef;

		# will fall forever
		if ($y > $lowest) {
			#return [undef, $y];
		}

		# look down
		if (not exists $map->{key($x, $y+1)}) {
			$y++;
			next;
		}

		# look down-left
		if (not exists $map->{key($x-1, $y+1)}) {
			$x--;
			$y++;
			next;
		}

		# look down-right
		if (not exists $map->{key($x+1, $y+1)}) {
			$x++;
			$y++;
			next;
		}

		# grain has come to a rest
		return [$x, $y];
	}
}

sub solveOne {
	my ($lines) = @_;

	my $sandOrigin = [500, 0];
	my $lowest = -1;

	my $paths= reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		my @path = split / -> /, $line;

		my @coords = map { [split /,/] } @path;

		for my $i (1 .. $#coords) {
			my $p = genPoints($coords[$i-1], $coords[$i]);
			for my $k (keys %$p) {
				my ($x, $y) = split /,/, $k;

				$lowest = max($lowest, $y);
				$acc->{$k} = undef;
			}
		}

		return $acc;
	},
	$lines,
	{},
	);

	my $restingSand = 0;

	while (1) {

		# fall down
		my $next = fall($paths, $sandOrigin, $lowest);

		my ($x, $y) = @$next;

		# check if at lowest point
		if ($y > $lowest) {
			last;
		}

		$restingSand++;
		$paths->{key($x, $y)} = undef;
	}

	print Dumper($paths, $lowest, $restingSand);
}

sub solveTwo {
	my ($lines) = @_;

	my $sandOrigin = [500, 0];
	my $lowest = -1;

	my $paths= reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		my @path = split / -> /, $line;

		my @coords = map { [split /,/] } @path;

		for my $i (1 .. $#coords) {
			my $p = genPoints($coords[$i-1], $coords[$i]);
			for my $k (keys %$p) {
				my ($x, $y) = split /,/, $k;

				$lowest = max($lowest, $y);
				$acc->{$k} = undef;
			}
		}

		return $acc;
	},
	$lines,
	{},
	);

	my $restingSand = 0;

	while (1) {

		# fall down
		my $next = fall2($paths, $sandOrigin, $lowest);

		my ($x, $y) = @$next;

		$restingSand++;
		$paths->{key($x, $y)} = undef;

		if ($y == 0) {
			last;
		}
	}

	print Dumper($paths, $lowest, $restingSand);
}

main(\&solveOne, \&solveTwo);
