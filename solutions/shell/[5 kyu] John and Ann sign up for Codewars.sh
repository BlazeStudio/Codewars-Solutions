# John and Ann sign up for Codewars
# https://www.codewars.com/kata/57591ef494aba64d14000526

# John and his wife Ann have decided to go to Codewars.  On the first day Ann will do one kata and John - he wants to know how it is working - 0 kata.
#
# Let us call a(n) - and j(n) - the number of katas done by Ann - and John - at day n. We have a(0) = 1 and in the same manner j(0) = 0.
#
# They have chosen the following rules:
# - On day n the number of katas done by Ann should be n minus the number of katas done by John at day t, t being equal to the number of katas done
# by Ann herself at day n - 1
#
# - On day n the number of katas done by John should be n minus the number of katas done by Ann at day t, t being equal to the number of katas done
# by John himself at day n - 1
#
# Whoops! I think they need to lay out a little clearer exactly what there're getting themselves into!
#
# Could you write:
# - functions ann(n) and john(n) that return the list of the number of katas Ann/John does on the first n days;
# - functions sum_ann(n) and sum_john(n) that return the total number of katas done by Ann/John on the first n days
#
# Note:
# functions ann and john are not tested
#
# Examples:
# john(11)  -->  [0, 0, 1, 2, 2, 3, 4, 4, 5, 6, 6]
# ann(6)    -->  [1, 1, 2, 2, 3, 3]
#
# sum_john(75)  -->  1720
# sum_ann(150)  -->  6930
#
# shell: sumJohnAndAnn has two parameters ->
# - first one : n (number of days, $1)
# - second one : which($2) ->
#  - 1 for getting John's sum
#  - 2 for getting Ann's sum.
#
# See "Sample Tests"
#
# Note:
#
# Keep an eye on performance.

sumJohnAndAnn() {
    awk -v n="$1" -v which="$2" 'BEGIN {
        a[0]=1
        j[0]=0
        sa=1
        sj=0

        for (i=1; i<n; i++) {
            a[i]=i-j[a[i-1]]
            j[i]=i-a[j[i-1]]
            sa+=a[i]
            sj+=j[i]
        }

        if (which==1)
            printf "%.0f\n", sj
        else
            printf "%.0f\n", sa
    }'
}

sumJohnAndAnn "$1" "$2"
