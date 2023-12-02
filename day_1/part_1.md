# Advent of Code

[Day 1](https://adventofcode.com/2023/day/1)

```
On each line, the calibration value can be found by combining the first digit and the last digit (in that order) to form a single two-digit number.
```

## Example Data
```
<<example-part1.data>>=
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
@
```

We need to find the first and last single digit number to form a two digit
number. A few notes:

* There has to be at least one digit.
* If there is one digit, the first and last digit will be the same.

My first thought is to approach the problem this way:

* Read in in a file line-by-line.
* Starting from the start of the string, look for a single integer.
  * If one is not found, error out the line. 
* Once the first one is found, start a search from the back of the 
line, looking for a digit.
  * If one is no found, error out the line. 
  * This should NEVER happen.
* Combine the two integers to form a two digit interger and add that 
to a running total.

### Variables we'll need

* input_file 		- from command line
* line			- when we read the file
* line_length		- computed from the line
* total			- our total (and only output)
* results		- all the digits we find in a line.
  * format - [digit localtion] (a list of lists)
* first_digit		- Our first digit
* first_digit_location	- first digit location in line
* second_digit		- out second digit
* second_digit_location - second digits location in line

### Inputs
* input_file (command line)

## Output
* total (stdput)

### Error conditions

* Can not open file.
* No digit found when looking for first digit.
* first digit is greater than the length of the line.
* No digit found when looking for second digit.
* second digit is less than the start of the line.
* Second digit is LESS THAN first digit. 

## Setting up the program.

I'm going to use [TCL](https://www.tcl-lang.org) 'cause I like TCL.
Specifically version 8.6.

``` tcl
<<scriptStart>>=
#!/usr/bin/env tclsh8.6
# -*- tcl -*-
# Mat Kovach
# Advent of Code, Day 1
#
@
```

## We'll need to work on an open file. 

This is a quick procedure to work on an open file. The procedure will
accept a filename, a mode to access the file, a variable or the 
file pointer, and a block of TCL data to run on the file.

``` tcl
<<procWithOpenFile>>=
proc with-open-file {fname mode fp block} {
    upvar 1 $fp fpvar
    set binarymode 0
    if {[string equal [string index $mode end] b]} {
            set mode [string range $mode 0 end-1]
            set binarymode 1
    }
    set fpvar [open $fname $mode]
    if {$binarymode} {
            fconfigure $fpvar -translation binary
    }
    uplevel 1 $block
    close $fpvar
}
@
```

## Variables

While one does not have to setup variables be being used in TCL, I'm 
going to set some up with defaults to document them.

In the main part of the application, we'll just need to make sure that 
the input_file is setup.
``` tcl
<<setupVarsMain>>=
set input_file {}
set total 0
set prog [file tail [file normalize $argv0]]
@
```

## Arguments

First a simple usage.

``` tcl
<<procUsage>>=
proc Usage {} { 
	global proc
	puts "usage: $prog <input_file>"
	exit 1
}
@
```

## Let's get our input file and make sure it is valid.

``` tcl
<<procCheckFile>>=
proc input-check-file { filepath } {

    set file_checks {
        exists          "does not exists"
        isfile          "is not a file"
        readable        "is not readable"
    }

    foreach {check err} $file_checks {
        if {![file $check $filepath]} {
            puts stderr "error $filepath $err, exiting"
            exit 1
        }
    }

}
@
```

The first thing we'll need to do is read in the input file from the command line
and make sure it is a valid file.

``` tcl
<<mainCheckInputFile>>=

if {[llength $argv] !=1 } {
    Usage
}

set input_file [lindex $argv 0]

input-check-file $input_file
@
```

Now we'll need a procedure to take a line as input and return the digits
and their position as a list. Since we are only looking for single digits
we can go through each charactor of the line and check if it is numeric.

``` tcl
<<procCheckForDigits>>=
proc check-for-digits { line } { 

    # at the start, we have no results so create an empty list.
    set results []

    # we start at the begining of the line
    # set start 0
    # we'll end when we reach the end of the line
    # set end [string length $line]
    # we step on charactor at a time
    # set step 1
    # a simple for loop will increment through the line
    for { set i 0 } { $i != [string length $line] } { incr i } {

	# get the current charactor
        set char [string index $line $i]

	# check if the line is an integer digit
        switch -regexp --  $char {
            [0-9] {
            	# if so append the char and it's position (i) to the result.
                lappend results [list $char $i ]
            }
        } 
    }

    # completed, return the results.
    return $results


}
@
```

Now that we have a function (check_for_digits) to look at the line, we need to 
loop the input file, get the results, and process them.

To do that, we'll use our file process (with-open-file). We'll start by setting the 
total to 0. We'll read a line into the line variable (gets filepointer line). Feeding 
the line into check-for-digits, we'll make sure we got a results (a non empty list)
then we'll take the first and last digit, make sure the results seem good (we'll test
that the first results is less than the last result). Then we'll combine the two numbers
to create a two digiti number and increment the total by that numbers. 

