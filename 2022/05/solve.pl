#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub getParts {
	my ($lines) = @_;

	# count number of stacks
	# first line is 3 mod 4 length
	my $stackCount = (length($lines->[0]) + 1) / 4;
	my @stacks;
	for (1 .. $stackCount) {
		push @stacks, [];
	}

	my $i = 0;
	# process stacks
	for (; $lines->[$i] ne ""; $i++) {
		for (my $j = 0; $j*4 < length($lines->[$i]); $j++) {
			if (my ($char) = substr($lines->[$i], $j*4, 4) =~ /^\[(.)\] ?$/) {
				push @{$stacks[$j]}, $char;
			}
		}
	}

	my @instructions;
	for ($i++; $i <= $#$lines; $i++) {
		if (my ($qty, $src, $dst) = $lines->[$i] =~ /^move (\d+) from (\d+) to (\d+)$/) {
			push @instructions, [$qty, $src, $dst];

		} else {
			die "line $i ($lines->[$i]) unparseable";
		}
	}


	return \@stacks, \@instructions;

}

sub solveOne {
	my ($lines) = @_;

	my ($stacks, $instructions) = getParts($lines);

	for my $ins (@$instructions) {
		my ($cnt, $src, $dst) = @$ins;

		for (1 .. $cnt) {
			unshift @{$stacks->[$dst-1]}, shift @{$stacks->[$src-1]};
		}
	}

	return join('', map {$stacks->[$_][0]} 0 .. $#$stacks);
}

sub solveTwo {
	my ($lines) = @_;

	my ($stacks, $instructions) = getParts($lines);

	for my $ins (@$instructions) {
		my ($cnt, $src, $dst) = @$ins;

		unshift @{$stacks->[$dst-1]}, splice @{$stacks->[$src-1]}, 0, $cnt;
	}

	return join('', map {$stacks->[$_][0]} 0 .. $#$stacks);
}

main(\&solveOne, \&solveTwo);
