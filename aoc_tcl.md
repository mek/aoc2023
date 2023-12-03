# Advent of Code TCL module

Since I plan to be using TCL quite a bit for my AOC work this year, I know there
will be some common things I will be using, I'll add those to a TCL module to use
to save typing.

## with-open-file

Since all the days activites involve working on a data from a file, having a good 
way to work with an open file is useful. 

`with-open-file` takes a filename, a mode, a filepointer var, and a block of TCL code
to run using the open file.

From [open](https://www.tcl-lang.org/man/tcl/TclCmd/open.htm) the modes can be:
* r  - read only, file must exist, default value.
* r+ - read write, file just exist.
* w  - write only, create new file or truncate current one.
* w+ - read write , create new file or truncate current one.
* a  - write, create new file if one doesn't exists (append).
* a+ - read write, create new file if one doesn't exists (append).

If the first char of the mode 'b', it will configure to read/write a binary file.

This procedure assumes that any checks on the file have been completed.

``` tcl
<<with-open-file>>=
proc with-open-file {fname mode fp block} {
    # This moves aliases the filepointer (fp) up to the 
    # next level, making it available in the TCL block.
    # inside the proc, we access fpvar.
    upvar 1 $fp fpvar

    # assume we are working on non-binary files.
    set binarymode 0

    # check if the first char in mode is a b, if so we assumed
    # wrong and we are working on a binary file. We'll have to 
    # remove the 'b' from the mode.
    if {[string equal [string index $mode end] b]} {
            set mode [string range $mode 0 end-1]
            set binarymode 1
    }

    # set fpvar to the file pointer returned by the open command. 
    # remember, in the TCL block, we'll refer to the fp var.
    set fpvar [open $fname $mode]
  
    # If we are using binary mode, configure the filepointer as needed.
    if {$binarymode} {
            fconfigure $fpvar -translation binary
    }

    # run the block in the same level as were it was called. This is why
    # we needed the upvar on the fp var.
    uplevel 1 $block

    # close
    close $fpvar
}
@
```

## check-input-file

For all the input files we'll be using, we'll want to make sure of three things:

* File exists
* File is a file
* File is readable.

This is a quick procedure that will run those three checks and exit if there is an issue.

``` tcl
<<input-file-check>>=
proc input-check-file { filepath } {

    # this is specific for AOC, but want to make sure 
    # that the file exists, is a file, and is readable. If not
    # exit with an given error.
    set file_checks {
        exists          "does not exists"
        isfile          "is not a file"
        readable        "is not readable"
    }

    # loop through the error checks and if something is amiss, notify and exit.
    foreach {check err} $file_checks {
        if {![file $check $filepath]} {
            puts stderr "error $filepath $err, exiting"
            exit 1
        }
    }

    # return success
    return 0
}
@
```

This should be it for now. Let's create a TCL module in lib/tcl/aoc.

``` tcl
<<lib/tcl/aoc/aoc.tcl>>=
# setup the package are require at least TCL 8.5
package provide aoc 2023
package require Tcl 8.5

## create the namespace for the module
namespace eval ::aoc {

    # what command will we export of usage
    namespace export with-open-file check-input-file

    <<with-open-file>>

   <<input-file-check>>

}
@
```