After we are done, we'll output the total.

``` tcl
<<mainProcessFile>>=
# open the file read only and setup a filepointer (fp).
with-open-file $input_file "r" fp {

    # set total to 0
    set total 0
    
    # start looping until we have reached the end of the file, or we get no data.
    # we assume the input file has no empty lines.
    while {[gets $fp line]>=0} {
        set results [check-for-digits $line]
        if {[llength $results] == 0 } { 
            puts stderr "line:$line produce no results, exiting"
            exit 1
        }
        
        # we have the results, use TCL lindex function to get the first
        # index of the list (position 0) and the end item of the list 
        # index (end). 
        # We could use
        # set first_result [lindex $results 0[
        # set fnum [lindex $first_result 0]
        # set findx [lindex $first_result 1]
        # but the foreach varList List break trick here
        # will set the variables without the need for the third variable.
        foreach {fnum fidx} [lindex $results 0  ] break
        foreach {lnum lidx} [lindex $results end] break
        
        # here is are data test.
        if { $fidx > $lidx } { 
            puts stderr "line:$data, $fnum found at $fidx but $lnum found at $lidx"
            exit 1
        }
        
        # combine the numbers to a double digit number FNUMLNUM
        set num [format "%d%d" $fnum $lnum]
        
        # TCL's incr defaults to one, but if you give it a second argument
        # it will increment the variable but the second argument.
        incr total $num
    }
}

# Done, print the total.
# Put a comment in from so I can include the data in a chuck 
# and allow it to be easily cut-n-pasted
puts "# $total"

# Exit successfully
exit 0
@
```

Now let's combine that into a script. 

``` tcl
<<part1.tcl>>=
<<scriptStart>>
#
# procedures
#
<<procWithOpenFile>>
<<procCheckFile>>
<<procUsage>>
<<procCheckForDigits>>
#
# main
#
# setup variables for main
<<setupVarsMain>>
#
# check input fuile
#
<<mainCheckInputFile>>
#
# let's do it!
#
<<mainProcessFile>>
@
```

## Testing part1

First we'll want to create the example data for part 1.

``` shell
../scripts/tcl-tangle -R example-part1.data part_1.md > example-part1.data
```

Now, create the part1 TCL scripts.

``` shell
../scripts/tcl-tangle -R part1.tcl part_1.md > part1.tcl && chmod 0700 part1.tcl
```

Then run the scripts on the example data and see if we get 142.

``` shell
./part1.tcl example-part1.data
# 142
```

Now, I'll take my puzzle input for Part 1 and put in into a file `part1.data`.

``` shell
./part1.tcl part1.data
# 54388
```

Which is the proper answer. 

Note, I created a [Makefile](Makefile) to actully run the commands, I am just put them 
in there to show how I use the tangle script.

## PART 2

