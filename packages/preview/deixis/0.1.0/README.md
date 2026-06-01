deixis [![Typst Universe](https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Fdeixis&query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&logo=typst&label=Universe&color=%23239DAE)](https://typst.app/universe/package/deixis) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE) [![User Manual](https://img.shields.io/badge/manual-.pdf-purple)][manual]
------

Decoupled annotations for [Typst](https://typst.app/).


<div align="center">
<img src="https://raw.githubusercontent.com/inspiros/typst-deixis/v0.1.0/assets/logo.svg" width="200px" alt="Deixis logo">
</div>

`deixis` is a unified layout engine for inline notes, footnotes, endnotes, margin notes, inset notes, and inline spatial highlights with visual connectors.

## Main Features

- **Marks:**
  - [Inline mark](#inline-mark-and-inline-note)
  - Phantom mark _(invisible inline mark)_
  - [Region mark](#pin-and-region-mark)
- **Notes:**
  - [Inline note](#inline-mark-and-inline-note)
  - [Footnote](#footnote)
  - [Endnote](#endnote)
  - [Margin note](#margin-note)
  - [Inset note](#inset-note)
- [Cross-reference & bi-directional backlinks](#cross-reference-and-backlink)
- [Note outline](#note-outline)
- [Minipage](#minipage)

## Installation

### From Typst Universe

This package is available in the Typst Universe, you can download and use it by simply adding the following line to your document.

```typst
#import "@preview/deixis:0.1.0": *
```

### Local Use

For local use, first you need to clone the repo and run the install script:

```bash
git clone https://github.com/inspiros/typst-deixis
python scripts/install.py
 ```

This Python script stores the package files in the right location following the instructions [here](https://github.com/typst/packages?tab=readme-ov-file#local-packages).
Once installed, you can import the package with:

```typst
#import "@local/deixis:0.1.0": *
```

## Usage and Examples

For detailed information, please see the [manual (PDF)][manual].

### Quick Start

No `deixis` functionality can be used before applying this setup show rule:

```typst
#show: deixis-setup-notes
```

> ⚠️ **Warning**
>
> `deixis` uses the page foreground/background for rendering notes.
> If you have your custom foreground/background, it needs to be set before `#show: deixis-setup-notes`.

#### Anatomy of a Note

`deixis` notes are decoupled by nature.
To create a complete note, you need to put a mark with `-mark` functions, and a note body with `-body` functions. They are linked together via `id`.

Alternatively, you can call wrapper functions, which internally generate a unique `id` and delegate the tasks to appropriate mark-only and body-only functions.
Note that not all notes have a wrapper function.

<div align="center">
<table>
<tr>
  <td width="50%">

```typst
#deixis-inline-mark(
  id: <note1>,
)
#deixis-footnote-body(
  id: <note1>,
)[Body]
```

  </td>
  <td width="50%">

```typst
#deixis-footnote(
  // auto-inferred
  mark-type: "inline",
)[Body]
```

  </td>
</tr>
<tr>
  <td align="center">
  Decoupled approach
  </td>
  <td align="center">
  Wrapper approach
  </td>
</tr>
</table>
</div>

---

### Inline Mark and Inline Note

<div align="center">
<img src="https://raw.githubusercontent.com/inspiros/typst-deixis/v0.1.0/assets/gallery/inline-note-1.svg" width="500px" alt="Inline mark and note example">
</div>

<details>
<summary><b>Show Typst Source Code</b></summary>

````typst
#set par(justify: true)

Le
#deixis-inline-mark(  // celibate mark
  inline-mode: "underline",
  stroke: gray,
  fill: gray.transparentize(90%),
)[chercheur]
a ressenti un immense
#deixis-inline-mark(id: <soulagement>,
  stroke: red,
  fill: red.transparentize(95%),
)[soulagement]
en découvrant enfin la
#deixis-inline-mark(id: <cle-de-voute>,
  stroke: teal,
  fill: teal.transparentize(95%),
)[clé de voûte]
de son argumentation.

#deixis-inline-note-body(id: <soulagement>)[
  *soulagement*: Relief.
]
#deixis-inline-note-body(id: <cle-de-voute>)[
  *clé de voûte*: Keystone _(metaphorically: the cornerstone or central principle of an argument)_.
]
#deixis-inline-note-body(  // celibate note
  stroke: gray,
  fill: gray.transparentize(95%),
)[
  Without an unique `id`, standalone bodies become celibate (no marker) like this one.
]
````

</details>

### Footnote

<div align="center">
<img src="https://raw.githubusercontent.com/inspiros/typst-deixis/v0.1.0/assets/gallery/footnote-1.svg" width="500px" alt="Footnote example">
</div>

<details>
<summary><b>Show Typst Source Code</b></summary>

````typst
#lorem(10)
#deixis-footnote[A plain footnote.]
#lorem(10)
#deixis-footnote(marker: lorem(2))[
  A footnote with very long marker, aligned with other notes.
]
#deixis-footnote-body[
  A celibate footnote body without linked mark.
]

#lorem(10)
#deixis-footnote(
  marker-style: (body: it => text(fill: orange, super(it))),
  stroke: red,
  fill: red.transparentize(95%),
  container-func: deixis-alert-container,
)[A marked text][A colorful footnote.].
````

</details>

### Endnote

<div align="center">
<img src="https://raw.githubusercontent.com/inspiros/typst-deixis/v0.1.0/assets/gallery/endnote-1.svg" width="500px" alt="Endnote example">
</div>

<details>
<summary><b>Show Typst Source Code</b></summary>

````typst
#lorem(10)
#deixis-endnote[A plain endnote.]
#lorem(10)
#deixis-endnote(
  stroke: maroon,
  fill: maroon.transparentize(90%),
)[
  Endnotes use a different counter
][
  They default to the `"endnote"` series.
].
#lorem(10)
// print all previous notes
#deixis-print-endnotes()

#lorem(5)
#deixis-endnote[
  ```typst #deixis-print-endnotes()``` flushes out unprinted notes by default, but it can do more than that.
]
#box()<split>
This
#deixis-endnote(
  stroke: gray,
  fill: none,
)[
  invisible note
][
  This note is not supposed to be printed.
]
is added after the label ```typst #box()<split>```.
// print with filter
#deixis-print-endnotes(before: <split>)
````

</details>

### Margin Note

<div align="center">
<img src="https://raw.githubusercontent.com/inspiros/typst-deixis/v0.1.0/assets/gallery/margin-note-1.svg" width="500px" alt="Margin note example">
</div>


<details>
<summary><b>Show Typst Source Code</b></summary>

````typst
#lorem(10)
#deixis-margin-note[A plain margin note.]
#lorem(10)
// use rect container for subsequent notes
#deixis-set(container-func: (margin-note: rect))
#deixis-margin-note(
  stroke: teal,
  fill: teal.transparentize(95%),
  link: "right-angle",
)[][A colorful margin note.]
#deixis-margin-note(
  stroke: green,
  fill: green.transparentize(95%),
  link: "right-angle",
  mark-align: (mark: horizon, body: horizon),
)[This is a marked text][A left side note, aligned horizontally to its mark.].
#lorem(10)
#deixis-margin-note(
  inline-mode: "highlight",
  stroke: (link: stroke(paint: orange, dash: "dashed"), body: orange),
  fill: (mark: orange.transparentize(80%), body: orange.transparentize(95%)),
  side: right,
  link: "curve",
)[Another highlighted text][A note with different styling.].

