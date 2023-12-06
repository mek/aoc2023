# Advent of Code - Day 4

[Day 6](https://adventofcode.com/2023/day/6)

Push button racking

``` shell

## Part 1

``` text
<<example-part1.data>>=
Time:      7  15   30
Distance:  9  40  200
@
```

```
Holding down the button charges the boat, and releasing the button allows 
the boat to move. The time spent holding the button counts against your 
given time. To win you have to go past the current record. 

The data includes, the time you have and the current record. 

So, we'll have to calculate how long the button time will move the 
boat. 

So, one ms hold on button means you move 1 mm/ms.
    two ms hold on button means you move 2 mm/ms. 
    ....
So, the equation would be `distance = Tbutton ms * (Tgiven - Tbutton mm/ms)`

So, we it seems like we'll have to interate over a bunch of computations until ..
wait. What?

```
Tbutton * (Tgiven - Tbutton) = distance
Tbutton*Tgiven - Tbutton^2 = distance
or
Tbutton*Tgiven = Tbutton^2 + distance.
0 = Tbutton^2 -Tbutton*Tgiven + distance
Tbutton^2 -Tbutton*Tgiven + distance = 0 
ax^2 - bx + c = 0
ax^2 + -bx +c = 0 
```
The Quadratic Equation!

We don't have to run any computation, expect for the quadtratic equation.

We can solve for the roots of the equation. We should have to roots, the distance
between the two roots when distance is the record distance will tell us the times
we can beat the record and the larger root will tell us the last point we can make it. 

I can see a few issues we'll have to check for. 

The lowest number can not be less than 1. 
We could have a case were the lowest root, could be an actual point, meaning that 
it would be the exact point to TIE the race, so we would need to check for that
and add one to the lowest number. 

Now, if we are going to do that, we'll run into situations were we'll have to compare 
integers and floating point in TCL. This can be a bit difficult, so we'll need a 
procedure to help use. This accepts two number, takes the absolute of the difference
between the two, and see if it is within a specific tolerace. If so, we consider 
then equal.

NOTE: I will had a link to the floating point / integer math issue with TCL.

``` tcl
<<CompareIntToFloat>>=
proc compare-int-to-float {a b {delta 1e-15}} {

    # have to be comparting floats with integers.
    # this is a pain in TCL, so we'll use a delta
    # and subtract the two numbers and see if they
    # are within the delta
    return [expr {abs($a - $b) < $delta}]

}
@
```

We'll also need a procedure to calculate the quadratic formulate and return a
sort list of the roots.

``` tcl
<<QuadraticFormula>>=
proc quadratic-formula {a b c} {

  # not perfect, it doesn't check if the parameters are correct
  # i.e.: trying to take the square root of a negative number.
  # calculate the roots of a quadratic equation
  set root1 [expr {(-$b + sqrt(pow($b, 2) - (4 * $a * $c))) / (2 * $a)}]
  set root2 [expr {(-$b - sqrt(pow($b, 2) - (4 * $a * $c))) / (2 * $a)}]

  # return the rols in sorted order
  set result [lsort -real [list $root1 $root2]]

}
@
```

### part1.tcl 

So, we are going to do math, and will only have to compute one time for each
race. My old math teacher would be so proud! 

We do have a challenge with reading in the data. The needed information is on 
two lines. So we can't work the file line-by-line. Also, we have to make sure 
that we have equal limits. TCL list are why you enter is what you get, so we 
can just append to the lines, and assume we'll have both in the right order. 

I'm going to create a global array `::DATA` and when we read a line we'll 
add them to the `::DATA(time)` and `::DATA(distance)`. We can then loop 
and pull in the information from each array. 

``` tcl
<<GlobalDataArray>>=
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
@
```

I also added a procedure that will allow use to append to a array key item. If the 
key is not already defined, we have to SET it, otherwise just append to the list 
`lappend`.

Now that we have have our data storage setup, let's process the file. All this does
is take a file pointer and read each line in the file. 

``` tcl
<<ProcessFile>>=
proc process-file { file_pointer } { 

    while {[gets $file_pointer line] != -1 } { 
            process-line $line
    }

}
@
```

If the line is parsed, call process line to take and data and put it in the global 
array `::DATA``. This contains the regular expression to get the `Time` or `Distance`
line and the data from the line. We change the name to all lowercase. We split the 
line into a list and because we might have extra spaces, if skip those.

Just to be sure, we also trim the input from the file.

``` tcl
<<ProcessLine>>=
proc process-line { line } { 

   if {[regexp {^(\w+): +([\d\s]+)$} $line -> name data]} {

        set name [string trim [string tolower $name]]
        foreach item [split $data " "] {
            if {$item ne ""} { lappend-array-element ::DATA $name [string trim $item] }
        }
    }

}
@
```

At this point we have the data read in and in the global array `::DATA` so we are 
ready to do some math.  This will take no arguments, and we'll start the results 
in the `::DATA` array under `part1results`. 

``` tcl
<<ComputeRecordBeaters>>=
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
@
```

At this point, we have computed the results, display them then exit with the 
results multiplied together.

``` tcl
<<DisplayResults>>=

set result 1 ; # we are using '*', so start with 1 not zero.
foreach item $::DATA(results) { set result [expr { $result * $item }] }
parray ::DATA
puts "# $result"
@
```

``` tcl
<<part1.tcl>>=
#!/usr/bin/env tclsh8.6
lappend auto_path [file join ../ lib tcl aoc]
package require aoc 2023

# procedures 
# 
<<CompareIntToFloat>>
#
<<QuadraticFormula>>
#
<<GlobalDataArray>>
# 
<<ProcessFile>>
#
<<ProcessLine>>
# 
<<ComputeRecordBeaters>>

# Set the program name variable
set prog [file tail [file normalize $argv0]]

if {[llength $argv] !=1 } {
    puts stderr "Usage: $prog input_file"
    exit 1
}

::aoc::input-check-file [set input_file [lindex $argv 0]]
::aoc::with-open-file $input_file "r" fp { process-file $fp }

compute-record-beaters

<<DisplayResults>>

exit 0
@
```
## part 1 testing

``` shell
$ make part1-example
Creating example data from part 1...
Running part1 example...
::DATA(distance) = 9 40 200
::DATA(results)  = 4 8 9
::DATA(time)     = 7 15 30
# 288
```

## part 1 data
``` shell
Creating part1 TCL script...
Running part1 ...
::DATA(distance) = 333 1635 1289 1532
::DATA(results)  = 38 18 5 41
::DATA(time)     = 53 83 72 88
# 140220
```

# Part 2

Now we don't have any new data, we just have the data wrong, so instance of several 
different numbers, we have two big numbers. All we'll have to do is process the 
line different.

We'll need an `append-array element` as we are making a string now, not a list.

``` tcl
<<part2ProcessLine>>=
## We'll use a proc to append to an array,
## if the array doesn't exist, we'll create it
proc append-array-element { var key value } {

    upvar $var arr

    if {[info exists arr($key)]} {
        append arr($key) $value
    } else {
        set arr($key) $value
    }

}

proc process-line { line } {

   if {[regexp {^(\w+): +([\d\s]+)$} $line -> name data]} {

        set name [string trim [string tolower $name]]
        foreach item [split $data " "] {
            if {$item ne ""} { append-array-element ::DATA $name [string trim $item] }
        }
    }

}
@
```

## part2.tcl

``` tcl 
<<part2.tcl>>=
#!/usr/bin/env tclsh8.6
lappend auto_path [file join ../ lib tcl aoc]
package require aoc 2023

# procedures 
# 
<<CompareIntToFloat>>
#
<<QuadraticFormula>>
#
<<GlobalDataArray>>
# 
<<ProcessFile>>
#
<<part2ProcessLine>>
# 
<<ComputeRecordBeaters>>

# Set the program name variable
set prog [file tail [file normalize $argv0]]

if {[llength $argv] !=1 } {
    puts stderr "Usage: $prog input_file"
    exit 1
}

::aoc::input-check-file [set input_file [lindex $argv 0]]
::aoc::with-open-file $input_file "r" fp { process-file $fp }

compute-record-beaters

<<DisplayResults>>

exit 0
@
```
Trying everything out.

## part 2 testing and run

``` shell
$ make part2-example
Creating example data from part 1...
Running part2 example...
::DATA(distance) = 940200
::DATA(results)  = 71503
::DATA(time)     = 71530
# 71503
matthewedwardkovach@WRJ21Y0Y66 ~/src/aoc2023/day_6
$ make part2
Running part2 ...
::DATA(distance) = 333163512891532
::DATA(results)  = 39570185
::DATA(time)     = 53837288
# 39570185
```

### timing

```
$ time make clean all
Cleaning...
Creating example data from part 1...
Creating part1 TCL script...
Running part1 example...
::DATA(distance) = 9 40 200
::DATA(results)  = 4 8 9
::DATA(time)     = 7 15 30
# 288
Running part1 ...
::DATA(distance) = 333 1635 1289 1532
::DATA(results)  = 38 18 5 41
::DATA(time)     = 53 83 72 88
# 140220
Creating part2 TCL script...
Running part2 example...
::DATA(distance) = 940200
::DATA(results)  = 71503
::DATA(time)     = 71530
# 71503
Running part2 ...
::DATA(distance) = 333163512891532
::DATA(results)  = 39570185
::DATA(time)     = 53837288
# 39570185
make clean all  0.08s user 0.11s system 26% cpu 0.713 total
```

Day 6 is completed.
