#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my $SEP = ',';

sub key {
	return join($SEP, @_);
}

sub coords {
	return split /$SEP/, $_[0];
}

sub neighbours {
	my ($x, $y, $z) = @_;

	# 6 neighbours
	my @out = (
		[$x+1, $y, $z],
		[$x-1, $y, $z],
		[$x, $y+1, $z],
		[$x, $y-1, $z],
		[$x, $y, $z+1],
		[$x, $y, $z-1],
	);


	return \@out;
}

sub solveOne {
	my ($lines) = @_;

	return reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		my ($x, $y, $z, @rest) = split /,/, $line;
		# should check @rest ...

		my ($total, $seen) = @$acc;

		my $exposed = 6; # 6 faces on a cube

		my $neighbours = neighbours($x, $y, $z);

		for my $n (@$neighbours) {
			$exposed -= 2 if (exists $seen->{key(@$n)});
		}

		$seen->{key($x, $y, $z)} = undef;

		return [$total+$exposed, $seen];
	},
	$lines,
	[0, {}],
	)->[0];
}

sub setBounds {
	my ($min, $max, $val) = @_;

	$min = defined $min ? min($min, $val) : $val;
	$max = defined $max ? max($max, $val) : $val;

	return ($min, $max);
}

sub withinBoundingBox {
	my ($min, $max) = @_;

	die unless (scalar @$min == scalar @$max);

	return sub {

		die unless (scalar @_ == scalar @$min);

		for my $i (0 .. $#_) {
			return 0 unless ($min->[$i] <= $_[$i] and $_[$i] <= $max->[$i]);
		}

		return 1;
	};
}

sub solveTwo {
	my ($lines) = @_;

	my %occupied;
	my ($mnX, $mnY, $mnZ);
	my ($mxX, $mxY, $mxZ);

	my $total = reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		my ($x, $y, $z, @rest) = split /,/, $line;
		# should check @rest ...

		# set bounds
		($mnX, $mxX) = setBounds($mnX, $mxX, $x);
		($mnY, $mxY) = setBounds($mnY, $mxY, $y);
		($mnZ, $mxZ) = setBounds($mnZ, $mxZ, $z);


		my $exposed = 6; # 6 faces on a cube

		my $neighbours = neighbours($x, $y, $z);

		for my $n (@$neighbours) {
			$exposed -= 2 if (exists $occupied{key(@$n)});
		}

		$occupied{key($x, $y, $z)} = undef;

		return $acc+$exposed;
	},
	$lines,
	0,
	);

	print "bounding box is ($mnX, $mnY, $mnZ) -> ($mxX, $mxY, $mxZ)\n";
	# increase bounding box
	for my $valRef (\$mnX, \$mnY, \$mnZ) {
		$$valRef--;
	}

	for my $valRef (\$mxX, \$mxY, \$mxZ) {
		$$valRef++;
	}

	print "bounding box is ($mnX, $mnY, $mnZ) -> ($mxX, $mxY, $mxZ)\n";

	my $outside = 0;

	# with bounding box, start in a spot we know is empty, then flood fill to get all exposed cubes
	my @start = ($mnX, $mnY, $mnZ);

	my %outside = (
		key(@start) => undef,
	);

	my $boxCheck = withinBoundingBox([$mnX, $mnY, $mnZ],[$mxX, $mxY, $mxZ]);

	my @list = (\@start);
	while (scalar @list > 0) {
		my $node = shift @list;

		my ($x, $y, $z) = @$node;

		print "looking at ($x, $y, $z)\n";

		for my $nbr (@{neighbours($x, $y, $z)}) {
			my $key = key(@$nbr);

			print "\tneighbour at (" .join(',',@$nbr) . ') ';

			# neighbour is occupied
			if (exists $occupied{$key}) {

				print "is occupied\n";

				$outside++;
			} elsif (not exists $outside{$key} and $boxCheck->(@$nbr)) {

				print "is somewhere to look\n";

				$outside{$key} = undef;

				push @list, $nbr;
			} else {
				print "is not worth considering\n";
			}
		}

	}

	return $outside;
}

main(\&solveOne, \&solveTwo);
