#import "@preview/cetz:0.4.1" : *
#import calc: *
#import "utils.typ": *

///// COUNTER
#let global-counter = counter("global")

#let cite-counter = counter("cite")
#let dev-counter = counter("dev")
#let item-counter = counter("item")

#let heading-1-counter = counter("heading_1")
#let heading-2-counter = counter("heading_2")
#let heading-3-counter = counter("heading_3")

#let item-in-dev = state("item-in-dev")

#let citations = state("citations")

///// COLORS
#let heading-2-color = red.darken(10%)
#let heading-3-color = green.darken(20%)
#let heading-4-color = purple.darken(20%)
#let item-color = blue
#let dev-accent-color = purple // black // purple

#let a4h = 595
#let a4w = 842

// #let bowtie = symbol(
//   "⋈",
//   ("large", "⨝"),
//   ("l", "⧑"),
//   ("r", "⧒"),
//   ("l.r", "⧓"),
// )

#let color-box(c, color: dev-accent-color, title: [DEV]) = context {
  dev-counter.step()
  let stroke_width = 1pt
  let stroke_box = color + stroke_width
  let title = text(color, 10pt, align(center + horizon,
    [*#title*]
  ))
  let inset = 0pt
  let outset = 4pt
  
  let (width: titlew, height: titleh) = measure(title)
  titlew += 0.6em
  titleh += 0.3em

  let all = block(
    breakable: true,
    stroke: stroke_box,
    radius: 0pt,
    inset: inset,
    outset: outset,
    width: 100%,
    c
  )
  
  let dec = -0.5pt
  let offset = -0em
  let on-the-left = here().position().x.pt() <= a4h / 2
  block(breakable: true)[
  #place(
    dy: if on-the-left {- titleh + titlew - outset + dec}
        else {-titleh -outset + dec},
    dx: if on-the-left { 100% - titlew + outset + dec + offset } 
        else {-titlew - outset - dec},
    rotate(if on-the-left {90deg} else { -90deg }, box(
      stroke: stroke_width + color,
      width: titlew,
      height: titleh,
      outset: dec,
      radius: 0pt,
      title
    ), origin: right + bottom)
  )
  #all
  ]
}

///// DEV
#let dev(c) = color-box(c)
#let warning(c) = color-box(c, 
  color: orange,
  title: emoji.warning
)

///// ITEM
#let item(type, name, c, show-title: true) = {
  block(width: 100%, context [
      // #let i = item-counter.display()
      #metadata(type)
      #label("item_type" + item-counter.display() + "_" + global-counter.display())
      #metadata(name)
      #label("item" + item-counter.display() + "_" + global-counter.display())
      #underline[
        *#text(item-color)[#type#h(0.3em)#item-counter.display()]*]
      #if show-title { if name != [] [*#name*] }
      #c
  ])
  item-counter.step()
  
  // item-in-dev.update(l => {
  //   if in_dev.get() { l.push(item-counter.get()) }
  //   l
  // })
}

#let color-from-string-cite(s) = {
  if s == "NAN" { gray } 
  else if s in colors-default {
    colors-default.at(s)
  } else {
    color-from-string(s, h:80%, s:80%, v:100%)
  }
}

///// TABLEAU

