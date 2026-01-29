#import "../lib.typ": render-miniframes

#set page(paper: "a4", margin: 1.5cm)
#set text(font: "Lato", size: 10pt)
#set heading(numbering: "1.1")

#let navy = rgb("#1a5fb4")

// --- MOCK DATA FOR DEMONSTRATION ---
#let mock-structure = (
  (
    title: [Introduction],
    loc: none,
    subsections: (
      (title: [Context], loc: none, slides: ((number: 1, loc: none), (number: 2, loc: none))),
      (title: [Goals], loc: none, slides: ((number: 3, loc: none),)),
    )
  ),
  (
    title: [Methodology],
    loc: none,
    subsections: (
      (title: [Data], loc: none, slides: ((number: 4, loc: none), (number: 5, loc: none), (number: 6, loc: none))),
      (title: [Tools], loc: none, slides: ((number: 7, loc: none),)),
    )
  ),
  (
    title: [Results],
    loc: none,
    subsections: (
      (title: none, loc: none, slides: ((number: 8, loc: none), (number: 9, loc: none))),
    )
  )
)

// --- DEMONSTRATION COMPONENT ---
#let demo(title, code-str, result) = block(width: 100%, breakable: false)[
  #grid(
    columns: (1fr, 1.5fr),
    column-gutter: 1.5em,
    block(fill: luma(248), inset: 10pt, radius: 4pt, width: 100%,
      text(size: 7pt, font: "DejaVu Sans Mono", code-str)),
    block(stroke: 0.5pt + gray, inset: 0pt, radius: 4pt, width: 100%, clip: true, [
      #block(fill: luma(240), width: 100%, inset: 5pt, text(weight: "bold", size: 9pt, fill: navy, title))
      #result
    ])
  )
  #v(1.5em)
]

#align(center)[
  #text(size: 26pt, weight: "bold", fill: navy)[Guide: Miniframes Navigation] \ 
]
#v(2em)

= Function documentation
The `render-miniframes` function generates a navigation bar showing the progress through sections and subsections using "miniframes" (dots or squares).

== Parameters Reference

#table(
  columns: (1.5fr, 1fr, 3fr),
  inset: 8pt,
  align: horizon,
  fill: (x, y) => if y == 0 { navy.lighten(90%) },
  table.header([*Option*], [*Type*], [*Effect & Expected Values*]),
  [`structure`], [array], [*Mandatory*. The presentation structure typically obtained via `get-structure()`.],
  [`current-slide-num`], [int], [*Mandatory*. The index of the active slide typically obtained via `get-current-logical-slide-number()`.],
  [`style`], [string], [Layout mode: `"compact"` (all dots on one line) or `"grid"` (one line per subsection/subsubsection). Default: `"grid"`.],
  [`marker-shape`], [string], [`"circle"` (default) or `"square"`.],
  [`marker-size`], [length], [Diameter/width of the markers. Default: `4pt`.],
  [`active-color`], [color], [Color of the current slide's marker. Default: `white`.],
  [`inactive-color`], [color], [Color of future slides' markers. Default: `gray`.],
  [`fill`], [color], [Background color of the navigation bar block. Default: `black`.],
  [`text-color`], [color], [Color of the section/subsection titles. Default: `white`.],
  [`text-size`], [length], [Size of the titles. Default: `10pt`.],
  [`font`], [string | none], [Font family for titles. Uses document default if `none`.],
  [`align-mode`], [string], [Global horizontal alignment of the block: `"left"`, `"center"`, `"right"`.],
  [`dots-align`], [string], [Alignment of the dots *within* their section column: `"left"`, `"center"`, `"right"`.],
  [`navigation-pos`], [string], [Vertical position of dots relative to titles: `"top"` (dots above) or `"bottom"` (dots below). Default: `"bottom"`.],
  [`show-level1-titles`], [bool], [Whether to display the names of sections.],
  [`show-level2-titles`], [bool], [In grid mode, whether to display subsection names.],
  [`show-numbering`], [bool], [Whether to display heading numbers. Default: `false`.],
  [`numbering-format`], [string], [Typst numbering format string (e.g., `"1.1"`). Default: `"1.1"`.],
  [`gap`], [length], [Horizontal space between sections. Default: `1.5em`.],
  [`line-spacing`], [length], [Vertical space between titles and dots. Default: `4pt`.],
  [`inset`], [dict | length], [Internal padding of the bar block. Default: `(x: 1em, y: 0.5em)`.],
  [`radius`], [length | dict], [Corner rounding of the background block. Can be a single length for all corners, or a dictionary (e.g., `(top: 5pt)`) for specific corners. Default: `0pt`.],
  [`width`], [length], [Total width of the block. Default: `100%`.],
  [`outset-x`], [length], [Horizontal bleed. Useful to make the bar touch page edges.],
)

== Structure Extraction

To work, the navigation bar needs to know the presentation structure. Two functions are provided to extract this data from metadata markers.

=== `get-structure`
`get-structure(slide-selector: auto, filter-selector: none)` \
Scans the document for headings and slide markers. Returns a structure dictionary.

=== `get-current-logical-slide-number`
`get-current-logical-slide-number(slide-selector: auto, filter-selector: none)` \
Determines the index of the current slide relative to the extracted structure.

=== Selection Parameters

#table(
  columns: (1.5fr, 1fr, 3fr),
  inset: 8pt,
  align: horizon,
  fill: (x, y) => if y == 0 { navy.lighten(90%) },
  table.header([*Option*], [*Type*], [*Description*]),
  [`slide-selector`], [selector | auto], [The metadata type used to identify slides. Default is `(t: "LogicalSlide")`. Useful for custom engines (e.g., Polylux).],
  [`filter-selector`], [selector | none], [If provided, only pages containing this selector will be counted. Useful to exclude transition slides that might share the same slide metadata.],
)

