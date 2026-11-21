// faboxyst — manual.  Built chapter by chapter (see docs/build-manual.py):
//   typst compile --root . docs/manual.typ --input lang=en --input chapter=fabox out.pdf
#import "_h.typ": *

#let chap = sys.inputs.at("chapter", default: "all")
#let first = int(sys.inputs.at("first", default: "1"))
#let starts = json(bytes(sys.inputs.at("starts", default: "{}")))

#set document(title: "faboxyst — " + T("manual", "manuel"), author: "FERGOUS Abdelhak")
#set page(paper: "a4", margin: (x: 1.55cm, top: 1.7cm, bottom: 1.6cm),
  numbering: "1", number-align: center,
  header: context if counter(page).get().first() > 1 [#set text(size: 7.5pt, fill: luma(130)); faboxyst #pkg.version #h(1fr) #T("manual", "manuel")],
)
#set text(font: ("Libertinus Serif", "DejaVu Serif"), size: 9.2pt, lang: lang)
#set par(justify: true, leading: 0.58em)
#show raw: set text(font: mono, size: 0.86em)
#show heading.where(level: 1): it => { set text(size: 21pt, fill: accent, weight: "bold"); block(below: 6pt, it.body); line(length: 100%, stroke: 1.2pt + accent); v(3pt) }
#show heading.where(level: 2): it => { set text(size: 13pt, fill: accent); block(above: 11pt, below: 4pt, it.body) }
#show heading.where(level: 3): it => { set text(size: 11pt, fill: black); it.body }
#show link: set text(fill: accent)
#counter(page).update(first)

#let cover() = {
  set page(header: none, margin: 1.6cm)
  v(1fr)
  align(center, {
    text(size: 54pt, weight: "bold", fill: accent, font: ("xkcd Script", "DejaVu Sans"))[faboxyst]
    v(2pt)
    text(size: 14pt)[#T("Hand-drawn boxes, frames and teaching blocks for Typst", "Boîtes, cadres et blocs pédagogiques dessinés à la main pour Typst")]
    v(4pt)
    text(size: 10pt, fill: luma(90))[#T("Reference manual", "Manuel de référence") · v#pkg.version]
  })
  v(14pt)
  {
    set text(size: 8.5pt)
    grid(columns: (1fr, 1fr, 1fr), gutter: 12pt,
      fb.fabox(title: [fabox], colour: rgb("#c0392b"))[#T("The all-purpose box.", "La boîte à tout faire.")],
      fb.note[#T("Semantic blocks.", "Blocs sémantiques.")],
      fb.plaque(title: [plaque])[#T("Curling plates.", "Plaques enroulées.")],
      fb.coilbox(title: [coilbox])[#T("Spiral notebook.", "Cahier spirale.")],
      fb.plankbox(title: [plankbox])[#T("Wooden plank.", "Planche de bois.")],
      fb.tornpage(title: [tornpage])[#T("Torn page.", "Page déchirée.")],
    )
  }
  v(1fr)
  align(center, text(size: 9pt, fill: luma(80))[#pkg.authors.first() · #link("https://github.com/fergousA/faboxyst")[github.com/fergousA/faboxyst] · #T("MIT licence", "licence MIT")])
}

#let toc() = {
  heading(level: 1, T("Contents", "Sommaire"))
  v(4pt)
  grid(columns: (auto, auto, 1fr, auto), gutter: 4pt, [*1.*], T("What's new in v0.3.0", "Nouveautés de la v0.3.0"), box(width: 100%, repeat[.]), [#starts.at("whatsnew", default: none)])
  v(1pt)
  grid(columns: (auto, auto, 1fr, auto), gutter: 4pt, [*2.*], T("Getting started", "Prise en main"), box(width: 100%, repeat[.]), [#starts.at("start", default: none)])
  v(6pt)
  for (i, c) in chapters.enumerate() {
    let pg = starts.at(c.id, default: none)
    grid(columns: (auto, auto, 1fr, auto), gutter: 4pt, [*#(i + 3).*], T(c.en, c.fr), box(width: 100%, repeat[.]), [#if pg != none [#pg]])
    v(1pt)
    text(size: 7.8pt, fill: luma(100), c.names.map(n => raw(n)).join(", ") + if c.names.len() > 0 { "." } else { "" })
    v(5pt)
  }
  grid(columns: (auto, auto, 1fr, auto), gutter: 4pt, [*#(chapters.len() + 3).*], T("Aliases and index", "Alias et index"), box(width: 100%, repeat[.]), [#starts.at("aliases", default: none)])
}

#let chapter(c) = {
  chapter-head(c)
  for n in c.names { entry(n) }
  values-table(c.values)
}

#if chap == "cover" { cover() }
#if chap == "whatsnew" { include "whatsnew.typ" }
#if chap == "toc" { toc() }
#if chap == "start" { include "start.typ" }
#for c in chapters { if chap == c.id { chapter(c) } }
#if chap == "aliases" { include "aliases.typ" }
