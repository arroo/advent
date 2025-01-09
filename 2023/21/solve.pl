#!/usr/bin/env perl

use warnings;
use strict;

use Time::HiRes qw(usleep);
use POSIX qw(floor);

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);
use AOC::Text qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my $start = 'S';
my $rock  = '#';
my $plot  = '.';

sub neighbours {
	my ($x, $y) = @_;

	return (
		[$x,$y-1],
		[$x,$y+1],
		[$x-1,$y],
		[$x+1,$y],
	);
}

sub walkableNeighbours {
	my ($x, $y, $grid) = @_;

	return [grep { defined $grid->{"$_->[0],$_->[1]"} and $grid->{"$_->[0],$_->[1]"} ne $rock } neighbours($x, $y)];
}

sub walkableNeighboursStr {
	my ($node, $grid) = @_;

	my @neighbours;
	for my $pair (@{walkableNeighbours((split /,/, $node), $grid)}) {
		push @neighbours, join(',', @$pair);
	}

	return \@neighbours;
}

sub solveGrid {
	my ($grid, $steps, $start) = @_;

	my %walkable = ($start => undef);
	for (1 .. $steps) {
		my %newWalkable;
		for my $node (keys %walkable) {
			for my $n (@{walkableNeighboursStr($node, $grid)}) {
				$newWalkable{$n} = undef;
			}
		}

		%walkable = %newWalkable;
	}

	return scalar keys %walkable;
}

sub solveOne {
	my ($lines) = @_;

	my $grid = parseGrid($lines);

	my ($start) = grep { $grid->{$_} eq $start } keys %$grid;

	return solveGrid($grid, 64, $start);

	my %walkable = ($start => undef);
	for (1 .. 64) {
		my %newWalkable;
		for my $node (keys %walkable) {
			for my $n (@{walkableNeighboursStr($node, $grid)}) {
				$newWalkable{$n} = undef;
			}
		}

		%walkable = %newWalkable;
	}

	return scalar keys %walkable;
}

sub walkableWraparoundNeighboursStr {
	my ($node, $grid, $maxX, $maxY) = @_;

	my ($x, $y) = split /,/, $node;

	my @neighbours;

	# up
	my $up = join(',', $x, $y-1);
	push @neighbours, defined $grid->{$up} ? $up : "$x,$maxY";

	my $down = join(',', $x, $y+1);
	push @neighbours, defined $grid->{$down} ? $down : "$x,0";

	my $left = join(',', $x-1, $y);
	push @neighbours, defined $grid->{$left} ? $left : "$maxX,$y";

	my $right = join(',', $x+1, $y);
	push @neighbours, defined $grid->{$right} ? $right : "0,$y";

	

	return \@neighbours;
}

sub neighbours2 {
	my ($node, $grid, $maxX, $maxY) = @_;

	my ($x, $y) = split /,/,$node;

	my ($up, $down, $left, $right) = ($y-1,$y+1,$x-1,$x+1);

	my %out;

	my $upKey = join(',', $x, $up % $maxY);
	if (defined $grid->{$upKey} and $grid->{$upKey} ne $rock) {
		$out{"$x,$up"} = [$x, $up % $maxY];
	}

	my $downKey = join(',', $x, $down % $maxY);
	if (defined $grid->{$downKey} and $grid->{$downKey} ne $rock) {
		$out{"$x,$down"} = [$x, $down % $maxY];
	}

	my $leftKey = join(',', $left % $maxX, $y);
	if (defined $grid->{$leftKey} and $grid->{$leftKey} ne $rock) {
		$out{"$left,$y"} = [$x % $maxX, $y];
	}

	my $rightKey = join(',', $right % $maxX, $y);
	if (defined $grid->{$rightKey} and $grid->{$rightKey} ne $rock) {
		$out{"$right,$y"} = [$x % $maxX, $y];
	}

	return \%out;
}

