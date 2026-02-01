#import "../lib.typ": progressive-outline

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
    block(stroke: 0.5pt + gray, inset: 10pt, radius: 4pt, width: 100%, [
      #text(weight: "bold", fill: navy, title)
      #v(0.5em)
      #result
    ])
  )
  #v(1.5em)
]

#align(center)[
  #text(size: 26pt, weight: "bold", fill: navy)[Guide: Progressive Outline] \ 
]
#v(2em)

= Function documentation
This section details all the parameters available for the `progressive-outline` function.

#table(
  columns: (1.5fr, 1fr, 3fr),
  inset: 8pt,
  align: horizon,
  fill: (x, y) => if y == 0 { navy.lighten(90%) },
  table.header([*Option*], [*Type*], [*Effect & Expected Values*]),
  [`level-X-mode`], [string], [Defines the visibility of level X (1, 2, or 3). \ Values: `"all"`, `"current"`, `"current-parent"`, `"none"`.],
  [`layout`], [string], [Switch between `"vertical"` (default) and `"horizontal"` rendering.],
  [`separator`], [content | str], [Separator displayed between items in horizontal layout. Ignored in vertical mode.],
  [`text-styles`], [dict], [Styles passed to `#text` (fill, weight, etc.). You can also use a float (e.g., `0.5`) as a shortcut to inherit the active style with that opacity.],
  [`spacing`], [dict], [Controls vertical space (`v-between-X-Y`), horizontal indentation (`indent-X`) and horizontal gap (`h-spacing`).],
  [`show-numbering`], [bool], [Enables or disables the display of heading numbering.],
  [`numbering-format`], [str | func | auto], [Typst numbering format (e.g., `"1.1"`) or custom function. If `auto`, respects global heading settings. Default: `auto`.],
  [`match-page-only`], [bool], [If true, considers a heading active if it is on the same page, regardless of its Y position. Useful for sidebars.],
  [`filter`], [func], [A callback function `(heading) => bool` to programmatically include or exclude headings.],
  [`marker`], [content | dict | func], [Content displayed before the item. Can be static, a dict by state, or a function `(state, level) => content`.],
  [`clickable`], [bool], [Enables clickable links on headings. Defaults to `true`.],
)

#v(2em)

= Layout Modes
`progressive-outline` supports two main layout modes: `"vertical"` (the default, based on a grid) and `"horizontal"` (based on a stack).

== Vertical Layout
This is the default mode, optimized for sidebars and roadmap slides. It supports complex indentation and vertical spacing between different levels.

== Horizontal Layout
The horizontal mode is ideal for headers, footers, and breadcrumbs. Elements are placed side-by-side and can be separated by custom content.

#demo("Horizontal Breadcrumb",
"progressive-outline(
  layout: 'horizontal',
  level-1-mode: 'current',
  level-2-mode: 'current',
  separator: ' > ',
  show-numbering: true
)",
progressive-outline(layout: "horizontal", level-1-mode: "current", level-2-mode: "current", separator: " > ", show-numbering: true))

#demo("Horizontal Navigation Bar",
"progressive-outline(
  layout: 'horizontal',
  level-1-mode: 'all',
  level-2-mode: 'none',
  separator: [ | ],
  spacing: (h-spacing: 1em)
)",
progressive-outline(layout: "horizontal", level-1-mode: "all", level-2-mode: "none", separator: [ | ], spacing: (h-spacing: 1em)))

= Navigation & Interactivity
By default, the outline is interactive: clicking on a section title navigates directly to the corresponding slide in the PDF.

#demo("Non-clickable Outline",
"progressive-outline()",
progressive-outline())

In some print-focused or strict layout scenarios, you might want to disable this interactivity.

#demo("Non-clickable Outline",
"progressive-outline(
  clickable: false
)",
progressive-outline(clickable: false, level-2-mode: "none"))

= Visibility
This section covers the `level-X-mode` parameters.

== The 'current-parent' mode
The `current-parent` mode is the most powerful: it only displays the "siblings" of the current element. This allows you to see the plan of the current section without being distracted by other chapters.

#demo("Visibility Demonstration H2",
"progressive-outline(
  level-1-mode: 'all',
  level-2-mode: 'current-parent'
)",
progressive-outline(level-1-mode: "all", level-2-mode: "current-parent"))

== Isolation via 'current' mode
If you want an ultra-minimalist rendering, the `current` mode hides everything except the exact entry where you are located.

#demo("Isolated Visibility Demonstration",
"progressive-outline(
  level-1-mode: 'current',
  level-2-mode: 'none'
)",
progressive-outline(level-1-mode: "current", level-2-mode: "none"))

== Deep nesting (Level 3)
For complex structures, you can enable Level 3. Using `current-parent` will show siblings at the current depth.

=== Deep Component A
=== Deep navigation test

#demo("Level 3 Siblings",
"progressive-outline(
  level-2-mode: 'all',
  level-3-mode: 'current-parent'
)",
progressive-outline(level-2-mode: "all", level-3-mode: "current-parent"))

