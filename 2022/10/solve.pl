#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub solveOne {
	my ($lines) = @_;

	my %reports = map {$_=>undef} (20, 60, 100, 140, 180, 220);
	my $cc = sub {
		
	};

	return reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		my ($x, $cycle, $out)= @$acc;

		if ($line =~ /^noop$/) {
			# nothing?
			$cycle++;

		} elsif (my ($amount) = $line =~ /^addx (-?\d+)$/) {

			my $t = $cycle+1;
			if (exists $reports{$t}) {
				print "sneaky ";
				print "cycle $t : $x * $t = " . ($x * $t) . "\n";
				$out += $x * $t;
			}

			$cycle += 2;
			$x += $amount;

		} else {
			die "unparseable line: $line";
		}

		if (exists $reports{$cycle}) {
			print "cycle $cycle : $x * $cycle = " . ($x * $cycle) . "\n";
			$out += $x * $cycle;
		}

		return [$x, $cycle, $out];
	},
	$lines,
	[1, 1, 0],
	)->[2];
}

sub isVisible {
	my ($sprite, $cursor) = @_;

	return abs($sprite - $cursor) < 2;
}

sub nextChar {
	my ($sprite, $cursor) = @_;


	#	return isVisible($sprite, $cursor) ? emojis{'black'} : emojis{'white'};

	return isVisible($sprite, $cursor) ? '⬛':'⬜';

	return isVisible($sprite, $cursor) ? '█' : ' ';
}

sub cycleF {
	my ($screen, $width) = @_;

	return sub {
		my ($cycleRef, $sprite) = @_;

		push @{$screen}, nextChar($sprite, ($$cycleRef-1) % $width);
		$$cycleRef++;
	};
}

sub solveTwo {
	my ($lines) = @_;

	my ($width, $height) = (40, 6);

	my @screen;
	my $cc = cycleF(\@screen, $width);

	reduce(sub {
		my ($acc, $line, $i, $lines) = @_;

		my ($x, $cycle)= @$acc;

		if ($line =~ /^noop$/) {

			$cc->(\$cycle, $x);

		} elsif (my ($amount) = $line =~ /^addx (-?\d+)$/) {

			$cc->(\$cycle, $x);
			$cc->(\$cycle, $x);

			$x += $amount;

		} else {
			die "unparseable line: $line";
		}

		return [$x, $cycle];
	},
	$lines,
	[1, 1],
	);

	my $out = '';
	for my $cursor (1 .. $width * $height) {
		$out .= $screen[$cursor-1];

		$out .= "\n" if ($cursor % $width == 0);
	}
	chomp $out;

	return $out;
}

main(\&solveOne, \&solveTwo);
