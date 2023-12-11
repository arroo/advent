#!/usr/bin/env perl

use warnings;
use strict;

use open qw(:std :encoding(UTF-8));
use POSIX qw(ceil floor);

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub parse {
	my ($lines) = @_;

	my %base;

	my $size = scalar(@$lines);
	for my $x (-1 .. length($lines->[0])) {
		$base{"$x,-1"} = '.';
		$base{"$x,$size"} = '.';
	}

	return reduce(
		sub {
			my ($acc, $line, $i) = @_;

			my @separated = split //, $line;
			for my $j (0 .. $#separated) {
				$acc->{"$j,$i"} = $separated[$j];
				if ($separated[$j] eq 'S') {
					$acc->{'start'} = "$j,$i";
					$acc->{"$j,$i"} = 'J';#'F';#'J';
				}
			}

			$acc->{"-1,$i"} = $acc->{(scalar @separated) . ",$i"} = '.';

			return $acc;
		},
		$lines,
		\%base,
	);
}

sub nextNode {
	my ($x, $y, $symbol) = @_;

	if ($symbol eq '|') { # N-S
		return [[$x, $y+1],[$x,$y-1]];
	}

	if ($symbol eq '-') { # E-W
		return [[$x+1,$y],[$x-1,$y]];
	}

	if ($symbol eq 'L') { # N-E
		return [[$x,$y-1],[$x+1,$y]];
	}

	if ($symbol eq '7') { # S-W
		return [[$x,$y+1],[$x-1,$y]];
	}

	if ($symbol eq 'F') { # S-E
		return [[$x,$y+1],[$x+1,$y]];
	}

	if ($symbol eq 'J') { # N-W
		return [[$x,$y-1],[$x-1,$y]];
	}

	die "no pipe in $x,$y: $symbol\n";
}

sub solveOne {
	my ($lines) = @_;

	my $parsed = parse($lines);

	my %seen = ($parsed->{'start'} => 0);
	my @node = ("0,$parsed->{'start'}");
	while (scalar @node) {
		my $node = shift @node;

		my ($dist, $x, $y) = split /,/, $node;

		print "$node\n";

		my $next = nextNode($x, $y, $parsed->{"$x,$y"});
		$dist++;

		for my $n (@$next) {
			my ($x, $y) = @$n;

			if (not defined $seen{"$x,$y"}) {
				$seen{"$x,$y"} = $dist;
				push @node, "$dist,$x,$y";
			}
		}
	}

	return max(values %seen);

	return Dumper($parsed);
}

sub ceilFloor {
	my @out;

	for my $n (@_) {
		push @out, ceil($n), floor($n);
	}

	return @out;
}

sub canSqueeze {
	my ($x, $y, $game, $loop, $boundary) = @_;

	my $cx = ceil($x);
	my $fx = floor($x);

	my $cy = ceil($y);
	my $fy = floor($y);

	# both parts of squeeze have to be in part of loop
	if (not (exists $loop->{"$cx,$cy"} and exists $loop->{"$fx,$fy"})) {
		#return;
	}

	
	if ((exists $loop->{"$cx,$cy"} or exists $loop->{"$fx,$fy"}) and (exists $boundary->{"$cx,$cy"} or exists $boundary->{"$fx,$fy"})) {
		#return;
	}

	if (exists $boundary->{"$cx,$cy"} or exists $boundary->{"$fx,$fy"}) {
		return;
	}

	my ($lower, $upper) = @$game{("$fx,$fy", "$cx,$cy")};

	#print "$fx,$fy\n";

	if ($cy == $fy) {
		if (($lower eq '-' or $lower eq 'L' or $lower eq 'F') and
			($upper eq '-' or $upper eq 'J' or $upper eq '7')) {
			return;
		}
	}

	if ($cx == $fx) {
		if (($lower eq '|' or $lower eq 'F' or $lower eq '7') and
			($upper eq '|' or $upper eq 'L' or $upper eq 'J')) {
			return;
		}
	}

	return 1;
}

