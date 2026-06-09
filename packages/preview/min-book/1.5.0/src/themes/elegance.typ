#let cover-page(meta, cfg) = context {
  let meta = meta
  let cfg = cfg
  let data
  
  if type(meta.authors) == array {meta.authors = meta.authors.at(0) + " et al."}
  
  cfg.page = (margin: 1.5cm) + cfg.at("page", default: (:))
  cfg.image = cfg.at("image", default: image("elegance/cover-image.png"))
  cfg.publisher = cfg.at("publisher", default: image("elegance/pub.png"))
  cfg.title = (size: 2.1em) + cfg.at("text", default: (:))
  
  cfg.text = (
    font: ("tex gyre adventor", "century gothic"),
    fill: luma(80),
    size: 1.2em,
    weight: "bold",
  ) + cfg.at("text", default: (:))
  
  meta.title = block(
    meta.title,
    width: 100%,
    inset: (bottom: 5pt, rest: cfg.page.margin),
  )
  
  if not meta.is-back-cover {
    data = align(top, {
      set image(width: 100% + 1pt)
      
      text(meta.title, size: cfg.title.size)
      v(-1em)
      cfg.image
      
      set image(width: auto, height: 1.5em)
      
      place(center + bottom, dy: -cfg.page.margin, cfg.publisher)
    })
  }
  else {
    data = align(
      center + horizon,
      text(meta.title, size: cfg.title.size, fill: cfg.text.fill.opacify(-90%))
    )
  }
  
  set text(..cfg.text)
  set page(..cfg.page, numbering: none)
  set par(justify: false, leading: 0.4em)
  
  page(background: data, none)
}


#let title-page(meta, cfg) = {
  let meta = meta
  let cfg = cfg
  let data
  
  if type(meta.authors) == array {meta.authors = meta.authors.join(", ", last: " & ")}
  
  cfg.page = (margin: 1.5cm) + cfg.at("page", default: (:))
  cfg.title = (size: 2.1em) + cfg.at("text", default: (:))
  
  cfg.text = (
    font: ("tex gyre adventor", "century gothic"),
    fill: luma(80),
    size: 1.2em,
    weight: "bold",
  ) + cfg.at("text", default: (:))
  
  data = {
    text(meta.title, size: cfg.title.size)
    
    if meta.subtitle != none {
      line(length: 80%, stroke: cfg.text.fill.opacify(-90%))
      v(0.5em)
      
      meta.subtitle
    }
    
    set align(bottom)
    
    par(meta.volume)
    par(meta.edition)
    par(meta.authors)
  }
  
  set align(center)
  set text(..cfg.text)
  set page(..cfg.page)
  set par(justify: false, leading: 0.4em, spacing: 0.5em)
  
  page(data)
}


#let part(meta, cfg, heading) = {
  set align(end)
  
  cfg = (two-sided: true) + cfg
  
  let break-to = if cfg.two-sided {"odd"} else {none}
  
  pagebreak(to: break-to, weak: true)
  heading
  v(1.5cm)
}


