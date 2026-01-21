## Numty

### Numeric Typst

A library for performing mathematical operations on n-dimensional matrices, vectors/arrays, and numbers in Typst, with support for broadcasting and handling NaN values. Numty’s broadcasting rules and API are inspired by NumPy.

```typ
#import "numty.typ" as nt

// Define vectors and matrices
#let a = (1, 2, 3)
#let b = 2
#let m = ((1, 2), (1, 3))

// Element-wise operations with broadcasting
#nt.mult(a, b)  // Multiply vector 'a' by scalar 'b': (2, 4, 6)
#nt.add(a, a)   // Add two vectors: (2, 4, 6)
#nt.add(2, a)   // Add scalar '2' to each element of vector 'a': (3, 4, 5)
#nt.add(m, 1)   // Add scalar '1' to each element of matrix 'm': ((2, 3), (2, 4))

// Dot product of vectors
#nt.dot(a, a)   // Dot product of vector 'a' with itself: 14

// Handling NaN cases in mathematical functions
#calc.sin((3, 4)) // Fails, as Typst does not support vector operations directly
#nt.sin((3.4))    // Sine of each element in vector: (0.14411, 0.90929)

// Generate equally spaced values and vectorized functions
#let x = nt.linspace(0, 10, 3)  // Generate 3 equally spaced values between 0 and 10: (0, 5, 10)
#let y = nt.sin(x)              // Apply sine function to each element: (0, -0.95, -0.54)

// Logical operations
#nt.eq(a, b)      // Compare each element in 'a' to 'b': (false, true, false)
#nt.any(nt.eq(a, b)) // Check if any element in 'a' equals 'b': true
#nt.all(nt.eq(a, b)) // Check if all elements in 'a' equal 'b': false

// Handling special cases like division by zero
#nt.div((1, 3), (2, 0))  // Element-wise division, with NaN for division by zero: (0.5, float.nan)

// Matrix operations (element-wise)
#nt.add(m, 1)  // Add scalar to matrix elements: ((2, 3), (2, 4))

// matrix
#nt.transpose(m)  // transposition
#nt.matmul(m,m) //  matrix multipliation

```

Since vesion 0.0.4 n-dim matrices are supported as well in most operations.

## Supported Features:

### Logic Operations:
```typ
#import "numty.typ" as nt

#let a = (1,2,3)
#let b = 2

#nt.eq(a,b)  // (false, true, false)
#nt.all(nt.eq(a,b))  // false
#nt.any(nt.eq(a,b))  // true
```

### Math operators:

All operators are element-wise, 
traditional matrix multiplication is not yet supported.

```typ
#nt.add((0,1,3), 1)  // (1,2,4)
#nt.mult((1,3),(2,2)) // (2,6)
#nt.div((1,3), (2,0)) // (0.5,float.nan)
```

### Algebra with Nan handling:

```typ
#nt.log((0,1,3)) //  (float.nan, 0 , 0.47...)
#nt.sin((1,3)) //  (0.84.. , 0.14...)
```

### Vector operations:

Basic vector operations

```typ
#nt.dot((1,2),(2,4))  //  9
#nt.normalize((1,4), l:1) // (1/5,4/5)
```

### Others:

Functions for creating equally spaced indexes in linear and logspace, usefull for log plots

```typ
#nt.linspace(0,10,3) // (0,5,10)
#nt.logspace(1,3,3)
#nt.geomspace(1,3,3) 
```

### Printing

```typ
#nt.print((1,2),(4,2)))  // to display in the pdf
```
