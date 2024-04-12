#import "lib.typ" : apply
#show: apply()
#set align(center)

= Example Typst Document
#set heading(numbering: "1.")
= Text and headings
#lorem(30)

== H2
#lorem(20)

=== H3
#lorem(15)

= Links and other references <links>
== Links
#link("https://typst.app")[
    Typst
]
#link("https://typst.app")

== References
@links

== Footnotes
Some text#footnote[footnote test]

= Tables
#table(
  columns: (1fr, auto, auto),
  inset: 10pt,
  align: horizon,
  [*Equation*], [*Area*], [*Parameters*],
  $ pi h (D^2 - d^2) / 4 $,
  [
    $h$: height \
    $D$: outer radius \
    $d$: inner radius
  ],
  $ sqrt(2) / 12 a^3 $,
)

= Visuals
== Circles
#circle(radius: 25pt)

#circle[
  #set align(center + horizon)
  Automatically \
  sized to fit.
]

== Ellipses
// Without content.
#ellipse(width: 35%, height: 30pt)

// With content.
#ellipse[
  #set align(center)
  Automatically sized \
  to fit the content.
]

== Lines

#line(length: 100%)
#line(end: (50%, 10%))
#line(
  length: 4cm,
)
== Paths
#path(
  closed: true,
  (0pt, 50pt),
  (100%, 50pt),
  ((50%, 0pt), (40pt, 0pt)),
)

== Polygons

#polygon(
  (20%, 0pt),
  (60%, 0pt),
  (80%, 2cm),
  (0%,  2cm),
)

== Rectangles
#rect(width: 35%, height: 30pt)

#rect[
  Automatically sized \
  to fit the content.
]

== Squares

#square(size: 40pt)

#square[
  Automatically \
  sized to fit.
]


== Highlights

This is #highlight[important].

This #highlight[#link("https://typst.app")[Link]] is important too.

So is this reference #highlight[@links].

== Code

Python syntax highlighting example, copied from #link("https://github.com/sharkdp/bat")[bat] (MIT License \@ bat-developers).

```python
from os import getcwd
import numpy as np
from matplotlib.pyplot import plot as plt
from time import *


# COMMENT test
h2 = 4  # this is a comment
"""this is also a comment"""

# Import test

# class test


class Hello:
    def __init__(self, x):
        self.name = x
        
    def selfprint(self):
        print("hello my name is ", self.name)

    def testprint(self):
        print(1*2, 2+3, 4 % 5, 8-4, 9/4, 23//4)

# Decorators test
class Decorators:
    @classmethod
    def decoratorsTest(self):
        pass
    
H1 = Hello("john")
H1.selfprint()
H1.testprint()


# list test
a = [1, 2, 3, 4, 5]
a.sort()
print(a[1:3])
print(a[:4])
print(a[2])
print(a[2:])

# dictionary test
# copied from w3schools example

myfamily = {
    "child1": {
        "name": "Emil",
        "year": 2004
    },
    "child2": {
        "name": "Tobias",
        "year": 2007
    },
    "child3": {
        "name": "Linus",
        "year": 2011
    }
}

# tuple test

testTuple = ("one", 2, "3")
print(testTuple)

print(np.random.randint(5, 45))

# string test
a = "hello world"
b = """good morning
hello world
bye"""

formattest = "teststring is ={}".format(5)

# lambda test


def x2(n):
    lambda n: n/7


# if else ladder
if 1 > 2:
    print("yes")
elif 4 > 5:
    print("maybe")
else:
    print("no")

# loops
i = 5
while(i > 0):
    print(i)
    i -= 1

for x in range(1, 20, 2):
    print(x)
```
