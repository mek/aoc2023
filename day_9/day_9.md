# Advent of Code - Day 9

[Day 9](https://adventofcode.com/2023/day/9)

## Intro
Mirage Maintenance

We get to figure out the Oasis And Sand Instability Sensor. Yea! 

Given a line of data, reduce the line by taking the differece 
between the values until you get a file line of zeros.

For example:

``` 
0   3   6   9  12  15
   3   3   3   3   3
     0    0   0   0
```

The, we need to predice the next value. To do that filling 
in the last lines:

```
0   3   6   9  12  15   B
  3   3   3   3   3   A
    0   0   0   0   0
```
Where `A = 0 + 3 = 3` and `B=A+15=B=0+3=18`
```

The answer for a line the sum of those calculated vale (A+B+0). 
The final result is the sum of the answer for each line.

So, we could read in and do this line-by-line, but I'm just going
to read all the data at once.

Then we'll process each line, which means.

* record the last value of the line and put in in a list.
* Calculate the next interation of the list but subracting between the two elements.
  * index 1 - index 0, index 2 - index 1, etc.
* Check if the all elememts are zero.
* if all are zero, calculate the sum of the last value.

``` tcl
<<CheckLine>>=
# given a list 'l' of unknown size, see if all elements are 'c'
# c defaults to 0
# return 1 if all elements are 'c', 0 otherwise.
proc check-line { l { c 0 } } { 
    if {[lsearch -not $l 0]==-1} { return 1 }
    return 0
}
@
```

Reducing the line to be the difference between elements.

``` tcl
<<LineReduce>>=
proc lreduce { l } {
   for {set res [list]; set i 0; set j 1} {$j<[llength $l]} {incr i; incr j} {
       lappend res [expr {[lindex $l $j] - [lindex $l $i]}]
   }
   return $res
}
@
```

And we'll need a procedure to sum up the elements of a list.

``` tcl 
<<Ladd>>=
proc ladd {l} {::tcl::mathop::+ {*}$l}
@
```

And a procedure to calculate the line anwser using the sum
of the all the last elements in the lines (math stuff).


``` tcl
<<Calc>>=
# given a line Celements, sum then together 
# and increase ltotal which holds the sum of the sums.
proc calc { l } { incr ::total [ladd $l] }
@
```

``` tcl
<<ReadDataintoVar>>=
proc K { x y } { set x }
proc slurp { name } { K [read [ set f [open $name]]] [close $f] }
set data [split [slurp [lindex $argv 0]] "\n"]
@
```

## Part 1

``` text
<<example-part1.data>>=
0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
@
```

We'll need to process a line, which means getting the last 
element on the line, reducing the line, and check if all 
elements are zero.

``` tcl
<<ProcessLine>>=
# takes a line from the input file
proc process-line { line } { 
    while {1} { 
        lappend value [lindex $line end] 
        if {[check-line [set line [lreduce $line]]]} break;
    }
    calc $value
}
@
```

### part1.tcl 

``` tcl
<<part1.tcl>>=
#!/usr/bin/env tclsh8.6
# Advent of Code Day 9 - Part 1
lappend auto_path [file join ../ lib tcl aoc]
package require aoc 2023

<<ReadDataintoVar>>

# check if the line is all zeros
<<CheckLine>>

# reduce the line by the difference of the elements.
<<LineReduce>>

# Sum all the elements in a list
<<Ladd>>

# How to the the answer for each line.
<<Calc>>

# process a line
<<ProcessLine>>

# set a global variable to hold our total
set ::total 0

# We have alread read in the input, let's process it line-by-line
foreach line $data { if {$line ne ""} { process-line $line } }

# output
puts "# total: $total"

exit 0
@
```

``` shell
$ make part1-example
Creating example data for part 1...
Creating part1 TCL script...
Running part1 example...
# total: 114
$ make part1
Creating part1 TCL script...
Running part1 ...
# total: 1868368343
```

## Part 2

Now for part two, instead of predicting, we want look for previous data. So, 
now we have to guess the previous value in the line. This isn't that hard. 

Instead of the `calc` procedure doing a sum of the values, we'll have to 
go through the values list in reverse subtracting the the current values
from the previously calculated one to get the next calulated value. 
With the first calculated value being '0'.

``` tcl
<<CalcPart2>>=
proc calc { l } {
    for {set l [lreverse $l] ; set c 0; set idx 0} \
        {$idx<[llength $l]} {incr idx} {
            set c [expr {[lindex $l $idx] - $c}]
    }
    incr ::total $c
}
@
```
We'll also need to change `process-line` to store the first value, not the last.

We'll change process line to accept an argument that we can feed to 
`lindex $line` to pull out the value we want. Default to 'end' 
so it should also work, but default, like the process line in the first part.

``` tcl
<<part2ProcessLine>>=
# takes a line from the input file
proc process-line { line {index end} } { 
    while {1} { 
        lappend value [lindex $line $index]
        if {[check-line [set line [lreduce $line]]]} break;
    }
    calc $value
}
@
```

``` tcl 
<<part2.tcl>>=
#!/usr/bin/env tclsh8.6
# Advent of Code Day 9 - Part 2
lappend auto_path [file join ../ lib tcl aoc]
package require aoc 2023

<<ReadDataintoVar>>

# check if the line is all zeros
<<CheckLine>>

# reduce the line by the difference of the elements.
<<LineReduce>>

# Sum all the elements in a list
<<Ladd>>

# How to the the answer for each line.
<<CalcPart2>>

# process a line
<<part2ProcessLine>>

# set a global variable to hold our total
set ::total 0

# We have alread read in the input, let's process it line-by-line
# make sure to add the new element to look for
set element 0
foreach line $data { if {$line ne ""} { process-line $line $element} }

# output
puts "# $total"

exit 0
@
```

Trying everything out.

``` shell
$ make part2-example
Creating example data for part 1...
Creating part2 TCL script...
Running part2 example...
# 2
mek@retro:~/git/aoc2023/day_9$ make part2
Running part2 ...
# 1022
```

Day 9 is completed.
