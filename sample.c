#include <stdio.h>

void functionC (void)
{
    printf("%s\n",__FUNCTION__);
}

void functionB (void)
{
    printf("%s\n",__FUNCTION__);
    functionC();
}

void functionA (void)
{
    printf("%s\n",__FUNCTION__);
    functionB();
}

int main (void)
{
    printf("\n%s\n",__FUNCTION__);
    functionA();
    functionB();
    functionC();
    printf("%s\n",__FUNCTION__);
    return 0;
}
