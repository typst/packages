#import "@preview/mitex:0.2.5": mi, mitex
#import "@preview/physica:0.9.6": *
#import "@preview/cuti:0.3.0": show-cn-fakebold

#import "Base/size.typ": *
#import "Base/paragraph.typ": *
#import "Base/list.typ": *
#import "./table.typ": *
#import "./boxes.typ": *

#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *

#import "@preview/mannot:0.3.0": *
#let boxed(it, x: 0.25em) = {
  let xmar2 = x - 0.02em
  h(xmar2)
  markrect(outset: (x: x, y: 0.3em))[#it]
  h(xmar2)
}

// 通过迭代，可以求得$u^*$，进而得到 $boxed(overline(a) = u^* pdv(f, a))$，代码如下。

// #let delta(x) = $Delta#x$
// #let pi = markhl.with(color: yellow)
// #let pj = markhl.with(color: red)

#let Blue(it) = {
  text(fill: blue)[*#it*]
}

#let rm-bracket(it) = {
  show "{": ""
  show "}": ""
  it
}

#let set-supplement(it) = {
  it
}

#let num-include-chapter(num) = {
  numbering("1.1", counter(heading).get().first(), num)
}

#let ref-zh(it) = {
  let EQ = math.equation
  let el = it.element
  let obj
  let count
  let head = counter(heading).get().first()

  // el.fields()
  // el.kind == image
  if el != none {
    if el.func() == EQ {
      count = counter(EQ).at(el.location())
    } else if el.kind == image {
      count = counter(figure.where(kind: image)).at(el.location())
    } else if el.kind == table {
      count = counter(figure.where(kind: table)).at(el.location())
    } else if el.kind == raw {
      count = counter(figure.where(kind: raw)).at(el.location())
    }
    // numbering("1.1", head, count)
    link(el.location(), numbering("1", ..count))
  } else {
    it
  }
}

#let btext(x, color: red, bg: rgb("fffd11a1")) = {
  highlight(fill: bg)[
    #text(x, fill: color)
  ]
}

#let mk-highlight(it) = {
  let txt = it.text
  txt = txt.replace("==", "")
  btext(txt)
}

#let set-figure(body) = {
  set figure(numbering: it => strong[#numbering("1.1", it)])
  set figure.caption(separator: ". ")
  // set figure(numbering: it => strong[#numbering("1.1", it)])
  set figure(numbering: num => numbering("1", num))
  // set figure(numbering: num => numbering("1.1", counter(heading).get().first(), num))
  show figure.caption: it => {
    set par(spacing: 0.9em, leading: 0.8em)
    it
  }

  show figure.where(kind: image): set figure(supplement: text("图", weight: "bold"))
  show figure.where(kind: table): set figure(supplement: text("表", weight: "bold"))
  show figure.where(kind: table): set figure.caption(position: top)
  body
}


#let template(doc, size: 12.5pt, size-config: (:), pagenum: true, footer: "", header: "") = {
  // 设置全局字号
  let size-config-all = define_size(size, size-config)
  show: it => set_size(it, size-config-all)

  set list(indent: 1em)
  show list: it => {
    let space = -0.2em
    v(space)
    it
    v(space)
  }

  set par(spacing: 1.24em + 0.2em, leading: 1.24em)
  set par(justify: true)

  show math.equation: rm-bracket
  show math.equation.where(block: true): set par(spacing: 0.7em, leading: 0.8em)
  set math.equation(numbering: "(1)")
  // numbering("(1.1)", counter(heading).get().first(), num)

  set underline(offset: 2pt)
  show: set-table
  show: set-figure
  // set heading(numbering: "1.1")
  // 代码
  show: codly-init.with()
  codly(stroke: 1pt + blue)
  codly(display-icon: true)
  codly(languages: codly-languages)

  show ref: ref-zh // 引用

  // // https://github.com/typst/typst/issues/1896
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    it
  }

  show heading: it => set-heading(it)
  show: show-cn-fakebold

  // 链接
  show link: underline
  show link: set text(fill: rgb(0, 0, 255))

  // 代码
  show raw: set text(font: ("consolas", "Microsoft Yahei", "SimSun"))
  show regex("==(\w+)=="): mk-highlight

  // 页眉页脚
  // footer
  if pagenum {
    set page(
      footer: context [
        #text(footer, weight: "bold")
        #h(1fr)
        #counter(page).display("1/1", both: true)
      ],
      header: align(right)[#text(header, weight: "bold")],
      numbering: "1",
    )
    doc
  } else {
    doc
  }
}

