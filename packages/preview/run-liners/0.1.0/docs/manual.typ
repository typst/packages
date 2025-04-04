#import "/lib.typ": *

#import "@preview/codly:1.1.1": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()
#codly(languages: codly-languages)

#set page(width: 8.5in, height: 11in, margin: 1in, numbering: "1",
  header: [#h(1fr) Version: `0.1.0`])
#set par(justify: true)
#show raw.where(block: true): set text(size:7pt)

#let easy-typography(
  body-size: 10pt,
  body-font: "Source Serif Pro",
  heading-font: "Source Sans Pro",
  paper: none,
  margin: none,
  body
) = {
  // Constants
  let heading-above-max = 1.25em
  let heading-above-min = 0.75em
  let heading-below-max = 0.65em
  let heading-below-min = 0.52em
  let heading-size-max  = 1.10em
  let heading-size-min  = 1.00em
  let body-weight       = "light"
  let line-spacing      = 1.25
  let paragraph-spacing = 2.00

  // Optional page setup
  if paper != none {
    set page(paper: paper)
  }
  if margin != none {
    set page(margin: margin)
  }

  // Paragraphs
  set par(
    leading: line-spacing * 0.5em,
    spacing: paragraph-spacing * 0.5em,
    justify: true,
    linebreaks: "optimized",
  )

  // Body text
  set text(
    font: body-font,
    fallback: false,
    style: "normal",
    weight: body-weight,
    stretch: 100%,
    size: body-size,
    tracking: 0pt,
    spacing: 100% + 0pt,
    baseline: 0pt,
    overhang: true,
    hyphenate: true,
    kerning: true,
    ligatures: true,
    number-type: "lining",
  )

  // Top-heavy easing function for heading sizes/spacing:
  //    - max = biggest size (H1), min = smallest size (H5), level in [1..5]
  //    - sqrt(t) => gives biggest decrease at top, gentlest at bottom
  let compute-size(max, min, level) = {
    if level <= 1 {
      max
    } else if level >= 5 {
      min
    } else {
      let t = (level - 1) / 4
      max - (max - min) * calc.sqrt(t)
    }
  }

  // Heading weight logic
  let compute-weight(level) = {
    if level <= 1 {
      "bold"
    } else if level == 2 {
      "semibold"
    } else if level == 3 {
      "medium"
    } else {
      "regular"
    }
  }

  // Show headings using computed size/spacing values
  show heading: it => block(
    breakable: false,
    sticky: true,
    above: compute-size(heading-above-max, heading-above-min, it.level),
    below: compute-size(heading-below-max, heading-below-min, it.level),
    text(
      font: heading-font,
      size: compute-size(heading-size-max, heading-size-min, it.level),
      weight: compute-weight(it.level),
      it
    )
  )

  // Finally, render the body
  body
}

#show: easy-typography

#text(
  size: 3em,
  weight: "black",
  font: "Source Sans Pro",
  [`run-liners`: User Manual]
)

#v(1fr)

#outline(depth: 1)

#pagebreak()


#set heading(numbering: "1.1.")

= Introduction

This package provides a set of functions that create “run-in” lists and enumerations, following guidelines similar to the *Chicago Manual of Style*. You can produce run-in enumerations, bullet lists, terms/definitions, or verses, all joined in a single line with flexible separators and optional words like “and,” “or,” or _none_ (i.e. omit a coordinator).

We’ll illustrate each function using
#run-in-terms(
  coordinator: "and",
  ([the left column], [a `typst` block containing the Typst code you’d write]),
  ([the right column], [the rendered result]),
).

= `run-in-enum`: Run-in numbered lists
`run-in-enum` is typically used for run-in enumerations like “(1) apple, (2) banana, and (3) cherry.” It offers these parameters:

- *`separator`*: Defaults to `"auto"` (which tries to detect commas and switch to semicolons).
- *`coordinator`*: The word or phrase before the last item—defaults to `"and"`, can be `"or"`, `"and/or"`, or `none`.
- *`numbering-pattern`*: A pattern like `"(1)"`, `"(A)"`, or any format the `numbering()` call supports.
- *`numbering-formatter`*: A function that can style or transform the generated number.



