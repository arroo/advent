#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub solve {
	my ($lines) = @_;

	return reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		return $acc;
	},
	$lines,
	0,
	);
}

my $SEP = ':';

sub parseTrees {
	my ($lines) = @_;

	my %trees;
	my $maxX = length($lines->[0]) - 1; # all the same length
	my $maxY = scalar(@$lines) - 1;

	my $y = 0;
	for my $line (@$lines) {

		my @row = split //, $line;

		for my $x (0 .. $#row) {
			$trees{"$x$SEP$y"} = $row[$x];
		}

		$y++;
	}

	return (\%trees, $maxX, $maxX);
}

sub key {
	return join $SEP, @_;
}

sub at {
	my ($tree, $x, $y) = @_;

	return $tree->{key($x, $y)};
}

sub treesVisible {
	my ($trees, $maxX, $maxY) = @_;

	my %visible;
	my $thing = sub {
		my ($x, $y, $maxHRef) = @_;

		my $height = at($trees, $x, $y);

		return if ($height <= $$maxHRef);

		$visible{key($x, $y)} = undef;
		$$maxHRef = $height;
	};

	# check visible from top
	for my $x (0 .. $maxX) {
		my $maxH = -1;

		for my $y (0 .. $maxY) {
			$thing->($x, $y, \$maxH);
		}
	}

	# check visible from bottom
	for my $x (0 .. $maxX) {
		my $maxH = -1;

		for my $y (0 .. $maxY) {
			$thing->($x, $maxY-$y, \$maxH);
		}
	}

	# check visible from left
	for my $y (0 .. $maxY) {
		my $maxH = -1;

		for my $x (0 .. $maxX) {
			$thing->($x, $y, \$maxH);
		}
	}

	# check visible from right
	for my $y (0 .. $maxY) {
		my $maxH = -1;

		for my $x (0 .. $maxX) {
			$thing->($maxX-$x, $y, \$maxH);
		}
	}

	return \%visible;
}

sub scenicScore {
	my ($trees, $coord, $bounds) = @_;
	my ($oX, $oY) = @$coord;
	my ($mX, $mY) = @$bounds;

	my $height = at($trees, $oX, $oY);


	# look down
	my $down = 0;
	for my $y ($oY+1 .. $mY) {
		$down++;
		last if ($height <= at($trees, $oX, $y));
	}

	# look up
	my $up = 0;
	for my $y (1 .. $oY) {
		$up++;
		last if ($height <= at($trees, $oX, $oY-$y));
	}

	# look right
	my $right = 0;
	for my $x ($oX+1 .. $mX) {
		$right++;
		last if ($height <= at($trees, $x, $oY));
	}

	# look left
	my $left = 0;
	for my $x (1 .. $oX) {
		$left++;
		last if ($height <= at($trees, $oX-$x, $oY));
	}

	return $up * $down * $left * $right;
}

sub solveOne {
	my ($lines) = @_;

	my ($trees, $maxX, $maxY) = parseTrees($lines);

	print Dumper($trees, $maxX, $maxY);

	my $visible = treesVisible($trees, $maxX, $maxY);

	print "\n";

	for my $y (0 .. $maxY) {
		for my $x (0 .. $maxX) {
			if (exists $visible->{key($x, $y)}) {
				#print at($trees, $x, $y);
				#print '|';
				print "🌲";

			} else {
				print ' ';
			}
		}

		print "\n";
	}

	print "\n";

	return scalar keys %$visible;
}

sub solveTwo {
	my ($lines) = @_;

	my ($forest, $maxX, $maxY) = parseTrees($lines);

	my @bounds = ($maxX, $maxY);

	my $mS = -1;
	for my $x (0 .. $maxX) {
		for my $y (0 .. $maxY) {
			my $s = scenicScore($forest, [$x, $y], \@bounds);

			if ($s > $mS) {
				$mS = $s;
			}
		}
	}

	return $mS;

	return reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		return $acc;
	},
	$lines,
	0,
	);
}

main(\&solveOne, \&solveTwo);