#let styling(meta, cfg, body) = {
  import "@preview/nexus-tools:0.1.0": default, get
  import "../utils.typ"
  
  cfg.std-toc = cfg.at("std-toc", default: false)
  cfg.part-toc = cfg.at("part-toc", default: true)
  cfg.styling = (reset: false) + cfg.styling
  
  let pattern = (
    part: (
      "{1:1}.",
      "{2:1}.",
      "{2:1}.{3:1}.",
      "{2:1}.{3:1}.{4:1}.",
      "{2:1}.{3:1}.{4:1}.{5:1}.",
      "{2:1}.{3:1}.{4:1}.{5:1}.{6:1}.",
    ),
    no-part: "1."
  )
  let font-size = default(
    when: text.size == 11pt and not cfg.styling.reset,
    value: 12pt,
    otherwise: text.size,
    false
  )
  let indent = default(
    when: par.first-line-indent == (amount: 0pt, all: false) and not cfg.styling.reset,
    value: 1em,
    otherwise: par.first-line-indent.amount,
    false
  )
  let auto-numbering = cfg.numbering == auto
  let outline-depth
  
  pattern = get.auto-val(
    cfg.numbering,
    if meta.part != none {pattern.part} else {pattern.no-part}
  )
  
  if meta.part != none {outline-depth += 1}
  if meta.chapter != none {outline-depth += 1}
  
  import "@preview/numbly:0.1.0": numbly
  
  set document(
    title: meta.title + if meta.subtitle != none {" – " + meta.subtitle},
    author: meta.authors,
    date: meta.date,
  )
  set page(
    ..default(
      when: page.margin == auto,
      value: (margin: (x: 2cm, y: 3cm)),
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
    ..default(
      when: par.spacing == 1.2em,
      value: (spacing: 0.75em),
      cfg.styling.reset,
    ),
    first-line-indent: indent,
  )
  set text(
    ..default(
      when: text.font == "libertinus serif",
      value: (font: "tex gyre heros"),
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
      value: (hanging-indent: indent),
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
    numbering: utils.numbering(
      pattern,
      part: meta.part,
      chapter: meta.chapter,
      default: "1.",
    ),
    hanging-indent: 0pt,
    supplement: it => context {
      if meta.part != none and it.depth == 1 {meta.part}
      else if meta.chapter != none {meta.chapter}
      else {auto}
    }
  )
  set outline(
    ..default(
      when: not cfg.std-toc,
      value: (depth: outline-depth),
      cfg.styling.reset
    ),
  )
  
  show heading: it => {
    set par(justify: false)
    set text(
      ..default(
        when: it.level == 1 and (meta.part != none or meta.chapter != none),
        value: (font: "tex gyre adventor"),
        cfg.styling.reset
      ),
      ..default(
        when: it.level == 2 and meta.chapter != none,
        value: (font: "tex gyre adventor"),
        cfg.styling.reset
      ),
      hyphenate: false,
    )
    
    show outline: set text(size: font-size)
    show outline.entry: it => it.indented(none, it.inner())
    
    let minitoc = none
    let back-matter = query(selector(<min-book:back-matter>).before(here())) == ()
    
    if (1, 2).contains(it.level) and it.outlined and back-matter {
      let level = counter(heading).get()
      let font = default(
        when: text.font == "tex gyre adventor",
        value: (font: "nunito"),
        cfg.styling.reset
      )
      let data = none
      let above = 1.44em
      
      if it.level == 1 and meta.part != none {
        data = meta.part + " " + numbly(..pattern, default: none)(..level)
        above = 1.8em
        
        if cfg.part-toc {
          import "@preview/suboutline:0.3.0": suboutline
          
          minitoc = pad(suboutline(indent: 0pt, depth: 1), left: 1cm)
        }
      }
      else if meta.chapter != none {
        if meta.part != none and it.level == 2 {
          data = meta.chapter + " " + numbly(..pattern, default: none)(..level)
        }
        else if it.level == 1 {
          data = meta.chapter + " " + numbly(..pattern, default: none)(..level)
        }
      }
      
      if data != none and auto-numbering {
        block(text(data, size: 1em - 5pt), above: above, below: 0.3em)
        it = block(it.body, above: 0em)
      }
    }
    
    it
    
    align(start, minitoc)
  }
  show heading.where(level: 1): set text(size: font-size + 12pt)
  show heading.where(level: 2): set text(size: font-size + 8pt)
  show heading.where(level: 3): set text(size: font-size + 6pt)
  show heading.where(level: 4): set text(size: font-size + 4pt)
  show heading.where(level: 5): set text(size: font-size + 2pt)
  show raw: it => {
    set text(
      size: font-size,
      ..default(
        when: text.font == "dejavu sans mono",
        value: (font: ("source code pro", "fira mono")),
        cfg.styling.reset
      ),
    )
    
    it
  }
  show raw.where(block: true): it => block(it, width: 100%, inset: (y: 1em))
  show math.equation: it => {
    set text(
      ..default(
        when: text.font == "new computer modern math",
        value: ( font: ("tex gyre pagella math", "asana math") ),
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
      show repeat: none
      
      v(font-size, weak: true)
      strong(entry)
    }
    else {entry}
  }
  
  body
}


#let horizontalrule(meta, cfg) = context {
  let cfg = cfg
  
  cfg.styling = (
    stroke: luma(210),
    hr-spacing: 1.5em,
  ) + cfg.at("styling", default: (:))
  
  set align(center)
  set line(stroke: text.fill.opacify(-90%))
  
  v(cfg.styling.hr-spacing, weak: true)
  text(size: 5pt, {
    line(length: 60%)
    line(length: 70%)
    line(length: 60%)
  })
  v(cfg.styling.hr-spacing, weak: true)
}