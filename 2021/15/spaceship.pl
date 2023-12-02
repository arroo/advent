#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;

sub thing {
	my ($A, $B) = @_;

	my ($a1, $a2) = @$A;
	my ($b1, $b2) = @$B;

	return ($a1 <=> $b1 or $a2 <=> $b2);
}

sub main {

	my @tests = (
		[[0,0],[0,1]],
	);

	for my $t (@tests) {
		print Dumper($t, thing(@$t));
		#print thing(@$t) . "\n"
	}
	
}

main();
