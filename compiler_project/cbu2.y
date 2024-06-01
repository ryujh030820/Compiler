%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define _CRT_SECURE_NO_WARNINGS

#define DEBUG	0

#define	 MAXSYM	100
#define	 MAXSYMLEN	20
#define	 MAXTSYMLEN	15
#define	 MAXTSYMBOL	MAXSYM/2

#define STMTLIST 500

typedef struct nodeType {
	int token;
	int tokenval;
	struct nodeType *son;
	struct nodeType *brother;
	} Node;

#define YYSTYPE Node*
	
int tsymbolcnt=0;
int errorcnt=0;
int label=0;
int out_label=0;
int if_label=0;
int loop_label=0;

FILE *yyin;
FILE *fp;

extern char symtbl[MAXSYM][MAXSYMLEN];
extern int maxsym;
extern int lineno;

void DFSTree(Node*);
Node * MakeOPTree(int, Node*, Node*);
Node * MakeNode(int, int);
Node * MakeListTree(Node*, Node*);
void codegen(Node* );
Node * CopyTree(Node * root);
void prtcode(int, int);

void	dwgen();
int	gentemp();
void	assgnstmt(int, int);
void	numassgn(int, int);
void	addstmt(int, int, int);
void	substmt(int, int, int);
int		insertsym(char *);
%}

%token	ADD SUB MUL DIV MOD ASSGN ID NUM STMTEND START END ID2 ID3
%token	NONE IFSTATEMENT IF IFELSE CONDSTART CONDEND ELSE STMTLISTSTART STMTLISTEND WHILE
%token	LOOPSTART EQUAL NOTEQUAL GREATER GREATEREQUAL LESS LESSEQUAL
%token	ADDUNARY SUBUNARY ADDASSIGN SUBASSIGN MULASSIGN DIVASSIGN



%%
program	: START stmt_list END	{ if (errorcnt==0) {codegen($2); dwgen();} }
		;

stmt_list: 	stmt_list stmt 	{$$=MakeListTree($1, $2);}
		|	stmt			{$$=MakeListTree(NULL, $1);}
		| 	error STMTEND	{ errorcnt++; yyerrok;}
		;

stmt	:	assign_stmt
		|	if_else_stmt	{ $$=MakeOPTree(IFSTATEMENT, $1, NULL); }
		|	while_stmt
		|	unary_stmt
		;

assign_stmt	: 	ID ASSGN expr STMTEND	{ $1->token = ID2; $$=MakeOPTree(ASSGN, $1, $3);}
			|	ID ADDASSIGN expr STMTEND	{ $1->token = ID3; $$=MakeOPTree(ADDASSIGN, $1, $3);}
			|	ID SUBASSIGN expr STMTEND	{ $1->token = ID3; $$=MakeOPTree(SUBASSIGN, $1, $3);}
			|	ID MULASSIGN expr STMTEND	{ $1->token = ID3; $$=MakeOPTree(MULASSIGN, $1, $3);}
			|	ID DIVASSIGN expr STMTEND	{ $1->token = ID3; $$=MakeOPTree(DIVASSIGN, $1, $3);}
		;

unary_stmt	:	ID ADDUNARY STMTEND	{ $1->token = ID3; $$=MakeOPTree(ADDUNARY, $1, NULL);}
			|	ID SUBUNARY STMTEND	{ $1->token = ID3; $$=MakeOPTree(SUBUNARY, $1, NULL);}
			;

cond_expr	:	cond_expr EQUAL expr { $$=MakeOPTree(EQUAL, $1, $3); }
			|	cond_expr NOTEQUAL expr { $$=MakeOPTree(NOTEQUAL, $1, $3); }
			|	cond_expr GREATER expr { $$=MakeOPTree(GREATER, $1, $3); }
			|	cond_expr GREATEREQUAL expr { $$=MakeOPTree(GREATEREQUAL, $1, $3); }
			|	cond_expr LESS expr { $$=MakeOPTree(LESS, $1, $3); }
			|	cond_expr LESSEQUAL expr { $$=MakeOPTree(LESSEQUAL, $1, $3); }
			|	expr
			;

