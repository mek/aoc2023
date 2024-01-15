# AOC Day 1 with Lex

An old work buddy contacted me during he holidays asking for a bit of help. He was working as a teacher now and was looking for different ways to introduce various programming subjects. Since we had worked on projects using lex and yacc before, we want to see if there were any days in the recent Advent of Code were lex and/or yacc might be useful.

After looking at the days I actually managed to complete, I decided to use Day 1 and Day 15 as examples. 

## Intro

After completed [Day 1](https://adventofcode.com/2023/day/1) in TCL already, it was actually simplier using lex. 

### Part 1 

The puzzle data consists of a next on a line we need to find the numbers and then use the first and last number to get a two digit calibration number.

Given example data of

```
<<testdata1>>=
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
@
```

We should get:

* 12    = 12
* 28    = 38
* 12345 = 15
* 7     = 77

Since using lex means we'll be writing in C, we'll need some help holding the strings of number we find on each line. We'll create a buffer `buf` to hold the numbers as we find them in the line. The buffer will have a maximun size `MAX_BUFF_SIZE`. Then we'll need some way to `append` a char to the buffer, check for `buffer_overflow`, and `init` the buffer, whic here will be setting the entirre buffer to null.


``` c
<<stringHelpers>>=
#define MAX_BUFF_SIZE 10
char buf[MAX_BUFF_SIZE]; /* buffer to store the numbers, size controlled by constant*/

/* check for buffer overflow */
void buffer_overflow()
{
  if (strlen(buf) >= MAX_BUFF_SIZE) { 
    fprintf(stderr,"Error: buffer overflow\n");
    exit(1);
  }
}

/* add a char to the buffer */
void append(char *in)
{
  buffer_overflow();
  buf[strlen(buf)] = *in;
}

/* all parts of the buffer to 0 */
void init() { memset(buf, 0, sizeof(buf)); }
@@@
```

Now, we'll need some lex parsing to check for an interger [0-9]. If we encounter a lower case charactor, we continue. If we see a space or tab, we continune. When we see a newline, we process the current line, which means we'll get the first and last number and increase the total as needed.

If we encounter anything else, we'll print an error, but continue. 

``` flex
<<lexSyntax>>=
[0-9]   { append(yytext); }
[a-z]   ;
[ \t]   ; /* skip whitespaces */
\n      { total += process(); }
.       { printf("bad value, %s", yytext); }
@
```

We'll need the process function. It should get the first and last number from the buffer. The first number should be mulipled by 10 and the second number should be unmodified, with that number (between 99 and 11) being returned from the functin.

``` c
<<process>>=
int process() {
  int num = (buf[0]-'0') * 10;
  num += buf[strlen(buf)-1]-'0';
  init();
  return num;
}
@
```

Now, we'll need a bit of code to tie things together and make a working programing. First, we need to tell lex what do with at the end of the file, For our use case, we'll just return `1` that tell it to end. 

We'll also need a main program. While lex will provide a basic `main`, we need to check if the buffer is empty, if not we need to process it. This could happen if a line does not end in a new line. We'll then need to output the total.

``` c
<<lexUserCode>>=
int yywrap(void){
  return 1;
}

int main()
{
  init();
  yylex();
  if(strlen(buf) > 0) { total += process(); }
  printf("# %d\n", total);
}
@
```

That will do it. Using the standard lex format of

```
%{ 

Definition Section. 

Variables, functions, etc. That will be needed.

%}

%%

Rules

%%

User Code

``` lex
<<part1.l>>=
%{
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>

<<stringHelpers>>

<<process>>

int total = 0; /* total of all calibration inputs */

%}

%%

<<lexSyntax>>

%%

<<lexUserCode>>
@
```

A quick check against the test data and my data gives:

``` shell
$ make view-example1 view-data1
# 142
# 54388
```

# Part 2

Part 2 adds a wrinkle, that the number could be given in text. Hence, 'two' = 2, 'one` = 1, etc. So, it would seem that we can just change the `lexSyntax` like so.

``` lex
[0-9]        { append(yytext); }

"zero"       { append("0"); }
"one"        { append("1"); }
"two"        { append("2"); }
"three"      { append("3"); }
"four"       { append("4"); }
"five"       { append("5"); }
"six"        { append("6"); }
"seven"      { append("7"); }
"eight"      { append("8"); }
"nine"       { append("9"); }

[a-z]   ;
[ \t]   ; /* skip whitespaces */
\n      { total += process(); }
.       { printf("bad value, %s", yytext); }
`
```

First notice that the search for the full text of the names is ABOVE the search for lower case letters. Lex syntax is check top to bottom, so if we check for single lower case letters FIRST, we would never get to the word check. 

```
<<testdata2>>=
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
@
```

Another problem is that we can miss things like `twoone`, which should report a `2` and a `1`, but the lex parse will not pick that up, it will see 'two', then 'ne'. So, we can either write a custom version of the lex parser `yylex`, or we can just check for the various of the double works. There are not many "one-offs", so we'll just add them BEFORE the single work checks.


``` lex
<<lexSyntaxPart2>>=
[0-9]        { append(yytext); }

"zerone"     { append("0"); append("1"); }
"oneight"    { append("1"); append("8"); }
"twone"      { append("2"); append("1"); }
"eightwo"    { append("8"); append("2"); }
"eighthree"  { append("8"); append("3"); }

"zero"       { append("0"); }
"one"        { append("1"); }
"two"        { append("2"); }
"three"      { append("3"); }
"four"       { append("4"); }
"five"       { append("5"); }
"six"        { append("6"); }
"seven"      { append("7"); }
"eight"      { append("8"); }
"nine"       { append("9"); }

[a-z]   ;
[ \t]   ; /* skip whitespaces */
\n      { total += process(); }
.       { printf("bad value, %s", yytext); }
@
```



Once again, the double words are added about the single works to make sure the are found first. There are not additional changes that need to be made. 

```
<<part2.l>>=
%{
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>

<<stringHelpers>>

<<process>>

int total = 0; /* total of all calibration inputs */

%}

%%

<<lexSyntaxPart2>>

%%

<<lexUserCode>>
@
```

Checking the data, gives the same answers as the TCL solution.

```
$ make part2 testdata2
$ ./part2 < testdata2
# 281
$ ../part2.tcl testdata2 
# 281
$ make view-example2 view-data2
# 281
# 53515
$ ../part2 < ../../data/day_1/part2.data
# 53515
```

Comparing the two:

```
$ wc -l ../*.tcl *.l
  144 ../part1.tcl
  174 ../part2.tcl
   59 part1.l
   77 part2.l
  454 total
```

