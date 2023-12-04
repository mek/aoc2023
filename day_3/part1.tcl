#!/usr/bin/env tclsh8.6
# Since I want this to work in the repo, we append the
# path to the TCL module location directly.
lappend auto_path [file join ../ lib tcl aoc]

# call our helper functions
package require aoc 2023

#
# procedures
#
proc is-symbol { line pos } { 
    switch -glob -- [string index $line $pos] { 
        [0-9] -
        "." {
            set symbol 0
        }
        default {
           set symbol 1
        }
    }
    return $symbol
    
}

proc check-limits { start end min max } { 
    # start end is the indices from the regexp. We want to 
    # subtract one from start and add one to end, but if 
    # those values are exceed min/max, not look there. 
    set search_start [expr $start - 1]
    set search_end   [expr $end   + 1]
    if { $start == $min } { 
        set search_start 0
    }
    if { $end == $max } { 
        set search_end $max
    }
    return [list $search_start $search_end]
}

proc fill-line { length char } {
    set str {}
    for {set idx 0} {$idx<$length} {incr idx} {
        append str $char
    }
    return $str
}

# main, let's check to make sure we have a usable input file.

# get the program name
set prog [file tail [file normalize $argv0]]

# make sure we were called correctly.
if {[llength $argv]!=1} {
    puts stderr "usage $prog input_file"
    exit 1
}

# Make sure the input file is available
::aoc::input-check-file [set input_file [lindex $argv 0]]

# We are ready to process.

# assume we are in the file working
set in_file_p 1

# zero out the total
set total 0
set row_number 0

# set all row strings to ""
foreach {before current after} {"" "" ""} break

::aoc::with-open-file $input_file "r" fp {
    while { $in_file_p } { 
        if {[gets $fp line]<0} { 
            # we have reached the end of the file.
            # set in_file_p 0
            # and add a default line so we can process
            # the last current line.
            set line [fill-line $line_length "."]
            set in_file_p 0
        }
        if {$current eq ""} { 
            # if current is empty, we haven't process a line yet.
            # set set current to a default line and set the 
            # after line to the line we just read in.
            # on the next interation, we'll have all the 
            # line filled and can process data.
            # we also assume the line length is the same for all lines 
            # so set the length on the first line we read.
            set line_length [string length $line]
            set current [fill-line $line_length "."] 
            set after $line
            # we have primed things up, continue. 
            continue
        }
        # increment the lines
        incr row_number
        set before $current
        set current $after 
        set after $line
       
        # get the number indices for the current line
        # and loop through them to check for symbols.
        foreach number_locations [regexp -all -indices -inline {[0-9]+} $current] { 
            # this will return a list of a indices 
            foreach {start end} $number_locations break
            foreach {search_start search_end} [check-limits $start $end 0 [expr $line_length - 1]] break
            # we have our columns to check, do so for each row.
            # assume we are not a part number
            set is_part_num 0
            # check the lines
            foreach check_line {before current after} { 
                # if we are a part number, skip further checks
                if { $is_part_num} { break } 
                for {set idx $search_start} {$idx<=$search_end} {incr idx} {
                    # skip checks if we are a part number
                    if {[is-symbol [set $check_line] $idx] && ! $is_part_num } { 
                        incr total  [string range $current $start $end]
                        set is_part_num 1
                    } 
                }
            }
        }
    }
}

puts "# $total"

exit 0