#import "@preview/colorful-boxes:1.4.3": stickybox

#lorem(3)
#deixis-margin-note(
  fill: blue.lighten(85%),
  container-func: (body, ..args) => stickybox(body, fill: args.at("fill"), rotation: args.at("rotation", default: 0deg)),
  rotation: 10deg,  // all unknown named parameters are passed to container-func
)[Sticky note.]
#lorem(5)
#deixis-margin-note(
  marker: "",
  stroke: red,
  fill: red.transparentize(95%),
  link: "right-angle",
)[A note with empty marker.]
#lorem(5)
````

</details>

#### Spillover

<div align="center">
<table>
<tr>
  <td align="center">
<img src="https://raw.githubusercontent.com/inspiros/typst-deixis/v0.1.0/assets/gallery/margin-note-spillover-1.svg" width="500px" alt="Margin note spillover example - page 1">
  </td>
</tr>
<tr>
  <td align="center">
  <sub>Page 1</sub>
  </td>
</tr>
<tr>
  <td align="center">
<img src="https://raw.githubusercontent.com/inspiros/typst-deixis/v0.1.0/assets/gallery/margin-note-spillover-2.svg" width="500px" alt="Margin note spillover example - page 2">
  </td>
</tr>
<tr>
  <td align="center">
  <sub>Page 2</sub>
  </td>
