#!/usr/bin/env perl

use warnings;
use strict;

use AOC::Base qw(:all);
use AOC::Math qw(:all);
use AOC::Utils qw(:all);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;


sub solveOne1 {
	my ($lines) = @_;

	my @blockDefs = split //, $lines->[0];

	print Dumper(\@blockDefs);

	my $sum = sum(@blockDefs);
	print "sum: $sum\n";

	# explode the thing
	my $blocks;
	for my $i (0 .. $#blockDefs) {

		my $char = ($i/2, '.')[$i % 2];

		$blocks .= $char x $blockDefs[$i];
	}

	print Dumper($blocks);

	return -1;
}

sub solveOne2 {
	my ($lines) = @_;

	my @blockDefs = split //, $lines->[0];

	my $sum = sum(map { $_ % 2 ? 0 : $blockDefs[$_] } 0 .. $#blockDefs);
	print Dumper(\@blockDefs, $sum);

	my $out = 0;
	my $chunk = 0;
	for my $i (0 .. $sum-1) {

 		my $something;
		if ($chunk % 2) { # odd means moved from higher
			$something = $#blockDefs/2;
			
		} else { # even means unmoved
			$something = $chunk/2;
		}

		if ($chunk % 2) {
			if ($blockDefs[$#blockDefs]-- == 0) { # remove empty end
				pop @blockDefs;
			}
		}

		if (--$blockDefs[$chunk] == 0) {
			$chunk++;
		}

		my $total = $i * $something;
		print "$i * $something = $total\n";

		$out += $i * $something;
	}

	return $out;
}

sub solveOne3 {
	my ($lines) = @_;

	my @blockDefs = split //, $lines->[0];

	# empties
	my @odds = map { $blockDefs[$_] } grep { $_ % 2 } 0 .. $#blockDefs;

	# blocks
	my @evens = map { $blockDefs[$_] } grep { $_ % 2 == 0 } 0 .. $#blockDefs;
	my @evens2 = map { [$_, $evens[$_]] } 0 .. $#evens;

	#print Dumper(\@evens, \@odds);

	my $out = 0;
	my $sum = sum(@evens);
	my $chunk = 0;
	my $lastChunk = $#evens;
	for my $i (0 .. $sum -1) {

		my $something;

		if ($chunk % 2) { # odd
			$something = $lastChunk;
			if (--$evens[$#evens] == 0) {
				$lastChunk--;
				pop @evens;
			}

			if (--$odds[0] == 0) {
				shift @odds;

				$chunk++;
			}

		} else { # even
			$something = $chunk/2;
			if (--$evens[$chunk/2] == 0) {
				$chunk++;
			}
		}

		my $total = $i * $something;
		print "\t$i * $something = $total\n";

		$out += $i * $something;
	}

	return $out;
}

sub solveOne {
	my ($lines) = @_;

	my @blockDefs = split //, $lines->[0];

	my @evens = map { $blockDefs[$_] } grep { $_ % 2 == 0 } 0 .. $#blockDefs;
	my @odds = map { $blockDefs[$_] } grep { $_ % 2 } 0 .. $#blockDefs;

	my $out = 0;
	my $i = 0;
	my $lastChunk = $#evens;
	my $chunk = 0;

	my $fromBack = sub {
		my $out = $lastChunk;

		$evens[-1]--;
		while ($evens[-1] == 0) {
			pop @evens;
			$lastChunk--;
		}

		return $out;
	};

	while (scalar @evens) {
		# evens
		for (0 .. $evens[0]-1) {

			my $total = $i * $chunk;
			#print "\t$i * $chunk = $total\n";

			$out += $i++ * $chunk;
		}
		$chunk++;
		shift @evens;

		next unless (scalar @odds);
		next unless (scalar @evens);

		# odds
		for (0 .. $odds[0]-1) {

			my $total = $i * $lastChunk;
			#print "\t$i * $lastChunk = $total\n";

			$out += $i++ * $lastChunk;

			#print Dumper(\@evens);

			$evens[-1]--;
			while (scalar @evens and $evens[-1] == 0) {
				pop @evens;
				$lastChunk--;
			}

			last unless (scalar @evens);
		}
		shift @odds;

	}

	return $out;
}

# 9146284526209 too high

sub solveTwo1 {
	my ($lines) = @_;

	my @blockDefs = split //, $lines->[0];


	my %lowestEmpty;

	my @blocks;
	for my $i (0 .. $#blockDefs) {

		next unless ($blockDefs[$i]);

		if ($i % 2) { # odd
			push @blocks, [$blockDefs[$i], undef];
			$lowestEmpty{$blockDefs[$i]} //= $#blocks;

		} else { # even
			push @blocks, [$blockDefs[$i], $i/2];
		}
	}

	#print Dumper(\@blocks, \%lowestEmpty);

	OUTER:for (my $m = 0; $m <= $#blocks; $m++) {
		my $i = $#blocks - $m;

		next unless (defined $blocks[$i]);

		my ($size, $value) = @{$blocks[$i]};
		{
			my $v = $value // 'undef';
			print "looking at block $i: ($size,$v)\n";
		}

		next if (not defined $value); # empty space

		# try to move to lowest
		#my $lowest;
		#for my $b ($size .. 9) {
		#	
		#}

		for my $j (0 .. $i) {
			next if (defined $blocks[$j][1]); # occupied
			next if ($blocks[$j][0] < $blocks[$i][0]); # not enough space

			print "can fit $size into $blocks[$j][0] at $j\n";

			my $oldSize = $blocks[$j][0];
			$blocks[$i][1] = undef;
			$blocks[$j] = [$size, $value];

			my $consolidateSize = $size;
			my $consolidateIdx = $i;
			my $consolidateLen = 1;
			if (not defined $blocks[$i-1][1]) { # consolidate block down
				$consolidateSize+=$blocks[$i-1][0];
				$consolidateIdx--;
				$consolidateLen++;
				print "\tconsolidate $i down\n";
			}
			if (not defined $blocks[$i+1][1]) { # consolidate block up
				$consolidateSize+=$blocks[$i+1][0];
				$consolidateLen++;
				print "\tconsolidate $i up\n";
			}

			if ($consolidateSize != $size) {
				splice @blocks, $consolidateIdx, $consolidateLen, [$consolidateSize, undef];
			}

			if ($oldSize > $size) { # create new block
				splice @blocks, $j+1, 0, [$oldSize - $size, undef];

				redo OUTER;
			}

			last;
		}
	}


	print Dumper(\@blocks);
	my $out = 0;
	my $i = 0;
	for my $block (@blocks) {
		my ($size, $value) = @$block;

		if (defined $value) {
			for my $j (0 .. $size-1) {
				$out += ($i + $j) * $value;
			}
		}

		$i += $size;
	}

	return $out;
}

sub solveTwo {
	my ($lines) = @_;

	my @blockDefs = split //, $lines->[0];

	my 
}

main(\&solveOne, \&solveTwo);
