#!/usr/bin/env perl

use warnings;
use strict;

use Time::HiRes qw(usleep);

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

			# do parsing...
			push @$acc, $line;

			return $acc;
		},
		$lines,
		[],
	);
}

my $up    = '^';
my $down  = 'v';
my $left  = '<';
my $right = '>';

my $empty = '.';
my $mirrorL = '\\';
my $mirrorR = '/';
my $splitV = '|';
my $splitH = '-';

my %move = (
	$up    => sub { return ($_[0], $_[1]-1) },
	$down  => sub { return ($_[0], $_[1]+1) },
	$left  => sub { return ($_[0]-1, $_[1]) },
	$right => sub { return ($_[0]+1, $_[1]) },
);

sub makeNextFn {
	my %map = @_;

	return sub {
		my ($from) = @_;

		my $to = $map{$from};
		if (ref $to eq '') {
			return $to;
		}

		return @$to;
	};
}

my %next = (
	$empty => makeNextFn(
		$up    => $up,
		$down  => $down,
		$left  => $left,
		$right => $right,
	),
	$mirrorL => makeNextFn(
		$up    => $left,
		$down  => $right,
		$left  => $up,
		$right => $down,
	),
	$mirrorR => makeNextFn(
		$up    => $right,
		$down  => $left,
		$left  => $down,
		$right => $up,
	),
	$splitV => makeNextFn(
		$up    => $up,
		$down  => $down,
		$left  => [$up, $down],
		$right => [$up, $down],
	),
	$splitH => makeNextFn(
		$up    => [$left, $right],
		$down  => [$left, $right],
		$left  => $left,
		$right => $right,
	),
);

sub solveOne {
	my ($lines) = @_;

	my $grid = parseGrid($lines);

	#print Dumper(\%next, \%move);

	# delete non-interactive tiles
	#delete $grid->{$_} for grep { $grid->{$_} eq $empty } keys %$grid;

	return solve($grid, 0, 0, $right);
}

sub solve {
	my ($grid, $x, $y, $dir) = @_;

	my %seen;
	my %seenWithDir;

	my @beams = ([$x,$y,$dir]);
	while (scalar @beams) {
		my $round = shift @beams;
		my ($x, $y, $dir) = @$round;

		next if (exists $seenWithDir{"$x,$y,$dir"});
		$seen{"$x,$y"}++;
		$seenWithDir{"$x,$y,$dir"} = undef;

		my $item = $grid->{"$x,$y"} // '.';

		for my $newDir ($next{$item}->($dir)) {
			my ($newX, $newY) = $move{$newDir}->($x, $y);

			if (exists $grid->{"$newX,$newY"}) {
				push @beams, [$newX, $newY, $newDir];
			}
		}
	}

	return scalar keys %seen;
}

sub printPath {
	my ($grid, $conf, $maxX, $maxY) = @_;

	print Dumper(\@_);

	my $blank = ' ';
	$next{$blank} = $next{$empty};

	my %printGrid = map { $_ => $grid->{$_} ne $empty ? $grid->{$_} : $blank } keys %$grid;

	# set start
	my ($startX, $startY, $dir) = @$conf;
	if ($dir eq $up) { $startY++; } elsif ($dir eq $down) { $startY++; }
	elsif ($dir eq $left) { $startX--; } elsif ($dir eq $right) {$startX++; }

	#print "print start x:$startX, y:$startY, dir:$dir\n";

	$maxX++;
	$maxY++;

	# add buffer for visualization
	for my $x (-1 .. $maxX) {
		$printGrid{"$x,-1"} = $printGrid{"$x,$maxY"} = $blank;
	}

	for my $y (-1 .. $maxY) {
		$printGrid{"-1,$y"} = $printGrid{"$maxX,$y"} = $blank;
	}

	$printGrid{"$startX,$startY"} = $dir;

	my %seen;
	my %seenWithDir;

	my @beams = ($conf);
	while (scalar @beams) {
		my $round = shift @beams;
		my ($x, $y, $dir) = @$round;

		next if (exists $seenWithDir{"$x,$y,$dir"});
		$seen{"$x,$y"}++;
		$seenWithDir{"$x,$y,$dir"} = undef;

		my $item = $grid->{"$x,$y"};
		#print "x:$x, y:$y, dir:$dir, it:$item\n";

		for my $newDir ($next{$item}->($dir)) {
			my ($newX, $newY) = $move{$newDir}->($x, $y);

			if (exists $grid->{"$newX,$newY"}) {
				push @beams, [$newX, $newY, $newDir];
			}
		}

		if ($item eq $blank or $item eq $empty) {
			$printGrid{"$x,$y"} = $dir;
		}

		next unless ($item eq $empty);

		system 'clear';
		for my $y (-1 .. $maxY) {
			for my $x (-1 .. $maxX) {

				my $coord = "$x,$y";
				if (defined $seen{$coord} and $seen{$coord} > 1 and $grid->{$coord} eq $empty) {
					print $seen{$coord};

				} else {
					print $printGrid{$coord};
				}
			}

			print "\n";
		}
		#usleep (50000);
	}
}

sub solveTwo {
	my ($lines) = @_;

	my $grid = parseGrid($lines);

	my @configurations;
	my ($maxX, $maxY);
	# go down left side -> start right
	for (my $y = 0; exists $grid->{"0,$y"}; $y++) {
		$maxY = $y;
		push @configurations, [0, $y, $right];
	}

	# go across top side -> start down
	for (my $x = 0; exists $grid->{"$x,0"}; $x++) {
		$maxX = $x;
		push @configurations, [$x, 0, $down];
	}

	# go down right side -> start left
	for (my $y = 0; exists $grid->{"$maxX,$y"}; $y++) {
		push @configurations, [$maxX, $y, $left];
	}

	# go across bottom side -> start up
	for (my $x = 0; exists $grid->{"$x,$maxY"}; $x++) {
		push @configurations, [$x, $maxY, $up];
	}

	my $best;
	my $max = reduce(
		sub {
			my ($acc, $conf) = @_;

			my ($x, $y, $dir) = @$conf;
			#print "x:$x, y:$y, dir:$dir, ";

			my $lit = solve($grid, @$conf);
			#print "lit:$lit ($acc)\n";

			if ($lit > $acc) { $best = $conf }

			return $lit > $acc ? $lit : $acc;
		},
		\@configurations,
		0,
	);

	#printPath($grid, $best, $maxX, $maxY);

	return $max;
}

main(\&solveOne, \&solveTwo);
