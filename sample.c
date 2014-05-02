#include <unistd.h>
#include <sys/types.h>
#include <errno.h>
#include <stdio.h>
#include <sys/wait.h>
#include <stdlib.h>

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
    functionC();
}

void functionR (int i)
{
   printf("%s\n",__FUNCTION__);
   if (i > 0) {
     functionR (--i);
   }
}

int main (void)
{
    int i = 0;
    printf("\n%s\n",__FUNCTION__);
    for (i = 0; i < 10; i++) {
	functionA();
    }

    functionB();
    functionC();
    functionR(3);


    printf("%s\n",__FUNCTION__);
    return 0;
}
