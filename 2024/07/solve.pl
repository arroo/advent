#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my @ops = (\&sum, \&prod);

sub canSolve2 {
	my ($target, $total, $ops, @nums) = @_;

	if (scalar @nums == 0 or $total > $target) {
		return ($total == $target) ? $total : undef;
	}

	my $cur = shift @nums;

	for my $op (@$ops) {
		my $ret = canSolve2($target, $op->($total, $cur), $ops, @nums);
		if (defined $ret) {
			return $ret;
		}
	}

	return undef;
}

sub canSolve {
	my ($lines, $ops) = @_;

	return reduce(
		sub {
			my ($acc, $line) = @_;

			my @nums = split /:? /, $line;
			my $target = shift @nums;

			return $acc + (canSolve2($target, 0, $ops, @nums) // 0);
		},
		$lines,
		0,
	);
}


sub canSolve3 {
	my ($lines, $ops) = @_;

	my $acc = 0;
	LINE: for my $line (@$lines) {

		#print "processing $line ";
		my @nums = split /:? /, $line;
		my $target = shift @nums;
		#print "target: $target, nums: @nums\n";

		my @queue = ([$nums[0], 1]);
		while (scalar @queue) {
			my ($total, $i) = @{shift @queue};

			next if ($total > $target);

			if ($i > $#nums) {
				if ($total == $target) {
					$acc += $target;
					next LINE;
				}

				next;
			}

			for my $op (@$ops) {
				push @queue, [$op->($total, $nums[$i]), $i+1];
			}
		}
	}

	return $acc;
}


sub solveOne {
	my ($lines) = @_;

	my @ops = (
		\&sum,
		\&prod,
	);

	return canSolve($lines, \@ops);
}

sub solveTwo {
	my ($lines) = @_;

	my @ops = (
		sub {
			my $acc = 0;
			$acc += $_ for @_;
			return $acc;
		},
		sub {
			my $acc = 1;
			$acc *= $_ for @_;
			return $acc;
		},
		sub {
			return join('', @_);
		},
	);

	return canSolve($lines, \@ops);
}

main(\&solveOne, \&solveTwo);
