#!/usr/bin/env tclsh8.6
# -*- tcl -*-
# Mat Kovach
# Advent of Code, Day 1
#
#
# procedures
#
proc with-open-file {fname mode fp block} {
    upvar 1 $fp fpvar
    set binarymode 0
    if {[string equal [string index $mode end] b]} {
            set mode [string range $mode 0 end-1]
            set binarymode 1
    }
    set fpvar [open $fname $mode]
    if {$binarymode} {
            fconfigure $fpvar -translation binary
    }
    uplevel 1 $block
    close $fpvar
}
proc input-check-file { filepath } {

    set file_checks {
        exists          "does not exists"
        isfile          "is not a file"
        readable        "is not readable"
    }

    foreach {check err} $file_checks {
        if {![file $check $filepath]} {
            puts stderr "error $filepath $err, exiting"
            exit 1
        }
    }

}
proc Usage {} { 
	global proc
	puts "usage: $prog <input_file>"
	exit 1
}
proc check-for-digits { line } { 

    # at the start, we have no results so create an empty list.
    set results []

    # we start at the begining of the line
    # set start 0
    # we'll end when we reach the end of the line
    # set end [string length $line]
    # we step on charactor at a time
    # set step 1
    # a simple for loop will increment through the line
    for { set i 0 } { $i != [string length $line] } { incr i } {

	# get the current charactor
        set char [string index $line $i]

	# check if the line is an integer digit
        switch -regexp --  $char {
            [0-9] {
            	# if so append the char and it's position (i) to the result.
                lappend results [list $char $i ]
            }
        } 
    }

    # completed, return the results.
    return $results


}
#
# main
#
# setup variables for main
set input_file {}
set total 0
set prog [file tail [file normalize $argv0]]
#
# check input fuile
#

if {[llength $argv] !=1 } {
    Usage
}

set input_file [lindex $argv 0]

input-check-file $input_file
#
# let's do it!
#
# open the file read only and setup a filepointer (fp).
with-open-file $input_file "r" fp {

    # set total to 0
    set total 0
    
    # start looping until we have reached the end of the file, or we get no data.
    # we assume the input file has no empty lines.
    while {[gets $fp line]>=0} {
        set results [check-for-digits $line]
        if {[llength $results] == 0 } { 
            puts stderr "line:$line produce no results, exiting"
            exit 1
        }
        
        # we have the results, use TCL lindex function to get the first
        # index of the list (position 0) and the end item of the list 
        # index (end). 
        # We could use
        # set first_result [lindex $results 0[
        # set fnum [lindex $first_result 0]
        # set findx [lindex $first_result 1]
        # but the foreach varList List break trick here
        # will set the variables without the need for the third variable.
        foreach {fnum fidx} [lindex $results 0  ] break
        foreach {lnum lidx} [lindex $results end] break
        
        # here is are data test.
        if { $fidx > $lidx } { 
            puts stderr "line:$data, $fnum found at $fidx but $lnum found at $lidx"
            exit 1
        }
        
        # combine the numbers to a double digit number FNUMLNUM
        set num [format "%d%d" $fnum $lnum]
        
        # TCL's incr defaults to one, but if you give it a second argument
        # it will increment the variable but the second argument.
        incr total $num
    }
}

# Done, print the total.
# Put a comment in from so I can include the data in a chuck 
# and allow it to be easily cut-n-pasted
puts "# $total"

# Exit successfully
exit 0
