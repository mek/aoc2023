# Advent of Code 2023 - Day 3

Oh boy, mapping for [Day 3](https://adventofcode.com/2023/day/3)

We have a map we need to get part numbers from. 

``` test
<<example-part1.data>>=
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
@
```

Part numbers are ones that are next to a symbol, while '.' is null and does not
count as a symbol.

## Part 1 

Find the part numbers and return a sum of them. To process a file, we'll need
to have access to the previous line (if any) and the next line (if any). So, we'll
probably need to set the row at first to all dots, but we won't know the length 
until we read the first line. So, to start we'll need to do something like:

row_count = 0 
* Read line
  * set it to current_line
  * set previous_line to all dots (based on lengh of current_line)
* Read in the next line
  * set that to next_line

When reading next line, if we read EOF, set next_line to a row of dots. 

This should make it so we don't have to read in the entire file to memory.

We'll parse the current_line to find the location of all the numbers. This will be 
easy with TCL's [regexp](https://www.tcl-lang.org/man/tcl/Tc297024lCmd/regexp.htm). We can 
use the `-all`, '-indices`, and `inline` option to provided the location in the current
line to provide a list of the numbers. Then, we can loop around the all the locations 
in the lines to look for a symbol (not a number and not a '.'). 

We'll assume that a symbol will get anything that is not a number, an alpha char, or a dot.

So, something line:

``` tcl
<<procIsSymbol>>=
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
@
```

Using TCL's regexp, we can search a line for numbers using `[regexp -all -indices -inline {[0-9]+} $line` which will give us a list of indices that numbers occur. For example:

``` tcl
}
% set line ".664.598.."
.664.598..
% regexp -all -indices -inline {[0-9]+} $line
{1 3} {5 7}
```

So, to search for symbols we would have to look at the line before and after the current 
line. For columns we'll have to look at the column before the number to the column after
the number. 

Using the indices above, the following would be were we check. N = cell has a number
C = cell we check.
``` 
         0 1 2 3 4 5 6 7 8 9
before  :C C C C C C C C C 
current :C N N N C N N N C
after   :C C C C C C C C C 
```

To save some complexity, we won't skip the checks on the current row we we know there are 
numbers. We know they'll return no symbol and will allow us to use the same steps for
each line.

One thing we'll do is if a indices is at the start (0) of the end of the line (line length)
we'll not be able to look there, so we'll adjust the start end as needed. 

``` tcl 
<<procCheckLimits>>=
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
@
```

Using those procedures, we'll be able to check a line by:

* getting the number indices.
* setting the start and ending searching columns. 
* checking the columns in the before, current, and after rows.
  * if a number is by a symbol, increase a total by the number.

Which means we need all three lines before we process anything.  Since we are not 
reading the entire file into memory, we'll have set the first line to a line filled
with "." then read in two lines before we can start processing. We'll also have to 
process a line AFTER we reach the end of the file. So the normal while loop 
(reading line until we read EOF) will not work. 

We'll also need a what to create a filled "noop" line, fill "." for the length
of a dat line.

``` tcl 
<<procFillLine>>=
proc fill-line { length char } {
    set str {}
    for {set idx 0} {$idx<$length} {incr idx} {
        append str $char
    }
    return $str
}
@
```
So, or main loop will look something like.

``` tcl
<<proccessFile>>=
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
@
```

### part1.tcl

Let's get the script ready.

``` tcl
<<scriptStart>>=
#!/usr/bin/env tclsh8.6
# Since I want this to work in the repo, we append the
# path to the TCL module location directly.
lappend auto_path [file join ../ lib tcl aoc]

# call our helper functions
package require aoc 2023

@
```

``` tcl
<<part1.tcl>>=
<<scriptStart>>
#
# procedures
#
<<procIsSymbol>>

<<procCheckLimits>>

<<procFillLine>>

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

<<proccessFile>>

exit 0
@
```

Get the puzzle input and save to `part1.data`

``` shell
$ make part1
Creating part1 TCL script...
Running part1 ...
# 553825
```

## Part 2

```
The missing part wasn't the only issue - one of the gears in the engine is wrong. A gear is any * symbol that is adjacent to exactly two part numbers. Its gear ratio is the result of multiplying those two numbers together.
```

So, now we have to look for gears '*' and find if they are matched up with two part numbers.

We can use the same processing that we did before. Get the indices of the 
'*' in the current line, then get the indices of numbers in the before,
current, and after lines and record the number of adjacent numbers.

If that number is two, multiple them together for the gear ratio.

Since we already have the file loading process in process file chuck, we'll add this chuck into there. We'll
also have to add a `set gears_total 0` and the beginning and output `gears_total` and the end.

``` tcl
<<lookForGears>>=
# Look for gears (part 2)
foreach gear_locations [regexp -all -indices -inline {\*} $current] {
    set power 1
    set gear_location [lindex $gear_locations 0]
    # we now have a single gear location in $gear_location
    set gear_adjacent_count 0
    foreach check_line {before after current} {
        # get our number location, in the form [start end]
        foreach num_location [regexp -all -indices -inline {[0-9]+} [set $check_line]] {
            foreach {start end} $num_location {
                foreach {search_start search_end} [check-limits $start $end 0 [expr $line_length - 1]] break
                if {$gear_location >= $search_start && $gear_location <= $search_end} {
                    incr gear_adjacent_count
                    set power [ expr $power * [string range [set $check_line] $start $end]]
                }
            }
        }
    }
    switch $gear_adjacent_count {
        0 { continue }
        1 { continue }
        2 {
            incr gears_total $power
         }
         default { puts "more that two adjacent number, bug?" }
    }
}
@
```

## proccessFile for part 2

``` tcl
<<part2proccessFile>>=
# assume we are in the file working
set in_file_p 1

# zero out the total
set total 0
set row_number 0
set gears_total 0

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
        <<lookForGears>>
    }
}

puts "# $total"
puts "# $gears_total"
@
```

``` tcl
<<part2.tcl>>=
<<scriptStart>>
#
# procedures
#
<<procIsSymbol>>

<<procCheckLimits>>

<<procFillLine>>

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
# Look for gears (part 2)
<<part2proccessFile>>

exit 0
@
```

``` shell 
$ make part2
Running part2 example...
# 553825
# 93994191
```
