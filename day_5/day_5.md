# Advent of Code - Day 5

[Day 5](https://adventofcode.com/2023/day/5)

## Intro

``` shell
What to do 
```

## Part 1

``` text
<<example-part1.data>>=
DATA HERE
@
```

### part1.tcl 

``` tcl
<<part1.tcl>>=
#!/usr/bin/env tclsh8.6
# Advent of Code Day 5 - Part 1
lappend auto_path [file join ../ lib tcl aoc]
package require aoc 2023

exit 0
@
```

``` shell
$ make part1-example
Creating example data from part 1...
Creating part1 TCL script...
Running part1 example...
# 13
$ make part1
Running part1 ...
# 24160
```

## Part 2

``` tcl 
<<part2.tcl>>=
#!/usr/bin/env tclsh8.6
# Advent of Code Day 5 - Part 2
lappend auto_path [file join ../ lib tcl aoc]
package require aoc 2023

::aoc::input-check-file [set input_file [lindex $argv 0]]

# process line
<<processLinePart2>>

exit 0
@
```

Trying everything out.

``` shell
$ make clean all
Cleaning...
Creating example data from part 1...
Creating part1 TCL script...
Running part1 example...
# 13
Running part1 ...
# 24160
Creating part2 TCL script...
Running part2 example...
# 13
# 30
Running part2 ...
# 24160
# 5659035
```

Day 5 is completed.
