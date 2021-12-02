package AOC::Algorithms;

use strict;
use warnings;

require Exporter;

use Data::Dumper;

our @ISA = qw(Exporter);
our %EXPORT_TAGS = (
	'all' => [qw(
		isNum
		standardShuntingValues
		shuntingYardGenerator
		reversePolishNotationGenerator
		standardReversePolishNotationGenerator
	)],
);
our @EXPORT_OK = (@{$EXPORT_TAGS{'all'}});

sub isNum {
	my ($token) = @_;
	return $token =~ /[+-]?(?:\.\d+|\d+(?:\.\d*)?)/;
}

sub min {
	my $min;
	for my $cur (@_) {
		$min = $cur if ($cur <= ($min // $cur));
	}
	return $min;
}

sub standardShuntingValues {
	my ($openGroup, $closeGroup) = ('(', ')');

	my %precedence = (
		'^' => 4,
		'*' => 3,
		'/' => 3,
		'+' => 2,
		'-' => 2,
	);

	# To prevent cases where operands would be associated with two operators, or no operator at all, operators with the same precedence must have the same associativity.
	# https://en.wikipedia.org/wiki/Operator_associativity
	my %associativity = (
		4 => 'right',
		3 => 'left',
		2 => 'left',
		1 => 'left',
	);

	return ($openGroup, $closeGroup, \%precedence, \%associativity, \&isNum);

	# going to leave this in in case associativity gets wonky in a problem
	my %legacyAssociativity = map { $_ => $associativity{$precedence{$_}} } keys %precedence;

	return ($openGroup, $closeGroup, \%precedence, \%legacyAssociativity, \&isNum);
}

# a method for parsing mathematical expressions specified in infix notation. output is in Reverse Polish Notation
# https://en.wikipedia.org/wiki/Shunting-yard_algorithm
# expected input is symbols separated by spaces
# adapted from https://titanwolf.org/Network/Articles/Article?AID=7ee70089-340b-47d5-9b2b-d68f0b69ddce#gsc.tab=0
# 	note: example is malformed as it does not separate all symbols with spaces
sub shuntingYardGenerator {

	my ($openGroup, $closeGroup, $precedence, $associativity, $isOperand) = @_;

	$precedence->{$openGroup} = min(values %$precedence) - 1;
	my $isRightAssociative = sub {
		my ($token) = @_;

		# To prevent cases where operands would be associated with two operators, or no operator at all, operators with the same precedence must have the same associativity.
		# https://en.wikipedia.org/wiki/Operator_associativity
		return $associativity->{$precedence->{$token}} eq 'right';
		return $associativity->{$token} eq 'right'; # going to leave this in in case associativity gets wonky in a problem
	};

	return sub {
		my ($input) = @_;

		my @operations;
		my @result;

		while (scalar @$input) {
			my $token = shift @$input;
			# numeral
			if ($isOperand->($token)) {
				push @result, $token;

				# opening bracket
			} elsif ( $token eq $openGroup ) {
				push @operations, $token;

				# closing bracket
			} elsif ( $token eq $closeGroup ) {
				while ( @operations and $openGroup ne ( my $x = pop @operations ) ) { push @result, $x }

				# operator
			} elsif (defined $precedence->{$token}) {
				my $newprec = $precedence->{$token};
				while (scalar @operations) {
					my $oldprec = $precedence->{ $operations[-1] };
					last if $newprec > $oldprec;
					last if $newprec == $oldprec and $isRightAssociative->($token);
					push @result, pop @operations;
				}

				push @operations, $token;

			} else {
				die "unknown token:'$token'\n";
			}
		}

		# why reverse?
		push @result, reverse splice @operations;

		return \@result;
	};
}

# given an array of symbols in reverse polish notation (https://en.wikipedia.org/wiki/Reverse_Polish_notation) and a method of translating symbols into operations, solve the equation
# worth noting in case I forget: RPN has no precedence-parsing requirements as everything is already in precedence order
# adapted from https://perlmaven.com/reverse-polish-calculator-in-perl
# expected inputs are:
# $isOperand = fn(arg) -> bool : is arg an operand e.g. give 4 5 +, is it a 4 or 5
# $ops = map{symbol}->[count, fn(arg...) -> symbol(s)/results(s)] : which go back onto the work stack], count is the number of operands fn takes
sub reversePolishNotationGenerator {
	my ($isOperand, $ops) = @_;

	return sub {
		my ($work) = @_;

		my @stack;

		while (scalar @$work) {
			my $symbol = shift @$work;

			# add item to stack
			if ($isOperand->($symbol)) {
				push @stack, $symbol;

			# remove last N ($terms) from stack and call operation on them
			} elsif (defined $ops->{$symbol}) {
				my ($terms, $op) = @{$ops->{$symbol}};
				push @stack, $op->(splice(@stack, -$terms));

			} else {
				die "unknown symbol: $symbol";
			}
		}

		if (scalar @stack != 1) {
			die "stack not fully processed: " . join(', ', @stack) . "\n";
		}

		return $stack[0];
	};
}

# given standard numerical and arithmetic symbols & operations, create a generator for them in RPN
sub standardReversePolishNotationGenerator {
	my ($isOperand) = @_;

	# standard numerical parsing with optional override
	$isOperand //= \&isNum;

	my %operations = (
		'+' => [2, sub {
				my ($x, $y) = @_;
				return $x + $y;
			}],
		'-' => [2, sub {
				my ($x, $y) = @_;
				return $x - $y;
			}],
		'*' => [2, sub {
				my ($x, $y) = @_;
				return $x * $y;
			}],
		'/' => [2, sub {
				my ($x, $y) = @_;
				return $x / $y;
			}],
		'^' => [2, sub {
				my ($x, $y) = @_;
				return $x ** $y;
			}],
	);

	return reversePolishNotationGenerator($isOperand, \%operations);
}

# had to snag this since it's so neat at evaluating standard RPN
# input is RPN string
sub rpnRegex {
	my ($in) = @_;

	my $number   = '[+-]?(?:\.\d+|\d+(?:\.\d*)?)';
	my $operator = '[-+*/^]';

	my $out = $in;
	while ($out =~
		s/ \s* ((?<left>$number))     # 1st operand
		   \s+ ((?<right>$number))    # 2nd operand
		   \s+ ((?<op>$operator))     # operator
		   (?:\s+|$)                  # more to parse, or done?
		/
		   ' '.rpnRegexEvaluate().' ' # substitute results of evaluation
		/ex
	) {}

	return $out;
}

sub rpnRegexEvaluate {
	# uses %+ which is last-done capture group
	(my $val = "($+{left})$+{op}($+{right})") =~ s/\^/**/;

        return eval $val;
}

1;
