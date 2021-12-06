package AOC::Base;

use strict;
use warnings;

require Exporter;

use AOC::Utils qw(:all);

use Data::Dumper;

our @ISA = qw(Exporter);
our %EXPORT_TAGS = (
	'all' => [qw(
		main
	)],
);
our @EXPORT_OK = (@{$EXPORT_TAGS{'all'}});

sub main {
	my ($solveOne, $solveTwo) = @_;

	my $input = slurp();

	my $solver = $solveTwo;
	if (scalar @ARGV >= 1 and $ARGV[0] eq '1') {
		$solver = $solveOne;
	}

	my $solution = $solver->($input);

	print "$solution\n";
}

1;
