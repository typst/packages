#let template-color = state("template-color", rgb("#4d1d14"))
#let template-lang = state("template-lang", "en")

#let img(path, width: 80%, pos: center, desc: none, alt: none, side-text: none, side: left) = {
  let alt-text = if alt != none { alt } else { desc }
  let img-content = image(path, width: 100%, alt: alt-text)
  
  let img-block = if desc != none {
    figure(img-content, caption: desc, numbering: "1", kind: image)
  } else {
    img-content
  }

  if side-text != none {
    let img-col = width
    let text-col = 1fr

    let cols = if side == left {
      (img-col, text-col)
    } else {
      (text-col, img-col)
    }

    grid(
      columns: cols,
      gutter: 1.5em,
      align: (horizon, horizon),
      ..if side == left {
        (img-block, side-text)
      } else {
        (side-text, img-block)
      }
    )
  } else {
    align(pos, box(width: width, img-block))
  }
}

#let project(
  title: "",
  subtitle: "",
  author: "",
  affiliation: "", 
  year: "",
  logo: none,
  toc: false,
  is-appendix: false, 
  main-color: rgb("#4d1d14"),
  lang: "en",
  body
) = {

  let authors-list = if type(author) == array { author } else { (author,) }
  let authors-string = authors-list.join(", ")

  let resolved-color = if type(main-color) == str { rgb(main-color) } else { main-color }

  set document(author: authors-list, title: title)
  set page(paper: "a4", margin: (top: 3cm, bottom: 2.5cm, x: 2cm))
  set text(font: "IBM Plex Mono", size: 11pt, lang: lang)

  set heading(numbering: "1.1.")

  set list(marker: text(fill: resolved-color)[•])
  set enum(numbering: (n) => text(fill: resolved-color)[#n.])

  show heading: set text(fill: resolved-color, weight: "bold")
  show heading: set block(above: 1.5em, below: 1em)

  show raw.where(block: true): it => {
    block(
      fill: luma(240),
      inset: 12pt,
      radius: 4pt,
      width: 100%,
      stroke: (left: 4pt + resolved-color), 
      {
        show raw: set text(font: "Cascadia Code", size: 10pt)
        set par(justify: false)
        raw(it.text, lang: it.lang, block: false)
      }
    )
  }

  page(header: none, footer: none)[
    #set align(center + horizon)
    
    #if logo != none {
      if type(logo) == str { image(logo, width: 30%) } else { logo }
      v(2em)
    }

    #text(size: 24pt, weight: "bold", fill: resolved-color)[#title]
    #v(1em)
    #text(size: 16pt, style: "italic")[#subtitle]
    
    #v(2em)
    #line(length: 50%, stroke: 2pt + resolved-color)
    #v(2em)
    
    #text(size: 14pt, weight: "bold")[#authors-string] \
    #v(0.5em)
    
    #if affiliation != "" [
      #text(size: 12pt, style: "italic")[#affiliation]
      #v(0.5em)
    ]
    
    #text(size: 12pt)[#year]
  ]

  if toc {
    if is-appendix {
      counter(page).update(1)
      counter(heading).update(0)
      context outline(
        title: auto,
        indent: auto,
        depth: 3,
        target: selector(heading).after(here()),
      )
    } else {
      context {
        let markers = query(<new-section>)
        let target-headings = if markers.len() > 0 {
          selector(heading).before(markers.first().location())
        } else {
          selector(heading)
        }
        
        outline(
          title: auto,
          indent: auto,
          depth: 3,
          target: target-headings,
        )
      }
    }
  }

  set page(
    numbering: "1", 
    number-align: right,
    
    header: context { 
      let before = query(selector(heading.where(level: 1)).before(here()))
      let after = query(selector(heading.where(level: 1)).after(here()))
      let current-heading = none
      
      if before.len() > 0 {
        current-heading = before.last()
      } else if after.len() > 0 {
        let first-after = after.first()
        if first-after.location().page() == here().page() {
          current-heading = first-after
        }
      }
      if current-heading != none {
        align(right)[
          #text(size: 9pt, style: "italic", fill: resolved-color)[
            #if current-heading.numbering != none {
              numbering(current-heading.numbering, ..counter(heading).at(current-heading.location()))
              [ ] 
            }
            #current-heading.body
          ]
          #v(-8pt)
          #line(length: 100%, stroke: 0.5pt + resolved-color.lighten(40%))
        ]
      }
    }
  )
  
  counter(page).update(1)
  template-color.update(resolved-color)
  template-lang.update(lang) 
  
  body
}

