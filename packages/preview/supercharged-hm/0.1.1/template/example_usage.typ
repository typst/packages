// Copyright 2024 Felix Schladt https://github.com/FelixSchladt

#import "@preview/supercharged-hm:0.1.1": *

= Template Usage
Small guide on the usage of the template and provided items.

== How to use the Glossarium

Use the `#gls(accronym)` function or `@acronym` to insert acronyms, which looks like this #gls("http").

#glspl("api") are used to define the interaction between different software systems @iso18004.

Only the first occurrence of an acronym will be expanded, like this #gls("http").

== Displaying Raw Text and Sourcecode

In the following example, we display python code with syntax highlighting.
For this, the `code` function is used. The `code` function is a wrapper for the `sourcecode` function from the `@preview/codelst` package, with some defaults applied.

#figure(
  caption: "Example code.",
)[
  #code(
    ```py
    def exmple_function(int a, int b) -> int:
        print("Hello, World!")
        yield a + b
    ```,
  )
]

For inline colored code, the \`\`\`py CODE \`\`\` syntax is used like ```py function(int a) -> int```. 

=== Displaying Inline Colored Monospace text

If you want to display monospaced colored text, the `rgb-raw` function can be used.
The following text is created with ```typ #rgb-raw("MACHINE_ADAPTER", rgb("#13A256"))``` and looks like #rgb-raw("MACHINE_ADAPTER", rgb("#13A256")).

== Notes

The family of note functions can be used to display note boxed: `note`, `color_note`, `warning-note`, and `good-note`.

#stack(
  dir: ltr,
  spacing: 10pt,
note("Note"),
color-note("Color note", rgb("#2B82BD"), rgb("#c9dfec")),
warning-note("Warning note"),
good-note("Good note"),
)\

== Tables

For tables, a prestyled wrapper function is available, the `styledtable` function, taking a `table` function as an argument. The `stroke`, `background-odd`, and `background-even` parameters can be set to change the table's color appearance.

#figure(caption: [Example Table])[
#styledtable(
  table(
    columns: (auto, auto, auto),
    table.header([*Platform*], [*Adapters*], [*Data*]),
    table.hline(),
    [Drone],[
      - wifi
      - lte
    ],[
      - Mission Data
      - Camera feed
      - Flight information
    ],[
      Car
    ],[
      - LTE
    ],[
      - Route information
      - Maintenance Data
    ],[
      Truck
    ],[
      - Lorawan
      - LTE
    ],[
      - Moving & rest times
      - Loading information
      - Maintenance Data
			],
	))
]

#figure(
  caption: "Table code example.",
)[
  #code(
```typ
#figure(caption: [Example Table])[
#styledtable(
  table(
    columns: (auto, auto, auto),
    table.header([*Platform*], [*Adapters*], [*Data*]),
    table.hline(),
    [Drone],[
      - wifi
      - lte
    ],
    [...]
	))
]
```,
  )
]

== Requirements

Requirements werden in funktional und nicht funktional gruppiert.

#figure(
  caption: "Requirements function usage example"
)[
  #set text(size: 11pt)
  #code(
```typ
#requirements(
  functional-chapter-description: [Functional requirements specify what functionality or behavior the resulting product under the specified conditions should have @balzert_lehrbuch_2011.],
  functional: (
    (
      title: [Drone Connectivity], 
      description: [The drone shall have connectivity to the server],
      subrequirements: (
        (
          title: [LTE Connectivity],
          description: [Connectivity to the server shall be achieved via LTE]
        ),
      ),
    ),
  ),
  non-functional-chapter-description: [Nonfunctional or technical requirements describe aspects regarding one or more functional requirements. In short, they specify how the product should work @balzert_lehrbuch_2011.],
  nonfunctional: (
    (
      title: [Server Placement], 
      description: [The drone server shall be placed in a remote server center.]
    ),
  ),
)
```
)
]

Below, the rendering of the above shown example is visible.

#requirements(
  functional-chapter-description: [Functional requirements specify what functionality or behavior the resulting product under the specified conditions should have @balzert_lehrbuch_2011.],
  functional: (
    (
      title: [Drone Connectivity], 
      description: [The drone shall have connectivity to the server],
      subrequirements: (
        (
          title: [LTE Connectivity],
          description: [Connectivity to the server shall be achieved via LTE]
        ),
      ),
    ),
  ),
  non-functional-chapter-description: [Nonfunctional or technical requirements describe aspects regarding one or more functional requirements. In short, they specify how the product should work @balzert_lehrbuch_2011.],
  nonfunctional: (
    (
      title: [Server Placement], 
      description: [The drone server shall be placed in a remote server center.]
    ),
  ),
)

#set align(bottom)
Each requirement can be referred to by its requirement id like ```typ @req_Drone_Connectivity```, @req_Drone_Connectivity.
Additional labels exist for ```typ @req_functional``` and ```typ @req_nonfunctional```.
