#include <stdio.h>

int main() {
    
    printf("%s\n", "Enter a num: ");

    int myNum;
    scanf("%u", &myNum);
    
    char *message = "myNum is: ";
    printf("%s%u\n", message, myNum);
    return 0;
}