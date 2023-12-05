# Advent of Code - Day 4

[Day 4](https://adventofcode.com/2023/day/4)

More fun with parsing. 

``` shell
As far as the Elf has been able to figure out, you have to figure out 
which of the numbers you have appear in the list of winning numbers. 
The first match makes the card worth one point and each match 
after the first doubles the point value of that card.
```

So we'll be given a line of data in the format:

`Cart NUM: WINNING NUMERS | CARD NUMBERS`

Then we'll have to keep a list of the winning numbers and check for
any card numbers that match the winning ones. The points get 
doubles each time, so the first one is 1, next is 2, then 4, then, 8, etc.

Keeping track of the number of matching winnings numbers, we should be 
able to calculate the points using:

`2**(number_of_wins - 1)`

Can we'll need to calculate the sum to get the anwser for part 1.

## Part 1

``` text
<<example-part1.data>>=
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
@
```

### calculate points
Let's write a procedure to calulate the points. One issue with TCL
is that we'll need to use the `pow(num,power)` function which returns
a floating point number. But we'll also use `incr` to increase the 
total after each line is checked, so we'll have to use `scan` to 
format the result of our calculation to integer. 

``` tcl
<<procCalculatePoints>>=
proc calculate-points { wins } { 
    # calculate the points based on the number of wins. 
    # format the float response of 'pow' to interger using scan.
    return [scan [expr {pow(2,$wins-1)}] "%d"]
}
@
```

### regular expression for the line

A regular expression with work find to parse the line to find the 
Card number `card`, the winnings numbers `winning_numbers`, and the
card's numbers we have to check, `card numbers`. 

Experience as taught me to now trust the formatting and we may get extra
spaces were we don't expect. This will factoring into the regular expression
since `Card (\d+):` will pickup `Card: 100` but not `Card:  10`. So 
we'll need `Card +(\d+):` and make sure to used the same for the 
`winning_numbers` and `card_numbers`. So, specific for TCL, the 
regexp command will be:

``` tcl
<<lineRegExp>>=
regexp {Card +(\d+): +(.*) \| +(.*)} $line -> card winning_numbers card_numbers
@
```

Note: `->` is actually a variable, holding all of the line that was matched. 
It isn't used and the `->` convention seems to be easy for folks to 
understand.

### split and trim

Since we'll probably have extra spaces in the card data and we plan to 
split and it only will split by one char, we'll need to go some clean up.
One could use an `regsub` to change any muliple spaces to single spaces. 
We will just do a split on spaces, and if a list item is empty `""`
we won't append it to the result.

``` tcl
<<procSplitNTrim>>=
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
@
```

### process part 1 line data

Now we are ready to process the line data. We'll do that in a proceure
that accepts that line, run the regexp, and if the line is successfully
regex'd set the number of wins to 0. Then we'll get the 
`winning_number_list` and run it through `split-n-trim`. Using a `foreach`
loop we'll go through each number in `card_numbers` and that data
has been `split-n-trim`'d also. 

Using `lsearch` we look for the `number` and if found (lsearch returns
a index in the `winning_number_list` and not `-1`, will increase
the number of wins by 1.

At the start of the procedure, but the regexp, we'll set total to 0. Once
we have checked all the `card_numbers` and return the number of wins. 

For the second part, we'll need the `card_num` so we'll return it from 
`process-line-part1`. 

Then we'll return the total.

``` tcl
<<procProcessLinePart1>>=
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
@
```

### part1.tcl 

The rest of the script is easy to put together. We'll need to 
typically beging to load the TCL aoc modules, check the input file
and call `process-line-part` from with in the `with-open-file` procedure
provied by the aoc modules.

We'll create a process line part, assuming we'll have to do more 
in part 2.

In fact the only change we really need to make was to return `card_num`
from `process-line-part1`. It isn't used here, but is used in part 2.


``` tcl
<<processLine>>=
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
@
```

``` tcl
<<part1.tcl>>=
#!/usr/bin/env tclsh8.6
lappend auto_path [file join ../ lib tcl aoc]
package require aoc 2023

# procedures
<<procCalculatePoints>>

<<procSplitNTrim>>

<<procProcessLinePart1>>

# Set the program name variable
set prog [file tail [file normalize $argv0]]

if {[llength $argv] !=1 } {
    puts stderr "Usage: $prog input_file"
    exit 1
}

::aoc::input-check-file [set input_file [lindex $argv 0]]

# process line
<<processLine>>

exit 0
@
```

Now let's test it.

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

# Part 2

It seems that we have to keep track of the number of winners each 
card has, since we get more "clone" cards. 

``` text
Copies of scratchcards are scored like normal scratchcards and 
have the same card number as the card they copied. So, if you 
win a copy of card 10 and it has 5 matching numbers, it would 
then win a copy of the same cards that the original card 10 won: 
cards 11, 12, 13, 14, and 15. This process repeats until none of 
the copies cause you to win any more cards. (Cards will never 
make you copy a card past the end of the table.)
```

So, we'll need an array to count the number of copies we get 
for eaching winning card number, then sum them together. 

Caveat: Cards will never make you copy a card past the end of the table.

So we don't have to do any bounds checking. (Famous last words).

We'll need to a a setup for the array in the script. We'll also 
need to add a proc that will allow use to increment an array value.

To incrment it, it will have to be already there, so the array 
increment procedure will need to check it if exists first. Since
TCL can't work on a passed array, we'll need to use `upvar` to 
work on the array. 

``` tcl 
<<setupCardCountArray>>=
array set card_count {}

proc incr-card-count-element { var card {incr 1} } { 

    upvar $var arr
    
    if {[info exists arr($card)]} {
        incr arr($card) $incr
    } else {
        set arr($card) $incr
    }

}
@
```

Originally I was just sending the `wins` back after processing the 
lines, but counting cards means the `card_num` was needed. I make
the need changes to have `card_num` availble.

Now we have a way to update the array `card_count`. If a card has
`wins`, we'll look for the range `card_num` + 1 to 
`card_num` + `wins` + 1.

We increase the card count by the number of current copies.

We'll increase the cards in that range by 1. 

``` tcl
<<countCardCopies>>=
# regardless, we have on card.
incr-card-count-element card_count $card_num

if {$wins>0} { 
    for { set idx [expr $card_num + 1] } {$idx<[expr $card_num + 1 + $wins]} { incr idx } { 
        incr-card-count-element card_count $idx $card_count($card_num)
    } 
}
@
```

``` tcl
<<processLinePart2>>=
# Set the total to 0
set total 0

# Process the file
::aoc::with-open-file $input_file "r" fp {
    while {[gets $fp line]>= 0} {
	foreach {card_num wins} [process-line-part1 $line] break
        if {$wins > 0} {
           incr total [calculate-points $wins]
        }
        <<countCardCopies>>
    }
}

puts "# $total"
set total_cards 0
foreach card [array names card_count] { 
    incr total_cards $card_count($card)
}
puts "# $total_cards"
@
```

``` tcl 
<<part2.tcl>>=
#!/usr/bin/env tclsh8.6
lappend auto_path [file join ../ lib tcl aoc]
package require aoc 2023

# procedures
<<procCalculatePoints>>

<<procSplitNTrim>>

<<procProcessLinePart1>>

# Setup part 2 card count array and procedure

<<setupCardCountArray>>

# Set the program name variable
set prog [file tail [file normalize $argv0]]

if {[llength $argv] !=1 } {
    puts stderr "Usage: $prog input_file"
    exit 1
}

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

Day 4 is completed.
