#!/usr/bin/env perl

use warnings;
use strict;

use open qw(:std :encoding(UTF-8));
use Time::HiRes qw(usleep);

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub parse {
	my ($lines) = @_;

	my %blankRows;
	my %blankCols;
	my %galaxies;

	for my $y (0 .. $#$lines) {

		$lines->[$y] =~ s/[^#]/ /g;

		if ($lines->[$y] !~ m/#/) {
			$blankRows{$y} = undef;
			next;
		}

		my @line = split //, $lines->[$y];

		for my $x (0 .. $#line) {
			if ($line[$x] eq '#') {
				$galaxies{"$x,$y"} = undef;
			}
		}
	}

	my $transposed = transposeLines($lines);
	for my $x (0 .. $#$transposed) {
		if ($transposed->[$x] !~ m/#/) {
			$blankCols{$x} = undef;
		}
	}

	return {
		'rows'     => \%blankRows,
		'cols'     => \%blankCols,
		'galaxies' => \%galaxies,
	};

	for my $g (keys %galaxies) {
		my ($x, $y) = split /,/, $g;

		for my $k (keys %blankCols) {
			$galaxies{$g}{'cols'}{$x < $k ? 'under' : 'over'}{$k} = undef;
		}

		for my $k (keys %blankRows) {
			$galaxies{$g}{'rows'}{$y < $k ? 'under' : 'over'}{$k} = undef;
		}
	}

	return \%galaxies;
}

sub solveOne {
	my ($lines) = @_;

	return solve($lines, 2);
}

sub solveTwo {
	my ($lines) = @_;

	return solve($lines, 1000000);
}

sub draw {
	my ($galaxies) = @_;

	for my $y (0 .. $#$galaxies) {
		my $row = $galaxies->[$y];
		for my $x (0 .. $#$row) {
			print $row->[$x];
		}

		print "\n";
	}
}

sub solve {
	my ($lines, $skip) = @_;
	my $parsed = parse($lines);

	my %pairs;

	for my $start (keys %{$parsed->{'galaxies'}}) {
		my ($sx, $sy) = split /,/, $start;

		for my $end (keys %{$parsed->{'galaxies'}}) {
			next if ($start eq $end);
			next if (exists $pairs{"$end;$start"});

			my ($ex, $ey) = split /,/, $end;

			my $dist = manhattan($sx, $sy, $ex, $ey);

			my $blankCrosses = 0;
			$blankCrosses += scalar grep {$sx < $_ and $_ < $ex or $ex < $_ and $_ < $sx} keys %{$parsed->{'cols'}};
			$blankCrosses += scalar grep {$sy < $_ and $_ < $ey or $ey < $_ and $_ < $sy} keys %{$parsed->{'rows'}};

			$pairs{"$start;$end"} = {
				'dist' => $dist,
				'blanks' => $blankCrosses,
			};

			my $sleep = 1_000_000 / $dist;

			my @galaxies = map { [ split //, $_ ] } @$lines;

			my @preElbow = (
				[],
				["\N{U+255A}", "\N{U+2554}"],
				["\N{U+255D}", "\N{U+2557}"],
			);

			my $step = $sx < $ex ? 1 : -1;
			for (my $x = $sx; $x != $ex; $x += $step) {

				if ($x != $sx) {
					$galaxies[$sy][$x] = "\N{U+2550}";
				}


				$galaxies[$sy][$x] = (exists $parsed->{'cols'}{$x} ? green : red) . $galaxies[$sy][$x] . reset;
				system 'clear';
				draw(\@galaxies);
				usleep($sleep);
			}

			$step = $sy < $ey ? 1 : -1;
			my @elbow = ("\N{U+2551}");
			push @elbow, @{$preElbow[$sx <=> $ex]};
			for (my $y = $sy; $y != $ey+$step; $y += $step) {

				if ($y == $sy){
					if ($sx == $ex) {
					} elsif ($sy != $ey) {
						$galaxies[$y][$ex] = $elbow[$sy <=> $ey];
					}
				} elsif ($y != $ey) {
					$galaxies[$y][$ex] = "\N{U+2551}";
				}

				$galaxies[$y][$ex] = (exists $parsed->{'rows'}{$y} ? green : red) . $galaxies[$y][$ex] . reset;
				system 'clear';
				draw(\@galaxies);
				usleep($sleep);
			}
			usleep(3 * 500 * 1000);
		}
	}

	my $total = reduce(
		sub {
			my ($acc, $key) = @_;

			my ($dist, $blanks) = @{$pairs{$key}}{qw(dist blanks)};

			return $acc + $dist + $blanks * ($skip - 1);
		},
		[keys %pairs],
		0,
	);

	return $total;
}

main(\&solveOne, \&solveTwo);
