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

my $up    = '^';
my $down  = 'v';
my $left  = '<';
my $right = '>';

my %opposite = (
	$up    => $down,
	$down  => $up,
	$left  => $right,
	$right => $left,
	''     => '',
);

sub addToPath {
	my ($x, $y, $dir, $delta) = @_;

	$delta //= 1;

	if ($dir eq $up) {
		return ($x, $y-$delta);
	}

	if ($dir eq $down) {
		return ($x, $y+$delta);
	}

	if ($dir eq $left) {
		return ($x-$delta, $y);
	}

	if ($dir eq $right) {
		return ($x+$delta, $y);
	}
}

sub sortPathFn {
	my ($tX, $tY) = @_;

	return sub {
		# my ($a, $b) = @_;

		return $a->[2] + manhattan(@$a[0,1], $tX, $tY) <=> $b->[2] + manhattan(@$b[0,1], $tX, $tY);
	};

	return sub {
		# my ($a, $b) = @_;

		# totals
		my $totalCMP = $a->[2] <=> $b->[2];

		return $totalCMP != 0 ? $totalCMP : manhattan(@$a[0,1], $tX, $tY) <=> manhattan(@$b[0,1], $tX, $tY);
	};
}

my @colours = (
	'bright white',
	'white',
	'bright green',
	'green',
	'bright cyan',
	'cyan',
	'bright yellow',
	'yellow',
	'bright red',
	'red',
);

sub printGrid {
	my ($grid, $seen, $total, $queued) = @_;

	system 'clear';
	print "$total : $queued\n";

	for (my $y = 0; exists $grid->{"0,$y"}; $y++) {
		for (my $x = 0; exists $grid->{"$x,0"}; $x++) {
			my $key = "$x,$y";
			my $val = $grid->{$key};
			if (exists $seen->{$key}) {
				print coloured($colours[$val],'#');

			} else {
				print coloured($colours[$val],$val);
			}
		}

		print "\n";
	}
}



sub solveOne {
	my ($lines) = @_;

	my $grid = parseGrid($lines);

	return solve($grid, 1, 3);
}

sub solve {
	my ($grid, $minStreak, $maxStreak) = @_;

	my ($maxX, $maxY);
	for (my $x = 0; exists $grid->{"$x,0"}; $x++) {
		$maxX = $x;
	}

	for (my $y = 0; exists $grid->{"0,$y"}; $y++) {
		$maxY = $y;
	}

	my $sort = sortPathFn($maxX, $maxY);

	my %seen;

	my $its = ~0;
	#$its = 10;

	my @queue = ([0,0,0,'',{}]);
	while (scalar @queue and --$its > 0) {
		my $node = shift @queue;
		my ($x, $y, $total, $dir, $seen) = @$node;

		my @dirs = grep { $_ ne $dir and $_ ne $opposite{$dir} } ($up, $down, $left, $right);
		my $key = "$x,$y;" . join(',', @dirs);

		my $seenRef;
		if (0) {
			next if (exists $seen->{$key});
			$seenRef = $seen;
		} else {
			next if (exists $seen{$key});
			$seenRef = \%seen;
		}

		$seen{$key} = undef;
		$seen->{$key} = undef;
		#printGrid($grid, $seen, $total, scalar @queue);
		#usleep(50000);
		return $total if ($x == $maxX and $y == $maxY);

		if ($its % 1_000 == 0) {
			my $q = scalar @queue;
			print "total:$total, queue:$q\n";

			# see how common clusters of totals are
			#my %totals;
			#for my $q (@queue) {
			#	$totals{$q->[2]}++;
			#}
			#print Dumper(\%totals);
		}

		#my @dirs = grep { $_ ne $dir and $_ ne $opposite{$dir} } ($up, $down, $left, $right);
		# go 1 .. $streakLength in each direction
		for my $d (@dirs) {
			my $delta = 0;
			my @path;

			STREAK: for my $l (1 .. $maxStreak) {
				my ($nX, $nY) = addToPath($x, $y, $d, $l);
				#push @path, [$nX, $nY];

				last unless (exists $grid->{"$nX,$nY"});
				#next if (exists $seenRef->{"$nX,$nY"});

				$delta += $grid->{"$nX,$nY"};
				next unless ($l >= $minStreak);

				#my $nt = $total + $delta;
				#print "($x,$y) -> ($nX,$nY): $total -> $nt\n";

				

				my %seen;
				#for my $k (keys %$seen) {
				#	$seen{$k} = $seen->{$k};
				#}

				## will have seen the path there
				#for my $i (0 .. $#path -1) {
				#	$seen{"$path[$i],$d"} = undef;
				#}

				my @node = ($nX, $nY, $total + $delta, $d);#, \%seen);
				$a = \@node;
				# push in correct priority order
				for my $i (0 .. $#queue) {
					$b = $queue[$i];
					if ($sort->() < 1) {
						splice @queue, $i, 0, \@node;
						next STREAK;
					}
				}

				push @queue, [$nX, $nY, $total + $delta, $d, \%seen];
			}
		}

		#@queue = sort $sort @queue;
	}

	print Dumper(\@queue, \%seen);

	return -1;
}

sub solveTwo {
	my ($lines) = @_;

	my $grid = parseGrid($lines);

	return solve($grid, 4, 10);
}

main(\&solveOne, \&solveTwo);
