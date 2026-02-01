#import "../lib.typ": render-transition

#set page(paper: "a4", margin: 1.5cm)
#set text(font: "Lato", size: 10pt)
#set heading(numbering: "1.1")

#let navy = rgb("#1a5fb4")

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
  #text(size: 26pt, weight: "bold", fill: navy)[Guide: Transition Engine] \ 
]
#v(2em)

= Introduction
The `render-transition` function is designed to automatically generate "roadmap" or "summary" slides when the document structure changes (e.g., entering a new section). It is typically invoked within a `show heading` rule.

= Function documentation
`render-transition(h, transitions: (:), mapping: (:), ...)`

== Parameters Reference

#table(
  columns: (1.5fr, 1fr, 3fr),
  inset: 8pt,
  align: horizon,
  fill: (x, y) => if y == 0 { navy.lighten(90%) },
  table.header([*Option*], [*Type*], [*Description*]),
  [`h`], [heading], [*Mandatory*. The heading object intercepted by the show rule.],
  [`slide-func`], [function], [*Mandatory*. A callback `(fill: color, body: content) => content` used to create the slide. It should wrap the presentation engine's slide function (e.g., `polylux.slide`).],
  [`transitions`], [dict], [Detailed configuration for the transition engine (see below).],
  [`mapping`], [dict], [Maps heading levels to roles. Example: `(section: 1, subsection: 2)`.],
  [`theme-colors`], [dict], [Dictionary containing `primary` and `accent` colors used for the transition slide style.],
  [`show-heading-numbering`], [bool], [Whether to display heading numbers in the roadmap. Default: `true`.],
  [`numbering-format`], [string | auto], [Typst numbering format string. If `auto`, uses the document's global heading numbering. Default: `auto`.],
  [`base-text-size`], [length | auto], [Base font size for the roadmap text. Default: `auto`.],
  [`base-text-font`], [string | auto], [Font family for the roadmap text. Default: `auto`.],
  [`top-padding`], [relative | length], [Vertical spacing added above the roadmap on the transition slide. Default: `40%`.],
)

== The `transitions` dictionary
This parameter allows fine-tuning the behavior and appearance of transition slides.

#table(
  columns: (1fr, 1fr, 3fr),
  inset: 8pt,
  fill: (x, y) => if y == 0 { luma(240) },
  table.header([*Key*], [*Type*], [*Description*]),
  [`enabled`], [bool], [Global switch for transitions. Default: `true`.],
  [`max-level`], [int], [The maximum heading level that triggers a transition. Default: `3`.],
  [`background`], [color | string], [Background type: `"theme"` (uses `primary` color), `"none"`, or an explicit color.],
  [`filter`], [function], [A callback `(heading) => bool` to programmatically enable/disable transitions for specific headings.],
  [`style`], [dict], [Controls typography: `inactive-opacity` (default `0.3`), `completed-opacity` (default `0.6`), `active-weight` (default `"bold"`).],
  [`sections`], [dict], [Override for section-level transitions. Contains `enabled`, `visibility` (dict), and `background`.],
  [`subsections`], [dict], [Override for subsection-level transitions. Contains `enabled`, `visibility` (dict), and `background`.],
)

=== Visibility Logic
For each transition role (`parts`, `sections`, `subsections`), you can define which hierarchy levels are visible using the `visibility` key:
- `"all"`: Show all headings at this level.
- `"current"`: Only show the active heading at this level.
- `"current-parent"`: Show siblings of the active heading.
- `"none"`: Hide this level.

= Basic Usage

In a typical presentation, you would set up the transition logic like this:

```typ
#import "@preview/navigator:0.1.1": render-transition

// 1. Define a wrapper for your slide engine
#let my-slide-func(fill: white, body) = {
  set page(fill: fill)
  polylux-slide(body)
}

// 2. Apply the transition engine via a show rule
#show heading: h => {
  if h.level > 2 { return h } // Only levels 1 and 2
  
  render-transition(
    h,
    mapping: (section: 1, subsection: 2),
    theme-colors: (primary: blue, accent: orange),
    slide-func: my-slide-func,
  )
}
```

= Advanced Customization

== Filtering transitions
You can prevent specific headings from triggering a transition slide using the `filter` parameter.

```typ
#show heading: h => render-transition(
  h,
  ...,
  transitions: (
    // Only headings containing "Part" will trigger a transition
    filter: h => h.body.text.contains("Part")
  )
)
```

== Selective visibility
You can configure different roadmap layouts for sections and subsections.

```typ
#show heading: h => render-transition(
  h,
  ...,
  transitions: (
    // Sections show the full plan
    sections: (visibility: (section: "all", subsection: "none")),
    // Subsections show only the current section and its children
    subsections: (visibility: (section: "current", subsection: "current-parent")),
  )
)
```
