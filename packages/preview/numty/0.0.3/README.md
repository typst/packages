# Numty
Numeric Typst

Mathematical functions to operate Matrices, vectors/arrays and numbers in typst, with simple broadcasting and Nan handling.

Broadcasting rules are inspired by the numpy ones, as well as the overall API.

```typ
#import "numty.typ" as nt

#let a = (1,2,3)
#let b = 2
#let m = ((1,2),(1,3))

#nt.mult(a,b) // (2,4,6)
#nt.add(a,a)  // (2,4,6)
#nt.add(2,a)  // (3,4,5)
#nt.add(m,1)  // ((2,3),(2,4))
#nt.dot(a,a)  // 11

#calc.sin((3,4)) // fails
#nt.sin((3.4))  // (0.14411, 0.90929)

#let x = nt.linspace(0,10,3)  // (0,5,10)
#let y = nt.sin(x) // (0, -0.95, -0.54)
```

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
