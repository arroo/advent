#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;

sub neighbours {
	my ($edges, $seen, $node) = @_;

	return grep { (uc($_) eq $_) or (not (exists $seen->{$_}) or not defined $seen->{'doubleSeen'}) } sort {$a cmp $b } @{$edges->{$node}};
}

sub dfs {
	my ($edges, $start, $end) = @_;

	my $total = 0;
	my %seen;

	my @path;
	my $doubleSeen = undef;

	my $fn;
	$fn = sub {
		my ($node) = @_;

		my $amDoubleSeen = 0;

		if (exists $seen{$node}) {
			if (defined $doubleSeen) {
				print "would visit $node but it's already been visited and $doubleSeen has been visited twice\n";
				return;
			}

			$doubleSeen = $node;
			$amDoubleSeen = 1;
			print "visiting $node for the second time\n";
		}

		print "seeing $node\n";
		if (uc($node) ne $node) {
			$seen{$node} = undef;
		}
		push @path, $node;

		if ($node eq $end) {
			$total++;
			delete $seen{$node};

			print join(',',@path) . "\n";

			pop @path;
			return;
		}

		for my $n (sort { $a cmp $b } @{$edges->{$node}}) {
		#for my $n (neighbours($edges, \%seen, $node)) {
			print "\t\$fn->($n)\n";
			$fn->($n);
		}

		pop @path;

		if ($amDoubleSeen) {
			$doubleSeen = undef;

		} else {
			delete $seen{$node};
		}
	};

	$fn->($start);

	return $total;
}

sub solveTwo {
	my ($lines) = @_;

	my %edges;

	my $start = 'start';

	my $ret = reduce(
		sub {
			my ($acc, $line, $i, $lines) = @_;

			my ($src, $dst) = $line =~ /^([^-]+)-([^-]+)$/;

			if ($dst ne $start) {
				push @{$edges{$src}}, $dst;
			}

			if ($src ne $start) {
				push @{$edges{$dst}}, $src;
			}

			return $acc;
		},
		$lines,
		{},
	);

	return dfs(\%edges, $start, 'end');
}

sub solveOne {
	my ($lines) = @_;

	my %edges;

	my $ret = reduce(
		sub {
			my ($acc, $line, $i, $lines) = @_;

			my ($src, $dst) = $line =~ /^([^-]+)-([^-]+)$/;

			push @{$edges{$src}}, $dst;
			push @{$edges{$dst}}, $src;

			return $acc;
		},
		$lines,
		{},
	);

	return dfs(\%edges, 'start', 'end');
}

main(\&solveOne, \&solveTwo);
