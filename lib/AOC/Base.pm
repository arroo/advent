package AOC::Base;

use strict;
use warnings;

use threads;
use threads::shared;

require Exporter;

use AOC::Utils qw(:all);

use Data::Dumper;

our @ISA = qw(Exporter);
our %EXPORT_TAGS = (
	'all' => [qw(
		main
		keyCoords
		coordsKey
		parseGrid
		upWhile
		downWhile
		leftWhile
		rightWhile
		upLeftWhile
		upRightWhile
		downLeftWhile
		downRightWhile
		cardinalNeighbours
		cardinalNeighbourKeys
	)],
);
our @EXPORT_OK = (@{$EXPORT_TAGS{'all'}});

my $keySep = ',';

sub keyCoords {
	return (split /$keySep/, $_[0]);
}

sub coordsKey {
	return join($keySep, @_);
}

sub parseGrid {
	my ($lines) = @_;

	my $maxX = 0;
	my $map = reduce(
		sub {
			my ($acc, $line, $y) = @_;

			my @chars = split //, $line;
			for my $x (0 .. $#chars) {
				$acc->{coordsKey($x,$y)} = $chars[$x];

				if ($x > $maxX) {
					$maxX = $x;
				}
			}

			return $acc;
		},
		$lines,
		{},
	);

	if (wantarray) {
		return ($map, $maxX, $#$lines);
	}

	return $map;
}

sub directionWhile {
	my ($x, $y, $condF, $nextF) = @_;

	my @out;

	for (; $condF->($x, $y); ($x, $y) = $nextF->($x, $y)) {
		push @out, [$x, $y];
	}

	return \@out;
}

sub upWhile {
	my ($x, $y, $condF) = @_;

	return directionWhile($x, $y, $condF, sub {
		my ($x, $y) = @_;

		return ($x, $y-1);
	});
}

sub downWhile {
	my ($x, $y, $condF) = @_;

	return directionWhile($x, $y, $condF, sub {
		my ($x, $y) = @_;

		return ($x, $y+1);
	});
}

sub leftWhile {
	my ($x, $y, $condF) = @_;

	return directionWhile($x, $y, $condF, sub {
		my ($x, $y) = @_;

		return ($x-1, $y);
	});
}

sub rightWhile {
	my ($x, $y, $condF) = @_;

	return directionWhile($x, $y, $condF, sub {
		my ($x, $y) = @_;

		return ($x+1, $y);
	});
}

sub upLeftWhile {
	my ($x, $y, $condF) = @_;

	return directionWhile($x, $y, $condF, sub {
		my ($x, $y) = @_;

		return ($x-1,$y-1);
	});
}

sub upRightWhile {
	my ($x, $y, $condF) = @_;

	return directionWhile($x, $y, $condF, sub {
		my ($x, $y) = @_;

		return ($x+1,$y-1);
	});
}

sub downLeftWhile {
	my ($x, $y, $condF) = @_;

	return directionWhile($x, $y, $condF, sub {
		my ($x, $y) = @_;

		return ($x-1,$y+1);
	});
}

sub downRightWhile {
	my ($x, $y, $condF) = @_;

	return directionWhile($x, $y, $condF, sub {
		my ($x, $y) = @_;

		return ($x+1,$y+1);
	});
}

sub cardinalNeighbours {
	my @vector = @_;

	my @neighbours;
	for my $i (0 .. $#vector) {
		$vector[$i]+=1;
		push @neighbours, [@vector];

		$vector[$i]-=2;
		push @neighbours, [@vector];

		$vector[$i]+=1;
	}

	return \@neighbours;
}

sub cardinalNeighbourKeys {
	my ($key) = @_;

	return [map {coordsKey(@$_)} @{cardinalNeighbours(keyCoords($key))}];
}

sub main {
	my ($solveOne, $solveTwo) = @_;

	my $input :shared = slurp();

	my $solver = $solveTwo;
	if (scalar @ARGV >= 1 and $ARGV[0] eq '1') {
		$solver = $solveOne;
	}

	my $solution = $solver->($input);

	print "$solution\n";
}

1;
