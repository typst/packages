#import "../utils.typ": todo, silentheading, flex-caption
#import "@preview/wrap-it:0.1.0": wrap-content

= Tutorial <Tutorial>
#todo[Exclude this chapter!]

Because I have to @cite_todo. This is a abbreviation @oidc explained in the glossary.

This template uses the Arial font with size 11pt, a spacing of 1em with a side margin of 2.5cm with a 1cm single sided bounding correction. This can be edited in the `main.typ` file#footnote[This is a footnote.]. If you are looking for how to cite, this sentence is what your are looking for @Bradshaw2012.
== Example for figures
=== Normal Figure
#lorem(30)
And this is a reference to this @tag.
#figure(
  image("../images/MissMoneypenny.jpg", width: 60%), caption: flex-caption([This is a #strike[caption] beautiful cat named Miss Moneypenny ],[Picture of Miss Moneypenny (short description of the image for the list of figures)])

)<tag>


=== Wrap-Content
#wrap-content([#figure(image("../images/JamesBond.jpg", width:150pt,), caption: [another caption])],
[
  #lorem(100)

], align: right)



=== Sub-Figures
#figure(grid(columns: 2, row-gutter: 2mm, column-gutter: 1mm,

  image("../images/Calcipher.jpg", height: 200pt), image("../images/Mei.jpg", height: 200pt), 

  "a) test 1", "b) test2"),

  caption: "Caption"

)<label>

== Math

This is how you define inline math: $a^2 + b^2 = c^2$. For bigger equations you  can use a math block, as you can see in @eq1.
$
integral_(-oo)^(oo) f(x) d x = 1\
1 = 1
$<eq1>

== Tables
=== Normal Table
#align(center)[
  #table(
    columns: 3,
    align: center,
    table.header(
      [Substance],
      [Subcritical °C],
      [Supercritical °C],
    ),
    [Hydrochloric Acid],
    [12.0], [92.1],
    [Sodium Myreth Sulfate],
    [16.6], [104],
    [Potassium Hydroxide],
    table.cell(colspan: 2)[24.7],
   )]
=== Referenceable Table
#figure(
  table(
    columns: 3,
    align: center,
    table.header(
      [Substance],
      [Subcritical °C],
      [Supercritical °C],
    ),
    [Hydrochloric Acid],
    [12.0], [92.1],
    [Sodium Myreth Sulfate],
    [16.6], [104],
    [Potassium Hydroxide],
    table.cell(colspan: 2)[24.7],
   ),
   caption: "This is a caption"
)

#silentheading(4)[This is a silent level 4 heading]
This won't show up in the overview.
== Code
Some python code:
```py
print("Hello World")
```
Some C++ code:
```cpp
#include <iostream>

int main() {
    std::cout << "Hello World!";
    return 0;
}
```