sub neighbours3 {
	my ($node, $grid, $maxX, $maxY) = @_;

	my ($x, $y) = split /,/,$node;

	my ($up, $down, $left, $right) = ($y-1,$y+1,$x-1,$x+1);

	my @out;

	my $upKey = join(',', $x, $up % $maxY);
	if (defined $grid->{$upKey} and $grid->{$upKey} ne $rock) {
		push @out, "$x,$up";
	}

	my $downKey = join(',', $x, $down % $maxY);
	if (defined $grid->{$downKey} and $grid->{$downKey} ne $rock) {
		push @out, "$x,$down";
	}

	my $leftKey = join(',', $left % $maxX, $y);
	if (defined $grid->{$leftKey} and $grid->{$leftKey} ne $rock) {
		push @out, "$left,$y";
	}

	my $rightKey = join(',', $right % $maxX, $y);
	if (defined $grid->{$rightKey} and $grid->{$rightKey} ne $rock) {
		push @out, "$right,$y";
	}

	return \@out;
}

sub neighbours4 {
	my ($node, $grid, $maxX, $maxY) = @_;

	my @out;
	for my $dir (neighbours(split /,/, $node)) {
		my ($x, $y) = @$dir;
		my $key = join(',', $x % $maxX, $y % $maxY);

		push @out, "$x,$y" unless ($grid->{$key} eq $rock);
	}

	return \@out;
}

sub allNeighbours {
	my ($nodes, $grid, $maxX, $maxY) = @_;

	my %neighbours;

	for my $node (@$nodes) {
		for my $n (@{neighbours4($node, $grid, $maxX, $maxY)}) {
			$neighbours{$n} = undef;
		}
	}

	return [keys %neighbours];
}

sub allUnseenNeighbours {
	my ($nodes, $seen, $grid, $maxX, $maxY) = @_;

	my $neighbours = allNeighbours($nodes, $grid, $maxX, $maxY);
	return [ grep { not exists $seen->{$_} } @$neighbours ];
}

sub working {
	my ($grid, $count, $maxX, $maxY) = @_;

	my ($start) = grep { $grid->{$_} eq $start } keys %$grid;

	my @totals = (1,1);
	my @seen = ({$start => undef}, {});

	for my $step (1 .. $count) {
		my $seen = shift @seen;

		print Dumper($seen);

		my $newNeighbours = allUnseenNeighbours([keys %$seen], $seen[0], $grid, $maxX, $maxY);

		@seen = ({ map { $_ => undef } @$newNeighbours }, $seen);

		$totals[($step+1)%2] += scalar @$newNeighbours;
	}

	return $totals[-1];
}

