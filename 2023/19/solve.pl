#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my %parts = (
	'x' => 0,
	'm' => 1,
	'a' => 2,
	's' => 3,
);

sub comparatorFn {
	my ($compStr) = @_;

	my ($name, $op, $val, $dst);
	die "malformed instruction: $compStr\n" unless (($name, $op, $val, $dst) = $compStr =~ /\A(?:([xmas])([<>])(\d+):)?(.+)\z/);

	return sub {
		my ($part) = @_;

		if (not defined $name) {
			return $dst;

		} elsif ($op eq '>') {
			if ($part->[$parts{$name}] > $val) {
				return $dst;
			}

		} elsif ($op eq '<') {
			if ($part->[$parts{$name}] < $val) {
				return $dst;
			}

		} else {
			die "malformed op: $name$op$val\n";
		}

		return;
	}
}

my $accept = 'A';
my $reject = 'R';

sub grade {
	my ($instructions, $part) = @_;

	my $node = 'in';

	while (1) {
		if ($node eq $reject) {
			return 0;
		}

		if ($node eq $accept) {
			return sumRef($part);
		}

		for my $step (@{$instructions->{$node}}) {

			$node = $step->($part) and last;

		}
	}
}

sub solveOne {
	my ($lines) = @_;

	my $parsed = reduce(
		sub {
			my ($acc, $line, $i) = @_;

			if (my ($name, $sequence) = $line =~ /\A(\w+)\{(.+)\}\z/) {
				my @sequence = map { comparatorFn($_) } split /,/, $sequence;
				$acc->{'instructions'}{$name} = \@sequence;

			} elsif (my ($x, $m, $a, $s) = $line =~ /\A\{x=(\d+),m=(\d+),a=(\d+),s=(\d+)\}\z/) {
				push @{$acc->{'parts'}}, [$x, $m, $a, $s];

			} elsif ($line ne '') {
				die "malformed line ($i): $line\n";
			}

			return $acc;
		},
		$lines,
		{},
	);

	return reduce(
		sub {
			my ($acc, $part) = @_;

			return $acc + grade($parsed->{'instructions'}, $part);
		},
		$parsed->{'parts'},
		0
	);

	return Dumper($parsed);
}

my $min = 1;
my $max = 4000;

sub parse2 {
	my ($lines) = @_;

	return reduce(
		sub {
			my ($acc, $line, $i) = @_;

			if (my ($name, $sequence) = $line =~ /\A(\w+)\{(.+)\}\z/) {
				my $base = $name;

				my @sequence = split /,/, $sequence;
				for my $i (0 .. $#sequence) {
					my $compStr = $sequence[$i];

					my ($field, $op, $val, $dst);
					if (($field, $op, $val, $dst) = $compStr =~ /\A(?:([xmas])([<>])(\d+):)?(.+)\z/) {
						if (not defined $field) {
							$acc->{$name} = ['x', $dst, $max+1, undef];
							die unless ($i == $#sequence);
						} else {
							die if ($i == $#sequence);

							my $next = $base . ($i+1);

							my ($under, $over) = $op eq '>' ? ($next, $dst) : ($dst, $next);
							if ($op eq '>') {
								$val++;
							}

							$acc->{$name} = [$field, $under, $val, $over];
							$name = $next;
						}

					} else {
						die "malformed instruction: $compStr\n";
					}
				}

			} else {
				die "malformed line ($i): $line\n";
			}

			return $acc;
		},
		[grep { /\A\w+/ } @$lines],
		{},
	);
}

sub copyNode {
	my ($node, $dst) = @_;

	my %node;

	for my $field (qw(x m a s)) {
		my ($lower, $upper) = @{$node->{$field}};
		$node{$field} = [$lower, $upper];
	}

	$node{'node'} = $dst // $node->{'node'};

	return \%node;
}

sub solveTwo {
	my ($lines) = @_;

	my $parsed = parse2($lines);

	my %start = (
		'node' => 'in',
		'x' => [$min-1, $max], # min < x <= max
		'm' => [$min-1, $max],
		'a' => [$min-1, $max],
		's' => [$min-1, $max],
	);


	my @queue = (\%start);
	my $total = 0;

	while (scalar @queue) {
		my $node = shift @queue;

		next if ($node->{'node'} eq $reject);

		if ($node->{'node'} eq $accept) {
			my $nodeTotal = 1;
			for my $field (qw(x m a s)) {
				my ($lower, $upper) = @{$node->{$field}};
				$nodeTotal *= $upper - $lower;
			}
			$total += $nodeTotal;

			next;
		}

		my ($field, $under, $val, $over) = @{$parsed->{$node->{'node'}}};

		my ($lower, $upper) = @{$node->{$field}};
		my $overStr = $over // 'undef';

		print "evaluate $node->{'node'}: $field($lower,$upper) under ${val}->$under, over ${val}->$overStr => ";

		if ($lower < $val and $val <= $upper) {
			my $lowerNode = copyNode($node, $under);
			my $upperNode = copyNode($node, $over);

			$lowerNode->{$field}[1] = $upperNode->{$field}[0] = $val-1;

			print "splits to (@{$lowerNode->{$field}})->$under & (@{$upperNode->{$field}})->$over";


			push @queue, $lowerNode, $upperNode;

		} elsif ($upper < $val) {
			# reaching here means the value is higher than anything seen
			$node->{'node'} = $under;

			print "entirely goes down to $under";

			push @queue, $node;

		} elsif ($val <= $lower and defined $over) {
			$node->{'node'} = $over;

			print "entirely goes up to $over";

			push @queue, $node;
		} else {
			print "disappears"
		}

		print "\n";
	}

	return $total;
}

main(\&solveOne, \&solveTwo);
