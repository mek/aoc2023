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
proc check-for-digits { haystack } { 

    # setup the needles we'll be looking for in the line, haystack
    set needles {
	one	1
	two	2
	three	3
	four	4
	five	5
	six	6
	seven	7
	eight	8
	nine	9
	1	1
	2	2
	3	3
	4	4
	5	5
	6	6
	7	7
	8	8	
	9 	9
    }

    # make sure the array is set, we'll unset the array before leaving the procedure.
    array set results_array {}

    # Do our very ineffective loop.
    foreach {needle value} $needles {
        set start 0

        while { [set start [string first $needle $haystack $start]] >= 0 } {

           # We have our data, let's put in in the results array, but first
           # make sure array key does not exists. If it does, something is 
           # wrong.
           if {[info exists results_array($start)]} { 
               puts stderr "Results at position: $start already defined"
               parray results_array
               exit 1
           }
           set results_array($start) $value
           
           # increment start by one
           incr start
       }
    }
    # Sort the results and put into a list of list.
    # Get the list of array keys (pos) and sort by integer.
    # using the sorted list, append the [pos value] list to 
    # the results list.
    set results {}
    foreach idx [lsort -integer [array names results_array]] {
        lappend results [list $results_array($idx) $idx]
    }
    array unset results_array

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