</tr>
</table>
</div>


<details>
<summary><b>Show Typst Source Code</b></summary>

````typst
If ```typc spillover: true```, and both margins
#deixis-margin-note(
  stroke: red,
  link: "right-angle",
  container-func: rect,
)[
  #lorem(20)
]
in one page has been filled
#deixis-margin-note[
  #lorem(28)
].

Subsequent notes
#deixis-margin-note[
  A spilled note.
]
will be _spilled_ to the next page
#deixis-margin-note[
  Margin notes cannot create new pages, one needs to use ```typst #pagebreak()``` manually.
]
if possible
#deixis-margin-note(
  stroke: orange,
  link: "right-angle",
  container-func: rect,
)[
  A spilled note with link crossing page border.
].

#pagebreak()
````

</details>

### Inset Note

<div align="center">
<img src="https://raw.githubusercontent.com/inspiros/typst-deixis/v0.1.0/assets/gallery/inset-note-1.svg" width="500px" alt="Inset note example">
</div>

<details>
<summary><b>Show Typst Source Code</b></summary>

````typst
Inset notes can be placed
#deixis-inset-note(
  stroke: orange,
  fill: yellow.transparentize(90%),
  link: "right-angle",
  link-ports: (mark: right, body: bottom),
  link-marks: "both",
  placement: body => deixis-absolute-place(top + right, dx: -5pt, dy: 5pt, body),
)[anywhere][A manually placed note.]

- #lorem(2)
- #lorem(3)#deixis-inset-note(
  marker: none,
  stroke: red,
  fill: red.transparentize(95%),
  link: "straight-line",
  link-marks: "mark",
  width: 4.5cm,
  dx: 1em,
  dy: 0pt,
  anchor: (mark: right + horizon, body: left + horizon),
  layer: "flow",
)[Alternatively, use `dx`, `dy`, and `anchor` to align the body.]
- #lorem(2)

#import "@preview/meander:0.4.2"
#import "@preview/colorful-boxes:1.4.3": outline-colorbox

#let note-body = deixis-inset-note-body(
  id: <meander>,
  width: 50%,
  stroke: purple,
  fill: purple.transparentize(95%),
  layer: "flow",  // important !!!
  container-func: (body, ..args) => outline-colorbox(body,
    color: (stroke: args.at("stroke").paint, fill: args.at("fill")),
    stroke: args.at("stroke").thickness,
    title: args.at("title", default: [Note])),
  title: [`meander` note],
)[A _true_ inset note.]
#meander.reflow({
  import meander: *

  placed(horizon + right, note-body)
  container()
  content[
    #set par(justify: true)
    Text will wrap around this note
    #deixis-inline-mark(id: <meander>).
    Note that you must set ```typc layer: "flow"``` (render immediately) for this to work.
    #lorem(29)
  ]
})
````

</details>

### Pin and Region Mark

#### Pin