== Example: Basic Three-Item Enumeration

#columns(2)[
  ```typst
  #run-in-enum(
    [Apple],
    [Banana],
    [Cherry]
  )
  ```
  #colbreak()

  #run-in-enum(
    [Apple],
    [Banana],
    [Cherry]
  )
]

This example uses *all defaults*:
- `separator: "auto"` → because there’s no comma in the content, it uses commas.
- `coordinator: "and"` → puts “and” before the last item.
- `numbering-pattern: "(1)"` → “(1) (2) (3)”
- `numbering-formatter: (it) => [#it]` → no special styling.



== Example: Coordinator = none, 4 Items, Comma in content

If one of your items contains `[text, with comma]`, the `auto` separator chooses `"; "`.

#columns(2)[
  ```typst
  #run-in-enum(
    coordinator: none,
    [Item One],
    [Item Two, comma here],
    [Item Three],
    [Item Four]
  )
  ```
  #colbreak()

  #run-in-enum(
    coordinator: none,
    [Item One],
    [Item Two, comma here],
    [Item Three],
    [Item Four]
  )
]

Notice it used semicolons because of comma detection, *and* no coordinator word (because `coordinator: none`).

== Example: Custom Numbering Pattern & Styling

#block(breakable: false)[
You can change `numbering-pattern` to `"(A)"` or `"(i)"` and style the numbers with `numbering-formatter`.

#columns(2)[
  ```typst
  #run-in-enum(
    numbering-pattern: "(A)",
    numbering-formatter: (txt) => [#strong(txt)],
    [Alpha],
    [Beta],
    [Gamma]
  )
  ```
  #colbreak()

  #run-in-enum(
    numbering-pattern: "(A)",
    numbering-formatter: (txt) => [#strong(txt)],
    [Alpha],
    [Beta],
    [Gamma]
  )
]
Here, `(A)`, `(B)`, `(C)` appear in *bold*.
]

== Example: Single Item & Two Items Edge Cases

When only one item is present, no separator or coordinator is used. With two items, you’ll see just one separator plus “and/or/or” (depending on coordinator).

#columns(2)[
  ```typst
  // Single item:
  #run-in-enum([LoneItem])
  ```
  #colbreak()
  #run-in-enum([LoneItem])
]
#columns(2)[
  ```typst
  // Two items:
  #run-in-enum([First], [Second])
  ```
  #colbreak()
  #run-in-enum([First], [Second])
]
#columns(2)[

  ```typst
  // Two items, no coordinator:
  #run-in-enum(coordinator: none, [First], [Second])
  ```
  #colbreak()
  #run-in-enum(coordinator: none, [First], [Second])
]
#columns(2)[

  ```typst
  // Three items:
  #run-in-enum([First], [Second], [Third])
  ```
  #colbreak()
  #run-in-enum([First], [Second], [Third])
]
#columns(2)[

  ```typst
  // Three items, no coordinator:
  #run-in-enum(coordinator: none, [First], [Second], [Third])
  ```
  #colbreak()
  #run-in-enum(coordinator: none, [First], [Second], [Third])
]



= `run-in-list`: Run-in bullet points
`run-in-list` behaves like `run-in-enum` but uses a *bullet (or any marker)* before each item. The rest of the logic is the same—`separator`, `coordinator`, etc.
See the “run-in-enum” section for *how `auto` detection* and *`coordinator`* work.



== Example1: Default Bullets
#columns(2)[
  ```typst
  #run-in-list(
    [Apple],
    [Banana],
    [Cherry]
  )
```
  #colbreak()

  #run-in-list(
    [Apple],
    [Banana],
    [Cherry]
  )
]

You get bullets `[•]` for each item by default.

== Example: Custom Marker, Coordinator = 'or'

