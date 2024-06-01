%{
#include <string.h>
#include <stdlib.h>
#include "cbu2.h"
#define _CRT_SECURE_NO_WARNINGS
#define MAXSYM	100
#define	MAXSYMLEN	20
char symtbl[MAXSYM][MAXSYMLEN];
int lineno=1;
int insertsym();
int maxsym=0;
char s[MAXSYMLEN];
int temp;

%}
sp		[ \t]
ws		{sp}+
nl		\n
eletter	[A-Za-z]
hletter	[\xb0-\xfe][\xa0-\xfe]
letter	({eletter}|{hletter})
digit	-?[0-9]
id		{letter}({letter}|{digit})*
%%
{ws}	{/* do nothing */}
{nl}	{lineno++; }
"+"	{return(ADD); }
더하기	{return(ADD); }
"-"	{return(SUB); }
빼기		{return(SUB); }
"*"	{return(MUL); }
곱하기	{return(MUL); }
"/"	{return(DIV); }
나누기	{return(DIV); }
"%"	{return(MOD); }
나머지	{return(MOD); }
if	{return(IF); }
만약	{return(IF); }
조건시작	{return(CONDSTART); }
조건끝	{return(CONDEND); }
else	{return(ELSE);	}
아니라면	{return(ELSE);	}
문장시작	{return(STMTLISTSTART); }
문장끝	{return(STMTLISTEND); }
"==" { return(EQUAL); }
같다면 { return(EQUAL); }
"!=" { return(NOTEQUAL); }
같지않다면	{ return(NOTEQUAL); }
">" { return(GREATER); }
크다면 { return(GREATER); }
">=" { return(GREATEREQUAL); }
크거나같다면 { return(GREATEREQUAL); }
"<" { return(LESS); }
작다면 { return(LESS); }
"<=" { return(LESSEQUAL); }
작거나같다면 { return(LESSEQUAL); }
while	{return(WHILE);}
동안	{return(WHILE);}
"++"	{return(ADDUNARY);}
하나더하기	{return(ADDUNARY);}
"--"	{return(SUBUNARY);}
하나빼기	{return(SUBUNARY);}
"+="	{return(ADDASSIGN);}
더하고대입	{return(ADDASSIGN);}
"-="	{return(SUBASSIGN);}
빼고대입	{return(SUBASSIGN);}
"*="	{return(MULASSIGN);}
곱하고대입	{return(MULASSIGN);}
"/="	{return(DIVASSIGN);}
나누고대입	{return(DIVASSIGN);}
:= { return(ASSGN); }
; { return(STMTEND); }
시작 { return(START); }
끝 { return(END); }
{id}	{temp=insertsym(yytext); yylval=MakeNode(ID, temp); return(ID);}
{digit}+		{sscanf(yytext, "%d", &temp); yylval=MakeNode(NUM, temp); return(NUM);}
.		{printf("invalid token %s\n", yytext); }
%%

int insertsym(s)
char *s;
{
int i;

	for(i=0;i<maxsym; i++) {
		if(strcmp(s, symtbl[i])==0) return(i);
		}
	if (i<MAXSYM-1) {
		strcpy(symtbl[maxsym],s);
		maxsym++;
		return(maxsym-1);
		}
	else
		{printf("symbol table overflow\n");}
	return(0);
}

yywrap() {}