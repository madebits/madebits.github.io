1996

#Iterative Methods for Polynomials with Complex Coefficients

<!--- tags: cpp -->

Complete implementation in C of two iterative methods (Newton and Secant) for finding the roots of polynomials with complex number coefficients.

The following C files are provided:

* cplx.h, cplx.c - a complex number library.
* nsh.h, nsh.c - the library with two iterative methods (Newton, Secant) and Horner method for evaluating polynomials.
* nsh-d.c - test program for the methods.

A test program for the methods is also provided. The output of the test program is given below.

```
I:\cc\projects\cplx>nsh

You are using this polynomial for testing:
(2.000000+0.000000j)x^2 + (0.000000+0.000000j)x^1
    + (-8.000000+0.000000j)x^0 = 0

This is a polynomial of order: 2

newt root=(-2.000000+0.000000j)
iterations=6

sec root=(-2.000000-0.000000j)
iterations=9

horner calculation:
f((5.0,0.0)) = (42.000000+0.000000j)
f'((5.0,0.0)) = (20.000000+0.000000j)
I:\cc\projects\cplx>
```

