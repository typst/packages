#import "@preview/ctheorems:1.1.3": *
#import "@preview/showybox:2.0.3": showybox
#import "../utils/style.typ": 字号, 字体

#let colors = (
  rgb("#9E9E9E"),
  rgb("#F44336"),
  rgb("#E91E63"),
  rgb("#9C27B0"),
  rgb("#673AB7"),
  rgb("#3F51B5"),
  rgb("#2196F3"),
  rgb("#03A9F4"),
  rgb("#00BCD4"),
  rgb("#009688"),
  rgb("#4CAF50"),
  rgb("#8BC34A"),
  rgb("#CDDC39"),
  rgb("#FFEB3B"),
  rgb("#FFC107"),
  rgb("#FF9800"),
  rgb("#FF5722"),
  rgb("#795548"),
  rgb("#9E9E9E"),
)


#show: thmrules



#show math.equation: set text(weight: 400)

#let thmtitle(t, color: rgb("#000000")) = {
  return text(font: 字体.黑体, weight: "semibold", fill: color)[#t]
}
#let thmname(t, color: rgb("#000000")) = {
  return text(font: 字体.黑体, fill: color)[(#t)]
}

#let thmtext(t, color: rgb("#000000")) = {
  let a = t.children
  if (a.at(0) == [ ]) {
    a.remove(0)
  }
  t = a.join()

  return text(font: 字体.宋体, fill: color)[#t]
}

#let thmbase(
  identifier,
  head,
  ..blockargs,
  supplement: auto,
  padding: (top: 0.5em, bottom: 0.5em),
  namefmt: x => [(#x)],
  titlefmt: strong,
  bodyfmt: x => x,
  separator: [#h(0.1em)\ ], 
  base: "heading",
  base-level: none,
) = {
  if supplement == auto {
    supplement = head
  }
  let boxfmt(name, number, body, title: auto, ..blockargs_individual) = {
    if not name == none {
      name = [ #namefmt(name)]
    } else {
      name = []
    }
    if title == auto {
      title = head
    }
    if not number == none {
      title += " " + number
    }
    title = titlefmt(title)
    body = bodyfmt(body)
    pad(
      ..padding,
      showybox(
        width: 100%,
        radius: 0.3em,
        breakable: true,
        padding: (top: 0em, bottom: 0em),
        ..blockargs.named(),
        ..blockargs_individual.named(),
        [#title#name#titlefmt(separator)#body],
      ),
    )
  }

  let auxthmenv = thmenv(
    identifier,
    base,
    base-level,
    boxfmt,
  ).with(supplement: supplement)

  return auxthmenv.with(numbering: "1.1")
}

#let styled-thmbase = thmbase.with(titlefmt: thmtitle, namefmt: thmname, bodyfmt: thmtext)

#let builder-thmbox(color: rgb("#000000"), ..builderargs) = styled-thmbase.with(
  titlefmt: thmtitle.with(color: color.darken(30%)),
  bodyfmt: thmtext.with(color: color.darken(70%)),
  namefmt: thmname.with(color: color.darken(30%)),
  frame: (
    body-color: color.lighten(92%),
    border-color: color.darken(10%),
    thickness: 1.5pt,
    inset: 1.2em,
    radius: 0.3em,
  ),
  ..builderargs,
)

#let builder-thmline(color: rgb("#000000"), ..builderargs) = styled-thmbase.with(
  titlefmt: thmtitle.with(color: color.darken(30%)),
  bodyfmt: thmtext.with(color: color.darken(70%)),
  namefmt: thmname.with(color: color.darken(30%)),
  frame: (
    body-color: color.lighten(92%),
    border-color: color.darken(10%),
    thickness: (left: 2pt),
    inset: 1.2em,
    radius: 0em,
  ),
  ..builderargs,
)

#let problem-style = builder-thmbox(color: colors.at(16), shadow: (offset: (x: 0pt, y: 0pt), color: luma(70%)))

#let problem = problem-style("problem", "例题")

#let theorem-style = builder-thmbox(color: colors.at(6), shadow: (offset: (x: 0pt, y: 0pt), color: luma(70%)))

#let theorem = theorem-style("theorem", "定理")
#let lemma = theorem-style("lemma", "引理")
#let corollary = theorem-style("corollary", "推论")

#let definition-style = builder-thmline(color: colors.at(8))

#let definition = definition-style("definition", "定义")
#let proposition = definition-style("proposition", "命题")
#let remark = definition-style("remark", "结论")
#let observation = definition-style("observation", "易知")

#let example-style = builder-thmline(color: colors.at(16))

#let example = example-style("example", "例题")

#let proof(body, name: none) = {
  thmtitle[证明]
  if name != none {
    [ #thmname[#name]]
  }
  thmtitle[:]
  body
  h(1fr)
  // $square$
}