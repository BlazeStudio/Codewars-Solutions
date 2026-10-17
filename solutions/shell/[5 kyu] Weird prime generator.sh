# Weird prime generator
# https://www.codewars.com/kata/562b384167350ac93b00010c

# Consider the sequence a(1) = 7, a(n) = a(n-1) + gcd(n, a(n-1)) for n >= 2:
#
# 7, 8, 9, 10, 15, 18, 19, 20, 21, 22, 33, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 69, 72, 73....
#
# Let us take the differences between successive elements of the sequence and
# get a second sequence g: 1, 1, 1, 5, 3, 1, 1, 1, 1, 11, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 23, 3, 1....
#
# For the sake of uniformity of the lengths of sequences we add a 1 at the head of g:
#
# g: 1, 1, 1, 1, 5, 3, 1, 1, 1, 1, 11, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 23, 3, 1...
#
# Removing the 1s gives a third sequence:
# p: 5, 3, 11, 3, 23, 3...
# where you can see prime numbers.
#
# Task:
# Write the following functions:
#
# 1. (not tested): an(n) with parameter n: returns the first n terms of the series of a(n)
# 2. (not tested): gn(n) with parameter n: returns the first n terms of the series of g (not tested)
# 3. (tested): countOnes(n) with parameter n: returns the number of 1s in the series gn(n) (don't forget to add a 1 at the head)
# 4. (not tested):  pn(n) with parameter n: returns an array filled with the first n distinct primes in the same order they are found in the sequence gn(n) defined in (3). That is, pn(n) is p with only the first instance of each prime kept.
# 5. (tested): maxPn(n) with parameter n: returns the biggest prime number of the n first terms of the sequence pn(n) defined in (4)
# 6. (not tested but interesting result): anOver(n) with parameter n: returns an array of n terms a(i) / i for every i such that gn(i) != 1
# 7. (tested): anOverAverage(n) with parameter n: returns as an integer the average of anOver(n) defined in (6)
#
# #### Note:
# You can write directly functions `3:`, `5:` and `7:`. There is no need to write functions `1:`, `2:`, `4:` `6:` except out of pure curiosity.

max_pn () {
perl -e '
sub gcd { my ($a,$b)=@_; ($a,$b)=($b,$a%$b) while $b; $a }
my $n = shift;
my $a = 7;
my @primes;
my %seen;
my $i=1;
while (@primes < $n) {
  $i++;
  my $g = gcd($i,$a);
  $a += $g;
  if ($g > 1 && !exists $seen{$g}) {
    $seen{$g}=1;
    push @primes, $g;
  }
}
use List::Util qw(max);
print max(@primes);
' "$1"
}
max_pn "$1"
