#include <stdio.h>

i(n,b){n?i(n/b,b),putchar(n%b+48+(n%b>9)*39):0;}
 
// j(n,b){n?j(n/b,b),putchar(n%b+48+(n%b>9)*39):0;}I(n,b){n?j(n,b):putchar(48);}
 
I(n,b){putchar(n?i(n/b,b),48+n%b+(n%b>9)*39:48);}
 
main(int argc, char* argv[])
{
	int value = 0;
	if (argc == 2) {
		value = atoi(argv[1]);
		printf("Value: %d\n", value);
		i(value,16);
		return puts("");
	}
}