To create region marks, `deixis` relies on `#deixis-pin`, an idea similar to the [pinit](https://github.com/OrangeX4/typst-pinit) package.
A region is defined as the minimum rectangle covering an array of input pins, taking padding into account.

Each pin holds its own `padding`, defaults to `"text"`, which means to pad the region around it similar to an inline mark with `inline-mode: "box"`.

<div align="center">
<img src="https://raw.githubusercontent.com/inspiros/typst-deixis/v0.1.0/assets/gallery/region-mark-cat-table-1.svg" width="500px" alt="Pin placement and region mark example">
</div>

<details>
<summary><b>Show Typst Source Code</b></summary>

````typst
Breakdown of standard #deixis-pin("feline-l")feline#deixis-pin("feline-r") architecture and performance metrics:
#deixis-region-mark(
  stroke: none,
  fill: yellow.transparentize(50%),
  radius: 0pt,
  pins: ("feline-l", "feline-r"),
  layer: "background",
)

#{
  set text(size: 0.8em)
  figure(
    table(
      align: left + horizon,
      columns: (auto, auto),

      table.header([*Property*], [*Specification*]),
      [\#legs], [4],
      [Max speed], [#deixis-pin("tab-tl")48 km/h],
      [Battery Life], [16--18 hours#deixis-pin("tab-br", padding: (bottom: 0.2em, right: 1em))],
      [Fuel Source], [Tuna],
      [Storage Capacity], [$infinity$]
  ))
}
#deixis-footnote(
  mark-type: "region",
  marker-style: it => text(fill: blue, super(it)),
  stroke: orange,
  fill: orange.transparentize(95%),
  pins: ("tab-tl", "tab-br"),
)[Top performance achieved at #sym.tilde.basic#[]3:00 AM, must recharge under direct sunlight #emoji.sun.]
````

</details>

#### Attach Pins

`#deixis-attach` allows you to attach pins on a wrapped content by:
- Providing a dictionary of pins and their attributes.
- If no pins provided, it automatically attaches two pins, one on the top-left corner and one on the bottom-right corner, both with `0pt` padding.
- Alternatively, pins can be placed with pattern matching `[prefix]pinname[postfix]`.
  The prefix and postfix patterns can be set using `#deixis-set-pin-pattern`.
  This is very useful for highlighting code.

<table>
<tr>
  <td width="50%">

<div align="center">
<img src="https://raw.githubusercontent.com/inspiros/typst-deixis/v0.1.0/assets/gallery/region-mark-cat-1.svg" width="500px" alt="Attach pins on image example">
</div>

  </td>
  <td width="50%">

<div align="center">
<img src="https://raw.githubusercontent.com/inspiros/typst-deixis/v0.1.0/assets/gallery/region-mark-sigmoid-1.svg" width="500px" alt="Attach pins on equation and raw example">
</div>

  </td>
</tr>
<tr>
  <td align="center">
  Cat
  </td>
  <td align="center">
  Sigmoid
  </td>
</tr>
</table>

<details>
<summary><b>Show Typst Source Code for Cat</b></summary>

````typst
#align(center,
  deixis-attach(
  pins: (
    cat-top-left: (dx: 40%, dy: 35%),
    cat-bottom-right: (dx: 62%, dy: 63%),
  )
)[
  #image("assets/loading-cat.jpg", width: 80%)
])

#deixis-region-mark(
  id: <cat>,
  pins: ("cat-top-left", "cat-bottom-right"),
  marker-style: (mark: it => text(fill: white, super(it))),
  marker-position: top + center,
  stroke: red,
  fill: red.transparentize(90%),
)
#deixis-footnote-body(
  id: <cat>,
)[A loading cat.]
````

</details>

<details>
<summary><b>Show Typst Source Code for Sigmoid</b></summary>

````typst
The Sigmoid function
#deixis-region-mark(
  stroke: yellow,
  fill: yellow.transparentize(95%),
  inline: true,
  layer: "background",
)[$sigma(dot)$]
maps any value into a probability in $[0, 1]$:

