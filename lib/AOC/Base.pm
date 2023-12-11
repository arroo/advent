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
		emojis
		WHITE
		BLACK
		RED
		ORANGE
		YELLOW
		GREEN
		BLUE
		PURPLE
		BROWN
		bold
		reset
		red
		green
		blue
	)],
);
our @EXPORT_OK = (@{$EXPORT_TAGS{'all'}});

use constant WHITE  => 'white';
use constant BLACK  => 'black';
use constant RED    => 'red';
use constant ORANGE => 'orange';
use constant YELLOW => 'yellow';
use constant GREEN  => 'green';
use constant BLUE   => 'blue';
use constant PURPLE => 'purple';
use constant BROWN  => 'brown';

use constant bold  => "\e[1m";
use constant reset => "\e[0m";
use constant red   => "\e[31m";
use constant green => "\e[32m";
use constant blue  => "\e[34m";

#use constant emojis => (
#	WHITE  => '⬜',
#	BLACK  => '⬛',
#	RED    => '🟥',
#	ORANGE => '🟧',
#	YELLOW => '🟨',
#	GREEN  => '🟩',
#	BLUE   => '🟦',
#	PURPLE => '🟪',
#	BROWN  => '🟫',
#);

sub emojis {
	return {
		WHITE  => '⬜',
		BLACK  => '⬛',
		RED    => '🟥',
		ORANGE => '🟧',
		YELLOW => '🟨',
		GREEN  => '🟩',
		BLUE   => '🟦',
		PURPLE => '🟪',
		BROWN  => '🟫',
	};
}

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
