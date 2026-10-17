# 1/n- Cycle
# https://www.codewars.com/kata/5a057ec846d843c81a0000ad

# Let n be an integer coprime with 10, e.g. 7.
#
# 1/7 = 0.142857 142857 142857 ....
#
# We see that the decimal part has a cycle: 142857. The length of this cycle is 6. In the same way:
#
# 1/11 = 0.09 09 09 .... Cycle length is 2.
#
# Task
#
# Given an integer n (n > 1), write a function that returns the length of the cycle if there is one, otherwise (if n and 10 not coprimes) return -1.
#
# Examples
#
# n = 5  --> Should return -1
# n = 13 --> Should return 6 -> 0.076923 076923 076923 ...
# n = 21 --> Should return 6 -> 0.047619 047619 047619 ...
# n = 27 --> Should return 3 -> 0.037 037 037 037 037 037 ...
# n = 33 --> Should return 2 -> 0.03 03 03 03 03 03 03 03 ...
# n = 37 --> Should return 3 -> 0.027 027 027 027 027 027 ...
# n = 94 --> Should return -1
#
# Notes
#
# n = 22 --> Should return -1 since 1/22 ~ 0.0 45 45 45 45 ...
# - Please ask before translating..

#!/bin/bash
cycle () {
    local n=$1
    local x=$n
    local p=1
    local phi=1
    local i

    if (( n % 2 == 0 || n % 5 == 0 )); then
        echo -1
        return
    fi

    phi=$n
    for ((i=2; i*i<=x; i++)); do
        if (( x % i == 0 )); then
            phi=$((phi - phi / i))
            while ((x % i == 0)); do
                x=$((x / i))
            done
        fi
    done
    if ((x > 1)); then
        phi=$((phi - phi / x))
    fi

    local d=$phi
    local q=$phi
    local prime

    for ((i=2; i*i<=q; i++)); do
        if ((q % i == 0)); then
            prime=$i
            while ((q % i == 0)); do
                q=$((q / i))
            done

            while ((d % prime == 0)); do
                local candidate=$((d / prime))
                local base=10
                local exp=$candidate
                local res=1

                while ((exp > 0)); do
                    if ((exp & 1)); then
                        res=$((res * base % n))
                    fi
                    base=$((base * base % n))
                    exp=$((exp / 2))
                done

                if ((res == 1)); then
                    d=$candidate
                else
                    break
                fi
            done
        fi
    done

    if ((q > 1)); then
        prime=$q
        while ((d % prime == 0)); do
            local candidate=$((d / prime))
            local base=10
            local exp=$candidate
            local res=1

            while ((exp > 0)); do
                if ((exp & 1)); then
                    res=$((res * base % n))
                fi
                base=$((base * base % n))
                exp=$((exp / 2))
            done

            if ((res == 1)); then
                d=$candidate
            else
                break
            fi
        done
    fi

    echo "$d"
}

cycle "$1"
