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
		AStar
		dijkstra
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

#function reconstruct_path(cameFrom, current)
#    total_path := {current}
#    while current in cameFrom.Keys:
#        current := cameFrom[current]
#        total_path.prepend(current)
#    return total_path
#
# A* taken from https://en.wikipedia.org/wiki/A*_search_algorithm
#// A* finds a path from start to goal.
#// h is the heuristic function. h(n) estimates the cost to reach goal from node n.
sub AStar {
	my ($start, $goal, $heuristicFn) = @_;
#function A_Star(start, goal, h)
	# The set of discovered nodes that may need to be (re-)expanded.
	# Initially, only the start node is known.
	# This is usually implemented as a min-heap or priority queue rather than a hash-set.
	# openSet := {start}
	my @openSet = ($start);

	# For node n, cameFrom[n] is the node immediately preceding it on the cheapest path from start
	# to n currently known.
	# cameFrom := an empty map
	my %cameFrom;

	# For node n, gScore[n] is the cost of the cheapest path from start to n currently known.
	# gScore := map with default value of Infinity
	# gScore[start] := 0
#
#    // For node n, fScore[n] := gScore[n] + h(n). fScore[n] represents our current best guess as to
#    // how short a path from start to finish can be if it goes through n.
#    fScore := map with default value of Infinity
#    fScore[start] := h(start)
#
#    while openSet is not empty
#        // This operation can occur in O(1) time if openSet is a min-heap or a priority queue
#        current := the node in openSet having the lowest fScore[] value
#        if current = goal
#            return reconstruct_path(cameFrom, current)
#
#        openSet.Remove(current)
#        for each neighbor of current
#            // d(current,neighbor) is the weight of the edge from current to neighbor
#            // tentative_gScore is the distance from start to the neighbor through current
#            tentative_gScore := gScore[current] + d(current, neighbor)
#            if tentative_gScore < gScore[neighbor]
#                // This path to neighbor is better than any previous one. Record it!
#                cameFrom[neighbor] := current
#                gScore[neighbor] := tentative_gScore
#                fScore[neighbor] := tentative_gScore + h(neighbor)
#                if neighbor not in openSet
#                    openSet.add(neighbor)
#
#    // Open set is empty but goal was never reached
#    return failure
	return undef;
}

sub dijkstra {
	my ($graph, $source) = @_;

	my @queue;
	my %distance;
	my %prev;

	for my $node (@$graph) { # TODO: define data structure
		$distance{$node} = ~0; # infinite distance
		$previous{$node} = undef;
		push @queue, $node;
	}

	$distance{$source} = 0;

	while (scalar @queue > 0) {
		@queue = sort { $distance{$a} <=> $distance{$b} } @queue;

		my $node = shift @queue;

		for my $elem (grep { $_ } @$graph) { # TODO: what's this grep for?
			my ($v) = grep { $_ ne $node } @$elem;

		
		}
	}

	return [\%distance, \%previous];
}

1;
