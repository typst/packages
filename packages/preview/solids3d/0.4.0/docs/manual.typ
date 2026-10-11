// solids3d — manual (English / Français)
// Build:  typst compile --root . docs/manual.typ docs/manual-en.pdf
//         typst compile --root . --input lang=fr docs/manual.typ docs/manual-fr.pdf
// (add --input ns=local for the local-install edition)
// The recommended way is `python3 docs/build-manual.py` : it builds the chapters one by one
// (memory!) and merges them into a single PDF with bookmarks and page numbers.
#import "_h.typ": *
#import "_cover.typ": cover-mosaic

#let part = sys.inputs.at("part", default: "all")
#let parts = ("part1", "ref-fig", "ref-solids", "ref-paths", "ref-view", "ref-styles", "ref-ornaments", "ref-edu", "part3")

#set document(title: "solids3d " + pkg.version + " — " + T("manual", "manuel"), author: "FERGOUS Abdelhak")
#set page(paper: "a4", margin: (x: 2.1cm, y: 2.2cm),
  footer: context {
    if part == "stamp" {
      if counter(page).get().first() > 1 { set text(8pt, fill: luma(120)); align(right)[#counter(page).display()] }
    } else if part == "all" {
      if counter(page).get().first() > 1 [
        #set text(8pt, fill: luma(120))
        solids3d #pkg.version · #T("Reference manual", "Manuel de référence") #h(1fr) #counter(page).display()
      ]
    } else if part != "front" {
      set text(8pt, fill: luma(120))
      [solids3d #pkg.version · #T("Reference manual", "Manuel de référence")]
    }
  })
#set text(font: ("Libertinus Serif", "DejaVu Serif"), size: 10.5pt, lang: lang)
#set par(justify: true)
#show raw: it => if ns == "local" and it.text.contains("@preview/") { raw(it.text.replace("@preview/", "@local/"), lang: it.lang, block: it.block) } else { it }
#show raw: set text(font: ("DejaVu Sans Mono",), size: 8.6pt)
#show raw.where(block: true): set par(justify: false)
#show raw.where(block: false): it => box(fill: luma(240), inset: (x: 2pt), outset: (y: 2pt), radius: 1.5pt, it)
#show heading.where(level: 1): it => { pagebreak(weak: true); v(4pt); text(20pt, fill: accent, it); v(4pt); line(length: 100%, stroke: 0.6pt + accent); v(4pt) }
#show heading.where(level: 2): it => { v(10pt); text(13.5pt, fill: accent, it); v(2pt) }
#show heading.where(level: 3): it => { text(11.5pt, fill: accent, it.body); v(-2pt) }
#show link: set text(fill: rgb("#1a4f8b"))

// ───────────────────────────────────────────────────────── front matter
#let cover() = page(margin: (x: 1.5cm, top: 1.4cm, bottom: 1.2cm), footer: none)[
  #align(center)[
    #v(0.2cm)
    #text(38pt, weight: "bold", fill: accent)[solids3d]
    #v(-0.1cm)
    #text(12pt)[#T("3D solids, knots and engraved figures for Typst — one function: fig()", "Solides 3D, nœuds et figures gravées pour Typst — une seule fonction : fig()")]
    #v(0.15cm)
    #text(16pt, weight: "bold")[#T("Reference manual", "Manuel de référence")]
    #h(0.5cm)
    #text(10pt, fill: luma(90))[#T("Version", "Version") #pkg.version · Typst ≥ 0.15 · #pkg.license]
    #v(0.1cm)
    #text(9pt, fill: luma(90))[#T("Author", "Auteur") #pkg.authors.first()]
    #v(0.5cm)
    #cover-mosaic()
  ]
]

#let toc-line(e) = {
  let lvl = e.at(0)
  if lvl == 1 { v(5pt) }
  box(width: 100%, {
    set text(weight: if lvl == 1 { "bold" } else { "regular" }, size: if lvl == 1 { 10.5pt } else { 9.5pt })
    h(if lvl == 1 { 0pt } else { 1.2em })
    e.at(1)
    box(width: 1fr, repeat[#text(fill: luma(150))[.] ])
    str(e.at(2))
  })
}

#let front() = {
  cover()
  let toc = if "toc" in sys.inputs { json(sys.inputs.toc) } else { () }
  text(20pt, weight: "bold", fill: accent)[#T("Contents", "Sommaire")]
  v(6pt)
  for e in toc.filter(e => e.at(0) <= 2) { toc-line(e) }
  pagebreak()
  text(20pt, weight: "bold", fill: accent)[#T("Index of functions", "Index des fonctions")]
  v(6pt)
  let names = toc.filter(e => e.at(0) == 3).sorted(key: e => lower(e.at(1)))
  set text(9pt)
  columns(2, for e in names { box(width: 100%, { text(font: "DejaVu Sans Mono", size: 8pt, e.at(1)); box(width: 1fr, repeat[#text(fill: luma(150))[.] ]); str(e.at(2)) }); linebreak() })
}

#{
  if part == "front" { front() }
  else if part == "stamp" { for i in range(int(sys.inputs.n)) { page[#none] } }
  else if part == "all" { front(); for p in parts { include (p + ".typ") } }
  else { include (part + ".typ") }
}
