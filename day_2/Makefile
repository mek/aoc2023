# -*- Makefile -*-
# vim: ft=make

SHELL = /bin/sh
TANGLE = ../scripts/tcl-tangle -R
TARGETS = example-part1.data part1.tcl part2.tcl

default:
	@echo "Please specify a target to make."

.PHONY: all
all: part1-example part1 part2-example part2

clean:
	@echo "Cleaning..."
	@rm -f *~
	@rm -f $(TARGETS)

example-part1.data: day_2.md
	@echo "Creating example data from part 1..."
	@$(TANGLE) $@ $< > $@

part1.tcl: day_2.md
	@echo "Creating part1 TCL script..."
	@$(TANGLE) $@ $< > $@
	@chmod 0700 $@

.PHONY: part1-example 
part1-example: example-part1.data  part1.tcl
	@echo "Running part1 example..."
	@./part1.tcl example-part1.data

.PHONY: part1
part1: part1.data  part1.tcl
	@echo "Running part1 example..."
	@./part1.tcl part1.data

part2.tcl: day_2.md
	@echo "Creating part2 TCL script..."
	@$(TANGLE) $@ $< > $@
	@chmod 0700 $@

.PHONY: part2-example 
part2-example: example-part1.data  part2.tcl
	@echo "Running part2 example..."
	@./part2.tcl example-part1.data

.PHONY: part2
part2: part1.data  part2.tcl
	@echo "Running part2 example..."
	@./part2.tcl part1.data
