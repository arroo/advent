#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub parse {
	my ($lines) = @_;

	my $info = reduce(
		sub {
			my ($acc, $line) = @_;

			if (my ($from, $to) = $line =~ /\A(.+) => (.+)\z/) {
				$acc->{'xforms'}{$from}{$to} = undef;

			} elsif ($line ne "") {
				$acc->{'molecule'} = $line;
			} else {
				print "$line\n";
			}

			return $acc;
		},
		$lines,
		{
			'xforms' => {},
			'molecule' => '',
		},
	);

	print Dumper($info);

	return @$info{qw(xforms molecule)};
}

sub solveOne {
	my ($lines) = @_;

	my ($xforms, $molecule) = parse($lines);

	my %seen = ($molecule => undef);

	my @queue
}

sub solveTwo {
	my ($lines) = @_;

	return reduce(
		sub {
			my ($acc, $line) = @_;

			return $acc;
		},
		$lines,
		0,
	);
}

main(\&solveOne, \&solveTwo);
