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

my %HEADING = (
	'>' => 0,
	'v' => 1,
	'<' => 2,
	'^' => 3,
);

sub parse {
	my ($lines) = @_;

	my %map;
	my $maxCol = -1;

	my $i;
	for ($i = 0; $lines->[$i] ne ''; $i++) {

		my $line = $lines->[$i];

		$maxCol = max($maxCol, length($line));

		my @chars = split //, $line;

		for my $j (0 .. $#chars) {
			my $c = $chars[$j];

			if ($c eq ' ') {
				# empty space

			} elsif ($c eq '.') {
				$map{key($j+1, $i+1)} = '.'

			} elsif ($c eq '#') {
				$map{key($j+1, $i+1)} = undef;

			} else {
				die "malformed line $i: $line";
			}
		}
	}

	my $maxRow = $i;

	my @instructions = grep length, split /(\d+)/, $lines->[$i+1];

	return \%map, [$maxCol, $maxRow], \@instructions;
}

my %TURN = (
	'>' => {
		'L' => '^',
		'R' => 'v',
	},
	'v' => {
		'L' => '>',
		'R' => '<',
	},
	'<' => {
		'L' => 'v',
		'R' => '^',
	},
	'^' => {
		'L' => '<',
		'R' => '>',
	},
);

sub follow {
	my ($map, $x, $y, $h, $ins, $max) = @_;

	if ($ins =~ /^\d+$/) {
		my ($maxX, $maxY) = @$max;

		# move forward

		my ($nX, $nY) = ($x, $y);

		my $mv;
		if ($h eq '>') {
			$mv = sub { $nX = $nX >= $maxX ? 1 : $nX+1; };

		} elsif ($h eq '<') {
			$mv = sub { $nX = $nX <= 1 ? $maxX : $nX-1; };

		} elsif ($h eq '^') {
			$mv = sub { $nY = $nY <= 1 ? $maxY : $nY-1; };

		} elsif ($h eq 'v') {
			$mv = sub { $nY = $nY >= $maxY ? 1 : $nY+1; };

		} else {
			die "where am i facing: $h";
		}

		for my $i (1 .. $ins) {

			# move forward until you
			do {
				$mv->();
			} while (not exists $map->{key($nX, $nY)});

			if (not defined $map->{key($nX, $nY)}) {
				last;
			}

			($x, $y) = ($nX, $nY);
		}

		return ($x, $y, $h);

	} elsif ($ins =~ /^[LR]$/) {
		# turn
		return ($x, $y, $TURN{$h}{$ins});

	} else {
		die "malformed instruction: $ins";
	}

}

sub solveOne {
	my ($lines) = @_;

	my ($map, $max, $ins) = parse($lines);

	print Dumper($map, $max, $ins);

	my ($maxX, $maxY) = @$max;

	# find starting location
	my $y = 1;
	my $x;
	{
		for my $p (1 .. $maxX) {
			if (defined $map->{key($p, $y)}) {
				$x = $p;

				last;
			}
		}
		print "$x\n";
	}

	# starting heading
	my $h = '>';

	for my $ins (@$ins) {
		($x, $y, $h) = follow($map, $x, $y, $h, $ins, $max);
	}

	return $y * 1000 + 4 * $x + $HEADING{$h};
}

sub solveTwo {
	my ($lines) = @_;

	return reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		return $acc;
	},
	$lines,
	0,
	);
}

main(\&solveOne, \&solveTwo);
