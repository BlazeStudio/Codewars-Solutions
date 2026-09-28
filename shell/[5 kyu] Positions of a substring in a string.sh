# Positions of a substring in a string
# https://www.codewars.com/kata/59f3956825d575e3330000a3

# Let us go  through an example.
#
# You have a string (here a short one):
#
# s = "GCAGCaGCTGCgatggcggcgctgaggggtcttgggggctctaggccggccacctactgg",
# with only upper or lower cases letters A, C, G, T.
#
# You want to find substrings in this string.  Each substring to find has a label.
# The different substrings to find are given in a string of the following form:
# Base = "Version xxxx
#
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Partial Database
# http://...
# Copyright (c) All rights reserved.
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#
# <>
#
# AaaI (XmaIII)                     CGGCCG
# AacI (BamHI)                      GGATCC
# AaeI                              GGATCC
# AagI (ClaI)                       ATCGAT
# AarI                              CACCTGCNNNN
# Acc38I (EcoRII)                   CCWGG
# AceI (TseI)                       GCWGC"
#
# Only the first lines of a Base are given here.
#
# In first place you get a few lines of comments.
# Then in three columns: the labels of the substrings, in the second one - that can be empty -
# kind of comments, in the 3rd one the substring corresponding to the label.
#
# Notice that other letters than A, C, G, T appear.
#
# The conventions for these other letters follow:
# R stands for G or A
# Y stands for C or T
# M stands for A or C
# K stands for G or T
# S stands for G or C
# W stands for A or T
# B stands for not A ie (C or G or T)
# D stands for not C ie (A or G or T)
# H stands for not G ie (A or C or T)
# V stands for not T ie (A or C or G)
# N stands for A or C or G or T
# In the tests there are two different Bases called Base and Base1 and two long strings: data and data1.
#
# Given a base base (Base or Base1), a string strng (which will be data or data1 or s of the example) and a query name query - e.g label "AceI" - the function get_pos will return:
#
# - the non-overlapping positions in strng where the query substring has been found.
#
# In the previous example we will return "1 7" since the positions are numbered from 1 and not from 0.
#
# Explanation:
# label "AceI" is the name of the substring "GCWGC" that can be written (see conventions above) "GCAGC" found at position 1 in s or "GCTGC" found at position 7.
#
# Particular cases
# If query name doesn't exist in Base return:
#
# "This query name does not exist in given Base".
#
# If query name exists but query is not found in strng return:
#
# "... is not in given string" (... being the query argument).
#
# Examples:
# get_pos(Base, str, "AceI") => "1 7"
# get_pos(Base, str, "AaeI") => "AaeI is not in given string"
# get_pos(Base, str, "XaeI") => "This query name does not exist in given Base"
# Notes
# - You can see other examples in the "Sample tests".
# - Translators are welcome for all languages, except for Ruby since the Bash random tests needing Ruby a Ruby reference solution is already there though not yet published.

#!/bin/bash

get_pos() {
    local base="$1"
    local strng="$2"
    local query="$3"
    local motif

    motif=$(awk -v q="$query" '
        $1 == q {
            print $NF
            exit
        }
    ' <<< "$base")

    if [[ -z "$motif" ]]; then
        echo "This query name does not exist in given Base"
        return
    fi

    awk -v s="$strng" -v motif="$motif" -v q="$query" '
    function ok(c, code) {
        code = toupper(code)
        c = toupper(c)

        if (code == "A") return c == "A"
        if (code == "C") return c == "C"
        if (code == "G") return c == "G"
        if (code == "T") return c == "T"
        if (code == "R") return c == "A" || c == "G"
        if (code == "Y") return c == "C" || c == "T"
        if (code == "M") return c == "A" || c == "C"
        if (code == "K") return c == "G" || c == "T"
        if (code == "S") return c == "G" || c == "C"
        if (code == "W") return c == "A" || c == "T"
        if (code == "B") return c != "A"
        if (code == "D") return c != "C"
        if (code == "H") return c != "G"
        if (code == "V") return c != "T"
        if (code == "N") return c == "A" || c == "C" || c == "G" || c == "T"

        return 0
    }

    BEGIN {
        m = length(motif)
        n = length(s)

        # Remove formatting characters only for the DNA sequence,
        # while positions are counted in DNA bases.
        dna = ""

        for (i = 1; i <= n; i++) {
            c = substr(s, i, 1)

            if (toupper(c) ~ /^[ACGT]$/)
                dna = dna c
        }

        n = length(dna)
        result = ""
        found = 0

        i = 1

        while (i + m - 1 <= n) {
            match_site = 1

            for (j = 1; j <= m; j++) {
                if (!ok(substr(dna, i + j - 1, 1),
                        substr(motif, j, 1))) {
                    match_site = 0
                    break
                }
            }

            if (match_site) {
                if (found)
                    result = result " "

                result = result i
                found = 1

                # Non-overlapping.
                i += m
            }
            else {
                i++
            }
        }

        if (found)
            print result
        else
            print q " is not in given string"
    }
    '
}

get_pos "$1" "$2" "$3"
