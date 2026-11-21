// Shared document class for report, article, book, journal, and proposal templates.

#import "defaults.typ": defaults, merge, validate-config
#import "heading-layout.typ": koma-headings
#import "themes.typ": theme-config
#import "@preview/hydra:0.6.3": hydra, selectors

/// Show a long caption under the figure, a short one in the List of Figures.
///
/// Typst's List of Figures normally repeats the full caption. This component
/// stores the long text as caption metadata and gives the figure the short
/// caption, so the list stays compact. Satz's document class restores the long
/// caption when it draws the figure. Without `short-caption`, it behaves like a
/// normal `figure`.
///
/// - body (content): visible figure content
/// - caption (content, none): long caption shown below the figure
/// - short-caption (content, none): compact title for the List of Figures
/// - ..args: native `figure` arguments, including `placement` and `kind`. Pass
///   `kind: table` when the body is a table so it enters the List of Tables.
///
/// ```example
/// #satz-figure(
///   rect(width: 8cm, height: 4cm, fill: luma(230)),
///   caption: [Full description spanning several lines.],
///   short-caption: [Empirical verification of Picard ICA],
/// ) <fig:results>
/// ```
#let satz-figure(body, caption: none, short-caption: none, ..args) = {
  if short-caption != none {
    figure(
      body,
      caption: [#metadata((satz-long-caption: caption))#short-caption],
      ..args,
    )
  } else {
    figure(body, caption: caption, ..args)
  }
}

