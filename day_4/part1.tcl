#!/usr/bin/env tclsh8.6
lappend auto_path [file join ../ lib tcl aoc]
package require aoc 2023

# procedures
proc calculate-points { wins } { 
    # calculate the points based on the number of wins. 
    # format the float response of 'pow' to interger using scan.
    return [scan [expr {pow(2,$wins-1)}] "%d"]
}

proc split-n-trim { data { char { } } } {

    # setup an empty to list to start the results.
    set result [list]

    # split data by the char. Loop through each item
    # and trim off spaces.
    foreach item [split $data $char] {
        # depending on formating, extra spaces might be causing
        # null items. Skip them.
        if {$item == ""} { continue }
        lappend result [string trim $item]
    }

    # return the resulting list.
    return $result
}

proc process-line-part1 { line } {

    set total 0

    if {[regexp {Card +(\d+): +(.*) \| +(.*)} $line -> card winning_numbers card_numbers]}  {
        set wins 0
        set winning_number_list [split-n-trim $winning_numbers]
        foreach number [split-n-trim $card_numbers] {
            if {[lsearch $winning_number_list $number] != -1} { incr wins }
        }
    }
    return [list $card $wins]
}

# Set the program name variable
set prog [file tail [file normalize $argv0]]

if {[llength $argv] !=1 } {
    puts stderr "Usage: $prog input_file"
    exit 1
}

::aoc::input-check-file [set input_file [lindex $argv 0]]

# process line
# Set the total to 0
set total 0

# Process the file
::aoc::with-open-file $input_file "r" fp {
    while {[gets $fp line]>= 0} {
	foreach {card_num wins} [process-line-part1 $line] break
        if {$wins > 0} {
           incr total [calculate-points $wins]
        }
    }
}

puts "# $total"

exit 0
