#import "design.typ": *
#import "options.typ": require, valid-text, present
#import "page.typ": current-config
#import "labels.typ": labelled
// The last numbered chapter at `location`, or none before the first one.
#let chapter-number-at(location) = {
  let hs = query(heading.where(level: 1).before(location, inclusive: true))
    .filter(h => h.numbering != none)
  if hs.len() > 0 {
    numbering(
      if hs.last().numbering == "A.1" { "A" } else { "1" },
      counter(heading).at(location).first(),
    )
  }
}
#let chapter-number() = chapter-number-at(here())
// "2.3" inside chapter 2; just "3" when no numbered chapter precedes.
#let chapter-prefixed(n, location) = {
  let chapter = chapter-number-at(location)
  if chapter == none { str(n) } else { chapter + "." + str(n) }
}
#let statement(kind, ..args) = {
  for key in args.named().keys() { panic("unknown argument `" + key + "`") }
  let items = args.pos()
  require(
    "body", items.len() in (1, 2) and items.all(valid-text), "one body, or a title and a body",
  )
  let title = if items.len() == 2 { items.first() }
  figure(
    metadata((title: title, statement: items.last(), kind: kind)),
    kind: "theorem", supplement: _ => context current-config().labels.at(kind),
    numbering: n => context {
      let o = current-config()
      if o.mode == "report" { chapter-prefixed(n, here()) } else { str(n) }
    },
  )
}
#let theorem = statement.with("theorem")
#let lemma = statement.with("lemma")
#let proposition = statement.with("proposition")
#let corollary = statement.with("corollary")
#let definition = statement.with("definition")
#let example = statement.with("example")
#let remark = statement.with("remark")
#let show-statement(it) = context {
  let o = current-config()
  set align(left)
  set text(top-edge: body-top-edge, bottom-edge: body-bottom-edge)
  let data = it.body.value
  let number = counter(figure.where(kind: "theorem")).display(it.numbering)
  let title = if present(data.title) { [ (#data.title)] }
  block(breakable: true, above: paragraph-gap, below: paragraph-gap)[
    #text(font: o.heading-font, size: scaled(o, label-size), weight: "bold", fill: o.accent)[
      #labelled(o.labels.at(data.kind), number, separator: [ ])]#title.
    #if data.kind in ("theorem", "lemma", "proposition", "corollary") {
      emph(data.statement)
    } else { data.statement }
  ]
}
// End `body` with the square on its last line: inside a closing list or enum item,
// or beside a closing display equation.
#let with-square(body) = {
  let children = if body.has("children") { body.children } else { (body,) }
  while children.len() > 0 and children.last() in ([ ], parbreak()) { children.pop() }
  let last = children.at(-1, default: none)
  let rest = children.slice(0, calc.max(children.len() - 1, 0)).join()
  if type(last) != content {
    [#body #h(1fr)□]
  } else if last.func() == math.equation and last.block {
    [#rest
      #v(proof-equation-gap)
      #grid(columns: (1fr, auto), column-gutter: qed-gap, align: horizon, last, [□])]
  } else if last.func() == list.item {
    [#rest#list.item(with-square(last.body))]
  } else if last.func() == enum.item {
    let number = last.at("number", default: auto)
    let item = if number == auto { enum.item(with-square(last.body)) } else {
      enum.item(number, with-square(last.body))
    }
    [#rest#item]
  } else {
    [#body #h(1fr)□]
  }
}
#let proof(body, ..args) = {
  require("body", args.pos().len() == 0, "one body")
  for key in args.named().keys() { panic("unknown argument `" + key + "`") }
  require("body", type(body) in (str, content), "str or content")
  let body = if type(body) == str { [#body] } else { body }
  context {
    let o = current-config()
    let prefix = if present(o.labels.proof) { [#emph[#o.labels.proof.] ] }
    block(breakable: true)[#prefix#with-square(body)]
  }
}