= Style Customization
The function allows you to modify the appearance of headings based on their state (*completed*, *active*, or *inactive*).

== The 3-state system
By default, headings can be in one of three states:
- *completed*: The heading has already been passed.
- *active*: This is the current heading.
- *inactive*: The heading is yet to come.

#demo("Past, Present, Future",
"text-styles: (
  level-1: (
    active: (fill: eastern, weight: 'bold'),
    completed: (fill: gray.lighten(50%)),
    inactive: (fill: black)
  )
)",
progressive-outline(
  level-2-mode: "none",
  text-styles: (
    level-1: (
      active: (fill: eastern, weight: "bold"),
      completed: (fill: gray.lighten(50%)),
      inactive: (fill: black)
    )
  )
))

== Advanced Opacity & Inheritance
Instead of redefining the full style for `inactive` or `completed` states, you can use smart inheritance to adapt the `active` style.

=== The Float Shortcut (Clone & Fade)
Pass a number (0.0 to 1.0) to automatically clone the active style and apply transparency. `0.2` means 20% opacity (very faint), `1.0` means fully opaque.

#demo("Auto-Fade Shortcut",
"text-styles: (
  level-1: (
    active: (fill: red, weight: 'black'),
    inactive: 0.2,   // Future: very faint (20%)
    completed: 0.5   // Past: semi-transparent (50%)
  )
)",
progressive-outline(
  level-2-mode: "none",
  text-styles: (
    level-1: (
      active: (fill: red, weight: "black"),
      inactive: 0.2,
      completed: 0.5
    )
  )
))

=== Partial Inheritance (Mix & Match)
You can also use a dictionary with an `opacity` key. This allows you to inherit the active color (faded) while overriding other properties (like weight).

#demo("Fade + Weight Change",
"text-styles: (
  level-1: (
    active: (fill: blue, weight: 'black'),
    inactive: (
      opacity: 0.5,      // 50% of active color
      weight: 'regular'  // But force regular weight
    )
  )
)",
progressive-outline(
  level-2-mode: "none",
  text-styles: (
    level-1: (
      active: (fill: blue, weight: "black"),
      inactive: (opacity: 0.5, weight: "regular")
    )
  )
))


= Customizable Markers
You can add visual indicators (icons, arrows, etc.) before each item using the `marker` parameter.

== Static Marker
The simplest usage is to pass a single content element (like a symbol) that will be used for all items.

#demo("Static Symbol",
"progressive-outline(
  marker: sym.triangle.filled.small
)",
progressive-outline(
  level-2-mode: "none",
  marker: sym.triangle.filled.small
))

== State-based Markers (Dictionary)
You can define different markers for `active`, `inactive`, and `completed` states using a dictionary.

#demo("State Indicators",
"progressive-outline(
  marker: (
    active: sym.arrow.r,
    completed: sym.checkmark,
    inactive: sym.circle.small
  )
)",
progressive-outline(
  level-2-mode: "none",
  marker: (
    active: sym.arrow.r,
    completed: sym.checkmark,
    inactive: sym.circle.small
  )
))

== Dynamic Markers (Function)
For total control, pass a function `(state, level) => content`. This allows you to vary markers based on depth level and status.

#demo("Advanced Logic",
"progressive-outline(
  marker: (state, level) => {
    if level == 1 { sym.star.filled }
    else if state == 'active' { sym.arrow.r }
    else { sym.circle.filled.tiny }
  }
)",
progressive-outline(
  level-2-mode: "all",
  marker: (state, level) => {
    if level == 1 { sym.star.filled }
    else if state == "active" { sym.arrow.r }
    else { sym.circle.filled.tiny }
  }
))

== Marker Alignment
Use the `spacing` parameter to fine-tune layout:
- `marker-gap`: Space between marker and text (default `0.5em`).
- `marker-width`: Fixed width for the marker container (useful for alignment).

#demo("Aligned Markers",
"progressive-outline(
  marker: (active: sym.arrow.r),
  spacing: (
    marker-gap: 1em,
    marker-width: 1.5em
  )
)",
progressive-outline(
  level-2-mode: "none",
  marker: (active: sym.arrow.r),
  spacing: (marker-gap: 1em, marker-width: 1.5em)
))

= The anti-jitter mechanism
Anti-jitter ensures that switching from a thin font to a bold one doesn't move the text. We use a ghost box to reserve the maximum space required.

#demo("Stability Test H1",
"text-styles: (
  level-1: (
    active: (weight: 'black', fill: eastern, size: 1.2em),
    inactive: (weight: 'light', fill: gray, size: 1.2em)
  )
)",
progressive-outline(level-2-mode: "none", text-styles: (level-1: (active: (weight: "black", fill: eastern, size: 1.2em), inactive: (weight: "light", fill: gray, size: 1.2em)))))

== Colors and decorations
Each level can have its own rules for colors, italics, or bold.

