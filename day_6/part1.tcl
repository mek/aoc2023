#!/usr/bin/env tclsh8.6
lappend auto_path [file join ../ lib tcl aoc]
package require aoc 2023

# procedures 
# 
proc compare-int-to-float {a b {delta 1e-15}} {

    # have to be comparting floats with integers.
    # this is a pain in TCL, so we'll use a delta
    # and subtract the two numbers and see if they
    # are within the delta
    return [expr {abs($a - $b) < $delta}]

}
#
proc quadratic-formula {a b c} {

  # not perfect, it doesn't check if the parameters are correct
  # i.e.: trying to take the square root of a negative number.
  # calculate the roots of a quadratic equation
  set root1 [expr {(-$b + sqrt(pow($b, 2) - (4 * $a * $c))) / (2 * $a)}]
  set root2 [expr {(-$b - sqrt(pow($b, 2) - (4 * $a * $c))) / (2 * $a)}]

  # return the rols in sorted order
  set result [lsort -real [list $root1 $root2]]

}
#
array set ::DATA {}

## We'll use a proc to append to an array,
## if the array doesn't exist, we'll create it
proc lappend-array-element { var key value } {

    upvar $var arr

    if {[info exists arr($key)]} {
        lappend arr($key) $value
    } else {
        set arr($key) [list $value]
    }

}
# 
proc process-file { file_pointer } { 

    while {[gets $file_pointer line] != -1 } { 
            process-line $line
    }

}
#
proc process-line { line } { 

   if {[regexp {^(\w+): +([\d\s]+)$} $line -> name data]} {

        set name [string trim [string tolower $name]]
        foreach item [split $data " "] {
            if {$item ne ""} { lappend-array-element ::DATA $name [string trim $item] }
        }
    }

}
# 
proc compute-record-beaters {} { 

    # Loop around all the values, we'll use 'time' but one could 
    # just as well as use distance.
    for {set idx 0} {$idx<[llength $::DATA(time)]} {incr idx} {
        # setup the values for the quadratic equation.
        # a = 1
        # b = -race_time (from ::DATA(time)
        # c = race_distance_record (from ::DATA(distance))
        set a 1
        set b "-[lindex $::DATA(time) $idx]"
        set c "[lindex $::DATA(distance) $idx]"
        
        # the quadratic proc returns a list, start end roots. 
        foreach {start end} [quadratic-formula $a $b $c ] break

        # make sure start is > 1
        if {$start < 1} { 
            puts stderr "data $data produces a result < 1, exiting"
	    puts stderr "start: $start, end: $end"
            exit 1
        }

        # check for start point is an exact position to tie distance record
        # if so increate the time by 1.0 ms
        if {[compare-int-to-float [expr {int($start)}] $start]} {
            set start [expr {$start + 1.0}]
        }        

	# We'll use the ceil command on to "round up" all the values.
        # Because, if the root is 12.0000001, we need 13 to beat the record.
        # For the end, we move up, which would not allow use to finish the 
        # race, but when we subract the two, we'll get the right distance.
        lappend-array-element ::DATA results [expr int(ceil($end) - ceil($start))]
    }
}

# Set the program name variable
set prog [file tail [file normalize $argv0]]

if {[llength $argv] !=1 } {
    puts stderr "Usage: $prog input_file"
    exit 1
}

::aoc::input-check-file [set input_file [lindex $argv 0]]
::aoc::with-open-file $input_file "r" fp { process-file $fp }

compute-record-beaters


set result 1 ; # we are using '*', so start with 1 not zero.
foreach item $::DATA(results) { set result [expr { $result * $item }] }
parray ::DATA
puts "# $result"

exit 0
