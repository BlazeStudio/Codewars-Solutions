# Decimal to Factorial and Back
# https://www.codewars.com/kata/54e320dcebe1e583250008fd

# Coding decimal numbers with factorials is a way of writing out numbers
# in a base system that depends on factorials, rather than powers of numbers.
#
# In this system, the last digit is always 0 and is in base 0!. The digit before that is either 0 or 1 and is in base 1!.  The digit before that is either 0, 1, or 2 and is in base 2!, etc.
# More generally, the nth-to-last digit is always 0, 1, 2, ..., n and is in base n!.
#
# Read more about it at: http://en.wikipedia.org/wiki/Factorial_number_system
#
# Example
#
# The decimal number 463 is encoded as "341010", because:
#
# 463 = 3×5! + 4×4! + 1×3! + 0×2! + 1×1! + 0×0!
#
# If we are limited to digits 0..9, the biggest number we can encode is 10!-1 (= 3628799). So we extend 0..9 with letters A..Z. With these 36 digits we can now encode numbers up to 36!-1 (= 3.72 × 1041)
#
# Task
#
# We will need two functions. The first one will receive a decimal number and return a string with the factorial representation.
#
# The second one will receive a string with a factorial representation and produce the decimal representation.
#
# Given numbers will always be positive.

#!/bin/bash
oper () {
    func="$1"
    s="$2"
    perl -e '
use Math::BigInt;
my $digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
my $func = $ARGV[0];
my $s = $ARGV[1];
if ($func eq "dec2FactString") {
    my $n = Math::BigInt->new($s);
    my $out = "";
    my $i = 1;
    while ($n->bcmp(0) > 0) {
        my $r = $n->copy->bmod($i);
        $n->bdiv($i);
        $out = substr($digits, $r->numify, 1) . $out;
        $i++;
    }
    print $out, "\n";
} else {
    my $len = length($s);
    my $result = Math::BigInt->new(0);
    my $fact = Math::BigInt->new(1);
    for (my $i = $len; $i >= 1; $i--) {
        my $c = substr($s, $i-1, 1);
        my $d = index($digits, $c);
        $result->badd($fact->copy->bmul($d));
        $fact->bmul($len - $i + 1);
    }
    print $result->bstr, "\n";
}
' "$func" "$s"
}
oper "$1" "$2"