if_else_stmt	:	if_else_stmt else_stmt { $$=MakeOPTree(NONE, $1, $2); }
			|	if_stmt { $$=MakeOPTree(NONE, $1, NULL); }
			;

else_stmt	:	ELSE STMTLISTSTART stmt_list STMTLISTEND { $$=MakeOPTree(ELSE, $3, NULL); }
		;

if_stmt	:	IF if_expr { $$=MakeOPTree(IF, $2, NULL); }
		;

if_expr	:	CONDSTART cond_expr CONDEND STMTLISTSTART stmt_list STMTLISTEND { $$=MakeListTree($2, $5); }
		;

expr	: 	expr ADD term	{ $$=MakeOPTree(ADD, $1, $3); }
		|	expr SUB term	{ $$=MakeOPTree(SUB, $1, $3); }
		|	expr MUL term	{ $$=MakeOPTree(MUL, $1, $3); }
		|	expr DIV term	{ $$=MakeOPTree(DIV, $1, $3); }
		|	expr MOD term	{ $$=MakeOPTree(SUB, $1, MakeOPTree(MUL, $3, MakeOPTree(DIV, CopyTree($1), CopyTree($3)))); }
		|	term
		;

while_stmt	:	loop_start if_expr { $$=MakeOPTree(WHILE, $1, $2); }
			;

loop_start	:	WHILE { $$=MakeNode(LOOPSTART, NULL); }
			;

term	:	ID		{ /* ID node is created in lex */ }
		|	NUM		{ /* NUM node is created in lex */ }
		;


%%

int main(int argc, char *argv[]) 
{
	printf("\nsample CBU compiler v2.0\n");
	printf("(C) Copyright by Jae Sung Lee (jasonlee@cbnu.ac.kr), 2022.\n");
	
	if (argc == 2)
		yyin = fopen(argv[1], "r");
	else {
		printf("Usage: cbu2 inputfile\noutput file is 'a.asm'\n");
		return(0);
		}
		
	fp=fopen("a.asm", "w");
	
	yyparse();
	
	fclose(yyin);
	fclose(fp);

	if (errorcnt==0) 
		{ printf("Successfully compiled. Assembly code is in 'a.asm'.\n");}
}

yyerror(s)
char *s;
{
	printf("%s (line %d)\n", s, lineno);
}


Node * MakeOPTree(int op, Node* operand1, Node* operand2)
{
    Node * newnode;

    newnode = (Node *)malloc(sizeof (Node));
    newnode->token = op;
    newnode->tokenval = op;
    newnode->son = operand1;
    newnode->brother = NULL;
    operand1->brother = operand2;
    return newnode;
}

Node * MakeNode(int token, int operand)
{
Node * newnode;

	newnode = (Node *) malloc(sizeof (Node));
	newnode->token = token;
	newnode->tokenval = operand; 
	newnode->son = newnode->brother = NULL;
	return newnode;
}

Node * MakeListTree(Node* operand1, Node* operand2)
{
Node * newnode;
Node * node;

	if (operand1 == NULL){
		newnode = (Node *)malloc(sizeof (Node));
		newnode->token = newnode-> tokenval = STMTLIST;
		newnode->son = operand2;
		newnode->brother = NULL;
		return newnode;
		}
	else {
		node = operand1->son;
		while (node->brother != NULL) node = node->brother;
		node->brother = operand2;
		return operand1;
		}
}

void codegen(Node * root)
{
	DFSTree(root);
}

void DFSTree(Node * n)
{
	if (n==NULL) return;
	DFSTree(n->son);
	prtcode(n->token, n->tokenval);
	DFSTree(n->brother);
	
}

Node * CopyTree(Node * root)
{
    if (root == NULL) {
        return NULL;
    }
    
    Node * newnode = (Node *)malloc(sizeof(Node));
    newnode->token = root->token;
    newnode->tokenval = root->tokenval;
    
    newnode->son = CopyTree(root->son);
    newnode->brother = CopyTree(root->brother);
    
    return newnode;
}

