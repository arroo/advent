#!/usr/bin/env perl

use warnings;
use strict;

use X11::Protocol;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub solveOne {
	my ($lines) = @_;

	my $border_w = 10;
	my $height = 5 * scalar @$lines;
	my $width  = 5 * length $lines->[0];
	my ($x_coord, $y_coord) = (10, 10);

	my $x = X11::Protocol->new();
	my $win = $x->new_rsrc;
	$x->CreateWindow($win, $x->root, 'InputOutput',
		$x->root_depth, 'CopyFromParent',
		($x_coord, $y_coord), $width,
		$height, $border_w);

	sleep 60;

	return -1;
}

sub solveTwo {
	my ($lines) = @_;

	return -1;
}

main(\&solveOne, \&solveTwo);
