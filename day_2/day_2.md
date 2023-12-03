# Advent of Code Day 2

Snow Island Elf Game

## Part 1
``` text
To get information, once a bag has been loaded with cubes, the Elf will reach into the bag, grab a handful of random cubes, show them to you, and then put them back in the bag. He'll do this a few times per game.

You play several games and record the information from each game (your puzzle input). Each game is listed with its ID number (like the 11 in Game 11: ...) followed by a semicolon-separated list of subsets of cubes that were revealed from the bag (like 3 red, 5 green, 4 blue).

For example, the record of a few games might look like this:
```

``` text
<<example-part1.data>>=
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
@
```

We have to determine if a game is "possible", which means no more than a certain about 
of colors are pulled out. The example given is:

``` test
red cubes	12
green cubes	13
blue cubes	14
```

So if more cubes are pulled than the max, a game is not possible. In the example
above, 1,2,5 are possible, 3 and 4 are not. Then we'll sum up the possible games
for a final score. 

### Part 1 data format

We'll start with `Game <GAME NUMBER>:` then have a comma seperated dynamic line, 
seperated by ';' in the format `<NUM> color`. Game is terminated by a new line.

We'll need to get the `game_num`, take the data after the ':' to be the game rounds.
Spliting the `game_rounds` but a ',' we'll have to pull the `num` and `color` for each
`round` and then check to make sure the color is valid and if the number for that 
round is `possible`.

### Setting a few things up

We'll need our limits, or `colormaxs` and we'll also need a procedure that, when given
a `color` and `num`, will exit if the color is invalid, or return 1 if num is less than
the max and 0 if num is greater than the max

Passing arrays to TCL is possible, but for this case using a global variable
`colormax` is fine. This is how TCL makes the environment variable array `::env` 
available to procedures. 

When then have `color-check` which will make sure we have a valid color and will indicate
if we have exceeded the max number of cubes.

``` tcl
<<colorMax>>=
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
@
```

Now we'll have to parse each line from the input file. To do that, we are going to 
use the tcl [split](https://www.tcl-lang.org/man/tcl/TclCmd/split.htm) function. But
we'll also have to worry about some whitespaces, so we'll combine that with the 
[string trim](https://www.tcl-lang.org/man/tcl/TclCmd/string.htm#M47) function.

The `split-n-trim` procedure accepts a string of `data` and and optional 
seperator `char` (default is space " "). It first splits the line and loops
through each item, trimming off spaces.

``` tcl
<<procSplitNTrim>>=
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
@
```

Now we'll have to create a proc to process each line and return if the game is 
possible or not. Technically, we should be able to stop after the first game round
that is NOT possible, but we do not. We don't know if part 2 will require full
processing even if a game is not possible.

The proc `process-line` will accept a line of data, get the game number `name_num`, 
check the game rounds and see if they are possible. If all are possible we'll return the
game number otherwise we'll return 0.

``` tcl
<<procProcessLine>>=
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
@
```

Ugh, that is a bit ugly but seems good. I'll put the part1 script together. I have create
a [TCL Module](../aoc_tcl.md) where I'll store some common fuctions to save on typing. 
Currently `with-ope-file` and `input-check-file` are availble. 

### part1.tcl

We need to setup the script and load our aoc helper package.

``` tcl
<<part1Start>>=
#!/usr/bin/env tclsh8.6
# Since I want this to work in the repo, we append the 
# path to the TCL module location directly. 
lappend auto_path [file join ../ lib tcl aoc]

# call our helper functions
package require aoc 2023

@
```

We we have to setup the procedures described above.

``` tcl
<<part1Procs>>=
#
# Color Limit Info
#
<<colorMax>>
#
# split-n-trim
#
<<procSplitNTrim>>
#
# process line
#
<<procProcessLine>>
@
```

Now create the main part, check for the input file and process. Since
process line returns 0 or the game number, to get the some we just 
have to incr a the total but the return value of `process-line`.


``` tcl
<<part1.tcl>>=
<<part1Start>>
<<part1Procs>>

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
@
```

Using the test data:

``` shell
make part1-example
Creating example data from part 1...
Creating part1 TCL script...
Running part1 example...
# 8
```

Now, I'll download my puzzle input for part1 into `part1.data` and give it a try.

``` shell
make part1
Running part1 example...
# 2716
```

## Part 2

Now, let's see what bad decisions I made in part 1. 

[Part 2](https://adventofcode.com/2023/day/2#part2) changes things a bit. 

Now we have

```
As you continue your walk, the Elf poses a second question: in each game you played, what is the fewest number of cubes of each color that could have been in the bag to make the game possible?
```

Also

```
The power of a set of cubes is equal to the numbers of red, green, and blue cubes multiplied together. The power of the minimum set of cubes in game 1 is 48. In games 2-5 it was 12, 1560, 630, and 36, respectively. Adding up these five powers produces the sum 2286.

For each game, find the minimum set of cubes that must have been present. What is the sum of the power of these sets?
```

So, all we really need to do is change `check-color` to start as an empty set for each 
game round, and use it to set the max. Instead of looking if a round is possible, we'll record
the max num of cubes.

Then in `process-line`, after processing the lines, we'll return the power min number of 
cubes to make a game possible (the max number per color for each round) mulipled together.

Our answer will be the sum of those.

``` tcl
<<part2colorMax>>=
array set colormax {
    red   0
    green 0
    blue  0
}

proc check-color { color num } {

    global colormax

    if {![info exists colormax($color)]} {
        puts stderr "Invalid color $color found, exiting"
        exit 1
    }

    # check if number is larger than current max.
    if { $num > $colormax($color) } {
        array set colormax [list $color $num]
    }

}
@
```

Now, let's update `process-line`. We'll remove the possible check. We'll have to 
make sure to reset the colormax var for each game round. We should also check 
to make sure not maxes are zero before we assume that will happen.

``` tcl
<<procPart2ProcessLine>>=
proc process-line { line } {

    global colormax

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

    # zero out the colormax array
    foreach color [array names colormax] { 
        array set colormax [list $color 0]
    }
    # uset the variable to be safe, it is used below.
    unset color

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
                # check for valid data.
                # this will update the max valume in colormax
                check-color $color $num
            } else {
                puts stderr "could not parse $round in $game_round for game num $game_num"
            }
        }
    }
    # we'll be return the color multipled togeter, so we'll start with power as 1.
    set power 1
    foreach color [array names colormax] { 
	if { $colormax($color) == 0 } {
            puts "game $game_num returned max cubes for $color as 0"
        }
        set power [expr $colormax($color) * $power]
    }
    return $power 
}
@
```

## part2.tcl

Making the changes, let's create our `part2.tcl` script.

``` tcl
<<part2Procs>>=
#
# Color Limit Info
#
<<part2colorMax>>
#
# split-n-trim
#
<<procSplitNTrim>>
#
# process line
#
<<procPart2ProcessLine>>
@
```

Now create the main part, check for the input file and process. Since
process line returns 0 or the game number, to get the some we just 
have to incr a the total but the return value of `process-line`.


``` tcl
<<part2.tcl>>=
<<part1Start>>
<<part2Procs>>

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
@
```

Working on the example data:

``` shell
make part2-example
Creating example data from part 1...
Running part2 example...
# 2286
```

Now the puzzle data

```
make part2
Creating part2 TCL script...
Running part2 example...
# 72227
```

Day 2 is done!

```
make all 
Creating example data from part 1...
Running part1 example...
# 8
Running part1 example...
# 2716
Running part2 example...
# 2286
Running part2 example...
# 72227
```