== Function Signature
`render-miniframes(structure, current-slide-num, ...)`

=== The `structure` object
The `structure` argument is an array of section dictionaries. Each section has the following schema:

- *Section*: `(title: content, loc: location, subsections: array)`
- *Subsection*: `(title: content, loc: location, slides: array)` OR `(title: content, loc: location, subsections: array)` (if 3 levels are used).
- *Slide*: `(number: integer, loc: location)`

==== What is `loc`?
The `loc` field expects a Typst *location* object. 
- *Purpose*: It defines the destination for navigation links. If a valid location is provided, clicking on the section title or the dot will take the user to that specific position in the PDF.
- *Disabling links*: If set to `none`, the element will be displayed normally but will not be clickable. This is used in the mock data of this guide.

=== The `current-slide-num` argument
An integer representing the current slide number. The function compares this value with the `number` field of each slide in the structure to determine its state:
- *Active*: `slide.number == current-slide-num`
- *Completed*: `slide.number < current-slide-num`
- *Future*: `slide.number > current-slide-num`

#v(2em)

= Basic usage
By default, the navigation bar uses the `"grid"` style and shows section titles.

#demo("Default Grid Style",
"render-miniframes(structure, 4)",
render-miniframes(mock-structure, 4, fill: navy))

= Layout Styles

== Compact Mode
In `"compact"` mode, all slide markers of a section are grouped on a single line, regardless of subsections. This is useful for saving space in the header or footer.

#demo("Compact Mode",
"render-miniframes(
  structure, 4, 
  style: 'compact'
)",
render-miniframes(mock-structure, 4, style: "compact", fill: navy))

== Grid Mode
The `"grid"` style is ideal for presentations with many subsections, as it aligns them vertically.

#demo("Grid Mode with Titles",
"render-miniframes(
  structure, 4, 
  style: 'grid',
  show-level2-titles: true
)",
render-miniframes(mock-structure, 4, style: "grid", show-level2-titles: true, fill: navy))

== Hiding Titles
You can hide titles at different levels to obtain a minimalist bar.

#demo("Hiding Subsection Titles (Grid)",
"render-miniframes(
  structure, 4, 
  style: 'grid',
  show-level2-titles: false
)",
render-miniframes(mock-structure, 4, style: "grid", show-level2-titles: false, fill: navy))

#demo("Hiding Section Titles (Dots Only)",
"render-miniframes(
  structure, 4, 
  show-level1-titles: false
)",
render-miniframes(mock-structure, 4, show-level1-titles: false, fill: navy))

= Customization

== Markers
Change the shape and size of the progress indicators.

#demo("Square Markers",
"render-miniframes(
  structure, 4, 
  marker-shape: 'square',
  marker-size: 6pt
)",
render-miniframes(mock-structure, 4, marker-shape: "square", marker-size: 6pt, fill: navy))

== Colors & Typography
Fine-tune the appearance of markers and labels.

#demo("Colors & Fonts",
"render-miniframes(
  structure, 4, 
  active-color: yellow,
  inactive-color: gray,
  text-color: luma(200),
  text-size: 8pt,
  fill: rgb('#2d3436')
)",
render-miniframes(mock-structure, 4, active-color: yellow, inactive-color: gray, text-color: luma(200), text-size: 8pt, fill: rgb("#2d3436")))

== Alignment & Spacing
Control the rhythm and positioning of the navigation elements.

#demo("Centered & Airy",
"render-miniframes(
  structure, 4, 
  align-mode: 'center',
  dots-align: 'center',
  gap: 3em,
  line-spacing: 8pt
)",
render-miniframes(mock-structure, 4, align-mode: "center", dots-align: "center", gap: 3em, line-spacing: 8pt, fill: navy))

== Advanced Layout
Use `inset` and `width` to integrate the bar into specific layout zones.

#demo("Compact Centered Bar",
"render-miniframes(
  structure, 4, 
  width: 60%,
  align-mode: 'center',
  inset: 15pt,
  show-level1-titles: false
)",
render-miniframes(mock-structure, 4, width: 60%, align-mode: "center", inset: 15pt, show-level1-titles: false, fill: navy))

#demo("Rounded Corners",
"render-miniframes(
  structure, 4, 
  radius: 10pt,
  fill: rgb('#34495e'),
  inset: (x: 2em, y: 1em)
)",
render-miniframes(mock-structure, 4, radius: 10pt, fill: rgb("#34495e"), inset: (x: 2em, y: 1em)))
