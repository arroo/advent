#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub foldLeft {
	my ($paper, $crease) = @_;

	# assume sparse
	for my $pos (keys %$paper) {
		my ($x, $y) = split /,/, $pos;

		# check if right of fold
		if ($x > $crease) {
			delete $paper->{$pos};

			my $newPos = join(',', 2*$crease - $x , $y);

			$paper->{$newPos} = undef;
		}
	}
}

sub foldUp {
	my ($paper, $crease) = @_;

	# assume sparse
	for my $pos (sort keys %$paper) {
		my ($x, $y) = split /,/, $pos;

		# check if below fold
		if ($y > $crease) {

			delete $paper->{$pos};

			my $newPos = join(',', $x, 2*$crease - $y);

			$paper->{$newPos} = undef;
		}
	}
}

sub fold {
	my ($paper, $axis, $crease) = @_;

	if ($axis eq 'x') {
		foldLeft($paper, $crease);
	} elsif ($axis eq 'y') {
		foldUp($paper, $crease);
	}
}

sub display {
	my ($paper) = @_;

	my @out;

	# find max dimensions
	my $maxX = max(map { (split /,/, $_)[0] } keys %$paper);
	my $maxY = max(map { (split /,/, $_)[1] } keys %$paper);

	for my $y (0 .. $maxY) {

		my $line;
		for my $x (0 .. $maxX) {
			$line .= exists $paper->{"$x,$y"} ? '#' : ' ';
		}

		push @out, $line;
	}

	return join("\n", @out);
}

sub process {
	my ($lines) = @_;

	my @ins;
	my %paper;

	for my $line (@$lines) {

		if (my ($x, $y) = $line =~ /^(\d+),(\d+)$/) {
			$paper{"$x,$y"} = undef;

		} elsif (my ($axis, $crease) = $line =~ /^fold along ([xy])=(\d+)$/) {
			push @ins, [$axis, $crease];
		}
	}

	return (\%paper, \@ins);
}

sub solveOne {
	my ($lines) = @_;

	my ($paper, $ins) = process($lines);

	fold($paper, @{$ins->[0]});

	return scalar keys %$paper;
}

sub solveTwo{
	my ($lines) = @_;

	my ($paper, $ins) = process($lines);

	fold($paper, @{$ins->[$_]}) for (0 .. $#$ins);

	return display($paper);
}

main(\&solveOne, \&solveTwo);
