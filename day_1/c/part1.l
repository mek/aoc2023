%{
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>

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

int process() {
  int num = (buf[0]-'0') * 10;
  num += buf[strlen(buf)-1]-'0';
  init();
  return num;
}

int total = 0; /* total of all calibration inputs */

%}

%%

[0-9]   { append(yytext); }
[a-z]   ;
[ \t]   ; /* skip whitespaces */
\n      { total += process(); }
.       { printf("bad value, %s", yytext); }

%%

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
