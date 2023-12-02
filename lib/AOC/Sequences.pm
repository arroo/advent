package AOC::Sequences;

use strict;
use warnings;

require Exporter;

use Data::Dumper;

our @ISA = qw(Exporter);
our %EXPORT_TAGS = (
	'all' => [qw(
		vanEck
		vanEckIter
	)],
);
our @EXPORT_OK = (@{$EXPORT_TAGS{'all'}});

#Van Eck's sequence: For n >= 1, if there exists an m < n such that a(m) = a(n), take the largest such m and set a(n+1) = n-m; otherwise a(n+1) = 0. Start with a(1)=0.
# 0, 0, 1, 0, 2, 0, 2, 2, 1, 6, 0, 5, 0, 2, 6, 5, 4, 0, 5, 3, 0, 3, 2, 9, 0, 4, 9, 3, 6, 14, 0, 6, 3, 5, 15, 0, 5, 3, 5, 2, 17, 0, 6, 11, 0, 3, 8, 0, 3, 3, 1, 42, 0, 5, 15, 20, 0, 4, 32, 0, 3, 11, 18, 0, 4, 7, 0, 3, 7, 3, 2, 31, 0, 6, 31, 3, 6, 3, 2, 8, 33, 0, 9, 56, 0, 3, 8, 7, 19, 0, 5, 37, 0, 3, 8, 8, 1
# https://oeis.org/A181391
sub vanEck {
	my ($game, $max) = @_;

	my $iter = vanEckIter($game);

	my $last;
	$last = $iter->() for (scalar @$game .. $max-1);
	return $last;
}

# will this be used? store for posterity
sub vanEckPlain {
	my ($game, $max) = @_;

	my $last = $game->[-1];

	# +1 because because turns are 1-based
	my %seen = map { $game->[$_] => $_ + 1 } (0 .. $#$game);

	for (my $turn = scalar @$game; $turn < $max; $turn++) {

		my $ago = 0;

		# actually seen this number before so track how many turns it's been since then
		if (defined $seen{$last} and $seen{$last} > 0) {
			$ago = $turn - $seen{$last};
		}

		$seen{$last} = $turn;
		$last = $ago;
	}

	return $last;
}

# an iterator for generating the next value of Van Eck's sequence for a given seed
sub vanEckIter {
	my ($game) = @_;

	my $last = $game->[-1];

	# +1 because because turns are 1-based
	my %seen = map { $game->[$_] => $_ + 1 } (0 .. $#$game);
	my $turn = scalar @$game;

	return sub {
		my $ago = 0;

		# actually seen this number before so track how many turns it's been since then
		if (defined $seen{$last} and $seen{$last} > 0) {
			$ago = $turn - $seen{$last};
		}

		$seen{$last} = $turn;
		$last = $ago;
		$turn++;

		return $last;
	};
}

1;
