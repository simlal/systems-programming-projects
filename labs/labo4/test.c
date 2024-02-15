#include <stdio.h>

int main()
{
    long n;
    long *nP = &n;
    scanf("%ld", nP);
    n = *nP;
    printf("%ld", n);
}


