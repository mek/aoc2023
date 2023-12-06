# Advent of Code - Day 5

[Day 5](https://adventofcode.com/2023/day/5)

## Intro

``` shell
Ranges today. 

The almanac (your puzzle input) lists all of the seeds that need 
to be planted. It also lists what type of soil to use with each 
kind of seed, what type of fertilizer to use with each kind of 
soil, what type of water to use with each kind of fertilizer, 
and so on.
```

So, we'll need to read in the seeds line

`seeds: NUM BERS .. ..`

Then we'll read in the maps:

```
seed-to-soil map:
50 98 2
52 50 48
```

Format is:

```
<name> map:
dest_range source_range range_length
dest_range source_range range_length
...
```

Then create a function that takes in the mapping, generates range
based on the mappings. 

Using the data above (and per the provided description)

`50 98 2` So .. 

* Source (seed number) range starts at 98 goes to 99. 
* Dest   (soil number) range starts at 50 and goes to 51. 

`52 50 48` means

* Source (seed number) range starts at 50 and goes to 97. (start+range-1)
* Dest   (soil number) range starts at 52 and goes to 99. (start+range-1)

If a source number is NOT in that range, it destination is the same. 

* Source (seed number) (not_in_range) 
* Dest   (soil number) (not_in_range)

To figure out the destination, you can find if it is in the range and 
them the given source value can be transformed using:

`dest_value = source_value + dest - source`

Also, since we'll probably do a lot of calculation, a nice cache would
be useful. 

We can create a simple cache in TCL. 

``` tcl
<<cache>>=

# create an array to act as a cache.
array set ::CACHE {} 

proc cache { args } { 
    # given a set of arguments (proc_name proc_arguments) 
    # see if we have already run it.  If so, return the value.
    if {[info exists ::CACHE($args)]} {
        set ::CACHE($args)
    } else {
        # Here the `args' have not been seen, so run the 
        # proc and save the value.
        # TCL will return the value to the calling level.
        set ::CACHE($args) [uplevel 1 $args]]
    }
}
```

So, now we can run a command using `remember proc arguments` and it will 
check if a we have run it before, if so, it will set the value, which will
be the return value of remember. 

If the arguments have NOT been seen, it wil run the arguments one level
up, which will be the level it was called from, and then set the value
to be returned from remember.

So, I quick test with a map function and test the cache.

``` tcl
#!/usr/bin/env tclsh8.6

set data {
  {50 98 2}
  {52 50 48}
}

proc array-incr { var key {incr 1} } { 

    upvar $var arr
    
    if {[info exists arr($key)]} {
        incr arr($key) $incr
    } else {
        set arr($key) $incr
    }

}

proc remember { args } { 
    array-incr ::CACHECOUNT total
    if {[info exists ::CACHE($args)]} {
        array-incr ::CACHECOUNT hits
        puts "cache hit"
        set ::CACHE($args)
    } else {
        array-incr ::CACHECOUNT missed
        set ::CACHE($args) [uplevel 1 $args]
    }
}

proc map {name map value} { 

    foreach range $map {
        foreach {d s r} $range {
            if {$value >= $s && $value < [expr {$s +$r}]} {
                return [expr {$value + $d - $s}]
            }
        }
    }
    return $value
}

array set ::CACHE      {}
array set ::CACHECOUNT {}

set mapping "data"
for {set source 48} {$source <=51} {incr source} {
    set dest_value [remember map "seed-to-soil" [set $mapping] $source]
    puts "source: $source dest_value: $dest_value"
}
for {set source 96} {$source <=99} {incr source} {
    set dest_value [remember map "seed-to-soil" [set $mapping] $source]
    puts "source: $source dest_value: $dest_value"
}
puts "-----"
puts "rerun"
puts "-----"
for {set source 48} {$source <=51} {incr source} {
    set dest_value [remember map "seed-to-soil" [set $mapping] $source]
    puts "source: $source dest_value: $dest_value"
}
for {set source 96} {$source <=99} {incr source} {
    set dest_value [remember map "seed-to-soil" [set $mapping] $source]
    puts "source: $source dest_value: $dest_value"
}
parray ::CACHECOUNT
```

``` text
ource: 48 dest_value: 48
source: 49 dest_value: 49
source: 50 dest_value: 52
source: 51 dest_value: 53
source: 96 dest_value: 98
source: 97 dest_value: 99
source: 98 dest_value: 50
source: 99 dest_value: 51
-----
rerun
-----
cache hit
source: 48 dest_value: 48
cache hit
source: 49 dest_value: 49
cache hit
source: 50 dest_value: 52
cache hit
source: 51 dest_value: 53
cache hit
source: 96 dest_value: 98
cache hit
source: 97 dest_value: 99
cache hit
source: 98 dest_value: 50
cache hit
source: 99 dest_value: 51
::CACHECOUNT(hits)   = 8
::CACHECOUNT(missed) = 8
::CACHECOUNT(total)  = 16
```

## Part 1

``` text
<<example-part1.data>>=
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
@
```

So, we will have to parse the entire file first.  We should be able to search using
`regexp {([\-\s\w]*): ?(.*)?} $line1 -> key value` which will look for `seeds` and 
`---- map`. If we get `seeds`, use the $value. If we get a map, we'll need to read
until we get a blank link, appending the lines to a list.

So, we'll need a varible to know if we are are reading just the lines.

``` tcl
<<processFile>>=
array set ::MAPS {}
::aoc::with-open-file $input_file "r" fp {
    # we'll need a mapping lines, we don't want to do a regexp.
    set reading_map_data 0
        switch $reading_map_data {
            0 {
                if {![regexp {([\-\s\w]*): ?(.*)?} $line -> key value]} {
                     puts "error reading file"
                 }
                 switch -glob -- $key {
                     seeds { puts "seeds" ; set seeds [split $value " "] }
                     *map* {
                         set reading_map_data 1
                         foreach {map extra} [split $key " "] break
                         set ::MAPS($map) [list]
                     }
                 }
             }
             1 {
                  if { $line eq "" } {
                      set reading_map_data 0
                  } else {
                      lappend ::MAPS($map) $line
                  }
             }
         }
    }
}
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