#let tableau(
  margin: 12pt,
  nb-columns : 2,
  title: none,
  body
) = {
  /*
  import "@preview/layout-ltd:0.1.0": layout-limiter
  show: layout-limiter.with(max-iterations: 5)
  */

  global-counter.step()
  dev-counter.update(0)
  heading-1-counter.update(0)
  heading-2-counter.update(0)
  heading-3-counter.update(0)
  cite-counter.update(0)
  item-counter.update(1)
  // in_dev.update(false)
  item-in-dev.update(())

  set document(title: title)
  set footnote.entry(gap: 0.1em, clearance: 0em, separator: none)
  set text(
    // alternates: false,
    // bottom-edge: 2em,
    // stretch: 170%,
    costs:(hyphenation: 100%, runt: 100%, widow: 100%, orphan: 100%),
    // baseline: 0pt,
    number-width: "proportional",
    fractions: true,
    14pt,
    lang: "fr",
    font: "New Computer Modern"
  )
  set list(tight: false,  body-indent: 0.4em, spacing: 0.5em, marker: ("‣", "•", "–"))
  show strong: set text(0.85em)
  show link: it => underline(stroke: black, it)
  show raw: set text(font: "New Computer Modern Mono")
  set page(
    flipped: true,
    margin: margin,
    columns: nb-columns,
    background: {
      for i in range(1, nb-columns) {
        place(dx: i * 100% / nb-columns, dy: 0 * 40%,
          rotate(90deg, origin: left + bottom,
            line(length: 100%)
          )
        )
      }
    }
  )
  set par(
    justify: true,
    linebreaks: "optimized",
    leading: 0.6em,
    spacing: 0.6em,
    hanging-indent: 0em,
  )
  set footnote.entry(gap: 0.4em, clearance: 2pt, indent: 0pt)
  
  let above = 0.6em // 1.4em // 0.7em
  let below = 0.7em // 1em // 0.7em

  show bibliography: it => {
    // if it.path.len() != 1 { assert(false, message: "Only accepts one bibliography file") }
    // let file = yaml(it.path.at(0))
    let file = yaml(it.sources.at(0))
    // let file = yaml("../lecons/bib.yaml")

    let done = ()
    text(underline[*Bibliographie* #linebreak()])
    let resume_author(author) = {
      let l = author.split(" ").filter(x=>x != "")
      l.enumerate().map(((i, name)) =>
        if i != l.len() - 1 [#name.slice(0,1).]
        else {name}).join(" ")
    }
    let all_citations = citations.get()
    
    for i in range(cite-counter.get().at(0)) {
      let lab = label("cite_" + str(i) + "_" + global-counter.display())
      
      let pos = locate(lab).position()
      let item = query(lab).at(0).value
      
      if item == "NAN" { continue }
      if not item in done {
        if item in file {
          let book = file.at(item)
          let a = book.author
          let type_author = type(a)
          let authors
          if type(book.author) == array {
            authors = book.author
          } else if type(book.author) == str {
            authors = book.author.split(",")
          }
          let resume_authors = authors.map(a => resume_author(a)).join(" & ")
          [#h(0.8em) #text(fill:color-from-string-cite(item))[[#item]]#h(0.5em)#resume_authors, #emph(book.title). #linebreak()]
        } else {
          assert(false, message:[#item not in #it.path.at(0)])
        }
      }
      done.push(item)
    }
  }
  show cite : it => {
    if str(it.key) != "NAN" { text(fill: color-from-string-cite(str(it.key)))[
      [#str(it.key)#if it.supplement != none [ #it.supplement]]
    ] }
    let lbl = label("cite_" + cite-counter.display() + "_" + global-counter.display())
    
    if query(selector(lbl).before(here())).len() == 0 {
    // if query(selector(lbl)).len() == 0 {
    [
      #metadata(str(it.key))
      #lbl
      #cite-counter.step()
    ]
    }
  }
  
  show heading.where(level: 1): c => [
    #block(below: below, above: above, text(0.8em, underline(c)))
    #label("heading_1_" + heading-1-counter.display() + "_"
    + global-counter.display())
    #heading-1-counter.step()
  ]

  set heading(numbering: (..nums) => {
    let (level, depth) = nums.pos().enumerate().last()
    if level == 1 {
      numbering("I.", depth)
    } else if level == 2 {
      numbering("A.", depth)
    } else if level == 3 {
      numbering("1.", depth)
    }
  })
  
  show heading.where(level: 2): c => [
    #block(below: below, above: above,
      text(0.9em, heading-2-color, underline(c)))
    #label("heading_2_" + heading-2-counter.display() + "_" + global-counter.display())
    #heading-2-counter.step()
  ]
  
  show heading.where(level: 3): c => [
    #block(below:below, above:above,
      text(0.9em, heading-3-color, underline(c)))
    #label("heading_3_" + heading-3-counter.display() + "_" + global-counter.display())
    #heading-3-counter.step()
  ]

  show heading.where(level: 4): it => [
    #block(below:below, above:above,
      text(0.8em, heading-4-color, underline(it)))
  ]
  
  // show heading.where(level: 4): it => {
  //   item(it.body)[][]
  // }


  body
}

#let short-item-dictionnary = (
  "Définition" : "Def",
  "Problème" : "Prob",
  "Proposition" : "Prop",
  "Propriété" : "Prop",
  "Complexité" : "Complex",
  "Notation" : "Not",
  "Méthode" : "Métho",
  "Implémentation" : "Implem",
  "Application" : "App",
  "Remarque" : "Rem",
  "Théorème" : "Thm",
  "Exemple" : "Ex",
  "Algorithme" : "Algo",
  "Pratique" : "Prat",
  "Motivation" : "Motiv",

  // ANGLAIS
  "Definition" : "Def",
  "Property" : "Prop",
  "Remark": "Rem",
  "Implementation": "Implem",
  "Example": "Ex",
  "Alorithm": "Algo",
  "Theorem": "Thm",
)
#let short-item-type(item) = {
  // assert(type(item) == content, message: "Some error")
  if type(item) == content {
    item 
  } else if item in short-item-dictionnary {
    short-item-dictionnary.at(item)
  } else { item }
}

#let without-refs(it) = {
  let seq = [].func()
  let styled = {
    show strong : it => ""
    strong[Hey]
  }.func()
  if it.func() == seq {
    seq(it.children.map(without-refs))
  } else if it.func() == heading {
    let fields = it.fields()
    let body_it = fields.remove("body")
    heading(..fields, without-refs(body_it))
  } else if it.func() == underline {
    underline(without-refs(it.body))
  } else if it.func() == styled {
    without-refs(it.child)
  } else if it.func() == block {
    without-refs(it.body)
  } else if it.func() == ref {
    let s = str(it.target)
    text(color-from-string-cite(s))[\[#s#if "supplement" in it.fields() [ #it.supplement]\]]
  } else {
    it
  }
}

#let recap(
  show-heading-big-numeral: true
) = {
  pagebreak()
  set text(9pt, weight: "black")
  set par(leading: 3pt)
  let length = 0.034em
  let debug = 0pt
  let padding = -10
  // let cites = () // TODO try this
  box(width: 100%, height: 100%, align(center + horizon,
  context canvas(length: length, {
  import draw : *

  let xy(x, y) = { (x * 1.5, y * 1.04) }
  let get_real_page(p, x) = {
    p * 2 + if x >= a4w / 2 {1} else {0}
  }

  let ratio = 1em.to-absolute()
  let global_id = str(global-counter.get().at(0))

  rect(xy(0, - a4h * 1), (rel: xy(a4w, a4h)))
  rect(xy(0, - a4h * 2), (rel: xy(a4w, a4h)))
  rect(xy(0, - a4h * 3), (rel: xy(a4w, a4h)))
  line(xy(a4w / 2, 0), xy(a4w / 2, - a4h * 3))

  assert(item-counter.get().at(0) > 1, message: "Should have at least one item")
  let fst_page = locate(label("item" + str(1) + "_" + global_id)).page()
  let todo = ()
  let seen = ()
  let seen_citation = ()

  let cites = () // todo use this

  let compute_pos(pos, fst_page, seen, offset) = {
    let real_page = get_real_page((pos.page - fst_page), pos.x.pt())
    // * 2 + if pos.x.pt() >= a4w / 2 {1} else {0}
    let posx = if pos.x.pt() >= a4w / 2 {a4w / 2} else {0}
    let posy = - pos.y.pt() - (pos.page - fst_page) * a4h
    let f = ((page, x, y)) => (y < posy) and page == real_page
    if seen.any(f) {
      let (page, x, y) = seen.filter(f).sorted(key: ((page, x, y)) =>(page, y)).at(0)
      posy = y - offset
    }
    (real_page, posx, posy)
  }

  // Citation
  let citation_f(seen, pos, fst_page) = {}
  for i in range(0, cite-counter.get().at(0)) {
    let name = "cite_" + str(i) + "_" + global_id
    let lab = label(name)
    let pos = locate(lab).position()
    let item = query(lab).at(0).value
    cites.push((item, pos, fst_page))
  }

  let draw_cite_box(seen_citation, cite_attach, (p1, x1, y1)) = {
    let (name0, p0, x0, y0) = if seen_citation.len() == 0 {
      ("NAN", 0, 0, 0)
    } else {
      seen_citation.at(seen_citation.len() - 1)
    }
    let current_page = p0
    if cite_attach != none {
      // Does not always terminate
      while (current_page != p1 + 1 and current_page < 7) {
        rect(
          xy(
            calc.rem(current_page, 2) * a4w / 2,
            if current_page == p0 { y0 } 
            else { -calc.div-euclid(current_page, 2) * a4h },
          ),
          xy(
            (calc.rem(current_page, 2) + 1) * a4w / 2,
            if current_page == p1 and y1 != none { y1 }
            else { -(calc.div-euclid(current_page, 2) + 1) * a4h } 
          ),
          fill: color-from-string-cite(name0).transparentize(80%),
          stroke: none
        )
        current_page += 1
      }
    }
  }

  // HEADING 1
  let heading1(seen, seen_citation, pos, fst_page, item, cite_attach) = {
    let (real_page, posx, posy) = compute_pos(pos, fst_page, seen, 0)
    let (posx, posy, dx) = (posx + 10, posy, a4w / 2 - 20)
    let height_item = - measure(box(width: dx * length * 1.5, item, stroke:debug)).height.pt()
    let dy = height_item * 1.04 / (length.em * ratio.pt())
    let res = content(
      xy(posx, posy),
      (rel: xy(dx, dy)),
      box(width: 100%, height: 100%, item, stroke:debug),
      anchor: "north-west"
    )
    let (x, y) = (posx, posy) // citation pos
    res += draw_cite_box(seen_citation, cite_attach, (real_page, posx, posy))
    
    return (real_page, posx, posy + dy, res, x, y)
  }
  
  for i in range(0, heading-1-counter.get().at(0)) {
    let lab = label("heading_1_" + str(i) + "_" + global_id)
    let pos = locate(lab).position()
    let item = without-refs(query(lab).at(0))
    todo.push(("heading_1",(pos, fst_page, item)))
  }

  // HEADING 2
  let heading2(seen, seen_citation, pos, fst_page, item, i, cite_attach) = {
    let (real_page, posx, posy) = compute_pos(pos, fst_page, seen, 10)
    let res
    if show-heading-big-numeral {
      res += content(
        xy(
          a4w / 4  + a4w / 2 * rem(real_page, 2),
          -a4h / 2  + - a4h * div-euclid(real_page, 2)
        ),
        text(140pt, gray.transparentize(70%), numbering("I", i + 1))
      )
    }

    let (x, y) = (posx, posy) // citation pos
    res += draw_cite_box(seen_citation, cite_attach, (real_page, posx, posy))
    
    let (posx, posy, dx) = (posx + 10, posy + padding, a4w / 2 - 20)
    let height_item = - measure(box(width: dx * length * 1.5, item, stroke:debug)).height.pt()
    let dy = height_item * 1.04 / (length.em * ratio.pt())
    res += content(
      xy(posx, posy),
      (rel: xy(dx, dy)),
      box(width: 100%, height: 100%, item, stroke:debug),
    )
    return (real_page, posx, posy + dy + padding, res, x, y)
  }

  for i in range(0, heading-2-counter.get().at(0)) {
    let lab = label("heading_2_" + str(i) + "_" + global_id)
    let pos = locate(lab).position()
    let item = without-refs(query(lab).at(0))
    todo.push(("heading_2", (pos, fst_page, item, i)))
  }
  
  // HEADING 3
  let heading3(seen, seen_citation, pos, fst_page, item, cite_attach) = {
    let (real_page, posx, posy) = compute_pos(pos, fst_page, seen, 0)

    let (posx, posy, dx) = (posx + 20, posy - 5, a4w / 2 - 30)
    let height_item = - measure(box(width: dx * length * 1.5, item, stroke:debug)).height.pt()
    let dy = height_item * 1.04 / (length.em * ratio.pt())
    
    let res = content(
      xy(posx, posy), (rel: xy(dx, dy)),
      box(
        width: 100%, height: 100%,
        item, stroke:debug),
    )

    let (x, y) = (posx, posy) // citation pos
    res += draw_cite_box(seen_citation, cite_attach, (real_page, posx, posy))
    
    return (real_page, posx, posy + dy + padding, res, x, y)
  }
  for i in range(0, heading-3-counter.get().at(0)) {
    let name = "heading_3_" + str(i) + "_" + global_id
    let lab = label(name)
    let pos = locate(lab).position()
    let item = without-refs(query(lab).at(0))
    todo.push(("heading_3", (pos, fst_page, item)))
  }

  // ITEM
  let item_f(seen, seen_citation, pos, fst_page, item_type, item, i, cite_attach) = {
    let (real_page, posx, posy) = compute_pos(pos, fst_page, seen, 0)
    item_type = short-item-type(item_type)
    item = text(black, item_type) + [ ] + item
    let res = content(
      xy(posx, posy), (rel: xy(40, - 35)),
      box(width: 100%, height: 100%, stroke: 1pt + black, outset: 0pt,
        align(center + horizon, [#i]))
    )

    let (x, y) = (posx, posy) // citation pos
    res += draw_cite_box(seen_citation, cite_attach, (real_page, posx, posy))
    
    let (posx, posy, dx) = (posx + 50, posy - 5, a4w / 2 - 60)
    let height_item = - measure(box(width: dx * length * 1.5, item, stroke:debug)).height.pt()
    
    let dy = height_item * 1.04 / (length.em * ratio.pt())
    res += content(xy(posx, posy), (rel: xy(dx, dy)),
      block(width : 100%, height: 100%,
        text(blue, item), stroke:debug),
    )
    return (real_page, posx, min(posy + 5 - 35, posy + dy), res, x, y)
  }
  for i in range(1, item-counter.get().at(0)) {
    let lab = label("item_type" + str(i) + "_" + global_id)
    let pos = locate(lab).position()
    let item_type = query(lab).at(0).value
    let item = without-refs(query(label("item" + str(i) + "_" + global_id)).at(0).value)
    todo.push(("item", (pos, fst_page, item_type, item, i)))
  }

  // Layout
  todo = todo.sorted(key:
    e => {
      let x = e.at(1).at(0).x.pt()
      let y = e.at(1).at(0).y.pt()
      let p = get_real_page(e.at(1).at(0).page, x)
      (p, y)
    })

  // Attach the citation to the right element
  for citation_attached_to_item in cites.map(
    ((cite_attach, (page:p0, x:x0, y:y0), fst_page)) => {
    let l = todo.enumerate().filter(((i, (type, args))) => {
      let (page, x, y) = args.at(0)
      get_real_page(page, x.pt()) == get_real_page(p0, x0.pt())
    }).sorted(key: ((i, (type, args))) => {
     let (page, x, y) = args.at(0)
     abs(y.pt() - y0.pt())
    })
    if l.len() > 0 {
      let (i, (type_item, args)) = l.at(0)
      (i, (type_item, args, cite_attach))
    }
  }) {
    if citation_attached_to_item != none {
      let (i, (type_item, args, cite_attach)) = citation_attached_to_item
      todo.at(i) = (type_item, args, cite_attach)
    }
  }

  todo = todo.map(t => {
   if t.len() == 2 { (..t, none) } else { t }
  })
  
  for (type_element, args, cite_attach) in todo {
    let typeset = (
      "heading_1" : heading1,
      "heading_2" : heading2,
      "heading_3" : heading3,
      "item" : item_f
    )
    let (
      real_page, posx, posy, res, cite_x, cite_y
    ) = typeset.at(type_element)(
        seen, seen_citation, ..args, cite_attach
      )
    res
    if cite_attach != none {
      seen_citation.push((cite_attach, real_page, cite_x, cite_y))
    }
    seen.push((real_page, posx, posy))
  }
  draw_cite_box(seen_citation, "NAN", (5, 0, -a4h * 3))
  })))
  // pagebreak()
}

// Graph
#let graph(g) = canvas(length: 1em, {
    import draw: *
    let r = g.radius
    let links = g.links
    let nodes = g.nodes
    for node in nodes {
      circle(node.at(1), radius: r, name: node.at(0))
      content(node.at(0), [#node.at(0)])
    }
    for link in links {
      if (link.at(0) == "bezier") {
        set-style(mark: (end: ">"))
        bezier(
          (link.at(1), r, link.at(2)),
          (link.at(2), r, link.at(1)),
          link.at(3)
        )
      } else {
        set-style(mark: (end: ">"))
        line(..link)
      }
    }
})

#let bibliography-all() = context {
  for global-counter in range(global-counter.get().at(0)) {
    for i in range(cite-counter.get().at(0)) {
      let lab = label("cite_" + str(i) + "_" + str(global-counter))
      let pos = locate(lab).position()
      let item = query(lab).at(0).value
      if item == "NAN" { continue }
      if not item in done {
        if item in file {
          let book = file.at(item)
          let a = book.author
          let type_author = type(a)
          let authors
          if type(book.author) == array {
            authors = book.author
          } else if type(book.author) == str {
            authors = book.author.split(",")
          }
          let resume_authors = authors.map(a => resume_author(a)).join(" & ")
          [#h(0.8em) #text(fill:color-from-string-cite(item))[[#item]]#h(0.5em)#resume_authors, #emph(book.title). #linebreak()]
        } else {
          assert(false, message:[#item not in #it.path.at(0)])
        }
      }
      done.push(item)
    }
  }
}

#let authors(c) = {
  align(bottom + center, c)
}
