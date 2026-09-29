#import "cmd.typ": boxed, mermaid, figure


/** #v(1fr) #outline() #v(1.2fr) #pagebreak()
= Quick Start
```typst
#import "@preview/min-writing:0.1.0": writing

#set document(
  title: "Title",
  author: "Author",
  description: "Description",
)

#show: writing

// Write typst with expanded syntax (see manual)
```

= Description
Create quick notes intuitively and rapidly, using syntactic sugar that extends the markup supported by Typst.
By default, new documents are created in quick-note mode—which ignores page breaks and optimizes the layout
for screens—though you can also select the classic paged mode.

This package was designed to make creating documents as easy as possible, without requiring extensive initial
configuration—in fact, you simply need to import the package and apply the `#show` rule to access its
features—yet it still offers various options for fine-tuning.

= Options
:show.with writing:
**/
#let writing(
  syntax: true, /// <- boolean
    /// Enable additional syntactic sugar (extended syntax). |
  paged: false, /// <- boolean
    /// Enable classical paged mode (disable for quick-note mode). |
  custom-styling: true, /// <- boolean
    /// Enable custom styles and formatting. |
  catppuccin-flavor: "mocha", /// <- string
    /// Set catppuccin color flavor: #("mocha", "frappe", "latte").map(underline).join(", "). |
  accent-color: auto, /// <- auto | color
    /// Set accent color. |
  help: false, /// <- boolean
    /// Enable quick help at the first page. |
  body
) = context {
  import "@preview/catppuccin:1.1.0": catppuccin, get-flavor
  import "@preview/nexus-tools:0.3.0": default, storage
  import "util.typ" as util: defaults, custom-divider
  import "syntax.typ" as syntax-init
  
  let default = default.with(not custom-styling)
  let flavor = get-flavor(catppuccin-flavor)
  let accent-color = if accent-color == auto {flavor.colors.mauve.rgb} else {accent-color}
  let sub-text = if custom-styling {flavor.colors.subtext0.rgb} else {text.fill}
  let font-size = text.size
  let body = body
  
  storage.add("accent-color", accent-color, namespace: "min-writing")
  
  // Generate quick help page at the end of the document
  if help {
    set text(font: ("tex gyre heros", "arial"))
    
    include "help.typ"
  }
  
  set page(
    ..util.default(
      when: page.margin == defaults.page.margin,
      value: (margin: (x: 2em, y: 3em)),
      paged
    ),
    ..util.default(
      when: repr(page.width) == defaults.page.width,
      value: (width: 26em),
      paged
    ),
    ..util.default(
      when: repr(page.height) == defaults.page.height,
      value: (height: auto),
      paged
    ),
    header: context if locate(here()).page() > 1 {
      set align(right)
      text(
        document.title,
        style: "italic",
        ..default(
          when: true,
          value: (fill: sub-text),
        ),
      )
    },
    footer: {
      set align(center)
      text(
        counter(page).display("1/1", both: true),
        style: "italic",
        ..default(
          when: true,
          value: (fill: sub-text),
        ),
      )
    },
  )
  set heading(
    ..default(
      when: heading.numbering == defaults.heading.numbering,
      value: (numbering: "1."),
    ),
  )
  set text(
    ..default(
      when: text.font == defaults.text.font,
      value: (font: ("tex gyre heros", "arial")),
    ),
  )
  set table(
    ..default(
      when: repr(table.stroke) == defaults.table.stroke,
      value: (stroke: 1pt + sub-text),
    ),
    ..default(
      when: table.fill == defaults.table.fill,
      value: (fill: (_,y) => if calc.even(y) {flavor.colors.mantle.rgb} else {none}),
    ),
  )
  set table.cell(
    ..default(
      when: table.cell.inset == defaults.table.cell.inset,
      value: (inset: (x: 0.5em, y: 0.75em))
    ),
  )
  set rect(
    ..default(
      when: rect.fill == defaults.rect.stroke,
      value: (stroke: accent-color),
    ),
  )
  set outline(
    ..default(
      when: not paged and outline.indent == defaults.outline.indent,
      value: (indent: 2em),
    ),
  )
  set par(justify: true)
  set terms(separator: [: ], tight: true)
  set footnote.entry(separator: line(length: 30% + 0pt, stroke: 0.05em + sub-text))
  set highlight(extent: 1pt)
  
  show heading: it => {
    set text(
      ..default(
        when: text.font == ("tex gyre heros", "arial"),
        value: (font: ("tex gyre adventor", "century gothic")),
      ),
      size: font-size + 5pt,
    )
    
    it
  }
  show raw: it => {
    set text(
      size: font-size,
      ..default(
        when: text.font == defaults.raw.text.font,
        value: (font: ("fira mono", "inconsolata")),
      ),
    )
    
    it
  }
  show outline.entry: it => link(
    it.element.location(),
    it.indented(it.prefix(), it.body()),
  )
  show divider: custom-divider.with(color: sub-text)
  show footnote: set line(stroke: 1pt + sub-text)
  show std.figure.caption: set text(size: 1em - 2pt)
  show footnote.entry: set text(size: font-size - 2pt)
  show heading.where(numbering: none): set align(center)
  show math.equation.where(block: true): set math.equation(numbering: "(1)")
  show quote.where(block: true): it => pad(x: 1em, it)
  show raw.where(block: true): it => pad(left: 1em, it)
  show bibliography: bibliography.with(style: "associacao-brasileira-de-normas-tecnicas")
  show: it => if custom-styling {catppuccin(flavor, it)} else {it} // set document styling
  show: syntax-init.unnumbered-headings.with(enable: syntax)
  show: syntax-init.quotes.with(enable: syntax)
  show: syntax-init.breaks.with(enable: syntax, paged: paged)
  show: syntax-init.inline.with(enable: syntax, accent-color: accent-color.transparentize(50%))
  show: syntax-init.check-lists.with(enable: syntax, stroke: accent-color, fill: if custom-styling {flavor.colors.base.rgb} else {white})
  show: syntax-init.dividers.with(enable: syntax)
  show: syntax-init.toc.with(enable: syntax)
  show: syntax-init.tables.with(enable: syntax)
  show: syntax-init.mermaid.with(enable: syntax)
  
  // Handle #pagebreak
  if not paged {
    body = body.children.map(elem => if elem.func() == pagebreak {divider()} else {elem}).join()
  }
  
  // Document title heading
  if document.title != none {
    heading(
      level: 1,
      outlined: false,
      numbering: none,
      align(center)[#document.title]
    )
  }
  
  let header-data = ()
  
  // Document date
  if document.date != none {
    import "@preview/datify:1.0.0": custom-date-format
    
    let date = if document.date != auto {document.date} else {datetime.today()}
    
    date = custom-date-format(date, pattern: "long", lang: text.lang)

    header-data.push(date)
  }
  
  // Document author
  if not document.author in (none, ()) {
    header-data.push(document.author.map(author => emph(author) + linebreak()).join())
  }
  
  // Generate header data
  if header-data.len() > 0 {
    set align(center)
    
    let alignment = if header-data.len() > 1 {(left, right)} else {center}
    
    grid(
      columns: (1fr,) * header-data.len(),
      align: alignment,
      ..header-data,
    )
  }
  
  // Document description
  if document.description != none {
    set align(center)
    
    block(
      document.description,
      width: 90%,
      above: par.spacing
    )
    
    v(1em)
  }
  
  body
}
