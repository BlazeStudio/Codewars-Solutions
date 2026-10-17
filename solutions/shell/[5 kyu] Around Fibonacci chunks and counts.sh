# Around Fibonacci: chunks and counts
# https://www.codewars.com/kata/59bf943cafcda28e31000130

# Another Fibonacci... yes but with other kinds of result.
# The function is named aroundFib or around_fib, depending of the language.
# Its parameter is n (positive integer).
#
# First you have to calculate f the value of fibonacci(n) with fibonacci(0) --> 0 and
# fibonacci(1) --> 1 (see: https://en.wikipedia.org/wiki/Fibonacci_number)
#
# - 1) Find the count of each digit ch in f (ch: digit from 0 to 9), call this value cnt and find the maximum value of cnt; call this maximum value maxcnt. If there are ties, the digit ch to consider is the first one - in natural digit order - giving maxcnt.
#
# - 2) Cut the value f into chunks of length at most 25. The last chunk may be 25 long or less.
#
# Example: for `n=100` you have only one chunk `354224848179261915075`
# Example: for `n=180` f is `18547707689471986212190138521399707760` and you have two chunks
# `1854770768947198621219013` and `8521399707760`. First length here is 25 and second one is 13.
#
# - At last return a string in the following format:
# "Last chunk ...; Max is ... for digit ..."
#
# where Max is maxcnt and digit the first ch (in 0..9) leading to maxcnt.
#
# Example: for `n=100` -> "Last chunk 354224848179261915075; Max is 3 for digit 1"
# Example: for `n=180` -> "Last chunk 8521399707760; Max is 7 for digit 7"
# Example: for `n=18000` -> "Last chunk 140258776000; Max is 409 for digit 1"
# Beware:
# fib(18000) has 3762 digits. Values of n are between 500 and 25000.
#
# Note
# Please maybe ask before translating.

aroundFib() {
    perl -Mbigint -e '
        my $n = shift;

        # Fast doubling:
        # Given (F(k), F(k+1)):
        # F(2k)   = F(k) * (2F(k+1) - F(k))
        # F(2k+1) = F(k)^2 + F(k+1)^2
        sub fib {
            my ($n) = @_;

            return (0, 1) if $n == 0;

            my ($a, $b) = fib(int($n / 2));

            my $c = $a * (2 * $b - $a);
            my $d = $a * $a + $b * $b;

            if ($n % 2 == 0) {
                return ($c, $d);
            } else {
                return ($d, $c + $d);
            }
        }

        my ($f, $next) = fib($n);
        my $s = "$f";

        # Count digits
        my @count = (0) x 10;

        for my $ch (split //, $s) {
            ++$count[$ch];
        }

        # First digit in natural order in case of a tie
        my $max = $count[0];
        my $digit = 0;

        for my $d (1 .. 9) {
            if ($count[$d] > $max) {
                $max = $count[$d];
                $digit = $d;
            }
        }

        # Chunks are formed from the LEFT, 25 digits at a time.
        my $len = length($s);
        my $r = $len % 25;

        my $last = $r
            ? substr($s, $len - $r)
            : substr($s, $len - 25);

        print "Last chunk $last; Max is $max for digit $digit\n";
    ' "$1"
}

aroundFib "$1"