sub solveTwo {
	my ($lines) = @_;

	my $game = parse($lines);

	my %loop = ($game->{'start'} => undef);
	my @node = ($game->{'start'});
	while (scalar @node) {
		my $node = shift @node;

		my ($x,$y) = split /,/, $node;

		for my $n (@{nextNode($x, $y, $game->{$node})}) {
			my ($x, $y) = @$n;
			if (not exists $loop{"$x,$y"}) {
				$loop{"$x,$y"} = undef;
				push @node, "$x,$y";
			}
		}
	}

	my %north = map { $_ => undef } split //, qw(|JLS);

	my %inside;

	my $inside = reduce(
		sub {
			my ($acc, $line, $y) = @_;

			my @line = split //, $line;

			my $level = 0;
			my $boundary = 0;
			for my $x (0 .. $#line) {
				my $key = "$x,$y";

				if (exists $loop{$key}) {
					if (exists $north{$line[$x]}) {
						$boundary = ($boundary + 1) % 2;
					}
				} elsif ($boundary) {
					$inside{$key} = undef;
					$level++;
				}
			}

			print "line: $y inside: $level total: " . ($acc + $level) . "\n";

			return $acc + $level;
		},
		$lines,
		0,
	);

	# print map
	my $y = 0;
	my %charset = (
		'|' => "\N{U+2551}",#"\x{186}",
		'-' => "\N{U+2550}",#"\x{205}",
		'L' => "\N{U+255A}",#"\x{200}",
		'J' => "\N{U+255D}",#"\x{188}",
		'7' => "\N{U+2557}",#"\x{187}",
		'F' => "\N{U+2554}",#"\x{201}",
		'.' => '.',
	);
	for (my $y = 0; exists $game->{"0,$y"}; $y++) {
		for (my $x = 0; exists $game->{"$x,$y"}; $x++) {
			my $key = "$x,$y";
			if (exists $loop{$key}) {
				print red;
				print "$charset{$game->{$key}}";
				print reset;
				next;
			}

			if (exists $inside{$key}) {
				print green;
				print "\N{U+2588}";
				print reset;
				next;

			} else {
				print blue;
				print "\N{U+2593}";
				print reset;
				next;
			}

		}

		print "\n";
	}

	return $inside;
}

