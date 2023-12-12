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

	return reduce(
		sub {
			my ($acc, $line) = @_;

			my ($pattern, $segments) = split / /, $line;

			push @$acc, [$pattern, $segments];

			return $acc;
		},
		$lines,
		[],
	);
}

sub iterate {
	my ($pattern, $segments) = @_;

	my %seen;


	my $go;
	$go = sub {
		my ($pattern, $req) = @_;

		my $key = join(',', $pattern, @$req);

		if (exists $seen{$key}) {
			return $seen{$key};
		}

		if (scalar @$req == 0) { # if there are no more groups of springs required
			return index($pattern, '#') == -1; # there must not be any in the remainder
		}

		if (length($pattern) == 0) { # there is no pattern left but there are springs to find
			return 0;
		}

		# remove leading dots
		$pattern =~ s/\A\.+//;

		my $total = 0;

		my $segment = $req->[0];
		if ($pattern =~ m/\A[#?]{$segment}([?\.]|\z)/) {
			#print "start of line ($pattern) can match exactly $segment springs\n";
			$total += $go->(substr($pattern, $segment + length($1)), [@$req[1 .. $#$req]]);
		}

		if ($pattern =~ s/\A\?/./) {
			$total += $go->($pattern, $req);
		}

		$seen{$key} = $total;

		return $total;
	};

	return $go->($pattern, [split /,/, $segments]);
}

sub solveOne {
	my ($lines) = @_;

	my $springs = parse($lines);

	print Dumper($springs);

	return reduce(
		sub {
			my ($acc, $springSet, $i, $arr) = @_;

			my ($pattern, $segments) = @$springSet;

			my $found = iterate($pattern, $segments);

			$acc += $found;

			print "$i/$#$arr $pattern $segments: $found ($acc)\n";

			return $acc;
		},
		$springs,
		0,
	);
}

sub solveTwo {
	my ($lines) = @_;

	my $springs = parse($lines);

	print Dumper($springs);

	return reduce(
		sub {
			my ($acc, $springSet, $i, $arr) = @_;

			my ($pattern, $segments) = @$springSet;

			# modify springs & reqs
			$pattern = "$pattern?"x5;
			chop $pattern;
			$segments = "$segments,"x5;
			chop $segments;

			my $found = iterate($pattern, $segments);

			$acc += $found;

			print "$i/$#$arr $pattern $segments: ($acc) $found\n";

			return $acc;
		},
		$springs,
		0,
	);
}

main(\&solveOne, \&solveTwo);
