#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Returns the n-th element of fibonacci sequence

int fibonacci(int n)
{
    if (n < 2)
        return n;
    return fibo(n - 1) + fibo(n - 2);
}

int check_authentication(char *password)
{
    char password_buffer[16];

    strcpy(password_buffer, password);

    if (strcmp(password_buffer, "michael") == 0)
        return 1;
    else if (strcmp(password_buffer, "tsikerdekis") == 0)
        return 1;
    else
        return 0;
}

int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        printf("Usage: %s <password>\n", argv[0]);
        exit(0);
    }
    if (check_authentication(argv[1]))
    {
        printf("\n-=-=-=-=-=-=-=-=-=-=-=-=-=-\n");
        printf(" Access Granted.\n");
        printf("-=-=-=-=-=-=-=-=-=-=-=-=-=-\n");
    }
    else
    {
        printf("\nAccess Denied.\n");
    }
}
