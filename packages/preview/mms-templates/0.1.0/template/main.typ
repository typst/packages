#import "@preview/mms-templates:0.1.0": *

#show: doc => report(
  doc,
  title: [Autonomous Systems (Car 66) Design Report],
  department: [Autonomous Systems],
  authors: ("Jayant Godse", "Joshua Goh", "Fay Briggs"),
  heading-numbers: false,
  abstract: [ #lorem(100) ],
)

= Heading 1

#lorem(30)

== Heading 2

#lorem(30)
=== A Third Heading

#lorem(45)


== What are we doing with this?

Some inline math $A in [2, 32)$ or even $2 + 35 = #(2 + 35)$

A math block
$
  sum_0^30x^2 = integral_0^30x space d x
$

Then you can also write code:
#figure(
  ```cpp
  int main(void){
    std::cout << "" << std::endl;
    return 0;
  }

  ```,
  caption: [A simple C++ program],
)

A table:

#figure(
  table(
    columns: (2cm, 1fr, 1fr),
    align: horizon,
    table.header([Type], "Apples", "Oranges"),
    [Good], [Expensive], [Cheap],
    [Bad], [Mid], [$e^(i pi) + 1 = 0$],
  ),
  caption: [Comparing apples and oranges],
)

#lorem(100)
#pagebreak()
#lorem(100)
