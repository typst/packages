#import "configs.typ": *
#import "styling.typ": *
#import "locale.typ": *

#let mkblock(font, weight, size, vup, vdown) = {
  it => align(center)[
    #v(vup)
    #block(text(font: font, weight: weight, size: size, it))
    #v(vdown)
  ]
}

#let mkauthor(font, size, vup, vdown) = {
  list => align(center)[
    #v(vup)
    #pad(
      top: 0.5em,
      bottom: 0.5em,
      x: 2em,
      if type(list) == array {
        grid(
          columns: (1fr,) * calc.min(3, list.len()),
          gutter: 1em,
          ..list.map(list => align(center, text(font: font, size: size, list))),
        )
      } else {
        align(center, text(font: font, size: size, list))
      },
    )
    #v(vdown)
  ]
}

#let mkabstract(font, size, vup, vdown) = {
  (abstract, keywords, lang: "zh") => [
    #v(vup)
    #set par(first-line-indent: 0em, leading: 1.1em)
    #v(2pt)
    *#localize("abstract", lang: lang): *#abstract
    #v(1pt)
    #if keywords != () [
      *#localize("keywords", lang: lang): * #text(font: kai, keywords.join(localize("keywords-separator", lang: lang) + " "))
    ]
    #v(vdown)
  ]
}

#let mkpreface(font, size, vup, vdown) = {
  (it, lang: "zh") => [
    #v(vup)
    #text(font: font, size: size)[#align(center)[#localize("preface", lang: lang)]
    ]
    #set par(first-line-indent: 2em, leading: 1.1em)
    #v(2pt)
    #it
    #v(vdown)
  ]
}

#let mkcontent(vup, vdown) = content-depth => {
  set par(first-line-indent: 2em, leading: 1em)
  show outline.entry.where(level: 1): it => {
    v(0.5em)
    set text(15pt)
    strong(it)
  }
  set outline.entry(fill: repeat("  ·"))
  outline(indent: auto, depth: content-depth)
  v(15pt)
  newpara()
}

#let article = (
  mktitle: mkblock(font.title, 700, 2.3em, 0em, 0em),
  mkinfo: mkblock(font.author, 500, 1.5em, 0.5em, 0em),
  mkauthor: mkauthor(font.author, 1.1em, 0em, 0em),
  mktime: mkblock(font.body, 500, 1em, -0.3em, 0em),
  mkabstract: mkabstract(font.body, 1em, 10pt, 10pt),
  mkcontent: mkcontent(0em, 0em),
)

#let book = (
  mktitle: mkblock(font.title, 700, 2.3em, 10em, 10em),
  mkinfo: mkblock(font.title, 700, 1.5em, 0em, 10em),
  mkauthor: mkauthor(font.author, 1.1em, 0em, 0em),
  mktime: mkblock(font.body, 500, 1.3em, 10em, 0em),
  mkabstract: mkabstract(font.body, 1em, 0em, 10pt),
  mkpreface: mkpreface(font.body, 2em, 0em, 10pt),
  mkcontent: mkcontent(0em, 0em),
)

#let report = (
  mktitle: mkblock(font.title, 700, 2.2em, 10em, 5em),
  mkinfo: mkblock(font.title, 700, 2.5em, 0em, 15em),
  mkauthor: mkauthor(font.author, 1.3em, 0em, 0em),
  mktime: mkblock(font.body, 500, 1.3em, 10em, 0em),
  mkabstract: mkabstract(font.body, 1em, 0em, 10pt),
  mkpreface: mkpreface(font.body, 1.1em, 0em, 10pt),
  mkcontent: mkcontent(0em, 0em),
)

#let proof(body) = {
  set enum(numbering: "(1)")
  block(
    inset: 8pt,
    width: 100%,
  )[_Proof._ #h(0.75em) #body
    #align(right)[$qed$]
  ]
  newpara()
}

#let solution(body) = {
  set enum(numbering: "(1)")
  block(
    inset: 8pt,
    width: 100%,
  )[_Solution._ #h(0.75em) #body
  ]
  newpara()
}

#let blankblock(color: color.orange, body) = {
  block(
    fill: color.transparentize(70%),
    inset: 10pt,
    radius: 4pt,
    width: 100%,
    stroke: (left: (thickness: 4pt, paint: color)),
    [
      #set text(font: font.countblock)
      #set align(left)
      #newpara()
      #body
    ],
  )
  newpara()
}

#let separator = {
  block(
    inset: 0pt,
    width: 100%,
    stroke: (top: (thickness: 1pt, paint: mycolor.grey)),
  )[]
  newpara()
}
