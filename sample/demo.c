/*
 * Sample bubble sort algorithm for OCAML-C-Profiler Demo
 *
 * Use 'make all' from root to compile this application
 */

#include <stdio.h>
#include <stdlib.h>
#include "libsort.h"

#define MAX_NUMS 100000
int data[MAX_NUMS];

/***********************************************************
 *  Recursive Call Demo
 ***********************************************************/
int factorial (int n)
{
	if (n == 0) {
		return 1;
	}

	return (n * factorial(n-1));
}

/************************************************************
 * Nested function Demo
 * **********************************************************/
int functionD (void)
{
	printf ("%s\n", __FUNCTION__);
}

int functionC (void)
{
	printf ("%s\n", __FUNCTION__);
	functionD();
}

int functionB (void)
{
	printf ("%s\n", __FUNCTION__);
	functionC();
	functionD();
}

int functionA (void)
{
	printf ("%s\n", __FUNCTION__);
	functionB();
	functionC();
	functionD();
}





/***********************************************************
 * Sorting demo
 ***********************************************************/

void ordered_data(void)
{
	int i;

	for (i = 0; i < MAX_NUMS; i++) {
		data[i] = i;
	}
}

void reversed_data(void)
{
	int i;

	for (i = 0; i < MAX_NUMS; i++) {
		data[i] = 1000000 - i;
	}
}

void random_data(void)
{
	int i;

	for (i = 0; i < MAX_NUMS; i++) {
		data[i] = rand();
	}
}

void print_data(const char *str)
{
	int i;

	printf("\n%s Data : [", str);
	for (i = 0; i < 20; i++) {
		printf("%d,", data[i]);
	}
	printf(" ...]\n\n");
}

void BubbleSort (void)
{
	bubble_sort(data, MAX_NUMS);
}

void QuickSort (void)
{
	quick_sort(data, 0, MAX_NUMS);
}

void HeapSort (void)
{
	heap_sort(data, MAX_NUMS);
}


int main(void)
{
	int i = 0;

	printf("\nRunning Bubble Sort\n");

	for (i = 0; i < 3; i++) {
		random_data();
		print_data("Unsorted ");
		BubbleSort();
		print_data("Bubble sorted ");
	}

	printf("\nRunning Quick Sort\n");

	for (i = 0; i < 3; i++) {
		random_data();
		print_data("Unsorted ");
		QuickSort();
		print_data("Quick sorted ");
	}

	printf("\nRunning Heap Sort\n");

	for (i = 0; i < 3; i++) {
		random_data();
		print_data("Unsorted ");
		HeapSort();
		print_data("Heap sorted ");
	}

	printf("Running Recursive function\n");

	factorial(6);

	printf("Running Nested Function\n");

	functionA();

	functionB();

	functionC();

	functionD();

	printf("\nCompleted!! Verify that 'profile.data' is generated in current directory\n");
	printf("\nTo generate reports run - ./profiler.native -n demo.o -p ./profile.data\n\n");
	return 0;
}
