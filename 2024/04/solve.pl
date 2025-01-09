#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub up {
	my ($x, $y) = @_;

	return sub {
		return ($x, --$y);
	};
}

sub down {
	my ($x, $y) = @_;

	return sub {
		return ($x, ++$y);
	};
}

sub left {
	my ($x, $y) = @_;

	return sub {
		return (--$x,$y);
	};
}

sub right {
	my ($x, $y) = @_;

	return sub {
		return (++$x,$y);
	};
}

sub upleft {
	my ($x, $y) = @_;

	return sub {
		return (--$x,--$y);
	};
}

sub upright {
	my ($x, $y) = @_;

	return sub {
		return (++$x,--$y);
	};
}

sub downleft {
	my ($x, $y) = @_;

	return sub {
		return (--$x,++$y);
	};
}

sub downright {
	my ($x, $y) = @_;

	return sub {
		return (++$x,++$y);
	};
}

my %dirs = (
	'U' => \&up,
	'D' => \&down,
	'L' => \&left,
	'R' => \&right,
	'UL' => \&upleft,
	'UR' => \&upright,
	'DL' => \&downleft,
	'DR' => \&downright,
);


sub start {
	my ($map, $x, $y) = @_;

	my $found = 0;
	DIR: for my $k (keys %dirs) {
		my ($X,$Y) = ($x,$y);
		my $f = $dirs{$k}($X,$Y);
		for my $letter (split //, 'XMAS') {
			my $key = coordsKey($X,$Y);
			if (not defined $map->{$key} or $map->{$key} ne $letter) {
				next DIR;
			}

			($X,$Y) = $f->();
		}

		$found++;
	}

	return $found;
}

sub While {
	my ($map) = @_;

	my $target = 'XMAS';
	my $seen = 0;

	return sub {
		my ($x, $y) = @_;

		my $key = coordsKey($x, $y);

		return ((defined $map->{$key}) and ($map->{$key} eq substr($target, $seen++, 1)));
	};
}

sub start2 {
	my ($map, $x, $y) = @_;

	my @dirFs = (
		\&upWhile,
		\&downWhile,
		\&leftWhile,
		\&rightWhile,
		\&upLeftWhile,
		\&upRightWhile,
		\&downLeftWhile,
		\&downRightWhile,
	);

	my @out;
	for my $dirF (@dirFs) {
		my $found = $dirF->($x, $y, While($map));

		if (scalar @$found > 0) {

			my @keys = map { coordsKey(@$_) } @$found;

			#print Dumper($found, [@$map{@keys}]) . "\n";
		}

		if (scalar @$found == 4) {
			push @out, $found;
		}
	}

	return \@out;
}

sub solveOne {
	my ($lines) = @_;

	my $map = parseGrid($lines);

	my $out = 0;
	for my $key (grep { $map->{$_} eq 'X' } keys %$map) {
		$out += start($map, keyCoords($key));

		my $thing = start2($map, keyCoords($key));

		#print Dumper($thing);
	}

	return $out;

}

sub solveTwo {
	my ($lines) = @_;

	my $map = parseGrid($lines);

	my $out = 0;
	for my $key (grep { $map->{$_} eq 'A' } keys %$map) {
		my ($x, $y) = keyCoords($key);

		my $ul = $map->{coordsKey($x-1,$y-1)} // '';
		my $ur = $map->{coordsKey($x+1,$y-1)} // '';
		my $dl = $map->{coordsKey($x-1,$y+1)} // '';
		my $dr = $map->{coordsKey($x+1,$y+1)} // '';

		my @combos = (
			"$ul$dr",
			"$dr$ul",
			"$ur$dl",
			"$dl$ur",
		);

		$out += 2 == scalar grep { $_ eq 'MS' } @combos;
	}

	return $out;
}

main(\&solveOne, \&solveTwo);