sub solveTwo {
	my ($lines) = @_;

	my $grid = parseGrid($lines);

	my ($start) = grep { $grid->{$_} eq $start } keys %$grid;

	my ($maxX, $maxY);
	for my $node (keys %$grid) {
		my ($x, $y) = split /,/, $node;
		$maxX = (not defined $maxX or $x > $maxX) ? $x : $maxX;
		$maxY = (not defined $maxY or $y > $maxY) ? $y : $maxY;
	}

	$maxX++;
	$maxY++;

	# assert square
	if ($maxY != $maxX) {
		die "not square: ($maxX, $maxY)\n";
	}

	my $size = $maxX; # either since it's square

	# assert odd size
	if ($maxX % 2 != 1 or $maxY % 2 != 1) {
		die "not odd grid: ($maxX, $maxY)\n";
	}

	# assert start in middle
	my ($sx, $sy) = split /,/, $start;
	if ($sx + $sx + 1 != $maxX or
		$sy + $sy + 1 != $maxY) {

		die "not starting in middle: ($start) ($maxX,$maxY)\n";
	}

	my $count = 26501365;
	my $steps = $count;

	# assert something
	if ($steps % $size != floor($size / 2)) {
		die "something\n";
	}

	my $total = 0;

	my $gridWidth = floor($steps / $size) - 1;
	my $sizeMO = $size - 1;

	{
		# count of odd-stepped grids * odd steps
		my $odd  = (floor($gridWidth/2) * 2 + 1) ** 2;
		my $oddPoints = solveGrid($grid, $size *2+1, $start);
		$total += $odd * $oddPoints;

		# count of even-stepped grids * even steps
		my $even = (floor(($gridWidth + 1) / 2) * 2) ** 2;
		my $evenPoints = solveGrid($grid, $size *2, $start);
		$total += $even * $evenPoints;
	}

	{

		# 4 corners
		my $cornerT = solveGrid($grid, $size-1, "$sx,$sizeMO");
		my $cornerR = solveGrid($grid, $size-1, "0,$sy");
		my $cornerB = solveGrid($grid, $size-1, "$sx,0");
		my $cornerL = solveGrid($grid, $size-1, "$sizeMO,$sy");

		$total += $cornerT + $cornerR + $cornerB + $cornerL;
	}

	{
		# small fill corners
		my $fill = floor($size / 2) - 1;
		my $smallTR = solveGrid($grid, $fill, "0,$sizeMO");
		my $smallTL = solveGrid($grid, $fill, "$sizeMO,$sizeMO");
		my $smallBR = solveGrid($grid, $fill, "0,0");
		my $smallBL = solveGrid($grid, $fill, "$sizeMO,0");

		$total += ($gridWidth + 1) * ($smallTR + $smallTL + $smallBR + $smallBL);
	}

	{
		# big fill corners
		my $fill = floor(3 * $size / 2) - 1;
		my $largeTR = solveGrid($grid, $fill, "0,$sizeMO");
		my $largeTL = solveGrid($grid, $fill, "$sizeMO,$sizeMO");
		my $largeBR = solveGrid($grid, $fill, "0,0");
		my $largeBL = solveGrid($grid, $fill, "$sizeMO,0");

		$total += $gridWidth * ($largeTR + $largeTL + $largeBR + $largeBL);
	}

	return $total;

	my @totals = (1, 1);
	my @seen = ({$start=>undef}, {});

	my %lastSeen = ();


	#$count = 5000;

	#return working($grid, $count, $maxX, $maxY);

	my %totals;

	for my $step (1 .. $count) {

		my $bucket = ($step+1) % 2;
		my $last   = ($bucket + 1) % 2;

		my $newNeighbours = allUnseenNeighbours([keys %{$seen[$bucket]}], $seen[$last], $grid, $maxX, $maxY);
		#print Dumper($newNeighbours);

		$seen[$last] = { map { $_ => undef } @$newNeighbours };
		#$seen[$bucket] = { map { $_ => undef } @$newNeighbours };

		#print "putting new into $bucket\n";

		#print Dumper(\@seen);

		my $n = scalar @$newNeighbours;

		$totals[$bucket] += scalar @$newNeighbours;
		#print "$n\n";

		#$totals{$n}++;
		#if ($step % 1_000 == 0) {
		#	print Dumper(\%totals);
		#}

		#last if ($step == 2);
		#push @totals, (shift @totals) + scalar @$newNeighbours;

		#system 'clear';
		#printGrid($grid, $seen[$bucket], $seen[$next]);
		#print Dumper(\@totals);
		#usleep(500000);
	}

	#return $totals[-1];
	return Dumper(\@totals);

	for my $step (1 .. $count) {

		my $lastSeen = shift @seen;
		my %thisSeen;

		for my $node (keys %lastSeen) {
			my $neighs = neighbours4($node, $grid, $maxX, $maxY);

			print "$node neighbours: (@$neighs) not seen ";

			my @notAlreadyStepped = grep { not exists $seen[0]{$_} } @$neighs;
			print "(@notAlreadyStepped)\n";
			for my $n (@notAlreadyStepped) {
				$thisSeen{$n} = undef;
			}
		}

		push @totals, (shift @totals) + (keys %thisSeen);
		print Dumper(\@totals);
		push @seen, \%thisSeen;
	}


	return $totals[-1];
}

sub printGrid {
	my ($grid, $new, $old) = @_;

	for (my $y = 0; exists $grid->{"0,$y"}; $y++) {
		for (my $x = 0; exists $grid->{"$x,$y"}; $x++) {

			my $key = "$x,$y";
			if (exists $old->{$key}) {
				print coloured('red', $grid->{$key});

			} elsif (exists $new->{$key}) {
				print coloured('green', $grid->{$key});

			} else {
				print $grid->{"$x,$y"};
			}
		}

		print "\n";
	}
}

main(\&solveOne, \&solveTwo);
