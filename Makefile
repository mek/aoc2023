# -*- Makefile -*- 

SHELL = /bin/sh
TANGLE = ./scripts/tcl-tangle -R
TARGETS = lib/tcl/aoc/aoc.tcl

.PHONY: default all clean
default:
	@echo "Choose your path wisely ..."

all: $(TARGETS)

clean:
	@rm -f *~
	@rm -f $(TARGETS)

lib/tcl/aoc/aoc.tcl: aoc_tcl.md
	@echo "Updating lib/tcl/aoc/aoc.tcl ... "
	@$(TANGLE) $@ $< > $@	
	@chmod 0644 $@
	
