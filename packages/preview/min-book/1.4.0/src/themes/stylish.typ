#let cover-page(meta, cfg) = context {
  let frame = image("stylish/frame.svg", width: 93%)
  let data = (horizon: none, bottom: none)
  let background-margin = page.height * 0.017
  let meta = meta
  let cfg = cfg
  let background
  
  // Transform (option: color) in (option: (fill: color))
  if type(cfg.at("title", default: "")) == color {cfg.title = (fill: cfg.title)}
  if type(cfg.at("page", default: "")) == color {cfg.page = (fill: cfg.page)}
  if type(cfg.at("text", default: "")) == color {cfg.text = (fill: cfg.text)}
  if type(meta.authors) == array {meta.authors = meta.authors.join("\n")}
  
  // Override defaults:
  
  cfg.back = cfg.at("back", default: false)
  
  cfg.page = (
    margin: (top: 20%, rest: 10%),
    fill: rgb("#3E210B"),
  ) + cfg.at("page", default: (:))
  
  cfg.title = (
    size: page.width * 0.06,
    font: "cinzel",
    fill: luma(250),
  ) + cfg.at("title", default: (:))
  
  cfg.text = (
    size: page.width * 0.04,
    font: "alice",
    fill: luma(200),
    hyphenate: false,
  ) + cfg.at("text", default: (:))
  
  set par(justify: false)
  set text(..cfg.text)
  set page(footer: none)
  
  // Page background
  background = {
    v(background-margin)
    align(center + top, frame) // top frame
    
    align(center + bottom, rotate(180deg, frame)) // bottom frame
    v(background-margin)
  }
  
  // Back cover will be empty (no data content)
  if not meta.is-back-cover {
    data.horizon = align(center + horizon, {
      par(text(meta.title, ..cfg.title), leading: 1.2em, spacing: 1.2em)
      
      if meta.subtitle != none {
        par(text(meta.subtitle), leading: 0.65em, spacing: 0.65em)
      }
    })
    data.bottom = align(center + bottom, {
      block(width: 52%, inset: 0pt, text(
        meta.volume + "\n" +
        meta.authors + "\n" +
        meta.date.display("[year]"),
        size: page.width * 0.035,
      ))
    })
  }
  
  // Insert cover page
  page(background: background, ..cfg.page, data.horizon + data.bottom)
}


#let title-page(meta, cfg) = context {
  let frame = image("stylish/frame.svg", width: 93%)
  let data = (horizon: none, bottom: none)
  let meta = meta
  let cfg = cfg
  
  // Transform (option: color) in (option: (fill: color))
  if type(cfg.at("title", default: "")) == color {cfg.title = (fill: cfg.title)}
  if type(cfg.at("page", default: "")) == color {cfg.page = (fill: cfg.page)}
  if type(cfg.at("text", default: "")) == color {cfg.text = (fill: cfg.text)}
  if type(meta.authors) == array {meta.authors = meta.authors.join("\n")}
  
  // Override defaults:
  
  cfg.page = (margin: (top: 20%, rest: 10%)) + cfg.at("page", default: (:))
  cfg.title = (size: page.width * 0.06) + cfg.at("title", default: (:))
  
  cfg.text = (
    size: page.width * 0.04,
    hyphenate: false
  ) + cfg.at("text", default: (:))
  
  set par(justify: false)
  set text(size: page.width * 0.04)
  
  // Set data content
  data.horizon = align(center + horizon, {
    par(text(meta.title, ..cfg.title), leading: 1.2em, spacing: 1.2em)
    
    if meta.subtitle != none {
      par(text(meta.subtitle, ..cfg.text), leading: 0.65em, spacing: 0.65em)
    }
  })
  data.bottom = align(center + bottom, {
    block(width: 52%, inset: 0pt, text(
      meta.volume + "\n" +
      meta.edition + "\n" +
      meta.authors + "\n" +
      meta.date.display("[year]"),
      size: page.width * 0.035,
    ))
  })
  
  // Insert title page
  page(data.horizon + data.bottom)
}


#let part(meta, cfg, heading) = {
  let background = none
  let break-to
  let frame
  
  cfg = (two-sided: true) + cfg
  break-to = if cfg.two-sided {"odd"} else {none}
  
  // Gray frame when using automatic cover
  if meta.cover == auto {
    frame = image("stylish/frame-gray.svg", width: 93%)
    background = {
      v(page.height * 0.017)
      align(center + top, frame) // top frame
      
      align(center + bottom, rotate(180deg, frame)) // bottom frame
      v(page.height * 0.017)
    }
  }
  
  if break-to != none {pagebreak(to: break-to, weak: true)}
  
  // Insert part page
  page(align(center + horizon, heading), background: background)
}


