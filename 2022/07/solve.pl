#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;


my $PRNT = '..';
my $SIZE = '__size';
my $META = '__meta';
my $PATH = '__path';

sub parse {
	my ($lines) = @_;

	#my $pwd;

	return reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		my ($root, $pwd) = @$acc;

		if (my ($dir) = $line =~ /^\$ cd (.+)$/) {
			#print "cd $dir\n";
			if ($dir eq '/') {
				$pwd = $root; # $acc;

			} else {
				$pwd = $pwd->{$dir};
			}

		} elsif ($line =~ /^\$ ls$/) {
			#print "ls\n";
			# nothing?

		} elsif (my ($size, $name) = $line =~ /^(\d+) (.+)$/) {
			#print "$name is $size\n";
			$pwd->{$name} = $size;

			# update parents
			for (my $ancestor = $pwd; defined $ancestor; $ancestor = $ancestor->{$PRNT} // undef) {
				$ancestor->{$SIZE} += $size;
			}

		} elsif (my ($Dir) = $line =~ /^dir (.+)$/) {
			#print "dir $dir\n";
			$pwd->{$Dir} //= {
				$PRNT => $pwd,
				$SIZE => 0,
				$PATH => "$pwd->{$PATH}$Dir/",
			};

		} else {
			die "unparseable: $line";
		}

		return [$root, $pwd];
	},
	$lines,
	[{ $PATH => '/' }, undef],
	)->[0];
}

sub sizeDir {
	my ($root) = @_;

	# this is a file
	if (ref $root eq '') {
		return $root;
	}

	# this is a dir
	if (ref $root eq 'HASH') {
		my $size = 0;

		for my $k (keys %$root) {
			$size += sizeDir($root->{$k});
		}

		$root->{$SIZE} = $size;

		return $size;
	}

	# this is a ?
	die "dunno what root is:" . Dumper($root);
}

my @levels;

sub totalUnder {
	my ($root, $threshold) = @_;

	my %skip = map { $_ => undef } ($PRNT, $SIZE, $PATH);

	my $total = 0;
	my @queue = ($root);
	while (scalar @queue > 0) {
		my $node = shift @queue;

		if ($node->{$SIZE} <= $threshold) {
			$total += $node->{$SIZE};
		}

		for my $k (sort { $a cmp $b } grep { not exists $skip{$_} } keys %$node) {
			my $v = $node->{$k};

			if (ref $v eq '') {
				next;
			}

			push @queue, $v;
		}
	}

	return $total;
}

sub solveOne {
	my ($lines) =@_;

	my $threshold = 100000;

	my $root = parse($lines);

	print Dumper($root);

	#my $size = sizeDir($root);

	return totalUnder($root, $threshold);

	return Dumper($root);
}

sub findSmallest {
	my ($root, $target) = @_;

	my %skip = map { $_ => undef } ($PRNT, $SIZE);

	my $actual = $root->{$SIZE};
	my @queue = ($root);
	while (scalar @queue > 0) {
		my $node = shift @queue;
		print "exploring $node->{$PATH}\n";

		my $size = $node->{$SIZE};
		if ($target <= $size and $size <= $actual) {
			print "$node->{$PATH} @ $size is new min\n";
			$actual = $size;
		}

		for my $k (sort { $a cmp $b } grep { not exists $skip{$_} } keys %$node) {
			my $v = $node->{$k};

			if (ref $v eq '') {
				next;
			}

			push @queue, $v;
		}
	}

	return $actual;

	return Dumper(\@_);
}

sub solveTwo {
	my ($lines) = @_;

	my $totalDiskSpace = 70_000_000;
	my $needed = 30_000_000;

	my $root = parse($lines);

	print Dumper($root);

	#print Dumper($needed, $root->{$SIZE}, $needed - $root->{$SIZE});

	my $used = $root->{$SIZE};
	my $available = $totalDiskSpace - $used;

	return findSmallest($root, $needed - $available);

	return reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		return $acc;
	},
	$lines,
	0,
	);
}

main(\&solveOne, \&solveTwo);