#demo("Creative Style H2",
"text-styles: (
  level-2: (
    active: (style: 'italic', fill: blue, weight: 'bold'),
    inactive: (fill: luma(200))
  )
)",
progressive-outline(level-2-mode: "all", text-styles: (level-2: (active: (style: "italic", fill: blue, weight: "bold"), inactive: (fill: luma(200))))))

= Fine-grained spacing management
The `spacing` dictionary sculpts the rhythm.

== Inter-level spacing
You can define the exact space between an H1 heading and an H2 heading, or between two headings of the same level.

#demo("Airy Vertical Rhythm",
"spacing: (
  v-between-1-1: 2em,
  v-between-1-2: 1.2em,
  v-between-2-2: 0.8em,
  v-between-2-1: 1.5em
)",
progressive-outline(level-2-mode: "all", spacing: (v-between-1-1: 2em, v-between-1-2: 1.2em, v-between-2-2: 0.8em, v-between-2-1: 1.5em)))

== Horizontal indentation
Indentation defines the offset to the right for each depth level.

#demo("Marked Indentation",
"spacing: (
  indent-2: 3em,
  indent-3: 6em
)",
progressive-outline(level-2-mode: "all", level-3-mode: "all", spacing: (indent-2: 3em, indent-3: 6em)))

= Numbering system
The function relies on Typst's native engine.

== Complex hierarchical formats
The `numbering-format` parameter accepts all standard Typst models (1, a, i, I, A).

#demo("Legal Format",
"show-numbering: true,
numbering-format: 'I.a.1. '",
progressive-outline(level-2-mode: "all", level-3-mode: "all", show-numbering: true, numbering-format: "I.a.1. "))

== Advanced textual prefixes
To use long words like "Chapter" without errors, pass a function. This prevents Typst from interpreting letters like 'a' or 'i' as numbering models.

#demo("Secure 'Chapter' Prefix",
"show-numbering: true,
numbering-format: (..n) => 'Chapter ' + numbering('1', ..n) + ' : '",
progressive-outline(
  level-1-mode: "all", 
  level-2-mode: "none", 
  show-numbering: true, 
  numbering-format: (..n) => "Chapter " + numbering("1", ..n) + " : "
))

= Filtering Content <hidden>
The `filter` parameter allows you to programmatically include or exclude headings from the outline. It expects a callback function `(heading) => boolean`.

The `heading` object passed to the filter contains standard properties (`level`, `body`, `label`, `counter`) as well as context properties: `parent-h1` and `parent-h2`.

== Label-based filtering
In this document, the current section "Filtering Content" has been tagged with the label `<hidden>`.

#demo("Standard Outline (No Filter)",
"progressive-outline(level-2-mode: 'none')",
progressive-outline(level-2-mode: "none"))

#demo("Filtered Outline (Label)",
"progressive-outline(
  level-2-mode: 'none',
  filter: h => h.label != <hidden>
)",
progressive-outline(
  level-2-mode: "none",
  filter: h => h.label != <hidden>
))

== Logic-based filtering
You can also filter based on any heading property.
Here, we filter the list to *keep only* the section named "Visibility".

#demo("Filtered Outline (Content)",
"progressive-outline(
  level-2-mode: 'none',
  // Keep only the heading named 'Visibility'
  filter: h => h.body == [Visibility]
)",
progressive-outline(
  level-2-mode: "none",
  filter: h => h.body == [Visibility]
))

Here, we create a custom rule: show all Level 1 headings, but show Level 2 headings *only* if they belong to the "Visibility" section.

#demo("Conditional Depth",
"progressive-outline(
  level-2-mode: 'all',
  filter: h => h.level == 1 or 
    (h.level == 2 and h.parent-h1.body == [Visibility])
)",
progressive-outline(
  level-2-mode: "all",
  filter: h => h.level == 1 or (h.level == 2 and h.parent-h1 != none and h.parent-h1.body == [Visibility])
))

== Recursive filtering
The filtering logic is recursive: if a parent heading (e.g., a Section) is excluded by the filter, all its children (Subsections and Sub-subsections) are automatically hidden as well, even if they would have passed the filter individually.

#demo("Recursive Hiding",
"// Hiding a parent automatically hides its children
progressive-outline(
  level-2-mode: 'all',
  filter: h => h.label != <hidden>
)",
progressive-outline(
  level-2-mode: "all",
  filter: h => h.label != <hidden>
))

= Advanced Behavior

== Page-based matching
In contexts like sidebars, the outline is rendered in the page margin or background before the slide content. This can cause the active heading detection to fail because the content is technically "after" the sidebar in the document flow.

Setting `match-page-only: true` solves this by considering any heading on the current page as "active", ignoring precise vertical positioning.

#demo("Sidebar Logic",
"match-page-only: true",
progressive-outline(match-page-only: true, level-2-mode: "none"))

= Additional information

It is optimized to work within presentation themes (like `progressive-outline`), but can be used in any standard Typst document.
