#!/usr/bin/env tclsh8.6
# Advent of Code Day 15 - Part 1
lappend auto_path [file join ../ lib tcl aoc]
package require aoc 2023

# K combinator is a new way to read a file into a var using a 
# one line, which I call 'slurp'
proc K { x y } { set x }
proc slurp { name } { K [read [ set f [open $name]]] [close $f] }

# we'll need some helper functions to split the data
# and trim the data
proc sl { s {c {}} } { return [split $s $c] }
proc st { d c } { return [sl [string trim $d] $c] }

# We need to convert a char to an ASCII value, I'll call that ord.
proc ord { c } { scan $c %c a; set a }

# We'll also have to do some basic math. So, to save some typing
# we'll make some wrapper functions around TCL's 'expr'.
# And yes, there are other ways to do this. 
proc add { x y } { set a [expr {$x + $y}] }
proc sub { x y } { set a [expr {$x - $y}] }
proc mul { x y } { set a [expr {$x * $y}] }
proc div { x y } { set a [expr {$x / $y}] }
proc mod { x y } { set a [expr {$x % $y}] }

# Now, given a total and a char, calculate a new hash vaule
# This is per the provided hash algo.
proc hv { l v } { return [mod [mul [add $v [ord $l]] 17 ] 256] }

# we'll need to calculate the hash for an entire string.
# Given a string, calculate the hash value for each char
proc hash { s } { set v 0; foreach l [sl $s] { set v [hv $l $v] } ; return $v }

proc part1 { data } { set total 0; foreach i [st $data ,] { incr total [hash $i] } ; puts "#1: $total" }

set data [slurp [lindex $argv 0]]

part1 $data

exit 0