// Book styling and formatting
#let styling(meta, cfg, body) = {
  import "@preview/nexus-tools:0.1.0": default, get
  import "../utils.typ"
  
  // Override defaults
  cfg.styling.reset = cfg.styling.at("reset", default: false)
  cfg.std-toc = cfg.at("std-toc", default: false)
  
  let h2-count = counter("min-book-h2-count")
  let font-size = default(
    when: text.size == 11pt and not cfg.styling.reset,
    value: 12pt,
    otherwise: 11pt,
    false
  )
  let indent = default(
    when: par.first-line-indent == (amount: 0pt, all: false) and not cfg.styling.reset,
    value: 1em,
    otherwise: par.first-line-indent.amount,
    false
  )
  let pattern = (
    part: (
      "{1:I}:\n",
      "{2:I}.\n",
      "{2:I}.{3:1}.\n",
      "{2:I}.{3:1}.{4:1}.\n",
      "{2:I}.{3:1}.{4:1}.{5:1}.\n",
      "{2:I}.{3:1}.{4:1}.{5:1}.{6:a}.",
    ),
    no-part: (
      "{1:I}.\n",
      "{1:I}.{2:1}.\n",
      "{1:I}.{2:1}.{3:1}.\n",
      "{1:I}.{2:1}.{3:1}.{4:1}.\n",
      "{1:I}.{2:1}.{3:1}.{4:1}.{5:1}.\n",
      "{1:I}.{2:1}.{3:1}.{4:1}.{5:1}.{6:a}.",
    )
  )
  
  // Set default numbering pattern (when cfg.numbering is auto)
  pattern = get.auto-val(
    cfg.numbering,
    if meta.part != none {pattern.part} else {pattern.no-part}
  )
  
  set document(
    title: meta.title + if meta.subtitle != none {" - " + meta.subtitle},
    author: meta.authors,
    date: meta.date,
  )
  set page(
    ..default(
      when: page.margin == auto,
      value: (margin: (x: 15%, y: 14%)),
      cfg.styling.reset,
    ),
    ..default(
      when: repr(page.width) == "595.28pt" and repr(page.height) == "841.89pt",
      value: (paper: "a5"),
      cfg.styling.reset,
    ),
  )
  set par(
    ..default(
      when: par.justify == false,
      value: (justify: true),
      cfg.styling.reset,
    ),
    ..default(
      when: par.leading == 0.65em,
      value: (leading: 0.5em),
      cfg.styling.reset,
    ),
    first-line-indent: indent,
  )
  set text(
    ..default(
      when: text.font == "libertinus serif",
      value: ( font: ("TeX Gyre Pagella", "Book Antiqua") ),
      cfg.styling.reset,
    ),
    size: font-size
  )
  set terms(
    ..default(
      when: terms.separator == h(0.6em, weak: true),
      value: (separator: ": "),
      cfg.styling.reset,
    ),
    ..default(
      when: terms.hanging-indent == 2em,
      value: (hanging-indent: 1em),
      cfg.styling.reset,
    ),
  )
  set list(
    ..default(
      when: list.marker == ([•], [‣], [–]),
      value: ( marker: ([•], [–]) ),
      cfg.styling.reset,
    ),
  )
  set heading(
    numbering: utils.numbering(pattern, part: meta.part, chapter: meta.chapter),
    hanging-indent: 0pt,
    supplement: it => context {
      if meta.part != none and it.depth == 1 {meta.part}
      else if meta.chapter != none {meta.chapter}
      else {auto}
    }
  )
  set outline(
    ..default(
      when: cfg.numbering == none and not cfg.std-toc,
      value: (depth: 2),
      cfg.styling.reset
    ),
  )
  
  show heading: it => {
    set align(center)
    set par(justify: false)
    set text(
      hyphenate: false,
      ..default(
        when: text.weight == "bold" and it.level < 6,
        value: (weight: "regular"),
        cfg.styling.reset
      )
    )
    
    it
  }
  show heading.where(level: 1): set text(size: font-size + 12pt)
  show heading.where(level: 2): set text(size: font-size + 8pt)
  show heading.where(level: 3): set text(size: font-size + 6pt)
  show heading.where(level: 4): set text(size: font-size + 4pt)
  show heading.where(level: 5): set text(size: font-size + 2pt)
  show quote.where(block: true): set pad(x: indent)
  show raw: it => {
    set text(
      size: font-size,
      ..default(
        when: text.font == "dejavu sans mono",
        value: (font: "Inconsolata"),
        cfg.styling.reset
      ),
    )
    
    it
  }
  show raw.where(block: true): it => pad(left: indent, it)
  show math.equation: it => {
    set text(
      ..default(
        when: text.font == "new computer modern math",
        value: ( font: ("Asana Math", "New Computer Modern Math") ),
        cfg.styling.reset
      )
    )
    
    it
  }
  show selector.or(
      terms, enum, list, table, figure, math.equation.where(block: true),
      quote.where(block: true), raw.where(block: true)
    ): set block(above: font-size, below: font-size)
  show ref: it => context {
    let el = it.element
    
    // When referencing headings in "normal" form
    if el != none and el.func() == heading and it.form == "normal" {
      let pattern = pattern
      let number
      
      // Remove \n and trim full stops
      if pattern != none and part != "" {
        import "@preview/numbly:0.1.0": numbly

        pattern = pattern.map( i => i.replace("\n", "").trim(regex("[.:]")) )
        number = numbly(..pattern)(..counter(heading).at(el.location()))
        
        // New reference without \n
        link(el.location())[#el.supplement #number]
      }
      else {link(it.target, el.body)}
    }
    else {it}
  }
  show link: it => {
    if cfg.paper-friendly and type(it.dest) == str and [#it.dest] != it.body {
      it
      footnote(it.dest)
    }
    else {it}
  }
  show outline.entry: it => {
    let condition = it.element.numbering == none and outline.indent == auto
    let prefix = if condition {h(0.5em)} else {it.prefix()}
    let entry = it.indented(prefix, it.inner(), gap: 0em)
    
    if not cfg.std-toc and it.level == 1 and meta.part != none {
      v(font-size, weak: true)
      strong(entry)
    }
    else {entry}
  }

  body
}


// Appearance of #horizontalrule (#hr) command
#let horizontalrule(meta, cfg) = context {
  let spacing = cfg.styling.at("hr-spacing", default: 1.5em)
  let data
  
  if meta.cover == auto {
    let svg = read("stylish/hr.svg")
    
    svg = svg.replace("FILL", text.fill.to-hex()) // same color as text
    data = image(bytes(svg), width: 45%)
  }
  else {data = line(length: 80%, stroke: text.fill)}
  
  v(spacing, weak: true)
  align(
    center,
    block(data, above: 1em, below: 1em)
  )
  v(spacing, weak: true)
}