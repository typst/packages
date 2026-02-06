#import "@preview/great-theorems:0.1.1": *

#import "@preview/rich-counters:0.2.1": *

#import "@preview/mitex:0.2.4": *

#import "@preview/cetz:0.3.1"

#import "@preview/tablex:0.0.8": tablex, rowspanx, colspanx, hlinex

#import "@preview/tablem:0.1.0": tablem


#let _treemap(is-root: false, max-columns: 3, is-child-of-root: false, tree) = {
  if is-root {
    table(
      inset: (x: 0.2em, y: 0.6em),
      columns: calc.min(tree.children.len(), max-columns),
      ..tree.children.map(_treemap.with(is-child-of-root: true)),
    )
  } else {
    if tree.children == () {
      box(inset: (x: 0.2em, y: 0em), rect(tree.title))
    } else {
      let res = stack(
        {
          set align(center)
          set text(size: 1.25em, weight: "bold")
          tree.title
        },
        v(0.8em),
        {
          tree.children.map(_treemap).sum()
        },
      )
      if is-child-of-root {
        res
      } else {
        box(
          inset: (x: 0.2em, y: 0em),
          rect(
            width: 100%,
            inset: (x: 0.2em, y: 0.6em),
            res,
          ),
        )
      }
    }
  }
}


#let _list-title(cont) = {
  let res = ([],)
  for child in cont.children {
    if child.func() != list.item {
      res.push(child)
    } else {
      break
    }
  }
  res.sum()
}


#let _treemap-converter(cont) = {
  if not cont.has("children") {
    if cont.func() == list.item {
      (title: cont.body, children: ())
    } else {
      (title: cont, children: ())
    }
  } else {
    (
      title: _list-title(cont),
      children: cont.children
        .filter(it => it.func() == list.item)
        .map(it => _treemap-converter(it.body))
    )
  }
}


#let treemap(cont) = _treemap(is-root: true, _treemap-converter(cont))


#let mathcounter = rich-counter(
  identifier: "mathblocks",
  inherited_levels: 1
)

#let theorem = mathblock(
  blocktitle: "Theorem",
  counter: mathcounter,
)

#let lemma = mathblock(
  blocktitle: "Lemma",
  counter: mathcounter,
)

#let remark = mathblock(
  blocktitle: "Remark",
  prefix: [_Remark._],
  inset: 5pt,
  fill: lime,
  radius: 5pt,
)

#let proof = proofblock()


#let eq(content) = math.equation(
  block: true,
  numbering: none,
  supplement: auto,
  content,
)