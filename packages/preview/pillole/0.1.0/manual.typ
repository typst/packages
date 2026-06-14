#import "lib.typ": pill
#import "@preview/tidy:0.4.1"

#show link: underline

#align(center)[
  #text(size: 24pt, weight: "bold")[Pillole] \
  #v(0.5em)
  _A Typst package for creating compact, breakable, multi-line bi-colored pills._
]

= Inspiration

The idea for this package came from the #link("https://docs.gitlab.com/user/project/labels/#scoped-labels")[scoped labels in GitLab's UI],
which are a common pattern in software development and project management tools.
I wanted to create a similar style of label in Typst
that could be easily customized and would flow well with text.

= Usage

Import the package and call `pill`, the only exported function:

#[
  #show raw.where(block: true): it => block(
    fill: rgb("#f6f8fa"),
    stroke: 0.5pt + luma(220),
    inset: 10pt,
    radius: 3pt,
    width: 100%,
    it,
  )

  ```typ
  #import "@preview/Pillole:0.1.0": pill

  A #pill("priority")[critical] item should be done first.

  You can also pass the value as a trailing block: #pill("env")[prod].

  Change the colors via the `primary` and `secondary` arguments:
  #pill("status", primary: rgb("#386641"))[ready].
  Pick a fully-rounded shape: #pill("tag", radius: 100%)[round].
  ```
]

Renders as:

#block(stroke: 0.5pt + silver, inset: 10pt, radius: 3pt)[
  A #pill("priority")[critical] item should be done first.

  You can also pass the value as a trailing block: #pill("env")[prod].

  Change the colors via the `primary` and `secondary` arguments:
  #pill("status", primary: rgb("#386641"))[ready].
  Pick a fully-rounded shape: #pill("tag", radius: 100%)[round].
]

Also works with mixed scripts and scales correctly with text size: \
#text(8pt)[#pill("env")[text текст テキスト]] \
#text(13pt)[#pill("env")[text текст テキスト]] \
#text(20pt)[#pill("env")[text текст テキスト]].

#pill("Pills are breakable")[
  This is a long pill that will break across lines if needed, with the
  middle section breaking naturally and the caps staying with their text.
  Cool, right?
]

= Known issues

1. #pill("Sometimes", "the right side will go to a new line, breaking in the wrong spot! An example of that.", radius: 100%) \
  The left or right cap (the rounded ends of the pill)
  can be left hanging when a pill breaks at an unfortunate point.
  This is a tricky one to solve, and if someone has a simple solution,
  they are encouraged to contribute.
  I have tried various approaches, including `sym.space.nobreak.narrow`, to no avail:
  the cap still breaks to a new line (and adds a tiny bit of extra space)
  instead of staying with its text.
2. #pill(sym.arrow.l + "Left side is closer to edge", "than right side" + sym.arrow.r, radius: 100%) \
  The spacing between the first cap and the text is slightly smaller than
  between the text and the last cap.
  This is because the text is shifted to the left into the left cap,
  but the opposite cannot be done for the right cap without using `measure` or `place`:
  moving the right cap closer to the text would overlap and hide it.
  As far as I know, using `place` would work but would break the pill's natural flow and ability to break across lines for the right side.
  The effect is more noticeable at larger radii.
  Contributions for a simple fix are very welcome!
3. #pill(sym.arrow.l + "not vertically centered", "more space below " + sym.arrow.b)\ 
  In lists, the pill's height can cause extra spacing between text rows
  (as you can see in this numbered list), and the pill itself is not centered
  vertically in the line.
4. #pill("mixing", [plain text and #raw("raw") leaves gaps]) \
  Mixing different inline element types (regular text, `raw`, `math`, etc.)
  inside a pill's value can leave visible gaps in the fill.
  This is because the pill body uses Typst's `highlight()`,
  which does not span seamlessly across heterogeneous text runs.
  Plain `content` and `string` values render correctly;
  only mixed-type content shows the artifact.

#pagebreak()

= API Reference

// Tidy parses the `///` doc-comments from lib.typ and renders the API.
// `scope: (pill: pill)` makes `pill` available to the inline `example` blocks
// in those doc-comments.
#let module-docs = tidy.parse-module(
  read("lib.typ"),
  name: "Pillole",
  scope: (pill: pill),
)
#tidy.show-module(
  module-docs,
  style: tidy.styles.default,
  show-module-name: false,
)