#block(breakable: false)[
#columns(2)[
  ```typst
  #run-in-list(
    coordinator: "or",
    marker: [#sym.ballot.check],
    [First],
    [Second],
    [Third, comma item]
  )
  ```
  #colbreak()

  #run-in-list(
    coordinator: "or",
    marker: [#sym.ballot.check],
    [First],
    [Second],
    [Third, comma item]
  )
]
Because of the comma, it uses semicolons. The coordinator is now `"or"`.
]

= `run-in-terms`: Run-in term definitions

`run-in-terms` is for run-in *terms and definitions*. By default, each term is *bold* (`[#strong(term)]`) followed by the definition, and you still get the same *separator* and *coordinator* logic as in `run-in-enum`.

== Example: Three Terms, No Coordinator

#columns(2)[
  ```typst
  #run-in-terms(
    coordinator: none,
    (
      ([Goal], [Summarize the prior research]),
      ([Methods], [Outline the approach]),
      ([Outcome], [Analyze the results])
    )
  )
  ```
  #colbreak()
  #run-in-terms(
    coordinator: none,
    ([Goal], [Summarize the prior research]),
    ([Methods], [Outline the approach]),
    ([Outcome], [Analyze the results])
  )
]

See how no “and” or “or” appears. It detects commas if they exist.



== Example: Custom Term Formatter
#columns(2)[
  ```typst
  #run-in-terms(
    term-formatter: (txt) => [#underline(txt)],
    ([Key], [Value 1]),
    ([Another Key], [Value 2])
  )
  ```
  #colbreak()
  #run-in-terms(
    term-formatter: (txt) => [#underline(txt)],
    ([Key], [Value 1]),
    ([Another Key], [Value 2])
  )
]

Each term is underlined, with a colon after the term.



= `run-in-verse`: Run-in poetry lines
`run-in-verse` simply joins lines (verses) with a given *separator* (default: `[ /~]`), and no coordinator. It’s much simpler since you typically don’t want “and” in between lines of poetry.

== Example: Default Verse Joining
#columns(2)[
  ```typst
  #run-in-verse(
    [Line 1],
    [Line 2],
    [Line 3]
  )
  ```
  #colbreak()
  #run-in-verse(
    [Line 1],
    [Line 2],
    [Line 3]
  )
]

== Example: Custom Separator

#block(breakable: false)[
#columns(2)[
  ```typst
  // Overriding the default with a comma + space
  #run-in-verse(
    separator: ", ",
    [Line A],
    [Line B],
    [Line C]
  )
  ```
  #colbreak()
  #run-in-verse(
    separator: ", ",
    [Line A],
    [Line B],
    [Line C]
  )
]
]

= Direct `run-in-join`
All these functions ultimately call *`run-in-join`*, which you can use yourself if you want to create custom transformations. You supply:

1. *`separator`* (or `"auto"` for comma detection).
2. *`coordinator`* or `none`.
3. A *spread* of content items (`..content`).



== Example: Using `run-in-join` Directly
#columns(2)[
  ```typst
  #run-in-join(
    coordinator: "and/or",
    [First item],
    [Second item],
    [Third item, comma triggers semicolon],
    [Final item]
  )
  ```
  #colbreak()
  #run-in-join(
    coordinator: "and/or",
    [First item],
    [Second item],
    [Third item, comma triggers semicolon],
    [Final item]
  )
]

You can see that it inserts semicolons (auto detection) and “and/or” before the last item.



= Conclusion
That’s your tour of the *run-in* functions! Remember:
- If you want enumerations with `(1)` or `(A)` prefixes, use *`run-in-enum`*.
- For bullet lists, use *`run-in-list`*.
- For term–definition pairs, *`run-in-terms`*.
- For verse lines, *`run-in-verse`*.
- Or just call *`run-in-join`* yourself for custom needs.

Explore different *separators* (like `[ /~]`, `", "`, or `"; "`) and *coordinators* (`"and"`, `"or"`, `"none"`, etc.) to get the exact run-in style your text requires.

Happy Typst-ing!
