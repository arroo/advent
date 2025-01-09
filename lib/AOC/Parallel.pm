package AOC::Parallel;

use strict;
use warnings;

require Exporter;

use AOC::Utils;

our @ISA qw(Exporter);
our %EXPORT_TAGS = (
	'all' => [qw(
	)],
);
our @EXPORT_OK = (@{$EXPORT_TAGS{'all'}});

sub parallelProcess {
	my ($arr, $fn, $max) = @_;

	$max ||= scalar @$arr;

	my @out;

	for my $i (0 .. $#$arr) {
		push @out, [$fn->($arr)];
	}

	return \@out;
}

sub parallelReduce {
	my ($cb, $arr, $init, $max) = @_;

	return reduce(
		sub {
			my ($acc, $item, $i, $arr) = @_;

		},
		parallelProcess($arr, $cb, $max);
		$init,
	);
}

1;