#align(center,  // wrapped equations cannot auto align center
  deixis-region-mark(
  stroke: blue,
  fill: blue.transparentize(95%),
  padding: "text",
  layer: "background",
)[
$ sigma(z) = frac(1, 1 + #deixis-pin("e-left")e#deixis-pin("e-right")^(-#deixis-pin("z-left")z#deixis-pin("z-right"))) $
])
#deixis-set(
  body-style: it => text(size: 0.6em, it),
  side-strategy: "strict",
  container-func: (margin-note: rect),
)
#deixis-inset-note(
  pins: ("z-left", "z-right"),
  marker-style: it => text(fill: green, super(it)),
  stroke: (rest: green, link: stroke(paint: green, thickness: 0.5pt, dash: "dashed")),
  fill: green.transparentize(95%),
  link: "curve",
  link-ports: (body: bottom),
  link-marks: "body",
  dx: 1em,
  dy: -2em,
)[
  $z$: input value (the "logit").
]
#deixis-inset-note(
  pins: ("e-left", "e-right"),
  marker-style: it => text(fill: red, super(it)),
  stroke: (rest: red, link: stroke(paint: red, thickness: 0.5pt, dash: "dashed")),
  fill: red.transparentize(95%),
  link: "curve",
  link-ports: (mark: bottom, body: left),
  link-marks: "body",
  dx: 2em,
  dy: 2em,
)[
  $e$: Euler's constant.
]
Python code:

#deixis-set-pin-pattern(
  prefix: "deixispin",
  postfix: "deixis",
)
#deixis-attach(
```python
z = np.array([-np.inf, -1.5, 0, 1.5, np.inf])
# this computes 1 / (1 + exp(-z))
probability = deixispine0deixisexpitdeixispine1deixis(z)
print(f"Logit:\n{z}")
print(f"Probability:\n{probability}")
```
)
#deixis-footnote(
  pins: ("e0", "e1"),
  marker-style: it => text(fill: teal, super(it)),
  stroke: teal,
  fill: teal.transparentize(95%),
)[```python from scipy.special import expit```]
````

</details>


### Routing Links

`deixis` provides margin note and inset note with a simple `link` drawing mechanism.
You can use `link-waypoints`, `link-ports`, and `link-marks` to configure the link.

<div align="center">
<img src="https://raw.githubusercontent.com/inspiros/typst-deixis/v0.1.0/assets/gallery/link-1.svg" width="500px" alt="Routing link example">
</div>

<details>
<summary><b>Show Typst Source Code</b></summary>

````typst
#deixis-margin-note(
  stroke: blue + 0.5pt,
  fill: blue.transparentize(95%),
  link: "curve",
  link-waypoints: (
    (0pt, 20pt),
    (50pt, 40pt),
    (50pt, -50pt),
    "right-angle",  // change link type
    (60pt, 40pt),
    "straight-line",
  ),
  link-marks: "body",
  container-func: rect,
)[][
  Waypoints allow creating complicated links.
]
#deixis-margin-note(
  inline-mode: "highlight",
  stroke: red + 0.5pt,
  fill: red.transparentize(95%),
  link: "chamfer",
  container-func: rect,
)[
  Margin links always exit up or down.
][
  *Fact:* The default margin links just follow auto-generated waypoints.
]

#v(70pt)
#deixis-inset-note(
  inline-mode: "highlight",
  width: 120pt,
  stroke: stroke(paint: green, dash: "densely-dotted"),
  fill: green.transparentize(95%),
  link: "ccr",
  link-waypoints: (
    // component anchor + alignment keywords
    (80pt, "mark-right"),
    (0pt, "body-right"),
  ),
  link-ports: (mark: right, body: right),
  link-marks: "both",
  layer: "flow",
)[
  Inset links give inline marks 3 link ports:\
  `right, top, bottom`.
][
  Inset notes (and region marks) have 4 link ports:\
  `left, right, top, bottom`.
]
````

</details>

---

### Update Default Parameters

Most of the parameters of a note function can be updated using `#deixis-set`.
In fact, some parameters can only be updated this way.

To update note-specific or component-specific parameters, pass a dictionary with the following keywords:
- **Note/mark type-scope keywords:**
  - `inline-mark`
  - `phantom-mark`
  - `region-mark`
  - `inline-note`
  - `footnote`
  - `endnote`
  - `margin-note`: _(applies to both `#deixis-margin-note` and `#deixis-sidenote`)_
  - `inset-note`
  - `rest`: applies to the rest
