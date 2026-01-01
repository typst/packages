#import "@preview/vintage-fiit-thesis:1.0.0": *

#show: fiit-thesis.with(
  title: "Moja záverečná práca",
  thesis: "bp2",
  author: "Jožko Mrkvička",
  supervisor: "prof. Jozef Mrkva, PhD.",
  abstract: (
    sk: lorem(150),
    en: lorem(150),
  ), // abstract
  id: "FIIT-12345-123456",
  lang: "sk", // this controls how the layout is presented, be careful!
  // remove the argument or made the value none to hide
  acknowledgment: [I would like to thank my supervisor for all the help and
    guidance I have received. I would also like to thank my friends and family
    for supporting during this work.],
  // remove the argument or leave the array empty to hide the list of
  // abbreviations
  abbreviations-outline: (
    ("SSL", "Secure socket layer"),
    ("RISC", "Reduced instruction set computer"),
    ("ISA", "Instruction set architecture"),
  ),
  figures-outline: true,
  tables-outline: true,
  style: "legacy",
)

= Introduction

#lorem(110)

#lorem(100)

#lorem(100)

#lorem(120)

= Analysis

== Intro to analysis

#lorem(250)

#figure(
  caption: [Imagine here FIIT logo in SVG file format for reference.],
  pad(
    2em,
    block(fill: color.aqua, width: 200pt, height: 100pt, radius: 15pt),
  ),
) <fiit-logo>

#lorem(150)

= Implementation

#lorem(250)

#figure(
  caption: [This is an example of a code listing in your thesis.],
  [```c
  int main()
  {
      printf("Hello World!\n");
      return 0;
  }
  ```],
) <c-example>

== Citation example

This is an example of how to reference a paper in your thesis @riscv.
Appendices are the chapters that come at the end, you can reference them too!
Here's an example: the source code for this project is recorded in
@source-code.

#lorem(150)

#figure(
  caption: [This is an example of a table that you can create using Typst.],
  table(
    columns: 2,
    table.header([*Left column*], [*Right column*]),
    [Some label], [Some data],
    [Another label], [Another data],
  ),
) <c-example>

#lorem(200)

== Another subject

#lorem(100)

// has the right format, goes before appendices
#bibliography("citations.bib")
#pagebreak(weak: true)

// #resume()[
// #lorem(250)
// ]

// start the appendices section with this line
#show: section-appendices.with()

= Source code <source-code>
#lorem(150)

= Plan of work <plan-of-work>

#pagebreak()