sub solveTwo2 {
	my ($lines) = @_;

	my $parsed = parse($lines);

	my %loop = ($parsed->{'start'} => undef);
	my @node = ($parsed->{'start'});
	while (scalar @node) {
		my $node = shift @node;

		my ($x,$y) = split /,/, $node;

		for my $n (@{nextNode($x, $y, $parsed->{$node})}) {
			my ($x, $y) = @$n;
			if (not exists $loop{"$x,$y"}) {
				$loop{"$x,$y"} = undef;
				push @node, "$x,$y";
			}
		}
	}

	@node = ("-1,-1"); # known to be outside loop
	my %outside;
	my %boundary;
	my %squeeze;
	my %squeezeSeen;
	while (scalar @node) {
		my $node = shift @node;

		my ($x, $y) = split /,/, $node;

		my @neighbours = (
			[$x-1,$y],
			[$x+1,$y],
			[$x,$y-1],
			[$x,$y+1],
		);

		for my $n (@neighbours) {
			my $key = join(',', @$n);

			if (exists $loop{$key}) {
				$boundary{$node} = undef;

				my ($xn, $yn) = @$n;
				if ($yn == $y) {

					my $ew = $xn / 2 + $x / 2;

					my $north = $yn-.5;
					if (canSqueeze($xn, $north, $parsed, \%loop, \%boundary)) {
						$squeeze{"$xn,$north"} = undef;
						$squeezeSeen{"$xn,$north"} = undef;
						$squeezeSeen{"$ew,$north"} = undef;
						$boundary{$node} = undef;
					}

					my $south = $yn+.5;
					if (canSqueeze($xn, $south, $parsed, \%loop, \%boundary)) {
						$squeeze{"$xn,$south"} = undef;
						$squeezeSeen{"$xn,$south"} = undef;
						$squeezeSeen{"$ew,$south"} = undef;
						$boundary{$node} = undef;
					}

				} else {

					my $ns = $yn / 2 + $y / 2;

					my $east = $xn+.5;
					if (canSqueeze($east, $yn, $parsed, \%loop, \%boundary)) {
						$squeeze{"$east,$yn"} = undef;
						$squeezeSeen{"$east,$yn"} = undef;
						$squeezeSeen{"$east,$ns"} = undef;
						$boundary{$node} = undef;
					}

					my $west = $xn-.5;
					if (canSqueeze($west, $yn, $parsed, \%loop, \%boundary)) {
						$squeeze{"$west,$yn"} = undef;
						$squeezeSeen{"$west,$yn"} = undef;
						$squeezeSeen{"$west,$ns"} = undef;
						$boundary{$node} = undef;
					}
				}

				next;
			}

			if (defined $parsed->{$key} and not exists $outside{$key}) {
				push @node, $key;
				$outside{$key} = undef;
			}
		}
	}

	#print Dumper(\%squeeze, \%squeezeSeen);

	@node = keys %squeeze;
	#@node=();
	while (scalar @node) {
		my $node = shift @node;
		$squeezeSeen{$node} = undef;

		my ($x, $y) = split /,/, $node;

		my $cx = ceil($x);
		my $fx = floor($x);

		my $cy = ceil($y);
		my $fy = floor($y);

		if ($cy == $fy) {
			my @neighbours = (
				[$x, $y-.5],
				[$x, $y+.5],
			);

			#print Dumper(\@neighbours);

			for my $n (@neighbours) {
				my $key = join(',', @$n);
				if (not exists $squeezeSeen{$key}) {
					push @node, $key;
				}
			}

		} elsif ($cx == $fx) {
			my @neighbours = (
				[$x-.5, $y],
				[$x+.5, $y],
			);

			#print Dumper(\@neighbours);

			for my $n (@neighbours) {
				my $key = join(',', @$n);
				if (not exists $squeezeSeen{$key}) {
					push @node, $key;
				}
			}

		} else { # corner
			my @neighbours = (
				[$fx, $y],
				[$cx, $y],
				[$x, $fy],
				[$x, $cy],
			);

			#print Dumper(\@neighbours);

			for my $n (@neighbours) {
				my $key = join(',', @$n);
				if (not exists $squeezeSeen{$key} and canSqueeze(@$n, $parsed, \%loop, \%boundary)) {
					push @node, $key;
					$squeeze{$key} = undef;
				}
			}
		}
	}

	#print Dumper(\%squeeze);

	#my %explore;
	for my $node (keys %squeeze) {
		my ($cx, $fx, $cy, $fy) = ceilFloor(split /,/, $node);

		for my $key ("$cx,$cy", "$fx,$fy") {
			if (not exists $loop{$key}) {
				#$explore{$key} = undef;
				$outside{$key} = undef;
			}
		}
	}

	#print Dumper(\%explore);

	# print map
	my $y = 0;
	my %charset = (
		'|' => "\N{U+2551}",#"\x{186}",
		'-' => "\N{U+2550}",#"\x{205}",
		'L' => "\N{U+255A}",#"\x{200}",
		'J' => "\N{U+255D}",#"\x{188}",
		'7' => "\N{U+2557}",#"\x{187}",
		'F' => "\N{U+2554}",#"\x{201}",
		'.' => '.',
	);
	for (my $y = -1; exists $parsed->{"-1,$y"}; $y++) {
		for (my $x = 0; exists $parsed->{"$x,$y"}; $x++) {
			my $key = "$x,$y";
			my $coloured = 0;
			if (exists $loop{$key}) {
				print red;
				print "$charset{$parsed->{$key}}";
				print reset;
				next;
			}


			if (exists $boundary{$key}) {
				print "\e[35m";
				print "\N{U+2593}";
				print reset;
				next;
				$coloured = 1;
			} elsif (exists $outside{$key}) {
				print blue;
				print "\N{U+2592}";
				print reset;
				next;
				$coloured = 1;
			#} elsif (exists $explore{$key}) {
			#	print green;
			#	$coloured = 1;
			} else {
				print green;
				print "\N{U+2588}";
				print reset;
				next;
				$coloured = 1;
			}
			print "\N{U+2593}";
			if ($coloured) {
				print reset;
			}

		}

		print "\n";
	}


	#print Dumper($parsed, \%outside, \%loop);

	return (scalar keys %$parsed) - (scalar keys %outside) - (scalar keys %loop) - 1;
}

main(\&solveOne, \&solveTwo);
