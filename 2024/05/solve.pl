#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub fix {
	my ($info, $book) = @_;

	my %book = map { $book->[$_] => $_  } (0 .. $#$book);

	my @fixed;
	# find all pages with
	my (%before, %after);
	for my $page (@$book) {
		for my $p (grep { exists $book{$_} } keys %{$info->{'before'}{$page}}) {
			$before{$page}{$p} = undef;
			$after{$p}{$page} = undef;
		}
	}


	#print Dumper(['before', \%before],['after', \%after]);

	my @start;
	do {
		# find page not pointed at
		@start = grep { not exists $after{$_} } keys %before;
		#print Dumper(\@start);
		push @fixed, @start;
		for my $elem (@start) {
			for my $next (keys %{$before{$elem}}) {
				delete $after{$next}{$elem};
				delete $after{$next} unless (scalar keys %{$after{$next}});
			}

			delete $before{$elem};
		}
	} while (scalar @start);

	#print Dumper(['before', \%before],['after', \%after]);

	return \@fixed;
}

sub solveOne {
	my ($lines) = @_;

	my $info = reduce(
		sub {
			my ($acc, $line) = @_;

			if (my ($before, $after) = $line =~ /\A(\d+)\|(\d+)\z/) {
				$acc->{'before'}{$before}{$after} = undef;
				$acc->{'after'}{$after}{$before} = undef;

			} elsif ($line ne "") {
				push @{$acc->{'pages'}}, [split /,/, $line];
			}

			return $acc;
		},
		$lines,
		{},
	);

	#print Dumper($info);

	my $out = 0;
	BOOK: for my $book (@{$info->{'pages'}}) {
		#print "@$book\n";

		my %order;
		for my $i (0 .. $#$book) {
			$order{$book->[$i]} = $i;
		}

		#print Dumper(\%order);

		my %seen;
		for my $page (@$book) {
			for my $prev (keys %seen) {
				next BOOK if (exists $info->{'after'}{$prev}{$page});
			}

			$seen{$page} = undef;
		}

		$out += $book->[(scalar @$book) / 2];
	}

	return $out;
}

sub solveTwo2 {
	my ($lines) = @_;

	my $info = reduce(
		sub {
			my ($acc, $line) = @_;

			if (my ($before, $after) = $line =~ /\A(\d+)\|(\d+)\z/) {
				$acc->{'before'}{$before}{$after} = undef;
				$acc->{'after'}{$after}{$before} = undef;

			} elsif ($line ne "") {
				push @{$acc->{'pages'}}, [split /,/, $line];
			}

			return $acc;
		},
		$lines,
		{},
	);

	#print Dumper($info);

	my $out = 0;
	BOOK: for my $book (@{$info->{'pages'}}) {
		#print "@$book\n";

		my %order;
		for my $i (0 .. $#$book) {
			$order{$book->[$i]} = $i;
		}

		#print Dumper(\%order);

		my %seen;
		for my $page (@$book) {
			for my $prev (keys %seen) {
				next unless (exists $info->{'after'}{$prev}{$page});

				my $fixed = fix($info, $book);

				$out += $fixed->[(scalar @$fixed) / 2];

				# test
				#last BOOK;

				next BOOK;
			}

			$seen{$page} = undef;
		}

		#$out += $book->[(scalar @$book) / 2];
	}

	return $out;
}

sub sorter {
	my ($rules) = @_;

	return sub {
		my ($A, $B) = @_;

		if (exists $rules->{"$A|$B"}) {
			return 1;
		}

		if (exists $rules->{"$B|$A"}) {
			return -1;
		}

		return 0;
	};
}

sub solveTwo {
	my ($lines) = @_;

	my %rules;
	my $i = 0;
	for (; length($lines->[$i]) != 0; $i++) {
		$rules{$lines->[$i]} = undef;
	}

	print Dumper(\%rules);
	my $sorter = sorter(\%rules);

	my $total = 0;
	for ($i = $i+1; $i < scalar @$lines; $i++) {
		my @pages = split /,/, $lines->[$i];

		my @sorted = sort { $sorter->($a, $b) } @pages;

		if (join(',', @pages) ne join(',', @sorted)) {
			$total += $pages[(scalar @pages) / 2];
		}
	}

	return $total;
}

main(\&solveOne, \&solveTwo);