Now to [Day 1 Part 2](https://adventofcode.com/2023/day/1#part2). The change we have 
here is that we'll not just be searching for a single interger in the data line, but we also
be searching for the spelled out words for digits. It was here I see a possible bug in 
the first part, my switch statement searching for digits included '0', which it should not have. 

But, looking at the new requirement, I should be able to correct that, and use the line 
processor for part 2 to get the right answer for part 1. 

All other parts for the script should remain the same. So, this will focus on those changes
to `proc check-for-digits`. We'll use the same interface, accepting a line of the input file, 
and we'll return the same, a list of results, in the proper order. 

In the first part, since we searched from start to end in the line, the results happened to 
be delivered in the right order. But the new procedure probably not do that, so we'll have
to make sure we return the results correctly. It would be fair to call that a bug in the 
first part. 

TCL has a number of [string](https://wiki.tcl-lang.org/page/string) and I think 
[string first]https://wiki.tcl-lang.org/page/string+first) will be helpful here. 

`string first needle haystack ?startIndex? ` will search for the first occurance on `needle` in 
the `haystack`. But default, it will start searching at position **0**. If it finds the occurance
it will return the starting position in the string. If it doesn't find an occurance in the 
of needle in the haystack in returns **-1**. 

So, despite we can be very ineffective, we can look through each possible value with
`string first` and if we find a match, search again using the position + 1. For example:

``` tcl
<<part2test>>=
#!/usr/bin/env tclsh8.6
set haystack {zoneight234}
set needle {one}
set start 0

while { [set start [string first $needle $haystack $start]] >= 0 } { 

    # if we get here, we found the needle.
    puts "# line: $haystack $needle: pos: $start"
    
    # increment start by one
    incr start

}
@
```

Now test it.

``` shell
../scripts/tcl-tangle -R part2test part_1.md > part2test
./part2test 
# line: zoneight234 one: pos: 1
```

So, that seemed to work, not let's create a list of needles and their values and 
test on the entire example data for part 2. We'll look around the `needle check`.

``` tcl
<<part2test1>>=
#!/usr/bin/env tclsh8.6
set haystacks {
	two1nine
	eightwothree
	abcone2threexyz
	xtwone3four
	4nineeightseven2
	zoneight234
	7pqrstsixteen
}

set needles {
	one	1
	two	2
	three	3
	four	4
	five	5
	six	6
	seven	7
	eight	8
	nine	9
	1	1
	2	2
	3	3
	4	4
	5	6
	6	6
	7	7
	8	8	
	9 	9
}

foreach haystack $haystacks {
    foreach {needle value} $needles {
        set start 0

        while { [set start [string first $needle $haystack $start]] >= 0 } {

           # if we get here, we found the needle.
           puts "# line: $haystack $needle: pos: $start value: $value"
    
           # increment start by one
           incr start
       }
    }
}
@
```

Now, test.

``` shell
../scripts/tcl-tangle -R part2test1 part_1.md > part2test1
tclsh part2test1 
# line: two1nine two: pos: 0 value: 2
# line: two1nine nine: pos: 4 value: 9
# line: two1nine 1: pos: 3 value: 1
# line: eightwothree two: pos: 4 value: 2
# line: eightwothree three: pos: 7 value: 3
# line: eightwothree eight: pos: 0 value: 8
# line: abcone2threexyz one: pos: 3 value: 1
# line: abcone2threexyz three: pos: 7 value: 3
# line: abcone2threexyz 2: pos: 6 value: 2
# line: xtwone3four one: pos: 3 value: 1
# line: xtwone3four two: pos: 1 value: 2
# line: xtwone3four four: pos: 7 value: 4
# line: xtwone3four 3: pos: 6 value: 3
# line: 4nineeightseven2 seven: pos: 10 value: 7
# line: 4nineeightseven2 eight: pos: 5 value: 8
# line: 4nineeightseven2 nine: pos: 1 value: 9
# line: 4nineeightseven2 2: pos: 15 value: 2
# line: 4nineeightseven2 4: pos: 0 value: 4
# line: zoneight234 one: pos: 1 value: 1
# line: zoneight234 eight: pos: 3 value: 8
# line: zoneight234 2: pos: 8 value: 2
# line: zoneight234 3: pos: 9 value: 3
# line: zoneight234 4: pos: 10 value: 4
# line: 7pqrstsixteen six: pos: 6 value: 6
# line: 7pqrstsixteen 7: pos: 0 value: 7
```

Now, we should prepare the results correctly. We'll use an an array, but one thing to 
remember is that TCL arrays can us arbitary keys, so we'll have to sort the array to 
the integer position before returning the results. 


``` tcl
<<part2test2>>=
#!/usr/bin/env tclsh8.6
set haystacks {
	two1nine
	eightwothree
	abcone2threexyz
	xtwone3four
	4nineeightseven2
	zoneight234
	7pqrstsixteen
}

set needles {
	one	1
	two	2
	three	3
	four	4
	five	5
	six	6
	seven	7
	eight	8
	nine	9
	1	1
	2	2
	3	3
	4	4
	5	6
	6	6
	7	7
	8	8	
	9 	9
}

# Note, the haystacks would be a line, we we'll return the results after 
#       each one.
foreach haystack $haystacks {
    array set results_array {}
    foreach {needle value} $needles {
        set start 0

        while { [set start [string first $needle $haystack $start]] >= 0 } {

           # if we get here, we found the needle.
           # puts "# line: $haystack $needle: pos: $start value: $value"
   	   
           # We have our data, let's put in in the results array, but first
           # make sure array key does not exists. If it does, something is 
           # wrong.
           if {[info exists results_array($start)]} { 
               puts stderr "Results at position: $start already defined"
               parray results_array
               exit 1
           }
           set results_array($start) $value
           
           # increment start by one
           incr start
       }
    }
    # Sort the results and put into a list of list.
    # Get the list of array keys (pos) and sort by integer.
    # using the sorted list, append the [pos value] list to 
    # the results list.
    set results {}
    foreach idx [lsort -integer [array names results_array]] {
        lappend results [list $idx $results_array($idx)]
    }
    # parray results_array
    puts "$results"
    array unset results_array
}
@
```

Now, running our test again things look correct, we'll create a replacement `check-for-digits`
procedure.

``` shell
../scripts/tcl-tangle -R part2test2 part_1.md > part2test2
tclsh part2test2
{0 2} {3 1} {4 9}
{0 8} {4 2} {7 3}
{3 1} {6 2} {7 3}
{1 2} {3 1} {6 3} {7 4}
{0 4} {1 9} {5 8} {10 7} {15 2}
{1 1} {3 8} {8 2} {9 3} {10 4}
{0 7} {6 6}
```

Notice, we are keeping the procedure name the same, put creating a different chuck name. 
When we create the chuck for `part2.tcl` we'll include this chuck as a replacement.

``` tcl
<<procCheckForDigitsPart2>>=
proc check-for-digits { haystack } { 

    # setup the needles we'll be looking for in the line, haystack
    set needles {
	one	1
	two	2
	three	3
	four	4
	five	5
	six	6
	seven	7
	eight	8
	nine	9
	1	1
	2	2
	3	3
	4	4
	5	5
	6	6
	7	7
	8	8	
	9 	9
    }

    # make sure the array is set, we'll unset the array before leaving the procedure.
    array set results_array {}

    # Do our very ineffective loop.
    foreach {needle value} $needles {
        set start 0

        while { [set start [string first $needle $haystack $start]] >= 0 } {

           # We have our data, let's put in in the results array, but first
           # make sure array key does not exists. If it does, something is 
           # wrong.
           if {[info exists results_array($start)]} { 
               puts stderr "Results at position: $start already defined"
               parray results_array
               exit 1
           }
           set results_array($start) $value
           
           # increment start by one
           incr start
       }
    }
    # Sort the results and put into a list of list.
    # Get the list of array keys (pos) and sort by integer.
    # using the sorted list, append the [pos value] list to 
    # the results list.
    set results {}
    foreach idx [lsort -integer [array names results_array]] {
        lappend results [list $results_array($idx) $idx]
    }
    array unset results_array

    # completed, return the results.
    return $results

}
@
```

Now write our `part2.tcl` chuck. Note, I had found out that that I returned the results 
in the wrong order. 

**During testing it was [index value] but it should have been [value index].
I changed the `procCheckForDigitsPart2` chuck, but did not update the testing.**

**I also had the needles wrong and had 5=6. opps!**

``` tcl
<<part2.tcl>>=
<<scriptStart>>
#
# procedures
#
<<procWithOpenFile>>
<<procCheckFile>>
<<procUsage>>
<<procCheckForDigitsPart2>>
#
# main
#
# setup variables for main
<<setupVarsMain>>
#
# check input fuile
#
<<mainCheckInputFile>>
#
# let's do it!
#
<<mainProcessFile>>
@
```

``` text
<<example-part2.data>>=
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
@
```

Running with the sample data.

``` shell
make part2-example
Creating example data from part 1...
Creating part2 TCL script...
Running part2 example...
# 281
```

Downloading my data for part 2 into `part2.data` and running it.

``` shell
$ make part2
Running part2 example...
# 53515
```
