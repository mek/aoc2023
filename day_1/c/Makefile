# -*- Makefile -*-
# vim: ft=make

SHELL = /bin/sh
TANGLE = ../../scripts/tcl-tangle -R

.PHONY: default
default:
	@echo "Please specify a target to make."

.PHONY: clean
clean:
	@rm -f part1.l testdata1 data1 part2 testdata2 data2
	@rm -f lex1.yy.c part1 example1 lex2.yy.c part2 example2
	@rm -f *~

part1.l: flex.md
	@$(TANGLE) $@ $< > $@

lex1.yy.c: part1.l	
	@flex -l -o $@ $<

part1: lex1.yy.c 
	@cc -lfl -o $@ $< 

testdata1: flex.md
	@$(TANGLE) $@ $< > $@

example1: part1 testdata1
	@./part1 < testdata1 > example1

data1: part1 ../../data/day_1/part1.data
	@./part1 < ../../data/day_1/part1.data > data1

.PHONY: view-example1
view-example1: example1
	@cat example1

.PHONY: view-data1
view-data1: data1
	@cat data1

part2.l: flex.md
	@$(TANGLE) $@ $< > $@

lex2.yy.c: part2.l	
	@flex -l -o $@ $<

part2: lex2.yy.c 
	@cc -Wall -lfl -o $@ $< 

testdata2: flex.md
	@$(TANGLE) $@ $< > $@

example2: part2 testdata2
	@./part2 < testdata2 > example2

data2: part2 ../../data/day_1/part2.data
	@./part2 < ../../data/day_1/part2.data > data2

.PHONY: view-example2
view-example2: example2
	@cat example2

.PHONY: view-data2
view-data2: data2
	@cat data2
