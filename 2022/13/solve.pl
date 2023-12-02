#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use List::MoreUtils qw(first_index);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my @tests = (
	['[1,1,3,1,1]', [1,1,3,1,1]],
	['[[1],[2,3,4]]', [[1],[2,3,4]]],
	['[1,[2,[3,[4,[5,6,7]]]],8,9]', [1,[2,[3,[4,[5,6,7]]]],8,9]],
);

for my $tc (@tests) {
	my $actual = toNested($tc->[0]);

	my $dActual = Dumper($actual);
	my $dExpected = Dumper($tc->[1]);

	if ($dActual ne $dExpected) {
		#print "got: ${dActual}want: $dExpected\n";
	}
}

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
	my @elems1 = split /\n/, $line;

	my @elems2 = map { toNested($_) } @elems1;

	return \@elems2;

}

sub unNest {
	my ($arr) = @_;

	if (ref $arr eq '') {
		return $arr;
	}


	return '[' . join(',', map { unNest($_) } @$arr) . ']';
}

sub compare {
	my ($left, $right, $p) = @_;

	my $sLeft = unNest($left);
	my $sRight = unNest($right);

	print "$p- Compare $sLeft vs $sRight\n";
	$p = "$p  ";

	# both are integers
	if (ref $left eq '' and ref $right eq '') {

		my $out = $left <=> $right;

		if ($out == -1) {
			print "$p- Left side is smaller, so inputs are in the right order\n";

		} elsif ($out == 1) {
			print "$p- Right side is smaller, so inputs are not in the right order\n";
		}

		return $left <=> $right;
	}

	# left is int, right is array
	if (ref $left eq '' and ref $right eq 'ARRAY') {
		print "$p- Mixed types; convert left to [$left] and retry comparison\n";
		return compare([$left], $right, "$p  ");
	}

	# left is array, right is int
	if (ref $left eq 'ARRAY' and ref $right eq '') {
		print "$p- Mixed types; convert right to [$right] and retry comparison\n";
		return compare($left, [$right], "$p  ");
	}

	for (my $i = 0; ; $i++) {

		if ($#$left < $i and $i > $#$right) {
			return 0;
		}

		if ($i > $#$left) {
			print "$p- Left side ran out of items, so inputs are in the right order\n";
			return -1;
		}

		if ($i > $#$right) {
			print "$p- Right side ran out of items, so inputs are not in the right order\n";
			return 1;
		}

		my $res = compare($left->[$i], $right->[$i], $p);
		next if ($res == 0);

		return $res;
	}

	return 0;
}

sub solveOne {
	my ($lines) = @_;

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
