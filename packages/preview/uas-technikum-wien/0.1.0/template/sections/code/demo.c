/*
 ============================================================================
 Name        : io_scanf.c
 Author      : Max Muster
 Version     :
 Copyright   : (cc) by Max
 Description : Hello World in C, Ansi-style
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>

int main(void) {
	int num;
	printf("Please give me a number: ");
	int ret = scanf("%d", &num);
	printf("You gave me %d\n", num);
	printf("scanf returned %d\n", ret);
	return EXIT_SUCCESS;
}