- **Component-scope keywords:**
  - `mark`
  - `body`
  - `link`
  - `nodes`: applies to mark and body
  - `rest`: applies to the rest

It is possible to nest note-scope and component-scope keywords, but not to mix them in the same dictionary.

<div align="center">
<img src="https://raw.githubusercontent.com/inspiros/typst-deixis/v0.1.0/assets/gallery/update-params-1.svg" width="500px" alt="Update parameters example">
</div>

<details>
<summary><b>Show Typst Source Code</b></summary>

````typst
#deixis-set(container-func: (margin-note: rect))

Update default parameters with ```typst #deixis-set```:
#deixis-margin-note[A simple margin note.]
- ```typc stroke: green```
  #deixis-set(stroke: green)
  #deixis-margin-note[This affects all subsequent notes.]
- ```typc stroke: (margin-note: blue)```
  #deixis-set(stroke: (margin-note: blue))
  #deixis-margin-note[This affects only margin notes.]
- ```typc stroke: (body: teal)```
  #deixis-set(stroke: (body: teal))
  #deixis-margin-note[][This affects all notes' bodies.]
- ```typc stroke: (margin-note: (body: maroon))```
  #deixis-set(stroke: (margin-note: (body: maroon)))
  #deixis-margin-note[][This affects only margin notes' bodies.]
````

</details>

### Cross-reference and Backlink

<div align="center">
<img src="https://raw.githubusercontent.com/inspiros/typst-deixis/v0.1.0/assets/gallery/cross-ref-1.svg" width="500px" alt="Cross-reference and backlink example">
</div>

<details>
<summary><b>Show Typst Source Code</b></summary>

````typst
Test notes:
#deixis-footnote(
  label: <note-1>,
  backlink: true,
  marker-style: (mark: it => text(fill: red, super(it))),
)[Note 1.]
#deixis-footnote(
  label: <note-2>,
  backlink: "always",  // equivalent to true
  marker-style: (mark: it => text(fill: blue, super(it))),
)[Note 2.]
#deixis-footnote(
  label: <note-3>,
  backlink: "none",  // equivalent to false
)[Note 3.]
#deixis-footnote(
  label: <note-4>,
  backlink: "multiple",  // only if they are ref-ed at least once
)[Note 4.]

*Cross-reference features supported by `deixis`:*
#grid(
  align: left,
  columns: (3fr, 1fr),
  row-gutter: 0.8em,
  stroke: none,
  [Ref using ```typst @label```], [#deixis-ref(<note-1>)],
  [Ref using ```typst #deixis-ref(<label>)```], [#deixis-ref(<note-1>, <note-2>)],
  [Ref with supplement], [@note-1[Note]],
  [Ref 3 or more consecutive notes], [#deixis-ref(<note-1>, <note-2>, <note-3>)],
  [Ref 2 or 3+ non-consecutive notes], [#deixis-ref(<note-1>, <note-2>, <note-4>)]
)
````

</details>

### Counter and Series

Each note belongs to a counter series.
All `deixis` notes default to the `"default"` series except for `#deixis-endnote` which default to the `"endnote"` series.

<div align="center">
<img src="https://raw.githubusercontent.com/inspiros/typst-deixis/v0.1.0/assets/gallery/counter-1.svg" width="500px" alt="Counter and series example">
</div>

<details>
<summary><b>Show Typst Source Code</b></summary>

````typst
#let todo = deixis-margin-note.with(
  series: "todo",
  stroke: red,
  fill: red.transparentize(95%),
  link: "right-angle",
  container-func: rect,
)
#let first-author = deixis-margin-note.with(
  series: "comm",
  stroke: blue,
  fill: blue.transparentize(95%),
  link: "right-angle",
  container-func: rect,
)
#let second-author = deixis-margin-note.with(
  series: "comm",
  stroke: teal,
  fill: teal.transparentize(95%),
  link: "right-angle",
  container-func: rect,
)
#let remark = deixis-margin-note.with(
  marker: "",
  series: "remark",
  stroke: maroon,
  fill: maroon.transparentize(95%),
  link: "right-angle",
  container-func: rect,
)

