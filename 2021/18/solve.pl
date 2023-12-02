#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use List::MoreUtils qw(first_index);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub toNested {
	my ($line) = @_;

	if (substr($line, 0, 1) ne '[' or substr($line, -1, 1) ne ']') {

		return $line;
		#return [split /,/, $line];
		die "malformed line: $line";
	}


	# remove first and last chars
	chop $line;
	$line = reverse $line;
	chop $line;
	$line = reverse $line;

	# convert commas not in square brackets to newlines
	$line =~ s/((\[(?>[^][]*(?2)?)*\])|[^,[]]*)(*SKIP),/$1\n/g;

	# split on newline
	my @elems = map { toNested($_) } split /\n/, $line;

	return \@elems;

}

sub unNest {
	my ($arr) = @_;

	if (ref $arr eq '') {
		return $arr;
	}


	return '[' . join(',', map { unNest($_) } @$arr) . ']';
}

sub explode {
	my ($n, $exp) = @_;

	my $exploded = 0;

	my $f;
	$f = sub {
		my ($n, $exp) = @_;

		if (ref $n eq '') {
			die "wtf $n";
		}

		# base case for explosion is both numbers as children and
		# $exp set to 0
		if (ref $n->[0] eq '' and ref $n->[1] eq '') {
			if ($exp <= 0) { # kaboom
				$exploded = 1;

				return (0, $n);
			}

			return $n;
		}

		if (ref $n->[0] eq 'ARRAY') {
			# go left
			($n->[0], my $rep) = $f->($n->[0], $exp-1);
		}

		# must explode
		if ($exp == 0) {
			$exploded = 1;
			return ;
		}

		my $left = $f->($n->[0], $exp-1);
		my $right = $f->($n->[1], $exp-1);

	};

	$n = $f->($n, $exp);

	return [$n, $exploded];
}

sub sSplit {
	my ($n, $spl) = @_;

	my $split = 0;

	my $f;
	$f = sub {
		my ($n) = @_;

		if (ref $n eq '') {
			if ($n < $spl) {
				return $n;
			}

			$split = 1;
			my $half = int($n/2);

			return [$half, $half + ($n%2)];
		}

		my $left = $f->($n->[0]);

		my $right = $split ? $n->[1] : $f->($n->[1]);

		return [$left, $right];
	};

	$n = $f->($n);

	return [$n, $split];
}

sub sReduce {
	my ($n, $exp, $spl) = @_;


	#If any pair is nested inside four pairs, the leftmost such pair explodes.
	my $expRes = explode($n, $exp);
	($n, my $exploded) = @$expRes;
	if ($exploded) {
		return sReduce($n, $exp, $spl);
	}


	#If any regular number is 10 or greater, the leftmost such regular number splits.
	my $splitRes = sSplit($n, $spl);
	($n, my $split) = @$splitRes;
	if ($split) {
		return sReduce($n, $exp, $spl);
	}


	return $n;
}

sub add {
	my ($left, $right, $exp, $spl) = @_;

	return sReduce([$left, $right], $exp, $spl);
}

sub magnitude {
	my ($n) = @_;

	if (ref $n eq '') {
		return $n;
	}

	return 3 * magnitude($n->[0]) + 2 * magnitude($n->[1]);
}

sub solveOne {
	my ($lines) = @_;

	my $sum = reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		my $n = toNested($line);

		if (scalar @$n != 2) {
			die "bad snailfish number: $line";
		}

		# first iteration
		if (not defined $acc) {
			return $n;
		}

		# add to $acc
		return add($acc, $n, 4, 10);
	},
	$lines,
	undef,
	);

	return magnitude($sum);

	#return compare([1,1,3,1,1], [1,1,5,1,1], '');
	#return '';

	my $index = 1;
	my $first = undef;
	my $total = 0;

	for my $line (@$lines) {

		if ($line eq '') {
			next;
		}

		if (not defined $first) {
			$first = toNested($line);
			next;
		}

		my $second = toNested($line);

		print "== Pair $index ==\n";

		if (compare($first, $second, '') == -1) {
			$total += $index;
		}

		$index++;
		$first = undef;

		print "\n";
	}

	return $total;
}


sub solveTwo {
	my ($lines) = @_;

	my $two = '[[2]]';
	my $six = '[[6]]';

	my @ordered = sort { compare(toNested($a), toNested($b)) } $two, $six, grep { $_ ne '' } @$lines;

	my $twoIdx = 1 + first_index { $_ eq $two } @ordered;
	my $sixIdx = 1 + first_index { $_ eq $six } @ordered;

	return $twoIdx * $sixIdx;
}

main(\&solveOne, \&solveTwo);