void prtcode(int token, int val)
{
	switch (token) {
	case ID:
		fprintf(fp,"RVALUE %s\n", symtbl[val]);
		break;
	case ID2:
		fprintf(fp, "LVALUE %s\n", symtbl[val]);
		break;
	case ID3:
		fprintf(fp, "LVALUE %s\n", symtbl[val]);
		fprintf(fp, "RVALUE %s\n", symtbl[val]);
		break;
	case NUM:
		fprintf(fp, "PUSH %d\n", val);
		break;
	case ADD:
		fprintf(fp, "+\n");
		break;
	case SUB:
		fprintf(fp, "-\n");
		break;
	case MUL:
		fprintf(fp, "*\n");
		break;
	case DIV:
		fprintf(fp, "/\n");
		break;
	case ASSGN:
		fprintf(fp, ":=\n");
		break;
	case EQUAL:
		fprintf(fp, "-\n");
		fprintf(fp, "GOTRUE label%d\n", label);
		break;
	case NOTEQUAL:
		fprintf(fp, "-\n");
		fprintf(fp, "GOFALSE label%d\n", label);
		break;
	case GREATER:
		fprintf(fp, "-\n");
		fprintf(fp, "GOPLUS outlabel%d\n", out_label);
		fprintf(fp, "GOTO label%d\n", label);
		fprintf(fp, "LABEL outlabel%d\n", out_label++);
		break;
	case GREATEREQUAL:
		fprintf(fp, "-\n");
		fprintf(fp, "GOMINUS label%d\n", label);
		break;
	case LESS:
		fprintf(fp, "-\n");
		fprintf(fp, "GOMINUS outlabel%d\n", out_label);
		fprintf(fp, "GOTO label%d\n", label);
		fprintf(fp, "LABEL outlabel%d\n", out_label++);
		break;
	case LESSEQUAL:
		fprintf(fp, "-\n");
		fprintf(fp, "GOPLUS label%d\n", label);
		break;
	case IFSTATEMENT:
		fprintf(fp, "LABEL IFlabel%d\n", if_label++);
		break;
	case IF:
		fprintf(fp, "GOTO IFlabel%d\n", if_label);
		fprintf(fp, "LABEL label%d\n", label++);
		break;
	case ELSE:
		fprintf(fp, "LABEL label%d\n", label++);
		break;
	case LOOPSTART:
		fprintf(fp, "LABEL looplabel%d\n", loop_label);
		break;
	case WHILE:
		fprintf(fp, "GOTO looplabel%d\n", loop_label);
		loop_label++;
		fprintf(fp, "LABEL label%d\n", label++);
		break;
	case ADDASSIGN:
		fprintf(fp, "+\n");
		fprintf(fp, ":=\n");
		break;
	case SUBASSIGN:
		fprintf(fp, "-\n");
		fprintf(fp, ":=\n");
		break;
	case MULASSIGN:
		fprintf(fp, "*\n");
		fprintf(fp, ":=\n");
		break;
	case DIVASSIGN:
		fprintf(fp, "/\n");
		fprintf(fp, ":=\n");
		break;
	case ADDUNARY:
		fprintf(fp, "PUSH %d\n", 1);
		fprintf(fp, "+\n");
		fprintf(fp, ":=\n");
	case SUBUNARY:
		fprintf(fp, "PUSH %d\n", 1);
		fprintf(fp, "-\n");
		fprintf(fp, ":=\n");
	case STMTLIST:
	case NONE:
	default:
		break;
	};
}


/*
int gentemp()
{
char buffer[MAXTSYMLEN];
char tempsym[MAXSYMLEN]="TTCBU";

	tsymbolcnt++;
	if (tsymbolcnt > MAXTSYMBOL) printf("temp symbol overflow\n");
	itoa(tsymbolcnt, buffer, 10);
	strcat(tempsym, buffer);
	return( insertsym(tempsym) ); // Warning: duplicated symbol is not checked for lazy implementation
}
*/
void dwgen()
{
int i;
	fprintf(fp, "HALT\n");
	fprintf(fp, "$ -- END OF EXECUTION CODE AND START OF VAR DEFINITIONS --\n");

// Warning: this code should be different if variable declaration is supported in the language 
	for(i=0; i<maxsym; i++) 
		fprintf(fp, "DW %s\n", symtbl[i]);
	fprintf(fp, "END\n");
}
