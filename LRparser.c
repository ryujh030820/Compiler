#include <stdio.h>
#include <string.h>

#define MAX 100
int action_tbl[12][6] = {
    {5, 0, 0, 4, 0, 0},
    {0, 6, 0, 0, 0, 999},
    {0, -2, 7, 0, -2, -2},
    {0, -4, -4, 0, -4, -4},
    {5, 0, 0, 4, 0, 0},
    {0, -6, -6, 0, -6, -6},
    {5, 0, 0, 4, 0, 0},
    {5, 0, 0, 4, 0, 0},
    {0, 6, 0, 0, 11, 0},
    {0, -1, 7, 0, -1, -1},
    {0, -3, -3, 0, -3, -3},
    {0, -5, -5, 0, -5, -5}};
int goto_tbl[12][4] = {
    {0, 1, 2, 3},
    {0, 0, 0, 0},
    {0, 0, 0, 0},
    {0, 0, 0, 0},
    {0, 8, 2, 3},
    {0, 0, 0, 0},
    {0, 0, 9, 3},
    {0, 0, 0, 10},
    {0, 0, 0, 0},
    {0, 0, 0, 0},   
    {0, 0, 0, 0},
    {0, 0, 0, 0}};
char lhs[] = {' ', 'E', 'E', 'T', 'T', 'F', 'F'}; // dummy in 0 index
int rhs_len[] = {0, 3, 1, 3, 1, 3, 1};            // rhs length: 0 for dummy rule
char token[] = {'d', '+', '*', '(', ')', '$'};
char NT[] = {' ', 'E', 'T', 'F'}; // non-terminals: dummy in 0 index
int stack[MAX], sp;

void push(int n) {
    stack[sp] = n;

    sp++;
}

int top() {
    return stack[sp - 1];
}

void pop() {
    sp--;
}

int get_token_idx(char current_token) {
    for(int i = 0; i < 6; i++) {
        if(current_token == token[i]) {
            return i;
        }
    }

    return -1;
}

void LR_Parser(char input[]) {
    int line_num = 2, idx = 0; // 현재 줄 번호와 input의 index

    push(0);

    printf("(1) initial :\t");

    for(int i = 0; i < sp; i++) {
        if(stack[i] >= 0 && stack[i] <= 11) { // stack[i]가 숫자인 경우
            printf("%d", stack[i]);
        } else {
            printf("%c", stack[i]);
        }
    }

    printf("\t");

    for(int i = idx; i < strlen(input); i++) {
        printf("%c", input[i]);
    }

    printf("\n");

    while(1) {
        int current_state = top();
        char current_token = input[idx];
        int token_idx = get_token_idx(current_token);

        if(token_idx == -1) {
            printf("(%d) invalid token (-) error\n", line_num);
            return;
        }

        int next_action = action_tbl[current_state][token_idx];

        if(next_action == 999) { // accept인 경우
            printf("(%d) accept\n", line_num);
            return;
        } else if(next_action > 0) { // shift인 경우
            push((int) current_token);
            push(next_action);
            idx++;

            printf("(%d) shift  %d:\t", line_num, next_action);

            for(int i = 0; i < sp; i++) {
                if(stack[i] >= 0 && stack[i] <= 11) { // stack[i]가 숫자인 경우
                    printf("%d", stack[i]);
                } else {
                    printf("%c", stack[i]);
                }
            }

            printf("\t");

            for(int i = idx; i < strlen(input); i++) {
                printf("%c", input[i]);
            }

            printf("\n");
        } else if(next_action < 0) { // reduce인 경우
            for(int i = 0; i < 2 * rhs_len[-next_action]; i++) {
                pop();
            }

            char reduce_token = lhs[-next_action];
            int reduce_action = top();

            push(lhs[-next_action]);

            if(reduce_token == 'E') {
                push(goto_tbl[reduce_action][1]);
            } else if(reduce_token == 'T') {
                push(goto_tbl[reduce_action][2]);
            } else if(reduce_token == 'F') {
                push(goto_tbl[reduce_action][3]);
            }

            printf("(%d) reduce %d:\t", line_num, -next_action);

            for(int i = 0; i < sp; i++) {
                if(stack[i] >= 0 && stack[i] <= 11) { // stack[i]가 숫자인 경우
                    printf("%d", stack[i]);
                } else {
                    printf("%c", stack[i]);
                }
            }

            printf("\t");

            for(int i = idx; i < strlen(input); i++) {
                printf("%c", input[i]);
            }

            printf("\n");
        } else { // error인 경우
            printf("(%d) error\n", line_num);
            return;
        }

        line_num++;
    }
}

int main(void)
{
    char input[MAX];
    while (1)
    {
        printf("\nInput: ");
        scanf("%s", input);
        if (input[0] == '$')
            break;

        LR_Parser(input);
    }
    
    return 0;
}
