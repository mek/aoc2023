#!/usr/bin/env tclsh8.6
# Since I want this to work in the repo, we append the 
# path to the TCL module location directly. 
lappend auto_path [file join ../ lib tcl aoc]

# call our helper functions
package require aoc 2023

#
# Color Limit Info
#
array set colormax {
    red   12
    green 13
    blue  14
}

proc check-color { color num} {

    global colormax

    if {![info exists colormax($color)]} {
        puts stderr "Invalid color $color found, exiting"
        exit 1
    }

    if { $num > $colormax($color) } {
        return 0
    }

    return 1
}
#
# split-n-trim
#
proc split-n-trim { data { char { } } } {

        # setup empty list for result
        set result [list]

	# split data by the char. Loop through each item
        # and trim off spaces.
        foreach item [split $data $char] {
                lappend result [string trim $item]
        }

	# return the resulting list.
        return $result
}
#
# process line
#
proc process-line { line } {
    # split at the :, which will give the Game and Number
    # We check to make sure the line started with 'Game'.
    foreach {game_info game_rounds} [split-n-trim $line ":"]      break
    foreach {game game_num}         [split-n-trim $game_info " "] break
    if { $game != "Game" } { 
        puts stderr "$line\nappears to be bad or we did not parser it correctly."
        exit 1
    }

    # we now have the game number in `game_num`. Let's work on parsing the game rounds
    # assume all game rounds are good.
    set all_possible 1

    # split the game_rounds by a comma, for individual rounds
    foreach game_round [split-n-trim $game_rounds ";"] {
 
        # Now, each game_round as seperate "rounds" for the various cubes. 
        # I think I've gone cross-eyed.
        foreach round [split-n-trim $game_round ","] {
            # A regular express to check the round
            # for <num>(SPACES)<color> 
            # note '->' is a variable here, indicating what part was matched.
            # but we don't need it.
            if {[regexp {([0-9]+)\s+(.*)} $round -> num color]} {
                # check for valid data. This means, a proper color AND we are not 
                # over the max
                if { ! [check-color $color $num] } { set all_possible 0}
            } else {
                puts stderr "could not parse $round in $game_round for game num $game_num"
            }
        }
    }
    if { $all_possible } { return $game_num } 
    return $all_possible

}

# main, let's check to make sure we have a usable input file.

# get the program name
set prog [file tail [file normalize $argv0]]

# make sure we were called correctly.
if {[llength $argv]!=1} { 
    puts stderr "usage $prog input_file"
    exit 1
}

set total 0
# Make sure the input file is available
::aoc::input-check-file [set input_file [lindex $argv 0]]
::aoc::with-open-file $input_file "r" fp {
    while {[gets $fp line]>=0} {
        incr total [process-line $line]
    }
}
puts "# $total"
