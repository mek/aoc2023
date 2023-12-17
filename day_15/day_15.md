# Advent of Code - Day 15

[Day 15](https://adventofcode.com/2023/day/15)

## Intro

And today is HASHMAP day (or it was, I'm a bit behind). So, we'll get a 
list of values to turn into a hash, given a hash equation. 

The HASH equation:

``` shell
The HASH algorithm is a way to turn any string of characters into a single 
number in the range 0 to 255. To run the HASH algorithm on a string, 
start with a current value of 0. Then, for each character in the string 
starting from the beginning:

    Determine the ASCII code for the current character of the string.
    Increase the current value by the ASCII code you just determined.
    Set the current value to itself multiplied by 17.
    Set the current value to the remainder of dividing itself by 256.
```

## Part 1

``` text
<<example-part1.data>>=
rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
@
```

Note: They make special note of ignoring new lines, so make sure to 
trim the input. 

So, we are going to need some helper functions to do stuff.

``` tcl
<<helperFunctions>>=
# K combinator is a new way to read a file into a var using a 
# one line, which I call 'slurp'
proc K { x y } { set x }
proc slurp { name } { K [read [ set f [open $name]]] [close $f] }

# we'll need some helper functions to split the data
# and trim the data
proc sl { s {c {}} } { return [split $s $c] }
proc st { d c } { return [sl [string trim $d] $c] }

# We need to convert a char to an ASCII value, I'll call that ord.
proc ord { c } { scan $c %c a; set a }

# We'll also have to do some basic math. So, to save some typing
# we'll make some wrapper functions around TCL's 'expr'.
# And yes, there are other ways to do this. 
proc add { x y } { set a [expr {$x + $y}] }
proc sub { x y } { set a [expr {$x - $y}] }
proc mul { x y } { set a [expr {$x * $y}] }
proc div { x y } { set a [expr {$x / $y}] }
proc mod { x y } { set a [expr {$x % $y}] }

# Now, given a total and a char, calculate a new hash vaule
# This is per the provided hash algo.
proc hv { l v } { return [mod [mul [add $v [ord $l]] 17 ] 256] }

# we'll need to calculate the hash for an entire string.
# Given a string, calculate the hash value for each char
proc hash { s } { set v 0; foreach l [sl $s] { set v [hv $l $v] } ; return $v }
@
```

### part1.tcl 

For part one we just need the same of the hash for each item for the comma 
seperataed values of the data.

Make sure to split and trim the data 'st' and then process the line.

``` tcl 
<<part1>>=
proc part1 { data } { set total 0; foreach i [st $data ,] { incr total [hash $i] } ; puts "#1: $total" }
@
```

Read in the data to a variable and then process part 1.

``` tcl
<<part1.tcl>>=
#!/usr/bin/env tclsh8.6
# Advent of Code Day 15 - Part 1
lappend auto_path [file join ../ lib tcl aoc]
package require aoc 2023

<<helperFunctions>>

<<part1>>

set data [slurp [lindex $argv 0]]

part1 $data

exit 0
@
```

``` shell
$ make part1-example
Creating example data for part 1...
Running part1 example...
#1: 1320
$ make part1
Running part1 ...
#1: 511343
```

Yea! 

## Part 2

Now for part 2 we have the HASHMAP. Turns out the CSV line is a set of 
instructions to add lens to boxes. 

Instructions are 

* (key)=num
* (key)-

The key is also the box number, which is calculated using the hash. If
the operation is `=` then we add the lens to the box, with the focal 
length of `num`. If there is already a focal length for `key` in box
`hash key` we overwrite it. If we are not overwritting something, we 
add to the END of the order. 

If the operation is `-`, which has no value, we remove the lens `key`
in box `hash key` if it exists, and then move anything behind the 
the key up one. 

Pretty much, we are making a linked list. Not that hard to do in TCL.

We'll need some more helper functions. Our hash map will be an array
`boxes` and the elemement for each `hash key` box number will be a list 
of lens and focal lengths. So, something like:
 
boxes(0) = {{cm 1} {ac 3} {bc 4}}

``` tcl
<<part2HelperFunctions>>=
# we'll need some push and pop functions to do the array and list 
# gymastics.
# push is just a list append `lappend` to the current list
proc push {_data elem} { upvar $_data data ; lappend data $elem }

# we'll need a way to check if a lens is in a box. `f`ind uses
# lsearch to look for first instance of `lens *`.
proc f {data elem} { set i [lsearch -asci -glob -ascii $data "$elem *"] }

# pop checks if the key `elem` is in the list and if some, removes it. 
#   we glob for ANY focal length as the second item.
#   lreplace with "" will remove, using `f`ind to find lens
proc pop { _data elem } { upvar $_data data ; if {[set i [f $data $elem]]>=0} { set data [lreplace $data $i $i] } }

# Now we need some array specific actions.

# check if the lens exists, if so pop off the lens. This uses the list `pop` 
# which is check if the lens actually exists in the box.
proc apop { _arr key } { upvar $_arr a; set idx [hash $key] ; if {[info exists a($idx)]} {pop a($idx) $key }}

# push gets a bit hairy, we have to search for the lens in the box first. 
# if the lens is already there, replace the focal point with the new 
# value. Otherwise, append to the END of the box list (using `push`).
proc apush { _arr key val } {
    upvar $_arr a; set idx [hash $key]
    if {[info exists a($idx)]} {
      if {[set i [f $a($idx) $key]] >= 0} {
          set a($idx) [lreplace $a($idx) $i $i [list $key $val]]
          return
      }
    }
    push a($idx) [list $key $val]
}

# Now we'll need to take a command and covert it to the lens, operation,
# and value (if needed). 
proc convert {line} { regexp {(\w+)([=|-])([1-9]?)} $line -> h o v; return [list $h $o $v] }

# After converstion, we'll need to `o`perate on the command using the values.
# If the operation is '=' using `apush` to add the lens and focal point
# to the box `hash key`. If operation is '-', remove the lens from the box
# if present.
proc o {h o {v 0}} {if {$o eq "=" } { apush ::boxes $h $v } else { apop ::boxes $h }  }

# First we'll need to process all the commands before we can calculate 
# the final needed total. First we'll setup an array, boxes, in the global
# variable space `array set ::boxes {}`. Then for each command (spliting
# the line by a ',' convert the command to it key, lens, and value then 
# run the operation.

proc part2_process { data } { array set ::boxes {}; lmap i [st $data ,]  { foreach {hash op val} [convert $i] { o $hash $op $val } } }

# At this point, we just need to do the math
#   One plus the box number of the lens in question.
#   The slot number of the lens within the box: 
#      1 for the first lens, 2 for the second lens, and so on.
#  The focal length of the lens.
# So, the lens value `lv` is 
proc lv { b i v } { set a [mul [mul [add $i 1] $v]  [add $b 1]] }

# So we we have to go through each box (key in the array boxes) and 
# add all the totals for each box.
proc part2_post {} {
    set total 0
    lmap lens [array names ::boxes] {
        foreach {box item} [array get ::boxes $lens] break
        for {set idx 0} {$idx<[llength $item]} { incr idx} {
            incr total [lv $box $idx [lindex [lindex $item $idx] 1]]
        }
    }
    puts "#2: $total"
}

# So part2 is process and then post processing the answer.
proc part2 { data } { part2_process $data; part2_post }
@
```

So, part two becomes.

``` tcl 
<<part2.tcl>>=
#!/usr/bin/env tclsh8.6
# Advent of Code Day 15 - Part 2
lappend auto_path [file join ../ lib tcl aoc]
package require aoc 2023

<<helperFunctions>>
<<part2HelperFunctions>>

set data [slurp [lindex $argv 0]]

part2 $data

exit 0
@
```

Trying everything out.
#
``` shell
$ make part2-example
Creating example data for part 1...
Running part2 example...
#2: 145
$ make part2
Running part2 ...
#2: 294474
```

Day 15 is completed.