#let i18n-dict = (
  it: (
    adt: "Abstract Data Type",
    rep: "Cosa rappresenta:",
    impl: "Metodi di implementazione:",
    func: "Funzioni principali:",
    algo: "Algoritmo",
    desc: "Descrizione:",
    work: "Funzionamento:",
    comp: "Complessità:",
    use: "Casi d'uso:",
    pseudo: "Pseudocodice:"
  ),
  en: (
    adt: "Abstract Data Type",
    rep: "What it represents:",
    impl: "Implementation methods:",
    func: "Functions:",
    algo: "Algorithm",
    desc: "Description:",
    work: "How it works:",
    comp: "Complexity:",
    use: "Use cases:",
    pseudo: "Pseudocode:"
  )
)

#let template-color = state("template-color", rgb("#4d1d14"))
#let template-lang = state("template-lang", "en")

#let img(path, width: 80%, pos: center, desc: none, alt: none, side-text: none, side: left) = {
  let alt-text = if alt != none { alt } else { desc }
  let img-content = image(path, width: 100%, alt: alt-text)
  
  let img-block = if desc != none {
    figure(img-content, caption: desc, numbering: "1", kind: image)
  } else {
    img-content
  }

  if side-text != none {
    let img-col = width
    let text-col = 1fr

    let cols = if side == left {
      (img-col, text-col)
    } else {
      (text-col, img-col)
    }

    grid(
      columns: cols,
      gutter: 1.5em,
      align: (horizon, horizon),
      ..if side == left {
        (img-block, side-text)
      } else {
        (side-text, img-block)
      }
    )
  } else {
    align(pos, box(width: width, img-block))
  }
}

#let project(
  title: "",
  subtitle: "",
  author: "",
  affiliation: "", 
  year: "",
  logo: none,
  toc: false,
  is-appendix: false, 
  main-color: rgb("#4d1d14"),
  lang: "en",
  body
) = {

  let authors-list = if type(author) == array { author } else { (author,) }
  let authors-string = authors-list.join(", ")

  let resolved-color = if type(main-color) == str { rgb(main-color) } else { main-color }

  set document(author: authors-list, title: title)
  set page(paper: "a4", margin: (top: 3cm, bottom: 2.5cm, x: 2cm))
  set text(font: "IBM Plex Mono", size: 11pt, lang: lang)

  set heading(numbering: "1.1.")

  set list(marker: text(fill: resolved-color)[•])
  set enum(numbering: (n) => text(fill: resolved-color)[#n.])

  show heading: set text(fill: resolved-color, weight: "bold")
  show heading: set block(above: 1.5em, below: 1em)

  show raw.where(block: true): it => {
    block(
      fill: luma(240),
      inset: 12pt,
      radius: 4pt,
      width: 100%,
      stroke: (left: 4pt + resolved-color), 
      {
        show raw: set text(font: "Cascadia Code", size: 10pt)
        set par(justify: false)
        raw(it.text, lang: it.lang, block: false)
      }
    )
  }

  page(header: none, footer: none)[
    #set align(center + horizon)
    
    #if logo != none {
      if type(logo) == str { image(logo, width: 30%) } else { logo }
      v(2em)
    }

    #text(size: 24pt, weight: "bold", fill: resolved-color)[#title]
    #v(1em)
    #text(size: 16pt, style: "italic")[#subtitle]
    
    #v(2em)
    #line(length: 50%, stroke: 2pt + resolved-color)
    #v(2em)
    
    #text(size: 14pt, weight: "bold")[#authors-string] \
    #v(0.5em)
    
    #if affiliation != "" [
      #text(size: 12pt, style: "italic")[#affiliation]
      #v(0.5em)
    ]
    
    #text(size: 12pt)[#year]
  ]

  if toc {
    if is-appendix {
      counter(page).update(1)
      counter(heading).update(0)
      context outline(
        title: auto,
        indent: auto,
        depth: 3,
        target: selector(heading).after(here()),
      )
    } else {
      context {
        let markers = query(<new-section>)
        let target-headings = if markers.len() > 0 {
          selector(heading).before(markers.first().location())
        } else {
          selector(heading)
        }
        
        outline(
          title: auto,
          indent: auto,
          depth: 3,
          target: target-headings,
        )
      }
    }
  }

  set page(
    numbering: "1", 
    number-align: right,
    
    header: context { 
      let before = query(selector(heading.where(level: 1)).before(here()))
      let after = query(selector(heading.where(level: 1)).after(here()))
      let current-heading = none
      
      if before.len() > 0 {
        current-heading = before.last()
      } else if after.len() > 0 {
        let first-after = after.first()
        if first-after.location().page() == here().page() {
          current-heading = first-after
        }
      }
      if current-heading != none {
        align(right)[
          #text(size: 9pt, style: "italic", fill: resolved-color)[
            #if current-heading.numbering != none {
              numbering(current-heading.numbering, ..counter(heading).at(current-heading.location()))
              [ ] 
            }
            #current-heading.body
          ]
          #v(-8pt)
          #line(length: 100%, stroke: 0.5pt + resolved-color.lighten(40%))
        ]
      }
    }
  )
  
  counter(page).update(1)
  template-color.update(resolved-color)
  template-lang.update(lang) 
  
  body
}

