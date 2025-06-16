# numty
Numeric Typst

Mathematical functions to operate vectors / arrays and numbers in typst, with simple broadcasting. 

```typ
#import "numty.typ" as nt

#let a = (1,2,3)
#let b = 2

#nt.mult(a,b)  => (2,4,6)
#nt.add(a,a)  => (2,4,6)
#nt.add(2,a)  => (3,4,5)
#nt.dot(a,a)  => 11

#calc.sin((3,4)) -> fails
#nt.sin((3.4)) -> (0.14411, 0.90929)
```

Supported functions

vpow -> exponentation

vmult -> multiplication

vdiv -> division

vsum -> sumation

vnorm -> normalization of a vector

vdot -> dot product
