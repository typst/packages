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
      *#localize("keywords", lang: lang): * #text(font: kai, keywords.join(localize("keywords-separator", lang: lang)+" "))
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

#let add-countblock(cb, name, info, color, counter-name: none) = {
  if counter-name == none { counter-name = name }
  cb.insert(name, (info, color, counter-name))
  return cb
}

#let reg-countblock(counter-name, cb-counter-depth: cb.at("cb-counter-depth"), body) = {
  show heading.where(level: 1, outlined: true): it => {
    if cb-counter-depth == 2 or cb-counter-depth == 3 { counter(counter-name).update(0) }
    it
  }
  show heading.where(level: 2, outlined: true): it => {
    if cb-counter-depth == 3 { counter(counter-name).update(0) }
    it
  }
  body
}

#let countblock(name, cb, cb-counter-depth: cb.at("cb-counter-depth"), subname: "", count: true, lab: none, body) = {
  let (info, color, counter-name) = cb.at(name)
  if count { counter(counter-name).step() }
  if cb.at(name) == none { panic("countblock: block not registered") }
  show figure: it => [
    #v(-4pt)
    #it
    #v(-4pt)
  ]
  let num = ""
  if count { num = generate-counter(cb-counter-depth, context counter(counter-name).display()) }
  let title = info + " " + num + " " + subname
  set text(font: font.countblock)
  let countblock = block(
    fill: color.transparentize(60%),
    inset: 8pt,
    radius: 2pt,
    width: 100%,
    stroke: (left: (thickness: 4pt, paint: cb.at(name).at(1))),
    [
      #set text(font: font.countblock)
      #set align(left)
      *#title* #h(0.75em)
      #figure(
        [],
        caption: none,
        kind: name,
        supplement: cb.at(name).at(0),
        numbering: it => {
          if count { generate-counter(cb-counter-depth, counter(counter-name).display()) } else { none }
        },
      )
      #if lab != none { label(lab) }
      #v(-1em)
      #body
    ],
  )
  countblock
}

#let definition = countblock.with("def", cb)
#let theorem = countblock.with("thm", cb)
#let proposition = countblock.with("prop", cb)
#let lemma = countblock.with("lem", cb)
#let corollary = countblock.with("cor", cb)
#let remark = countblock.with("rmk", cb)
#let claim = countblock.with("clm", cb)
#let exercise = countblock.with("ex", cb)
#let problem = countblock.with("prob", cb)
#let example = countblock.with("eg", cb)
#let note = countblock.with("note", cb, count: false)
#let caution = countblock.with("cau", cb, count: false)

#let reg-default-countblock(cb-counter-depth: cb.at("cb-counter-depth"), body) = {
  show: reg-countblock.with("def", cb-counter-depth: cb-counter-depth)
  show: reg-countblock.with("thm", cb-counter-depth: cb-counter-depth)
  show: reg-countblock.with("prop", cb-counter-depth: cb-counter-depth)
  show: reg-countblock.with("ex", cb-counter-depth: cb-counter-depth)
  show: reg-countblock.with("prob", cb-counter-depth: cb-counter-depth)
  show: reg-countblock.with("eg", cb-counter-depth: cb-counter-depth)
  show: reg-countblock.with("note", cb-counter-depth: cb-counter-depth)
  show: reg-countblock.with("cau", cb-counter-depth: cb-counter-depth)
  body
}

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
    fill: color.transparentize(60%),
    inset: 8pt,
    radius: 2pt,
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
