2001

#AnA Language

<!--- tags: cpp parsing -->

AnA is a simple interpreted language with syntax similar to C, implemented for teaching purposes within a week in portable ANSI C, using Flex and Bison. The interpreter is based on a kernel language approach and does not do any optimizations.

##Introduction

While AnA is a simple language conforming to LARL(1) parsing, it contains:

* Simple strongly typed type system with lazy scope checking, postponed at run-time; automatic scalar coercion.
* Complete name scope rules, each block gets its own stack frame.
* Full support for functions, including recursive and mutual-recursive functions.
* Multi-dimensions arrays, passed by reference, implemented in the row-major order, initialized to zero.
* Some debugging support (memory, instructions tree, variable dump).

Several things are missing, or are not implemented:

* Single namespace for functions.
* Limited type system.
* No possibility to create / include modules.
* No optimizations.
* Limited OS interaction support.

![](r/cpp-ana-language/ana.gif)

##Examples

Several examples to give a feeling how AnA looks like. More examples are provided as part of the source.

###Example 1: Quicksort in AnA

An implementation of quick sort algorithm in AnA, and its usage to sort an integer array.

```c
program Quicksort {

 function void quicksort;
 function int partition;
 function void swap;

 void sort(int a[]) {
  quicksort(a, 0, len(a) - 1);
 }

 void quicksort(int a[], int low, int high) {
  int pivot;
  if(high > low) {
   pivot = partition(a, low, high);
   quicksort(a, low, pivot - 1);
   quicksort(a, pivot + 1, high);
  }
   }

 int partition(int a[], int low, int high) {

  int left, right;
  int pivot_item;

  pivot_item = a[low];

  left = low;
  right = high;

  while (left < right) {
   while(a[left] <= pivot_item) {
    left = left + 1;
    if(left >= high) break;
   }
   while( a[right] > pivot_item) {
    right = right - 1;
    if(right <= left) break;
   }
   if(left < right) swap(a, left, right);
  }
  a[low] = a[right];
  a[right] = pivot_item;
  return right;
 }

 void swap(int a[], int left, int right) {
  int t = a[left];
  a[left] = a[right];
  a[right] = t;
 }

 void main() {
  int array[10] = { 9, 1, 4, 5, 2, 8, 3, 6, 7, 3};
  print(array);
  sort(array);
  print(array);
 }
}
```

###Example 2: Memory allocation using arrays

Arrays in AnA are allocated in the heap and passed by reference only. This means that arrays in AnA can have dimensions calculated dynamically at run-time. Because every block in AnA gets its own stack frame, arrays can be used for heap memory allocation.

```c
program DynamicMemory {

 void dynMem(int dim) {
  int i, temp;
  int A[dim];
  for(i = 0; | i < dim | i = i + 1;) {
   print("\nSpecify element: ");
   print(i);
   read(temp);
   A[i] = temp;
  }
  for(i = 0; | i < size(A, 0) | i = i + 1;) {
   print(A[i]);
   if(i != (size(A, 0) - 1)) print(", ");
  }
 }

 void main() {
  int dim;
  print("Enter the number of elements: ");
  read(dim);
  if(dim <= 0){
   print("\nNumber of elements must be possitive!");
   exit();
  }
  dynMem(dim);

  // another alternative
  // this is a trick to create a new block
  // to dynamically allocate memory
  if(1) {
   int A[dim];
   print("\nInside the block");
   nl();
   print(size(A, 0));
   // A is destroyed here
  }
 }
}
```

###Example 3: Factorial

This example shown n! implementation in AnA and the internal representation of the same code inside the interpreter (obtained with the -df option).

**N! Source Code**

```c
program Factorial {
 int fact(int n) {
  if(n < 1) return 1;
  return n * fact(n - 1);
 }
 void main() {
  print("fact(5) = ");
  print(fact(5));
 }
}
```

**Internal Representation**

```
START FUNCTION nops=6
% FUNC fact 0x321040 int
% ENTER BLOCK none
% DEFINE VAR nops=1 none
% . ID fact 0x321040 int
% DEFINE VAR nops=1 none
% . ID n 0x3210a0 int
% ; nops=1 none
% . SET nops=2 none
% . . ID n 0x3210a0 void
% . . constant 0 none
% ; nops=2 none
% . IF nops=2 none
% . . < nops=2 int
% . . . ID n 0x3210a0 void
% . . . constant 1 int
% . . RETURN nops=1 none
% . . . = nops=2 none
% . . . . ID fact 0x321040 void
% . . . . constant 1 int
% . RETURN nops=1 none
% . . = nops=2 none
% . . . ID fact 0x321040 void
% . . . * nops=2 int
% . . . . ID n 0x3210a0 void
% . . . . CALL nops=2 int
% . . . . . FUNC fact 0x321040 int
% . . . . . - nops=2 int
% . . . . . . ID n 0x3210a0 void
% . . . . . . constant 1 int
% EXIT BLOCK none
END FUNCTION
```