/*
 * Sample sort algorithms for OCAML-C-Profiler Demo
 */

#include <stdio.h>
#include <stdlib.h>

/*
 * Quick Sort
 */
static int
partition(int a[], int l, int r)
{
	int pivot, i, j, t;
	pivot = a[l];
	i = l;
	j = r + 1;

	while (1) {
		do
			++i;
		while (a[i] <= pivot && i <= r);
		do
			--j;
		while (a[j] > pivot);
		if (i >= j)
			break;
		t = a[i];
		a[i] = a[j];
		a[j] = t;
	}
	t = a[l];
	a[l] = a[j];
	a[j] = t;
	return j;
}

void quick_sort(int a[], int l, int r)
{
	int j;

	if (l < r) {
		j = partition(a, l, r);
		quick_sort(a, l, j - 1);
		quick_sort(a, j + 1, r);
	}
}

/*
 * Heap Sort
 */

static
void shift_down(int data[], int first, int last)
{
  int temp, other, max;

  max = first * 2 + 1;
  if(max < last) {
    other = max + 1;
    max = (data[other] > data[max]) ? other:max;
  } else {
    if(max > last) return;
  }

  if(data[first] >= data[max]) return;

  temp = data[first];
  data[first] = data[max];
  data[max] = temp;

  shift_down(data, max, last);
}

void heap_sort(int data[], int n)
{
  int i, temp;

  for (i = (n / 2); i >= 0; i--) {
	  shift_down(data, i, n - 1);
  }

  for (i = n; i >= 1; i--) {
    temp = data[0];
    data[0] = data[i];
    data[i] = temp;

    shift_down(data, 0, i-1);
  }
}

/*
 * Bubble sort
 */
void bubble_sort(int data[], int n)
{
	int i, j, swap;

	for (i = 0; i < ( n - 1); i++) {
		for (j = 0; j < n - i - 1; j++) {
			if (data[j] > data[j + 1]) {
				swap = data[j];
				data[j] = data[j + 1];
				data[j + 1] = swap;
			}
		}
	}
}


