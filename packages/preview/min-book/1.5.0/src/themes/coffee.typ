#let cover-page(meta, cfg) = context {
  import "@preview/catppuccin:1.0.1": get-flavor
  
  let flavor = get-flavor(cfg.at("flavor", default: "mocha"))
  let palette = flavor.colors
  let main-grad = (palette.peach.rgb, palette.mauve.rgb)
  let meta = meta
  let cfg = cfg
  
  if type(meta.authors) == array {meta.authors = meta.authors.at(0) + " et al."}
  
  cfg.back = cfg.at("back", default: true)
  
  cfg.page = (
    margin: (x: 1.5cm, y: 0pt),
    fill: palette.mantle.rgb,
    background: place(bottom, dy: -1.5cm, block(
      if not cfg.back {align(center, meta.authors)} else {""},
      width: 100%,
      outset: 1.5cm,
      fill: palette.crust.rgb,
    )),
    numbering: none,
  ) + cfg.at("page", default: (:))
  
  cfg.title = (
    size: page.width * 0.06,
    weight: "bold",
    font: "jellee roman"
  ) + cfg.at("title", default: (:))
  
  cfg.text = (
    size: page.width * 0.035,
    font: "nunito",
  ) + cfg.at("text", default: (:))
  
  set page(..cfg.page)
  set text(..cfg.text)
  set par(justify: false)
  
  meta.title = {
    line(length: 100%, stroke: gradient.linear(..main-grad, angle: 50deg))
    if not meta.is-back-cover {
      align(right, text(
        meta.title,
        fill: gradient.linear(..main-grad, angle: 60deg),
        ..cfg.title
      ))
    }
  }
  
  page(place(right + horizon, dy: -3cm, meta.title), ..cfg.page)
}


#let title-page(meta, cfg) = context {
  import "@preview/catppuccin:1.0.1": get-flavor
  
  let flavor = get-flavor(cfg.at("flavor", default: "mocha"))
  let palette = flavor.colors
  let main-grad = (
    flavor.colors.peach.rgb,
    flavor.colors.mauve.rgb,
  )
  let meta = meta
  let cfg = cfg
  let data = (top: none, horizon: none, bottom: none)
  
  if type(meta.authors) == array {meta.authors = meta.authors.join(", ")}
  
  cfg.title = (
    size: page.width * 0.06,
    weight: "bold",
    font: "jellee roman",
    fill: palette.pink.rgb,
  ) + cfg.at("title", default: (:))
  
  cfg.text = (
    size: page.width * 0.035,
    font: "nunito",
    fill: palette.subtext0.rgb,
  ) + cfg.at("text", default: (:))
  
  set text(..cfg.text)
  set par(justify: false)
  
  data.top = align(center + top, {
    par(text(meta.title, ..cfg.title))
    par(text(meta.subtitle, ..cfg.text))
  })
  data.horizon = align(center + horizon, text(meta.authors, ..cfg.text))
  data.bottom = align(center + bottom, text(meta.edition, ..cfg.text))
  
  page(data.top + data.horizon + data.bottom)
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
  import "@preview/catppuccin:1.0.1": catppuccin, get-flavor
  import "@preview/nexus-tools:0.1.0": default, get
  import "../utils.typ"
  
  cfg.std-toc = cfg.at("std-toc", default: false)
  cfg.styling = (
    flavor: "mocha",
    reset: false,
  ) + cfg.styling
  
  let flavor = get-flavor(cfg.styling.flavor)
  let palette = flavor.colors
  let pattern = (
    part: ("{1:1}.", if meta.chapter != none {"{2:1}"}),
    no-part: (if meta.chapter != none {"{2:1}\n"})
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
  let outline-depth
  
  pattern = get.auto-val(
    cfg.numbering,
    if part != none {pattern.part} else {pattern.no-part}
  )
  cfg.numbering = utils.numbering(
    pattern,
    part: meta.part,
    chapter: meta.chapter,
    default: none,
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
      value: ( font: ("nunito") ),
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
    numbering: (..level) => context {
      let before-toc = query(selector(<toc:inserted>).before(here())) == ()
      let pattern = pattern
      
      if before-toc {
        if type(pattern) != array {pattern = (pattern,)}
        pattern = pattern.map(
          item => if type(item) == str { item.trim(regex("\n+")) } else {item}
        )
        
        numbly(..pattern, default: none)(..level)
        h(0.5em)
      }
      else {none}
    },
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
    )
  )
  
  show heading: it => {
    let this = it
    
    if (1, 2).contains(it.level) and it.outlined {
      let level = counter(heading).get()
      let font = default(
        when: text.font == "jellee roman",
        value: (font: "nunito"),
        cfg.styling.reset
      )
      let data = none
      let em = 1.44em
      
      if it.level == 1 and meta.part != none {
        data = meta.part + " " + numbly(..pattern, default: none)(..level)
        em = 1.8em
      }
      else if meta.chapter != none {
        if meta.part != none and it.level == 2 {
          data = meta.chapter + " " + numbly(..pattern, default: none)(..level)
        }
        else if it.level == 1 {
          data = meta.chapter + " " + numbly(..pattern, default: none)(..level)
        }
      }
      
      if data != none {
        block(text(data, size: 1em - 5pt), above: em)
        this = block(it, above: 0.2em)
      }
    }
    
    set par(justify: false)
    set text(
      ..default(
        when: it.level == 1 and (meta.part != none or meta.chapter != none),
        value: (font: "jellee roman"),
        cfg.styling.reset
      ),
      ..default(
        when: it.level == 2 and meta.chapter != none,
        value: (font: "jellee roman"),
        cfg.styling.reset
      ),
      hyphenate: false,
    )
    
    this
  }
  show heading.where(level: 1): set text(size: font-size + 12pt)
  show heading.where(level: 2): set text(size: font-size + 8pt)
  show heading.where(level: 3): set text(size: font-size + 6pt)
  show heading.where(level: 4): set text(size: font-size + 4pt)
  show heading.where(level: 5): set text(size: font-size + 2pt)
  show quote: set text(fill: palette.subtext1.rgb)
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
  show raw.where(block: true): it => block(
    it,
    fill: palette.crust.rgb,
    width: 100%,
    inset: (y: 1em),
    outset: (x: 1em)
  )
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
  show: catppuccin.with(flavor)
  
  body
}


#let horizontalrule(meta, cfg) = {
  import "@preview/catppuccin:1.0.1": catppuccin, get-flavor
  
  cfg.styling = (
    flavor: "mocha",
    hr-spacing: 1.5em,
  ) + cfg.at("styling", default: (:))
  
  let flavor = get-flavor(cfg.styling.flavor)
  let palette = flavor.colors
  let svg = read("coffee/hr.svg")
  let data = bytes(svg.replace("BLUE", palette.lavender.hex))
  
  v(cfg.styling.hr-spacing, weak: true)
  align(center, image(data, width: 40%))
  v(cfg.styling.hr-spacing, weak: true)
}