#let i18n-dict = (
  it: (
    adt: "Abstract Data Type",
    rep: "Cosa rappresenta:",
    impl: "Metodi di implementazione:",
    func: "Operazioni / Funzioni principali:",
    algo: "Algoritmo",
    desc: "Descrizione:",
    work: "Funzionamento:",
    comp: "Complessità:",
    use: "Casi d'uso:",
    pseudo: "Pseudocodice:"
  ),
  en: (
    adt: "Abstract Data Type",
    rep: "What it represents:",
    impl: "Implementation methods:",
    func: "Main operations / functions:",
    algo: "Algorithm",
    desc: "Description:",
    work: "How it works:",
    comp: "Complexity:",
    use: "Use cases:",
    pseudo: "Pseudocode:"
  )
)

#let adt-card(
  name: "",
  desc: none,
  image: none,
  impl: none,
  funcs: none
) = context {
  let mc = template-color.get()
  let lang = template-lang.get()
  
  let l = if lang in i18n-dict.keys() { lang } else { "en" }
  let t = i18n-dict.at(l)
  
  block(
    width: 100%,
    stroke: 1pt + mc.lighten(40%),
    radius: 4pt,
    clip: true,
    breakable: false,
    [
      #block(
        width: 100%,
        fill: mc.lighten(85%),
        inset: (x: 12pt, y: 8pt),
        stroke: (bottom: 1pt + mc.lighten(40%))
      )[
        #text(size: 13pt, weight: "bold", fill: mc)[#name]
        #h(1fr)
        #text(size: 10pt, style: "italic", fill: mc.lighten(20%))[#t.adt]
      ]
      #block(inset: 12pt, width: 100%)[
        #if desc != none [
          #text(weight: "bold", fill: mc)[#t.rep] \
          #desc
          #v(0.5em)
        ]
        #if image != none [
          #align(center)[#image]
          #v(0.5em)
        ]
        #if impl != none [
          #text(weight: "bold", fill: mc)[#t.impl] \
          #impl
          #v(0.5em)
        ]
        #if funcs != none [
          #text(weight: "bold", fill: mc)[#t.func] \
          #funcs
        ]
      ]
    ]
  )
}

#let algo-card(
  name: "",
  desc: none,
  image: none,
  working: none,
  complexity: none,
  use-cases: none,
  pseudo: none
) = context {
  let mc = template-color.get()
  let lang = template-lang.get()
  
  let l = if lang in i18n-dict.keys() { lang } else { "en" }
  let t = i18n-dict.at(l)
  
  block(
    width: 100%,
    stroke: 1pt + mc.lighten(40%),
    radius: 4pt,
    clip: true,
    breakable: false,
    [
      #block(
        width: 100%,
        fill: mc.lighten(85%),
        inset: (x: 12pt, y: 8pt),
        stroke: (bottom: 1pt + mc.lighten(40%))
      )[
        #text(size: 13pt, weight: "bold", fill: mc)[#name]
        #h(1fr)
        #text(size: 10pt, style: "italic", fill: mc.lighten(20%))[#t.algo]
      ]
      #block(inset: 12pt, width: 100%)[
        #if desc != none [
          #text(weight: "bold", fill: mc)[#t.desc] \
          #desc
          #v(0.5em)
        ]
        #if image != none [
          #align(center)[#image]
          #v(0.5em)
        ]
        #if working != none [
          #text(weight: "bold", fill: mc)[#t.work] \
          #working
          #v(0.5em)
        ]
        #if complexity != none or use-cases != none [
          #grid(
            columns: (1fr, 1fr),
            gutter: 1.5em,
            if complexity != none [
              #text(weight: "bold", fill: mc)[#t.comp] \
              #complexity
            ],
            if use-cases != none [
              #text(weight: "bold", fill: mc)[#t.use] \
              #use-cases
            ]
          )
          #v(0.5em)
        ]
        #if pseudo != none [
          #text(weight: "bold", fill: mc)[#t.pseudo] \
          #pseudo
        ]
      ]
    ]
  )
}