package AOC::GameOfLife;

use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);
our %EXPORT_TAGS = (
	'all' => [qw(
		iterate
		iterateCell
		neighbours
	)],
);
our @EXPORT_OK = (@{$EXPORT_TAGS{'all'}});

sub neighbours {
	my ($row, $col, $field) = @_;

	my @neighs;

	for my $r ($row - 1 .. $row + 1) {
		next if ($r < 0 or $r > $#$field); # out of bounds

		for my $c ($col - 1 .. $col + 1) {
			next if ($c < 0 or $c > $#{$field->[$r]}); # out of bounds

			next if ($c == $col and $r == $row); # self isn't neighbour

			push @neighs, $field->[$r][$c];
		}
	}

	return \@neighs;
}

# this will be application-specific
sub iterateCell {
	my ($old, $neighbours) = @_;

	return $old;
}

sub iterate {
	my ($field, $iterate, $neighbours) = @_;

	$neighbours //= \&golNeighbours;
	my @out;

	for my $row (0 .. $#$field) {
		my @newCol;

		for my $col (0 .. $#{$field->[$row]}) {
			push @newCol, $iterate->($field->[$row][$col], $neighbours->($row, $col, $field));
		}

		push @out, \@newCol;
	}

	return \@out;
}

1;
