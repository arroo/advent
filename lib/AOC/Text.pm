package AOC::Text;

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
		emojis

		sgr
		csi
		coloured
		bold
		faint
	)],
#		WHITE
#		BLACK
#		RED
#		ORANGE
#		YELLOW
#		GREEN
#		BLUE
#		PURPLE
#		BROWN
#		bold
#		reset
#		red
#		green
#		blue
#	)],
);
our @EXPORT_OK = (@{$EXPORT_TAGS{'all'}});

#use constant WHITE  => 'white';
#use constant BLACK  => 'black';
#use constant RED    => 'red';
#use constant ORANGE => 'orange';
#use constant YELLOW => 'yellow';
#use constant GREEN  => 'green';
#use constant BLUE   => 'blue';
#use constant PURPLE => 'purple';
#use constant BROWN  => 'brown';
#
#use constant bold  => "\e[1m";
#use constant reset => "\e[0m";
#use constant red   => "\e[31m";
#use constant green => "\e[32m";
#use constant blue  => "\e[34m";

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

my %colours = map { $_->[0] => $_->[1] } (
	[ 'reset', 0 ],
	(map { [ $_->[0], 30 + $_->[1] ] }
		['black', 0],
		['red', 1],
		['green', 2],
		['yellow', 3],
		['blue', 4],
		['magenta', 5],
		['cyan', 6],
		['white', 7],
	),
	(map { [ "bright $_->[0]", 90 + $_->[1] ] }
		['black', 0],
		['red', 1],
		['green', 2],
		['yellow', 3],
		['blue', 4],
		['magenta', 5],
		['cyan', 6],
		['white', 7],
	),
);

sub csi {
	my ($param, $intermediate, $final) = @_;

	return join('', "\e[", $param, $intermediate, $final);
}

sub sgr {
	return csi(join(';', @_), '', 'm');
}

# call this after adding escape sequences to text to add a reset to the end of it
sub addReset {
	my ($text) = @_;

	my $rcsi = sgr($colours{'reset'});

	my $ercsi = $rcsi;
	$ercsi =~ s/\[/\\[/g;
	#$text =~ s/(?:$ercsi)+\z/$rcsi/g;
	$text =~ s/(?:$ercsi)+\z//g;

	return "$text$rcsi";
}

sub addSGR {
	my ($n, $text) = @_;

	return addReset(join('', sgr($n), $text));
}

sub bold {
	return addSGR(1, @_);
}

sub faint {
	return addSGR(2, @_);
}

sub coloured {
	my ($fg, $text, $bg) = @_;

	my $csi = sgr($colours{$fg}, defined $bg ? $colours{$bg}+10 : ());

	#print Dumper(\%colours);
	my $rcsi = sgr($colours{'reset'});

	$text = join('', $csi, $text, $rcsi);

	my $ercsi = $rcsi;
	$ercsi =~ s/\[/\\[/g;

	$text =~ s/(?:$ercsi)+\z/$rcsi/g;

	return $text;

	#my $reset = $text =~ m/\\$rcsi$/ ? '' : $rcsi;
	#return "$csi$text$reset";
}

1;
