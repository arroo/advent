package AOC::Math;

use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);
our %EXPORT_TAGS = (
	'all' => [qw(
		gcd
		lcm
		lcmRef
		min
		minRef
		max
		maxRef
		sum
		sumRef
		prod
		prodRef
		chineseRemainder
		manhattan
		lineLineIntersection
		lineSegmentLineSegmentIntersection
	)],
);
our @EXPORT_OK = (@{$EXPORT_TAGS{'all'}});

sub gcd {
	my ($x, $y) = @_;

	while ($x > 0) {
		($x, $y) = ($y % $x, $x);
	}

	return $y;
}

sub lcm {
	my @n = @_;

	return 0 unless (scalar @n);

	my $lcm = $n[0];
	my $y;
	for (my $i = 1; $i < scalar @n; $i++) {
		$lcm = $lcm / gcd($lcm, $n[$i]) * $n[$i];
	}

	return $lcm;

	#my ($x, $y) = @_;
	#($x && $y) and $x / gcd($x, $y) * $y or 0
}

sub lcmRef {
	my ($items) = @_;

	my $lcm = 1;

	for my $i (@$items) {
		$lcm = lcm($lcm, $i);
	}

	return $lcm;
}

# redo reduce to avoid the import
sub reduce {
	my ($cb, $arr, $init) = @_;

	$init = $cb->($init, $arr->[$_], $_, $arr) for (0..$#$arr);

	return $init;
}

sub minRef {
	my ($range) = @_;

	return reduce(
		sub {
			my ($acc, $cur) = @_;

			return $cur if ($cur <= ($acc // $cur));

			return $acc;
		},
		$range,
		undef,
	);
}

sub min {
	return minRef(\@_);
}

sub maxRef {
	my ($range) = @_;

	return reduce(
		sub {
			my ($acc, $cur) = @_;

			return $cur if ($cur >= ($acc // $cur));

			return $acc;
		},
		$range,
		undef,
	);
}

sub max {
	return maxRef(\@_);
}

sub sumRef {
	my ($arr) = @_;

	return reduce(sub {
		my ($acc, $i) = @_;
		return $acc + $i;
	},
	$arr,
	0,
	);
}

sub sum {
	return sumRef(\@_);
}

sub prodRef {
	my ($arr) = @_;

	return reduce(
		sub {
			my ($acc, $multiplicand) = @_;

			return $acc * $multiplicand;
		},
		$arr,
		1,
	);
}

sub prod {
	return prodRef(\@_);
}

# apply the chinese remainder theorem - assumes it's solvable (mod values are coprime):
# find smallest 'x' s.t.
# x = a1 mod m1
# x = a2 mod m2
# ...
# x = ak mod mk
# $pairs = { m1 => a1, m2 => a2, ..., mk => ak }
# returns x
sub chineseRemainder {
	my ($pairs) = @_;

	my $inv = sub {
		my ($i, $m) = @_;

		return 1 if $m == 1;

		my $m0 = $m;
		my $x0 = 0;
		my $x1 = 1;

		while ($i > 1) {
			(
				$i,
				$m,
				$x0,
				$x1
			) = (
				$m,
				$i % $m,
				$x1 - int($i / $m) * $x0,
				$x0
			);
		}

		return ($x1 + $m0) % $m0;
	};

	my $M = prod(keys %$pairs);

	return reduce (
		sub {
			my ($acc, $p) = @_;

			my ($rem, $mod) = @$p;

			my $m = $M / $mod;

			my $inverse = $inv->($m, $mod);

			return ($acc + $inverse * $m * $rem) % $M;
		},
		[ map { [ $pairs->{$_}, $_ ] } sort { $b <=> $a } keys %$pairs ],
		0,
	);
}

sub manhattan {
	my ($xS, $yS, $xD, $yD) = @_;

	return abs($xD - $xS) + abs($yD - $yS);
}

sub lineLineIntersection {
	my ($x0, $y0, $x1, $y1, $x2, $y2, $x3, $y3) = @_;

	my $A = [$x0, $y0];
	my $B = [$x1, $y1];
	my $C = [$x2, $y2];
	my $D = [$x3, $y3];

	my $fst = sub { return $_[0][0] };
	my $scd = sub { return $_[0][1] };

	my $a1 = $scd->($B) - $scd->($A);
	my $b1 = $fst->($A) - $fst->($B);
	my $c1 = $a1 * $fst->($A) + $b1 * $scd->($A);

	my $a2 = $scd->($D) - $scd->($C);
	my $b2 = $fst->($C) - $fst->($D);
	my $c2 = $a2 * $fst->($C) + $b2 * $scd->($C);

	my $determinant = $a1 * $b2 - $a2 * $b1;

	return undef if $determinant == 0;

	my $x = ($b2 * $c1 - $b1 * $c2) / $determinant;
	my $y = ($a1 * $c2 - $a2 * $c1) / $determinant;

	return [$x, $y];
}

# assumes point lies on line
sub pointOnLineSegment {
	my ($xP, $yP, $x0, $y0, $x1, $y1) = @_;

	my $minX = min($x0, $x1);
	my $maxX = max($x0, $x1);
	my $minY = min($y0, $y1);
	my $maxY = max($y0, $y1);

	return $minX <= $xP && $xP <= $maxX && $minY <= $yP && $yP <= $maxY
}

sub lineSegmentLineSegmentIntersection {
	my ($x0, $y0, $x1, $y1, $x2, $y2, $x3, $y3) = @_;

	my $int = lineLineIntersection($x0, $y0, $x1, $y1, $x2, $y2, $x3, $y3);

	return unless (defined $int and pointOnLineSegment(@$int, $x0, $y0, $x1, $y1) and pointOnLineSegment(@$int, $x2, $y2, $x3, $y3));

	return $int;
}

sub rotate {
	my ($x0, $y0, $xO, $yO) = @_;
}

1;
