#!/usr/bin/env tclsh8.6
# Advent of Code Day 9 - Part 2
lappend auto_path [file join ../ lib tcl aoc]
package require aoc 2023

proc K { x y } { set x }
proc slurp { name } { K [read [ set f [open $name]]] [close $f] }
set data [split [slurp [lindex $argv 0]] "\n"]

# check if the line is all zeros
# given a list 'l' of unknown size, see if all elements are 'c'
# c defaults to 0
# return 1 if all elements are 'c', 0 otherwise.
proc check-line { l { c 0 } } { 
    if {[lsearch -not $l 0]==-1} { return 1 }
    return 0
}

# reduce the line by the difference of the elements.
proc lreduce { l } {
   for {set res [list]; set i 0; set j 1} {$j<[llength $l]} {incr i; incr j} {
       lappend res [expr {[lindex $l $j] - [lindex $l $i]}]
   }
   return $res
}

# Sum all the elements in a list
proc ladd {l} {::tcl::mathop::+ {*}$l}

# How to the the answer for each line.
proc calc { l } {
    for {set l [lreverse $l] ; set c 0; set idx 0} \
        {$idx<[llength $l]} {incr idx} {
            set c [expr {[lindex $l $idx] - $c}]
    }
    incr ::total $c
}

# process a line
# takes a line from the input file
proc process-line { line {index end} } { 
    while {1} { 
        lappend value [lindex $line $index]
        if {[check-line [set line [lreduce $line]]]} break;
    }
    calc $value
}

# set a global variable to hold our total
set ::total 0

# We have alread read in the input, let's process it line-by-line
# make sure to add the new element to look for
set element 0
foreach line $data { if {$line ne ""} { process-line $line $element} }

# output
puts "# $total"

exit 0
