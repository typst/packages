#import "@preview/hydra:0.6.0": hydra


#let titlepage(
  name: [Ihr Familienname],
  vorname: [Ihr Vorname],
  gebdatum: [Ihr Geburtsdatum],
  ort: [Ihr Geburtsort],
  betreuer: [Titel Vorname Familienname Ihres Betreuers],
  institut: [Institut ihres Betreuers],
  thema: [Titel ihrer Arbeit],
  datum: [tt. mm. jjjj],
  studiengang: [Studiengang],
  thesis: "bsc",
  // body,
) = {
  let arbeit = if thesis == "bsc" [Bachelorabeit] else [Masterarbeit]

  set page(
    margin: 3cm,
  )
  set text(
    size: 12pt,
    font: "Latin Modern Roman",
  )
  set align(center)
  let space = 0pt
  // https://tex.stackexchange.com/questions/24599/what-point-pt-font-size-are-large-etc ... dont ask!
  let large(body) = text(size: 14.4pt)[#body]
  let Large(body) = text(size: 17.28pt)[#body]
  let LARGE(body) = text(size: 20.74pt)[#body]
  let Huge(body) = text(size: 24.88pt)[#body]

  show smallcaps: set text(font: "Latin Modern Roman Caps")

  // Font-Source: https://www.1001fonts.com/latin-modern-roman-font.html
  text(
    font: "Latin Modern Roman 17",
    weight: "thin",
  )[
    #Large[Technische Universität Dresden #text(font: "New Computer Modern Math")[#sym.circle.filled.small] Fakultät für Mathematik]
  ]
  v(1fr)
  Huge[*#thema*]
  v(1fr)
  LARGE[
    #arbeit #v(space)
    zur Erlangung des ersten Hochschulgrades #v(space)
    #if thesis == "bsc" [
      *_Bachelor of Science_ (_B.Sc._)*
    ] else [
      *_Master of Science_* \
      *(_#studiengang _)* \
      *(_M.Sc._)*
    ]

  ]
  v(1fr)
  v(1fr)
  v(1fr)
  [
    #set text(weight: "thin")
    vorgelegt von #v(space)
    #smallcaps[#vorname] #upper[#name] #v(space)
    (geboren am #gebdatum in #smallcaps[#ort]) #v(space)
    Tag der Einreichung: #datum #v(space)
    #betreuer (#institut)
  ]
  v(1fr)
  pagebreak(weak: true)
}

#let selbständigkeit(
  betreuer: [Titel Vorname Familienname Ihres Betreuers],
  thema: [Titel ihrer Arbeit],
  datum: [tt. mm. jjjj],
  thesis: "bsc",
) = {
  set page(margin: 3cm)
  set heading(numbering: none)
  heading(outlined: false)[Erklärung]
  let arbeit = if thesis == "bsc" [Bachelorabeit] else [Masterarbeit]
  [
    Hiermit erkläre ich, dass ich die am #datum eingereichte #arbeit zum Thema _#thema _ unter Betreuung von #betreuer selbstständig erarbeitet, verfasst und Zitate kenntlich gemacht habe. Andere als die angegebenen Hilfsmittel wurden von mir nicht benutzt.
    #v(2cm)
    Dresden, #datum #h(1fr) Unterschrift
  ]
}

#let classic-tud-math-thesis(
  name: [Ihr Familienname],
  vorname: [Ihr Vorname],
  gebdatum: [Ihr Geburtsdatum],
  ort: [Ihr Geburtsort],
  betreuer: [Vollständiger akad. Titel (z.B. Prof. Dr. rer. nat. habil.) Vorname Familienname Ihres Betreuers / Ihrer Betreuerin],
  betreuer-kurz: [Kurzer akad. Titel (z.B. Prof. Dr.) Vorname Familienname Ihres Betreuers / Ihrer Betreuerin],
  institut: [Institut ihres Betreuers],
  thema: [Titel ihrer Arbeit],
  datum: [tt. mm. jjjj],
  abschluss: "bsc",
  studiengang: [Mathematik oder Technomathematik oder Wirtschaftsmathematik],
  use_default_math_env: true,
  body,
) = {
  set page(
    margin: 3cm,
    paper: "a4",
  )
  set par(justify: true)
  set text(
    font: "Latin Modern Roman",
    size: 12pt,
    lang: "de",
  )
  set math.equation(numbering: "(1a)")
  // Links
  // show link: set text(fill: rgb(0, 0, 238))
  // Überschriften
  set heading(numbering: "1.1.1")
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    set block(
      below: 1cm,
    )
    v(3cm)
    [*#it*]
  }
  show heading: it => {
    set text(font: "Latin Modern Sans")
    set block(below: 1em)
    let level = it.level
    if level == 1 {
      set text(size: 1.8em)
      [*#it*]
    } else if level == 2 {
      set text(size: 1.5em)
      [*#it*]
    } else {
      [*#it*]
    }
  }
  // Variablen
  let header = context {
    if query(heading.where(level: 1)).find(h => h.location().page() == here().page()) != none {} else {
      rect(
        stroke: (bottom: 1pt + black),
        width: 100%,
      )[
        #upper()[#hydra(1)]
      ]
    }
  }

  show: if (use_default_math_env) {
    import "@preview/great-theorems:0.1.2": great-theorems-init
    great-theorems-init
  }

  titlepage(
    name: name,
    vorname: vorname,
    gebdatum: gebdatum,
    ort: ort,
    betreuer: betreuer,
    institut: institut,
    thema: thema,
    datum: datum,
    studiengang: studiengang,
    thesis: abschluss,
  )
  set page(
    header: header,
    numbering: "- 1 -",
  )
  outline()
  body
  set page(
    numbering: none,
  )
  selbständigkeit(
    betreuer: betreuer-kurz,
    thema: thema,
    datum: datum,
    thesis: abschluss,
  )
}
