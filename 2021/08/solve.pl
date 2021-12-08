#!/usr/bin/env perl

use warnings;
use strict;

use POSIX;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;

sub solveLineOne {
	my ($signals, $digits) = @_;

	die "bad signals\n" unless (scalar @$signals == 10);
	die "bad digits\n" unless (scalar @$digits == 4);

	my @output;
	for my $d (@$digits) {
		if (length($d) == 3) {
			push @output, 7;
		} elsif (length($d) == 4) {
			push @output, 4;
		} elsif (length($d) == 7) {
			push @output, 8;
		} elsif (length($d) == 2) {
			push @output, 1;
		}
	}

	return \@output;
}

sub solveOne {
	my ($lines) = @_;

	my $total = 0;
	for my $line (@$lines) {
		my ($signalPatterns, $digits) = split / \| /, $line;

		my $res = solveLineOne([split / /, $signalPatterns], [split / /, $digits]);

		$total += scalar @$res;

		print "$signalPatterns : $digits\n";
	}

	return $total;
}

sub makeSegmentSignal {
	my ($sig) = @_;

	return join('', sort { $a cmp $b } split //, $sig);
}

sub stringOverhang {
	my ($one, $two) = @_;


}

sub splitStrings {
	my ($re, @strings) = @_;

	return map { [ split $re, $_] } @strings;
}

sub solveLineTwo {
	my ($signals, $digits) = @_;

	my %signalToNumber = map { $_ => undef } @$signals;
	my %numberToSignal = map { $_ => undef } 0 .. 9;

	for my $sig (sort { length($a) cmp length($b) } @$signals) {

		# 1
		if (length($sig) == 2) {
			$signalToNumber{$sig} = 1;
			$numberToSignal{1} = $sig;

		# 7
		} elsif (length($sig) == 3) {
			$signalToNumber{$sig} = 7;
			$numberToSignal{7} = $sig;

		# 4
		} elsif (length($sig) == 4) {
			$signalToNumber{$sig} = 4;
			$numberToSignal{4} = $sig;

		# 2,3,5
		} elsif (length($sig) == 5) {

			# 3
			my ($inOne, undef, undef) = vennDiagram(splitStrings(qr//, $numberToSignal{1}, $sig));

			# 2,5
			my ($inFour, undef, undef) = vennDiagram(splitStrings(qr//, $numberToSignal{4}, $sig));

			# 3
			if (scalar @$inOne == 0) {
				$signalToNumber{$sig} = 3;
				$numberToSignal{3} = $sig;

			# 5
			} elsif (scalar @$inFour == 1) {
				$signalToNumber{$sig} = 5;
				$numberToSignal{5} = $sig;

			# 2
			} elsif (scalar @$inFour == 2) {
				$signalToNumber{$sig} = 2;
				$numberToSignal{2} = $sig;

			# ???
			} else {
				die "unable to decypher $sig\n";
			}


		# 0,6,9
		} elsif (length($sig) == 6) {

			# 6
			my ($inOne, undef, undef) = vennDiagram(splitStrings(qr//, $numberToSignal{1}, $sig));

			# 0,9
			my ($inFour, undef, undef) = vennDiagram(splitStrings(qr//, $numberToSignal{4}, $sig));

			# 6
			if (scalar @$inOne == 1) {
				$signalToNumber{$sig} = 6;
				$numberToSignal{6} = $sig;

			# 9
			} elsif (scalar @$inFour == 0) {
				$signalToNumber{$sig} = 9;
				$numberToSignal{9} = $sig;

			# 0
			} elsif (scalar @$inFour == 1) {
				$signalToNumber{$sig} = 0;
				$numberToSignal{0} = $sig;

			# ???
			} else {
				die "unable to decypher $sig\n";
			}

		# 8
		} elsif (length($sig) == 7) {
			$signalToNumber{$sig} = 8;
			$numberToSignal{8} = $sig;
		}
	}

	my @output;
	for my $digit (@$digits) {
		push @output, $signalToNumber{$digit};
	}

	return \@output;
}

sub solveTwo {
	my ($lines) = @_;

	my $total = 0;

	for my $line (@$lines) {
		my ($signalPatterns, $digits) = split / \| /, $line;

		my $res = solveLineTwo([map { makeSegmentSignal($_) } split / /, $signalPatterns], [map { makeSegmentSignal($_) } split / /, $digits]);

		$total += 0+ join('', @$res);
	}

	return $total;
}

main(\&solveOne, \&solveTwo);
