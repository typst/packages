#import "@preview/navigator:0.1.2": render-transition, progressive-outline

#set page(paper: "a4", margin: 1.5cm)
#set text(font: "Lato", size: 10pt)
#set heading(numbering: "1.1")

#let navy = rgb("#1a5fb4")

// --- MOCK DATA FOR DEMONSTRATION ---
#let mock-slide-func(fill: navy, body) = block(
  width: 100%,
  height: 120pt,
  fill: if fill == none { luma(40) } else { fill.darken(50%) },
  stroke: 0.5pt + if fill == none { black } else { fill },
  inset: 10pt,
  radius: 4pt,
  {
    set text(fill: white)
    body
  }
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
  [`content-padding`], [length | dict], [Padding around the roadmap content. Default: `(x: 10%)`.],
  [`content-align`], [alignment], [Alignment of the roadmap content. Default: `top + left`.],
  [`content-wrapper`], [function], [A callback `(roadmap, heading, active-state) => content` to completely override the layout logic.],
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

#v(2em)

= Basic usage

#context {
  let h = query(heading.where(level: 1)).at(1) // Target "Function documentation"
  let heads = query(heading.where(level: 1).or(heading.where(level: 2))).slice(1, 6)

  demo("Default Transition",
  "render-transition(
  h,
  mapping: (section: 1, subsection: 2),
  theme-colors: (primary: navy),
  slide-func: my-slide-func,
)",
  render-transition(
    h,
    mapping: (section: 1, subsection: 2),
    theme-colors: (primary: navy),
    slide-func: mock-slide-func,
    headings: heads,
    top-padding: 20pt
  ))
}

= Layout & Positioning Control

== Padding and Alignment
Use `content-padding` and `content-align` to place the roadmap exactly where you want it.

#context {
  let h = query(heading.where(level: 1)).first()
  let heads = query(heading.where(level: 1).or(heading.where(level: 2))).slice(0, 5)

  demo("Centered Roadmap",
  "render-transition(
  h,
  top-padding: 0pt,
  content-align: center + horizon,
  content-padding: 0pt,
  slide-func: my-slide-func,
)",
  render-transition(
    h,
    mapping: (section: 1, subsection: 2),
    theme-colors: (primary: navy),
    slide-func: mock-slide-func,
    headings: heads,
    top-padding: 0pt,
    content-align: center + horizon,
    content-padding: 0pt,
  ))
}

== The Wrapper Mode (Total Control)
The `content-wrapper` parameter offers complete freedom over the slide layout. It allows you to place the roadmap alongside other elements (images, titles, decorations) or to wrap it in complex layouts.

The callback function receives three arguments:
1. `roadmap`: The progressive outline component generated by Navigator.
2. `heading`: The specific heading object that triggered this transition.
3. `active-state`: A dictionary `{ h1, h2, h3 }` containing the active hierarchy (useful to retrieve the parent Part title when entering a Section).

=== Example 1: Split Layout (Title + Roadmap)
In this example, we place the current section title on the left and the roadmap on the right. We also disable the section display in the roadmap to avoid repetition.

#context {
  let h = query(heading.where(level: 1)).at(1)
  let heads = query(heading.where(level: 1).or(heading.where(level: 2))).slice(0, 5)

  demo("Split Layout",
  "content-wrapper: (roadmap, h, active) => {
  grid(
    columns: (1fr, 1.5fr),
    align(center + horizon, 
      text(size: 1.5em, weight: 'bold', format-heading(h))
    ),
    align(left + horizon, roadmap)
  )
},
transitions: (
  sections: (visibility: (section: 'none', subsection: 'all'))
)",
  render-transition(
    h,
    mapping: (section: 1, subsection: 2),
    theme-colors: (primary: navy),
    slide-func: mock-slide-func.with(fill: none),
    headings: heads,
    transitions: (
      sections: (visibility: (section: "none", subsection: "all"))
    ),
    content-wrapper: (roadmap, heading, active-state) => {
      import "@preview/navigator:0.1.2": format-heading
      grid(
        columns: (1fr, 1.5fr),
        column-gutter: 1em,
        align(center + horizon, text(size: 1.2em, weight: "bold", fill: white, format-heading(heading))),
        align(left + horizon, roadmap)
      )
    }
  ))
}

=== Example 2: Contextual Header
Use `active-state` to display the parent heading (e.g., the Part) above the roadmap.

#context {
  let h = query(heading.where(level: 2)).at(0) // A Subsection
  let heads = query(heading.where(level: 1).or(heading.where(level: 2))).slice(0, 5)

  demo("Contextual Info",
  "content-wrapper: (roadmap, h, active) => {
  set align(left + top)
  if active.h1 != none {
    text(size: 0.8em, fill: white.transparentize(40%), smallcaps(active.h1.body))
    v(0.5em)
  }
  roadmap
}",
  render-transition(
    h,
    mapping: (section: 1, subsection: 2),
    theme-colors: (primary: navy),
    slide-func: mock-slide-func.with(fill: none),
    headings: heads,
    top-padding: 20pt,
    content-wrapper: (roadmap, heading, active) => {
      set align(left + top)
      pad(2em, {
        if active.h1 != none {
          text(size: 0.8em, fill: white.transparentize(40%), smallcaps(active.h1.body))
          v(0.5em)
        }
        roadmap
      })
    }
  ))
}

=== Example 3: Branding (Logo + Roadmap)
You can easily integrate graphical elements.

#context {
  let h = query(heading.where(level: 1)).at(0)
  let heads = query(heading.where(level: 1).or(heading.where(level: 2))).slice(0, 5)
  // Mock logo
  let logo = circle(radius: 25pt, fill: white, stroke: 5pt + white.transparentize(80%))

  demo("Branding",
  "content-wrapper: (roadmap, h, active) => {
  stack(dir: ltr, spacing: 2em,
    align(horizon, image('logo.png')),
    align(horizon, roadmap)
  )
}",
  render-transition(
    h,
    mapping: (section: 1, subsection: 2),
    theme-colors: (primary: navy),
    slide-func: mock-slide-func.with(fill: none),
    headings: heads,
    content-wrapper: (roadmap, heading, active) => {
      align(center + horizon, stack(dir: ltr, spacing: 2em,
        align(horizon, logo),
        align(horizon, roadmap)
      ))
    }
  ))
}

#v(2em)

= Advanced Customization

== Selective visibility
You can configure different roadmap layouts for sections and subsections.

#context {
  let h = query(heading.where(level: 2)).first()
  let heads = query(heading.where(level: 1).or(heading.where(level: 2))).slice(0, 5)

  demo("Subsection roadmap",
  "transitions: (
  subsections: (
    visibility: (
      section: 'current', 
      subsection: 'current-parent'
    )
  )
)",
  render-transition(
    h,
    mapping: (section: 1, subsection: 2),
    theme-colors: (primary: navy),
    slide-func: mock-slide-func,
    headings: heads,
    top-padding: 20pt,
    transitions: (
      subsections: (visibility: (section: "current", subsection: "current-parent"))
    )
  ))
}