/// Shared document-wide styling used internally by Satz's named templates.
///
/// User-authored document structures should use `custom()` below.
///
/// ```example
/// #show: custom.with(kind: "thesis", config: (page: (paper: "a5")))
/// = My Thesis
/// ```
///
/// - kind (str): document behavior: `article`, `book`, `journal`, `proposal`, `report`, or `thesis`
/// - config (dictionary): partial nested overrides deep-merged with shared defaults.
///   The exported `defaults` dictionary is the single documented schema for shared
///   keys, types, meanings, and baseline values. This class applies page, typography,
///   headings, line numbers, links, captions, lists, bibliography, and contents/list
///   settings. Template wrappers add their own defaults and may use only a subset.
///   See the configuration reference for template-specific defaults and overrides.
/// - header (none, content): your own header, if you want one
/// - footer (none, content): your own footer, if you want one
/// - body (content): your content
#let document-class(
  kind: "report",
  config: (:),
  header: none,
  footer: none,
  body,
) = {
  let config = validate-config(config)
  let c = merge(defaults, config)

  // --- Build page arguments ---
  let page-numbering = if kind == "report" or kind == "thesis" {
    (n) => { if n > 1 { str(n - 1) } else { none } }
  } else {
    none
  }
  let two-sided = "binding" in c.page and c.page.binding != none
  let binding-correction = c.page.at("binding-correction", default: 0pt)

  // Convert left/right to inside/outside when two-sided
  let margin = c.page.margin
  if two-sided {
    let inside-side = if c.page.binding == right { "right" } else { "left" }
    let outside-side = if inside-side == "left" { "right" } else { "left" }
    margin = (
      inside: margin.at(inside-side, default: margin.at("x", default: 2.5cm)) + binding-correction,
      outside: margin.at(outside-side, default: margin.at("x", default: 2.5cm)),
      top: margin.at("top", default: 2.5cm),
      bottom: margin.at("bottom", default: 2.5cm),
    )
  }

  let page-args = (
    paper: c.page.paper,
    margin: margin,
    fill: c.colors.bg-paper,
    header: if header != none { header } else { none },
    footer: if footer != none { footer } else { none },
    numbering: page-numbering,
    columns: c.page.columns,
  )
  if two-sided {
    page-args.insert("binding", c.page.binding)
  }
  set page(..page-args)
  set columns(gutter: c.page.column-gutter)
  set figure(placement: c.figures.placement)

  // Reports and theses show page numbers in the footer. Bound documents
  // alternate them toward the outer edge; one-sided documents center them.
  // Set rules are block-scoped in Typst, so a `set page` inside an `if` block
  // would not apply to the body — compute the footer value, then set it once.
  let page-footer = if footer != none {
    footer
  } else if kind == "report" or kind == "thesis" {
    context {
      let d = counter(page).display()
      if d != none {
        let displayed = text(size: c.page-footer.size, weight: c.page-footer.weight, fill: c.colors.brand-primary, d)
        if two-sided {
          let n = counter(page).get().first()
          if calc.rem(n, 2) == 0 { align(left, displayed) } else { align(right, displayed) }
        } else {
          align(center, displayed)
        }
      }
    }
  } else {
    none
  }
  set page(footer: page-footer)

  // Two-sided: chapter on even counters, section/chapter on odd counters.
  // Hydra selects the last relevant heading on the page, or the previous one.
  // Including h1 in the odd-page selector resets section context each chapter.
  // Outlined headings include unnumbered chapters but exclude outline titles.
  let page-header = if two-sided and header == none and c.page.at("headers", default: false) {
    context {
      let n = counter(page).get().first()
      let is-even = calc.rem(n, 2) == 0
      let chapters = heading.where(level: 1, outlined: true)
      // Suppress every chapter-opening page, even when styling or a float
      // moves the chapter heading below the top margin.
      let opening = query(chapters).any(h => h.location().page() == here().page())
      if not opening {
        let target = if is-even {
          selectors.custom(chapters)
        } else {
          selectors.custom(heading, filter: (_, h) => h.outlined and h.level <= 2)
        }
        align(
          if is-even { left } else { right },
          text(size: c.decorative.header-size, fill: c.colors.text-muted,
            hydra(target, skip-starting: false, use-last: true, display: (_, h) => h.body)),
        )
      }
    }
  } else {
    if header != none { header } else { none }
  }
  set page(header: page-header)

  // --- Text ---
  set text(
    font: c.typography.font,
    size: c.typography.size,
    fill: c.colors.text-main,
    hyphenate: c.typography.hyphenate,
    lang: "en",
  )

  // --- Paragraph ---
  // Omit auto to retain Typst's native mathematical typeface and local rules.
  let math-typeface = if c.typography.math-font == auto { (:) } else { (font: c.typography.math-font) }
  show math.equation: set text(..math-typeface)
  let mono-typeface = if c.typography.mono-font == auto { (:) } else { (font: c.typography.mono-font) }
  show raw: set text(..mono-typeface)

  assert(
    type(c.typography.first-line-indent) == bool,
    message: "typography.first-line-indent must be true or false.",
  )
  set par(
    justify: c.typography.justify,
    leading: c.typography.leading,
    spacing: c.typography.paragraph-spacing,
    first-line-indent: if c.typography.first-line-indent {
      (amount: 1em, all: true)
    } else {
      0pt
    },
  )
  let line-numbering = if c.line-numbers.enabled {
    n => text(size: c.line-numbers.size, fill: c.line-numbers.color)[
      #numbering(c.line-numbers.format, n)
    ]
  } else {
    none
  }
  set par.line(
    numbering: line-numbering,
    numbering-scope: c.line-numbers.scope,
    number-clearance: c.line-numbers.clearance,
  )

  // --- Heading numbering (journal uses none) ---
  set heading(numbering: if kind == "journal" { none } else { c.headings.numbering })

  // --- Native heading styling ---
  // Style the heading's own block rather than nesting a second heading block.
  // Native above-spacing, page-start trimming, and stickiness remain intact.
  show heading: set text(hyphenate: c.headings.hyphenate)
  show heading: set par(justify: false)
  show heading.where(level: 1): set text(size: c.headings.h1-size, fill: c.colors.brand-primary, weight: "bold")
  show heading.where(level: 2): set text(size: c.headings.h2-size, fill: c.colors.brand-primary, weight: "bold")
  show heading.where(level: 3): set text(size: c.headings.h3-size, fill: c.colors.brand-primary, weight: "bold")
  show heading.where(level: 4): set text(size: c.headings.h4-size, fill: c.colors.brand-primary, weight: "bold")
  // Setting block(above: auto) replaces native per-level heading skips.
  // Omit the property entirely when callers request native spacing.
  let heading-above(value) = if value == auto { (:) } else { (above: value) }
  show heading.where(level: 1): set block(..heading-above(c.headings.h1-above))
  show heading.where(level: 2): set block(..heading-above(c.headings.h2-above))
  show heading.where(level: 3): set block(..heading-above(c.headings.h3-above))
  show heading.where(level: 4): set block(..heading-above(c.headings.h4-above))
  show heading.where(level: 1): set block(below: c.headings.h1-below)
  show heading.where(level: 2): set block(below: c.headings.h2-below)
  show heading.where(level: 3): set block(below: c.headings.h3-below)
  show heading.where(level: 4): set block(below: c.headings.h4-below)
  show heading.where(level: 1): it => if kind == "journal" {
    block(smallcaps(it.body))
  } else {
    if c.headings.h1-pagebreak { pagebreak(weak: true) }
    it
  }

  // --- Links ---
  // External URLs (string dest) get url-color + underline for all kinds.
  // Internal links, refs (@fig: / @eq:) and cites (@key) get c.links.color
  // for report/thesis; journal stays black. Outline overrides to black below.
  show link: it => {
    if type(it.dest) == str {
      text(fill: c.links.url-color, underline(it))
    } else if kind != "journal" {
      text(fill: c.links.color, it)
    } else {
      it
    }
  }
  // Every ref carries a fallback citation, including resolved figure refs.
  // A resolved element distinguishes cross-references from bibliography keys.
  show ref: it => if kind != "journal" {
    if it.element == none {
      it
    } else {
      text(fill: c.links.color, it)
    }
  } else { it }
  show cite: it => if kind != "journal" {
    // Only the year (4-digit) is colored — not "Fuster & Alexander,"
    show regex("\d{4}[a-z]?"): y => text(fill: c.links.color, y)
    it
  } else { it }

  // --- Table styling (booktabs-style) ---
  set table(
    stroke: none,
    inset: c.tables.inset,
  )

  show table: set text(size: c.tables.font-size)
  show table: set align(left)
  show table: set par(justify: false)

  // Work-package summaries can continue across pages without clipping.
  show figure.where(kind: "work-package"): set block(breakable: true)

  // The short caption carries the long caption as invisible metadata, so
  // floating does not break the association between the two.
  show figure.caption: set align(c.captions.alignment)
  show figure.caption: it => context {
    set text(size: c.captions.size, weight: c.captions.weight)
    let caption-body = it.body
    if caption-body.has("children") and caption-body.children.len() > 0 {
      let first = caption-body.children.first()
      if first.func() == metadata and type(first.value) == dictionary and "satz-long-caption" in first.value {
        caption-body = first.value.at("satz-long-caption")
      }
    }
    let caption-label = if it.numbering != none {
      let separator = if it.separator == auto { [: ] } else { it.separator }
      text(weight: c.captions.label-weight)[
        #if it.supplement != none { [#it.supplement~] }#it.counter.display(it.numbering)#separator
      ]
    } else { none }
    if c.captions.hanging and caption-label != none {
      block(width: 100%, grid(
        columns: (auto, 1fr),
        column-gutter: 0.2em,
        caption-label,
        caption-body,
      ))
    } else if caption-label != none {
      [#caption-label#caption-body]
    } else { caption-body }
  }

  // --- Outline entries ---
  // Keep native numbering, hanging indents, and formatted page numbers.
  // Compact figure/table lists omit only the caption, not the native prefix.
  let lof-compact = "lof" in c and c.lof.at("compact", default: false)
  let lot-compact = "lot" in c and c.lot.at("compact", default: false)
  show outline.entry: it => context {
    let el = it.element
    if el.func() == figure and (
      (el.kind == image and lof-compact) or
      (el.kind == table and lot-compact)
    ) {
      link(el.location(), text(fill: c.colors.text-main,
        it.indented(it.prefix(), [#box(width: 1fr, it.fill) #sym.wj#it.page()])))
    } else {
      it
    }
  }

  // Outline links (ToC/LoF/Lot) — uniform black, no fancy color.
  // Body cross-refs (@fig:...) keep `c.links.color` via the global
  // `show link` above. This show must be inside `outline` scope only;
  // we use a nested show that applies only while rendering the outline.
  // (Do not move `show link` outside — it would affect body links.)
  show outline: it => context {
    show link: lnk => text(fill: c.colors.text-main, lnk)
    show ref: r => text(fill: c.colors.text-main, r)
    show cite: c => text(fill: c.colors.text-main, c)
    it
  }

  // One rhythm for the automatic contents, figure list, and table list.
  // Entry gaps must not fall below leading: paragraph spacing replaces leading
  // at block boundaries, so tiny values squash rows rather than adding air.
  let document-outline(settings, target: heading, contents: false) = {
    if settings.title != none {
      block(below: settings.title-below, sticky: true)[
        #text(size: c.headings.h1-size, fill: c.colors.brand-primary, weight: "bold", settings.title)
      ]
    }
    set text(size: settings.entry-size)
    set par(justify: false, leading: settings.leading, spacing: settings.entry-above, first-line-indent: 0pt)
    show outline.entry: set block(above: settings.entry-above, below: 0pt)
    show outline.entry.where(level: 1): set block(above: if contents { settings.main-entry-above } else { settings.entry-above })
    show outline.entry.where(level: 1): set text(weight: if contents { "bold" } else { "regular" })
    show outline.entry.where(level: 1): set outline.entry(fill: if contents { none } else { repeat(gap: 0.15em)[.] })
    outline(title: none, target: target, depth: settings.depth, indent: settings.indent)
    v(settings.below)
  }

  // --- Bibliography ---
  set bibliography(style: c.bibliography.style)

  // --- Automatic front matter (report/thesis) ---
  // Each list has its own toggle; disabling the contents must not hide tables.
  if kind == "report" or kind == "thesis" {
    context {
      let has-toc = c.toc.depth != 0
      let has-lof = c.lof.depth != 0 and query(figure.where(kind: image, outlined: true)).len() > 0
      let has-lot = c.lot.depth != 0 and query(figure.where(kind: table, outlined: true)).len() > 0
      if has-toc or has-lof or has-lot {
        {
          set page(header: none, footer: none, numbering: none, columns: 1)
          if has-toc { document-outline(c.toc, contents: true) }
          if has-lof {
            if has-toc { pagebreak() }
            document-outline(c.lof, target: figure.where(kind: image))
          }
          if has-lot {
            if has-toc or has-lof { pagebreak() }
            document-outline(c.lot, target: figure.where(kind: table))
          }
        }
        // Update before the pagebreak so the next header sees the right parity.
        // Counter 2 displays as page 1 in reports and theses.
        counter(page).update(2)
        pagebreak()
      } else if counter(page).get().first() == 1 {
        // With no cover or generated front matter, the first content page is 1.
        counter(page).update(2)
      }
    }
  }

  assert(c.headings.spacing in ("koma", "native"), message: "headings.spacing must be koma or native.")
  let styled-body = if c.headings.spacing == "koma" { koma-headings(c, kind, body) } else { body }
  let line-spacing = c.typography.line-spacing
  assert(
    line-spacing == none or
      ((type(line-spacing) == int or type(line-spacing) == float) and line-spacing > 0),
    message: "typography.line-spacing must be none or a positive number such as 1.5.",
  )
  context {
    let font-size = c.typography.size
    let sample = text(
      font: c.typography.font,
      size: font-size,
      top-edge: "cap-height",
      bottom-edge: "baseline",
    )[H]
    let text-height = measure(sample).height
    let baseline-distance = if line-spacing == none {
      text-height + c.typography.leading
    } else {
      font-size * line-spacing
    }
    let calculated-leading = baseline-distance - text-height
    assert(
      line-spacing == none or calculated-leading >= 0pt,
      message: "typography.line-spacing is too small for the selected font and size.",
    )
    assert(
      (type(c.typography.list-spacing) == int or type(c.typography.list-spacing) == float)
        and c.typography.list-spacing >= 0,
      message: "typography.list-spacing must be a non-negative number.",
    )
    let list-spacing = baseline-distance * (1 + c.typography.list-spacing) - text-height
    if line-spacing != none {
      // Put the rules and body in the same scope so Typst applies them.
      set text(top-edge: "cap-height", bottom-edge: "baseline")
      set par(leading: calculated-leading)
      set list(tight: false, spacing: list-spacing)
      set enum(tight: false, spacing: list-spacing)
      styled-body
    } else {
      set list(tight: false, spacing: list-spacing)
      set enum(tight: false, spacing: list-spacing)
      styled-body
    }
  }
}

/// Apply Satz's shared document styling to a document structure you write.
///
/// Prefer a named template when its structure fits: `report`, `article`,
/// `book`, or the journal and proposal templates. Use `custom` when you want
/// to write the structure yourself while reusing Satz's page, typography,
/// heading, link, and outline settings.
///
/// ```example
/// #show: custom.with(
///   kind: "thesis",
///   config: (
///     typography: (font: "STIX Two Text", math-font: "STIX Two Math", size: 11pt),
///     page: (paper: "a5"),
///   ),
/// )
/// = My document
/// I choose the structure and content.
/// ```
///
/// - kind (str): behavior preset. `"report"` and `"thesis"` support page
///   numbering and optional contents/LoF/LoT; `"thesis"` is currently
///   otherwise identical to `"report"`. `"journal"` disables heading numbering
///   and colored internal links. `"article"`, `"book"`, and `"proposal"` add no
///   front matter. Defaults to `"report"`.
/// - config (dictionary): partial nested overrides; nested dictionaries merge recursively.
///   Template defaults: Defaults to the neutral palette and no automatic contents, figure list, or table list (`toc.depth`, `lof.depth`, `lot.depth: 0`); set a depth to `none` to enable it. Other values follow the shared defaults. `kind` defaults to `"report"`; other kinds can change front matter, numbering, headers, and bibliography behavior. `theme` accepts the built-in palettes.
///   The selected kind controls front matter, heading numbering, links and bibliography behavior.
///   The following values are the shared baseline; template defaults above override them.
///
/// Every key below is nested under its group, for example
/// `typography.font` means `(typography: (font: ...))`.
///
/// **Page (`page`)**
/// - `paper` (paper name or custom size; `"a4"`): page format.
/// - `margin` (dictionary of edge lengths; 2.5cm on every edge): page margins.
///   Use `top`, `bottom`, `left`, and `right`; two-sided layouts may instead
///   derive inside/outside margins. `x` and `y` are shorthand for horizontal
///   and vertical margins.
/// - `binding` (`none`, `left`, or `right`; `none`): enables two-sided layout
///   and selects the binding edge where supported.
/// - `binding-correction` (length; `0pt`): extra space at the binding edge.
/// - `headers` (bool; `false`): enables the template's running header where
///   implemented.
/// - `columns` (positive integer; `1`): number of text columns where supported.
/// - `column-gutter` (length; `5mm`): gap between columns.
///
/// **Typography (`typography`)**
/// - `font` (font name; `"Libertinus Serif"`): body text typeface.
/// - `math-font` (font name or `auto`; `auto`): math typeface. `auto` leaves
///   math font selection to Typst.
/// - `mono-font` (font name or `auto`; `auto`): monospace typeface. `auto`
///   leaves raw text in Typst's native style.
/// - `size` (length; `11pt`): body text size.
/// - `line-spacing` (positive number or `none`; `none`): optional baseline to
///   baseline distance as a multiple of body size, for example `1.25`. Satz
///   uses the selected font's metrics to calculate leading. When set, it
///   overrides `leading`.
/// - `leading` (length; `0.65em`): Typst's gap between adjacent line boxes.
///   This is a direct length, not a baseline-distance multiplier.
/// - `list-spacing` (non-negative number; `0.5`): additional gap between list
///   items as a fraction of the calculated body baseline distance. Zero adds
///   no extra gap. The baseline follows `line-spacing` when set, or the
///   selected font metrics and `leading` otherwise.
/// - `paragraph-spacing` (length; `1.2em`): vertical gap between paragraphs.
/// - `first-line-indent` (bool; `false`): whether to indent the first line of
///   every paragraph. `true` uses one em (the current body font size, so 11pt
///   at an 11pt text size), including the first paragraph in a
///   document/container and paragraphs immediately after blocks such as
///   headings; `false` uses no indent. This horizontal measure is independent
///   of vertical `line-spacing` and `paragraph-spacing` and does not change
///   either setting.
/// - `hyphenate` (bool; `false`): automatic word hyphenation in body text.
/// - `justify` (bool; `true`): justify body paragraphs where supported.
///
/// **Headings (`headings`)**
/// - `numbering` (Typst numbering pattern/function or `none`; `"1.1"`):
///   numbering for native headings.
/// - `hyphenate` (bool; `false`): allow line breaks by hyphenation in headings.
/// - `h1-pagebreak` (bool; `false`): start level-one headings on a new page
///   where supported.
/// - `spacing` (`"koma"` or `"native"`; `"koma"`): `"koma"` derives heading
///   gaps from KOMA-style baseline skips and font metrics; `"native"` keeps
///   Typst's native spacing policy.
/// - `h1-size` … `h4-size` (lengths; `14pt`, `12pt`, `11pt`, `11pt`): text size
///   for heading levels one through four.
/// - `h1-above` … `h4-above` (`auto` or length; `auto`): gap before each level.
///   `auto` follows the selected spacing policy.
/// - `h1-below` … `h4-below` (`auto` or length; `auto`): gap after each level.
///   An explicit length overrides the template's automatic value.
///
/// **Journal (`journal`)**
/// - `header-below` (length; `1.5em`): gap after the full entry heading/date
///   block and before the notes.
/// - `running-gutter` (length; `1em`): gap between columns in a running header.
/// - `running-leading` (length; `0.35em`): line gap in a multi-line running
///   header.
/// - `running-header-size` (length; `9pt`): journal running-header text size.
/// - `date-size` (length; `10pt`): journal date text size.
/// - `keywords-size` (length; `9pt`): journal keyword text size.
/// Journal lists use the shared `typography.list-spacing` setting.
///
/// **Decorative text and lists (`decorative`)**
/// - `header-size` (length; `9pt`): running-header text size.
/// - `footer-size` (length; `10pt`): footer text size where implemented.
/// - `date-size` (length; `10pt`): date text size where implemented.
/// - `keywords-size` (length; `9pt`): keyword text size where implemented.
/// General list spacing uses `typography.list-spacing`. DFG templates also
/// accept the extension fields `list-indent`, `list-body-indent`,
/// `list-block-spacing`, and `list-spacing` in this group. These control DFG
/// geometry and a DFG-specific length override.
///
/// **Page number (`page-footer`)**
/// - `format` (Typst numbering pattern/function; `"1"`): page-number format.
/// - `size` (length; `10pt`): page-number text size.
/// - `weight` (Typst font weight; `"regular"`): page-number text weight.
///
/// **Line numbers (`line-numbers`)**
/// - `enabled` (bool; `false`): show line numbers in templates that support
///   draft line numbering.
/// - `format` (Typst numbering pattern; `"1"`): line-number format.
/// - `scope` (`"document"` or `"page"`; `"document"`): keep numbering
///   continuous across pages or restart on each page.
/// - `size` (length; `8pt`): line-number text size.
/// - `color` (color; `#64748B`): line-number color.
/// - `clearance` (`auto` or length; `auto`): gap between numbers and body text.
///
/// **Links (`links`)**
/// - `color` (color; `#0563C1`): color of internal references.
/// - `url-color` (color; `#0563C1`): color of external URLs.
///
/// **Tables (`tables`)**
/// - `stroke` (length; `0.5pt`): default rule thickness for shared table
///   helpers.
/// - `inset` (length or dictionary; `(x: 8pt, y: 4pt)`): cell padding. A
///   dictionary can set horizontal and vertical padding independently.
/// - `font-size` (length; `10pt`): text size in shared styled tables.
/// - `caption-position` (`top` or `bottom`; `top`): caption location in the
///   scientific-table show rule.
/// - `caption-gap` (length; `6pt`): space between a table caption and table.

/// **Figures (`figures`)**
/// - `placement` (`auto`, `none`, or vertical alignment; `none`): native
///   placement policy for figures, including tables represented as figures.
///   `none` keeps them in source order; `auto` lets Typst place them at a
///   suitable page edge. Templates may override this baseline.
///
/// **Callouts (`callouts`)**
/// - `inset` (length; `9pt`): inner padding.
/// - `radius` (length; `3pt`): corner radius.
/// - `stroke` (length; `0.8pt`): border thickness.
/// - `title-below` (length; `1em`): gap below a callout title.
/// - `paragraph-spacing` (length; `1em`): gap between callout paragraphs.
/// - `list-spacing` (length; `1.2em`): gap between callout list items.
///
/// **Captions (`captions`)**
/// - `size` (length; `10pt`): caption text size.
/// - `weight` (Typst font weight; `"regular"`): caption text weight.
/// - `alignment` (Typst alignment; `left`): caption alignment when not hanging.
/// - `label-weight` (Typst font weight; `"regular"`): weight of the caption
///   label, independently of the rest of the caption.
/// - `hanging` (boolean; `true`): put the label in its own column so wrapped
///   lines align with the caption text. Set to `false` for inline labels.
///
/// **Contents (`toc`)**
/// - `depth` (`none` or non-negative integer; `none`): included heading depth.
///   In report/thesis documents, `0` disables the automatic contents.
/// - `title` (content or `none`; `[Table of Contents]`): title above the list;
///   `none` omits it.
/// - `indent` (`auto` or length; `auto`): indentation of nested entries.
/// - `entry-size` (length; `10pt`): entry text size.
/// - `leading` (length; `0.65em`): line gap in wrapped entries.
/// - `entry-above` (length; `0.65em`): gap between ordinary entries.
/// - `main-entry-above` (length; `1.25em`): extra gap before main-section
///   entries.
/// - `title-below` (length; `1.5em`): gap between title and first entry.
/// - `below` (length; `2em`): gap after the contents.
///
/// **List of Figures (`lof`) and List of Tables (`lot`)**
/// Both groups use the same fields and meanings as `toc`, with these defaults:
/// `depth: none` (automatic depth), `title: [List of Figures]` or
/// `[List of Tables]`, `indent: auto`, `entry-size: 10pt`, `leading: 0.65em`,
/// `entry-above: 0.85em`, `title-below: 1.5em`, and `below: 2em`.
/// - `compact` (bool; `false`): when true, show only the figure/table label
///   and page number, omitting caption text.
///
/// **Bibliography (`bibliography`)**
/// - `style` (CSL style name; `"apa"`): citation style where bibliography
///   support is enabled.
///
/// **Colors (`colors`)**
/// - `bg-paper` (color; `white`): page or paper background.
/// - `bg-subtle` (color; `white`): subtle surface/background color.
/// - `brand-primary` (color; `black`): primary brand and heading accent.
/// - `brand-accent` (color; `black`): secondary accent.
/// - `text-main` (color; `black`): primary body text.
/// - `text-muted` (color; `black`): secondary or muted text.
///
/// Some templates add validated settings not present in this baseline,
/// including `page.header-ascent`, `headings.h1-number-size`, and
/// `decorative.list-indent`, `decorative.list-body-indent`, `decorative.list-spacing`,
/// and `decorative.list-block-spacing`. Consult the relevant template's API and
/// the configuration reference before using template-specific keys.
///
/// With `math-font: auto`, Typst selects its default math font. The Typst CLI
/// embeds New Computer Modern Math, so users do not need to install it.
/// Template defaults may differ from this shared baseline.
///
/// For details about which templates consume each key and for template-specific
/// overrides, see the versioned configuration reference.
///
/// - theme (str, none): `neutral` (default), `slate`, `soft-jade`, `soft-slate`,
///   `warm-editorial`, `plum`, or `soft-rose`. Explicit `config.colors` and
///   `config.links` values override the selected palette.
/// - header (none, content): replaces Satz's automatic running header
/// - footer (none, content): replaces Satz's automatic alternating page footer
/// - body (content): your document structure
#let custom(
  kind: "report",
  theme: "neutral",
  config: (:),
  header: none,
  footer: none,
  body,
) = {
  let custom-defaults = (toc: (depth: 0), lof: (depth: 0), lot: (depth: 0))
  let config = theme-config(theme, config: merge(custom-defaults, config))
  document-class(
    kind: kind,
    config: config,
    header: header,
    footer: footer,
    body,
  )
}
