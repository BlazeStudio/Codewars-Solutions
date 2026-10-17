# Bernoulli numbers
# https://www.codewars.com/kata/567ffb369f7f92e53800005b

# Story
#
# Before we dive into the exercise, I would like to show you why these numbers are so important in computer programming today.
#
# It all goes back to the time of 19th century. Where computers we know today were non-existing. The first ever computer program was for the Analytical Engine to compute Bernoulli numbers. A woman named Ada Lovelace wrote the very first program. The sad part is the engine was never fully build so her code was never tested. She also predicted the start of AI (artificial intelligence).
#
# Computers will be able to compose music by themselves, solve problems (not only numbers) ... So in her honor reproduce what was done back in 1842. The Bernoulli numbers are a sequence of rational numbers with deep connections to number theory. The Swiss mathematician Jakob Bernoulli and the Japanese mathematician Seki Kowa discovered the numbers around the same time at the start of the 18th Century. If you want to read more about her or Bernoulli numbers follow these links:
#
# https://en.wikipedia.org/wiki/Ada_Lovelace
#
# https://en.wikipedia.org/wiki/Bernoulli_number
#
# http://mathworld.wolfram.com/BernoulliNumber.html
#
# Exercise
#
# Your job is to write a function bernoulli_number(n) which outputs the n-th Bernoulli number. The input will always be a non-negative integer so you do not need to worry about exceptions. How you will solve the problem is none of my business but here are some guidelines.
# You can make pascal triangle and then with the basic formula generate all Bernoulli numbers. Look example below.
#
# For the sake of floating numbers, just use Fractions so there will be no problems with rounding.
#
# 0 = 1 + 2b1 ...............................................................
#   b1 = - 1/2
#
# 0 = 1 + 3b1 + 3b2 ...................................................    b2        = 1/6
#
# 0 = 1 + 4b1 + 6b2 + 4b3 .......................................  b3 = 0
#
# 0 = 1 + 5b1 + 10b2 + 10b3 + 5b4 ...................... b4 = - 1/30
#
# ... and so on.
#
# bernoulli_number(0) # return 1
# bernoulli_number(1) # return Fraction(-1,2) or Rational(-1,2) or "1/2"
# bernoulli_number(6) # return Fraction(1,42) or ...
# bernoulli_number(42) # return Fraction(1520097643918070802691,1806) or ...
# bernoulli_number(22) # return Fraction(854513,138) or ... "854513/138"
#
# Note
#
# See "Sample Tests" to see the return type for each language.
#
# Good luck and happy coding!
#
# PS: be careful some numbers might exceed 1000.
# If this kata is too hard for you try to solve pascal triangle and something similar to this and then come back :).

#!/bin/bash
bernoulli_number () {
  perl -e '
    use strict;
    use warnings;
    use Math::BigInt;

    sub gcd {
      my ($a, $b) = @_;
      $a = $a->copy->babs;
      $b = $b->copy->babs;
      while (!$b->is_zero) {
        ($a, $b) = ($b, $a->copy->bmod($b));
      }
      return $a;
    }

    sub bernoulli {
      my $n = shift;
      return (Math::BigInt->new(1), Math::BigInt->new(1)) if $n == 0;
      return (Math::BigInt->new(0), Math::BigInt->new(1)) if $n % 2 && $n > 1;

      my @num = map { Math::BigInt->new(1) } 0..$n;
      my @den = map { Math::BigInt->new($_+1) } 0..$n;

      for my $m (1..$n) {
        for (my $j = $m; $j >= 1; $j--) {
          my $newnum = $num[$j-1]->copy->bmul($den[$j])->bsub( $num[$j]->copy->bmul($den[$j-1]) );
          my $newden = $den[$j-1]->copy->bmul($den[$j]);
          $newnum->bmul($j);
          my $g = gcd($newnum, $newden);
          $num[$j-1] = $newnum->bdiv($g);
          $den[$j-1] = $newden->bdiv($g);
        }
      }
      my $resnum = $num[0]->copy;
      my $resden = $den[0]->copy;
      $resnum->bneg if $n == 1;
      if ($resden->is_neg) {
        $resnum->bneg;
        $resden->bneg;
      }
      return ($resnum, $resden);
    }

    my $n = 0 + $ARGV[0];
    my ($num, $den) = bernoulli($n);
    if ($den->is_one) {
      print $num, "\n";
    } else {
      print $num, "/", $den, "\n";
    }
  ' "$1"
}
bernoulli_number "$1"
