// Example deck of the touying-ufac-unofficial theme: the elements of the syntax at a glance (details: package README).
#import "@preview/touying:0.7.4": *
#import "@preview/touying-ufac-unofficial:0.1.0": *

#show: ufac-theme.with(
  aspect-ratio: "16-9",
  lang: "en",                         // "pt-br" (default), "en" or "es": text language and pill/section names
  // exercise-name: [Exercise], example-name: [Example], part-name: [Part],   // override the localized names
  config-info(
    title: [Title of the teaching unit],
    subtitle: [Teaching unit I],
    author: [Prof. Dr. Your Name],
    subject: [Subject name],
    subject-code: [CODE or Department],
    counter-prefix: [1.],
  ),
)

#title-slide()

= Name of the first section
// Content right after `=` goes to the right of the section slide, flush with the page edge (usually an image):
// #image("figure.png")

== Slide title
=== Subtitle (repeated after `---`)

Text with *bold*, _italic_, ~~blue emphasis~~, ==yellow highlight== and ~underline~.

-> Item with an arrow
-> Another item

- Item
  - Sub-item
    - Sub-sub-item

> == Definition
> Box with a title (same as `#emph-box(title: [Definition])[...]`).

---

> Box without title

"A quotation in a box."


$ 
x -3x + 2 = 0 
$

Equation box:

> $
x = {2, 1}
$

---

"A list of quotation box"
"Another item"
"Another item \
with 2 lines"
"Another item"
"Another item"


#cols(divider: true)[
  Column with blue divider
][
  Column 2
]

#v(3em)

#cols[Col without divider][Column 2]

== An exercise <exercise-a>

Statement. (Also `#exercise-slide(title: [Title])[...]`.)

== An example <example>

Citing the @exercise-a.
