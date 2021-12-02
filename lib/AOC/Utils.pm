package AOC::Utils;

use strict;
use warnings;

require Exporter;

use Data::Dumper;
use LWP::UserAgent;
use HTML::Parser;

our @ISA = qw(Exporter);
our %EXPORT_TAGS = (
	'all' => [qw(
		flatten
		intersection
		intersectionHash
		groupByBlankLine
		slurp
		slurpIterate
		processLines
		processRegexMatch
		randomAccessReduce
		reduce
		reduceHash
		reduceHashKV
		reduceFn
		reduceRegex
		getSingleHashKey

		makeInclusiveRangeTest
		atLeastOne

		submit
		parseResponse

	)],
);
our @EXPORT_OK = (@{$EXPORT_TAGS{'all'}});

my $base = 'https://adventofcode.com';

sub slurp {
	my @lines;

	while (<>) {
		chomp;
		push @lines, $_;
	}

	return \@lines;
}

sub slurpIterate {
	my ($fn) = @_;

	my $i = 0;
	while (<>) {
		chomp;
		$fn->($_, $i++);
	}
}

sub processLines {
	my ($fn, $lines) = @_;

	for my $i (0..$#$lines) {
		$fn->($i, $lines->[$i]);
	}
}

sub processRegexMatch {
	my ($re, $fn, $lines) = @_;

	for my $line (@$lines) {
		$fn->($line =~ $re);
	}

	return;
}

sub reduceHash {
	my ($cb, $hsh, $init) = @_;

	$init = $cb->($init, $hsh->{$_}, $_, $hsh) for keys %$hsh;

	return $init;
}

sub reduceHashKV {
	my ($cb, $hsh, $init) = @_;

	$init = $cb->($init, $_, $hsh->{$_}, $hsh) for keys %$hsh;

	return $init;
}

sub reduce {
	my ($cb, $arr, $init) = @_;

	$init = $cb->($init, $arr->[$_], $_, $arr) for (0..$#$arr);

	return $init;
}

sub reduceFn {
	my ($fn, $cb, $arr, $init) = @_;

	for my $i (0..$#$arr) {
		$init = $cb->($init, $fn->($arr->[$i], $i), $i, $arr);
	}

	return $init;
}

sub reduceRegex {
	my ($re, $cb, $arr, $init) = @_;

	my $fn = sub {
		my ($item, $i) = @_;

		return [$item =~ $re];
	};

	return reduceFn($fn, $cb, $arr, $init);
}

sub randomAccessReduce {
	my ($cb, $arr, $init) = @_;

	for (my $i = 0; defined $i && 0 <= $i && $i <= $#$arr; ) {
		($init, $i) = $cb->($init, $arr->[$i], $i, $arr);
	}

	return $init;
}

# flatten any level of array
sub flatten {
	return map { ref eq 'ARRAY' ? flatten(@$_) : $_ } @_;
}

# given an input that separates groups by blank lines, group them together
sub groupByBlankLine {
	my ($lines) = @_;

	my @groups;
	my @cur;

	for my $line (@$lines) {
		if ($line ne '') {
			push @cur, $line;

			next;
		}

		my @copy = @cur;
		push @groups, \@copy;
		@cur = ();
	}

	# last group
	push @groups, \@cur;

	return \@groups;
}

# given 2 array refs, return common elements from them
sub intersection {
	my ($A, $B) = @_;

	return intersectionHash(
		{ map { $_ => undef } @$A },
		{ map { $_ => undef } @$B },
	);
}

# given 2 hash refs, return common keys from them
sub intersectionHash {
	my ($A, $B) = @_;

	return [grep { exists $A->{$_} } keys %$B];
}

# take in hash ref that is assumed to have exactly 1 key in it and return that
sub getSingleHashKey {
	my ($hash) = @_;

	die "invalid single-key hash: " . Dumper($hash) if (scalar keys %$hash != 1);

	for my $key (keys %$hash) {
		return $key;
	}
}

# close over a range and return a test indicating whether a value lies within it
sub makeInclusiveRangeTest {
	my ($lo, $hi) = @_;

	return sub {
		my ($val) = @_;

		return $lo <= $val && $val <= $hi;
	};
}

# take in a list of tests and return a test that returns true if at least one returns true
sub atLeastOne {
	my ($tests) = @_;

	return sub {
		my ($val) = @_;

		for my $t (@$tests) {
			return 1 if $t->($val);
		}

		return 0;
	};
}

sub getPuzzle {
	my ($year, $day, $session) = @_;

	my $ua = LWP::UserAgent->new();

	my $url = "$base/$year/day/$day/input";

	my $response;
	{
		local $SIG{__DIE__};
		$response = $ua->get($url);
	}
	if ($@) {
		
	}
}

use Data::Dumper;

sub submit {
	my ($session, $year, $day, $level, $answer) = @_;

	my $file = "answer";

	my $url = "$base/$year/day/$day/$file";

	my $body = "level=$level&answer=$answer";

	my $ua = LWP::UserAgent->new();

	my $req = HTTP::Request->new('POST', $url, [ cookie => "session=$session", 'content-type' => 'application/x-www-form-urlencoded' ], $body);

	my $res = $ua->request($req);

	my $code = $res->code();
	my $content = $res->decoded_content();

	if ($code ne '200') {
		return ($code, $content);
	}

	if ($content =~ /that's the right answer/i) {
	} elsif ($content =~ /did you already complete it/i) {
	} elsif ($content =~ /that's not the right answer/i) {
		if ($content =~ /please wait (.+) before trying again/i) {}
	} elsif ($content =~ /you gave an answer too recently/i) {
		if ($content =~ /you have (.+) left to wait/i) {}
	} else {
	}

	return ($code, $content);
}

# this could probably be put into submit
sub parseResponse {
	my ($code, $content) = @_;

	my $p = HTML::Parser->new();

	# add handlers here?

	$p->parse($content);
	$p->eof();
}

1;
