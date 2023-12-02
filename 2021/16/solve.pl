#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;



sub solveOne {
	my ($lines) = @_;

	my $hex = $lines->[0];

	my @chars = map { sprintf "%04b", $_ } map { hex } split //, $hex;

	my $string = join('', @chars);

	print Dumper(\@chars, $string);

	while (length($string)) {
		my $version = substr($string, 0, 3, '');
		my $typeID = substr($string, 0, 3, '');

		my $typeN = oct("0b$typeID");
		my $seenBits = 6;

		# literal value
		if ($typeN == 4) {

			my $n = '';

			while (substr($string,0,1) eq '1') {
				my $new = substr($string, 1, 4, '');

				#print "\tnew: $new\n";

				$n .= $new;
				substr($string, 0, 1, '');
				$seenBits += 5;
			}

			# last one
			my $new = substr($string, 1, 4, '');
			#print "\tnew: $new\n";
			$n .= $new;
			$seenBits += 5;
			substr($string, 0, 1, '');

			# remove padding zeroes
			substr($string, 0, 4 - $seenBits % 4, '');

			my $h = oct("0b$n"); # output
			#print "$n => $h seenbits: $seenBits  remainder($string)\n";

		# operator packet
		} else {

			my $lengthTypeID = substr($string, 0, 1);
			$seenBits++;


			if ($lengthTypeID == 0) {

				my $total = substr($string, 0, 15, '');
				$seenBits += 15;

			} else {

				my $packets = substr($string, 0, 11, '');
				$seenBits += 11;
			}

		}
	}

	return $#$lines;
}

sub solveTwo{
}

main(\&solveOne, \&solveTwo);
