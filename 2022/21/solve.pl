#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my %OPS = (
	'+' => sub { return $_[0] + $_[1] },
	'-' => sub { return $_[0] - $_[1] },
	'*' => sub { return $_[0] * $_[1] },
	'/' => sub { return $_[0] / $_[1] },
	'=' => sub { return $_[0] == $_[1] },
);

sub mkSub {
	my ($eqs, $l, $op, $r) = @_;

	my $f = $OPS{$op};

	return sub {

		my $L = ref $eqs->{$l} eq '' ? $eqs->{$l} : $eqs->{$l}();
		my $R = ref $eqs->{$r} eq '' ? $eqs->{$r} : $eqs->{$r}();

		# back propogation
		$eqs->{$l} = $L;
		$eqs->{$r} = $R;

		return $f->($L, $R);
	}
}

sub solveOne {
	my ($lines) = @_;

	return reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		if (my ($id, $l, $op, $r) = $line =~ /^(.+): (.+) ([+\-*\/]) (.+)$/) {
			$acc->{$id} = mkSub($acc, $l, $op, $r);

		} elsif ( my ($id2, $val) = $line =~ /^(.+): (\d+)$/) {
			$acc->{$id2} = $val;

		} else {
			die "malformed line: $line";
		}

		return $acc;
	},
	$lines,
	{},
	)->{'root'}();
}

sub solveTwo {
	my ($lines) = @_;

	my $eqs = reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		if (my ($id, $l, $op, $r) = $line =~ /^(.+): (.+) ([+\-*\/]) (.+)$/) {

			#$op = $id eq 'root' ? '=' : $op;

			$acc->{$id} = [$l, $op, $r]; #mkSub($acc, $l, $op, $r);

		} elsif ( my ($id2, $val) = $line =~ /^(.+): (\d+)$/) {

			

			$acc->{$id2} = $val;

		} else {
			die "malformed line: $line";
		}

		return $acc;
	},
	$lines,
	{},
	);

	return Dumper($eqs);
}

main(\&solveOne, \&solveTwo);