#lorem(3)
#todo[Rewrite this sentence.]
#lorem(3)
#first-author[Good point.]
#lorem(2)
#deixis-update-note-counter(0, series: "todo")
#todo[```typc "todo"``` restarts from 1 again.].

#lorem(7)
#second-author[But ```typc "comm"``` is unaffected.]
#lorem(2)
#deixis-update-note-counter(0)  // no effect
#first-author[][This keeps counting up.]
#second-author[][Use an empty mark `[]` to avoid overlapping highlight box.]
#lorem(10)
#remark[*Remark:* ```typst #deixis-update-note-counter``` defaults to the ```typc "default"``` series!]

Counter: \
```typc "default"```: #context deixis-note-counter(series: "default") \
```typc "todo"```: #context deixis-note-counter(series: "todo") \
```typc "comm"```:  #context deixis-note-counter(series: "comm")
````

</details>

### Note Outline

<div align="center">
<img src="https://raw.githubusercontent.com/inspiros/typst-deixis/v0.1.0/assets/gallery/note-outline-1.svg" width="500px" alt="Note outline example">
</div>

<details>
<summary><b>Show Typst Source Code</b></summary>

````typst
#deixis-inline-mark(
  id: <celibate>,  // linked to no note body
)[A celibate marked text]
#deixis-footnote(
  stroke: gray,
)[A footnote.]
#deixis-endnote(
  stroke: green,
  fill: green.transparentize(95%),
  numbering: "i",
)[An endnote.]
#deixis-margin-note(
  stroke: orange,
  fill: orange.transparentize(95%),
  container-func: rect,
)[A margin note.]
#deixis-inset-note(
  stroke: blue,
  fill: blue.transparentize(95%),
  placement: body => deixis-absolute-place(top + left, dx: 5pt, dy: 5pt, body),
)[An inset note.]

#deixis-note-outline(
  fill: repeat[.],
  include-celibates: "mark",
)
````

</details>

---

### Minipage

Minipages (basically just _glorified_ blocks) serve as an environment to sandbox notes.
They maintains their own counter system (but can be synced with the page or together), default note parameters, and can be nested.

Since `deixis` notes are decoupled and each component can target different minipages, the rules are:
- The mark dictates the counter (numbering).
- The body dictates the rendering context of the body.

<div align="center">
<img src="https://raw.githubusercontent.com/inspiros/typst-deixis/v0.1.0/assets/gallery/minipage-1.svg" width="500px" alt="Minipage example">
</div>

<details>
<summary><b>Show Typst Source Code</b></summary>

````typst
#import "../src/lib.typ": *
#show: deixis-setup-notes
#show raw: set text(size: 0.85em)

Notice the numbers#deixis-footnote[A page-level footnote.].
#deixis-block(
  id: <gray-block>,
  fill: gray.lighten(80%),
  inset: (right: 2cm, rest: 5pt),
)[
  Minipages are very handy for creating locally rendered notes
  #deixis-footnote[A block-level footnote.]
  #deixis-margin-note[A block-level margin note.].
]

#deixis-block(
  sync-counters-with: <gray-block>,
  fill: green.lighten(80%),
  inset: 5pt,
)[
  Moreover, they can maintain a separate counter system, or sync with each other #deixis-footnote[This block shares the counters with ```typst <gray-block>.```].
]
````

</details>

## Acknowledgements

This package has some similar functionalities inspired by existing packages:
- [drafting](https://github.com/ntjess/typst-drafting): Inline mark, inline note, and margin note, without numbering.
- [marge](https://github.com/EpicEricEE/typst-marge): Margin note, without links.
- [pinit](https://github.com/OrangeX4/typst-pinit): Equivalent to region mark and inset note, without numbering.
- [Rik's endnote](https://forum.typst.app/t/an-endnotes-implementation-with-headings-and-cross-referencing/7760): An early attempt to implement endnote.

## License

MIT licensed, see [LICENSE](LICENSE).

[manual]: https://github.com/inspiros/typst-deixis/blob/v0.1.0/docs/manual.pdf
