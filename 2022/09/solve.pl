#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my $SEP = ',';

sub follow {
	my ($leader, $follower) = @_;

	my ($lX, $lY) = @$leader;
	my ($fX, $fY) = @$follower;



	# check if touching
	if (abs($lX - $fX) <= 1 and abs($lY - $fY) <= 1) {
		return ($fX, $fY);
	}

	#return ($fX + ($fX <=> $lX), $fY + ($fY <=> $lY));
	# directly above
	if ($lX == $fX) {
		return ($fX, $fY + ($lY > $fY ? 1 : -1));
		#return ($fX, $fY + ($fY <= $lY ? -1 : 1));
	}

	# directly beside
	if ($lY == $fY) {
		return ($fX + ($lX > $fX ? 1 : - 1), $fY);
	}

	# diagonal
	return ($fX + ($lX > $fX ? 1 : - 1), $fY + ($lY > $fY ? 1 : -1));
}

sub solveOne {
	my ($lines) = @_;

	return solve($lines, 2);
}

sub solve {
	my ($lines, $fCnt) = @_;

	my @followers;
	for (1 .. $fCnt) {
		push @followers, [0, 0];
	}

	my %mvF = (
		'L' => sub { $_[0][0]-- },
		'R' => sub { $_[0][0]++ },
		'U' => sub { $_[0][1]++ },
		'D' => sub { $_[0][1]-- },
	);

	my $seen = reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		my ($nodes, $seen) = @$acc;

		my $mvF;
		my ($dir, $cnt) = $line =~ /^(.) (\d+)$/;

		for (1 .. $cnt) {
			# move head
			$mvF{$dir}->($nodes->[0]);

			# move tails
			for my $i (1 .. $#$nodes) {
				($nodes->[$i][0], $nodes->[$i][1]) = follow($nodes->[$i-1], $nodes->[$i]);
			}

			# record
			my $key = join($SEP, @{$nodes->[$#$nodes]});
			$seen->{$key} = undef;
		}

		return [$nodes, $seen];
	},
	$lines,
	[ \@followers, { "0${SEP}0" => undef }],
	)->[1];

	return scalar keys %$seen;
}

sub solveTwo {
	my ($lines) = @_;

	return solve($lines, 10);
}

main(\&solveOne, \&solveTwo);
