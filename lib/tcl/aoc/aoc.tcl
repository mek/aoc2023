# setup the package are require at least TCL 8.5
package provide aoc 2023
package require Tcl 8.5

## create the namespace for the module
namespace eval ::aoc {

    # what command will we export of usage
    namespace export with-open-file check-input-file

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

}
