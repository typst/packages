/// Markdown-style sugar: `> ` blockquotes, `---` section rules, `[label](url)` links, `![alt](path)` images, visible link styling.
/// Package code can't resolve paths relative to the caller, so images need `#show: md-parity-prelude.with(img: p => image(p))`
#let md-parity-prelude(doc, img: none) = {
  // `---` is already an em-dash shorthand by the time show rules run; alone in a paragraph it's a section split
  show regex("^—$"): _ => block(above: 1.4em, below: 1.4em, line(length: 100%, stroke: 0.5pt + luma(180)))

  let quote-block(body) = block(inset: (left: 1em), stroke: (left: 2pt + gray), text(fill: gray.darken(30%), body))
  // source newlines are lost by now (indistinguishable from spaces), so inside a quote any space-preceded `>` starts a new line
  show par: it => {
    let space = [ ].func()
    let ch = if it.body.func() == [].func() { it.body.children } else { (it.body,) }
    if ch.first().func() != text or not ch.first().text.starts-with("> ") { return it }
    let lines = ()
    let prev-space = true
    for c in ch {
      if prev-space and c.func() == text and (c.text == ">" or c.text.starts-with("> ")) {
        lines.push(if c.text == ">" { () } else { (text(c.text.slice(2)),) })
      } else if not (c.func() == space and lines.last().len() == 0) {
        lines.at(-1).push(c)
      }
      prev-space = c.func() == space
    }
    // markdown semantics: `- ` lines group into a list, consecutive plain lines merge into one paragraph
    let out = ()
    let items = ()
    let para = ()
    for l in lines {
      let head = l.at(0, default: none)
      if head != none and head.func() == text and (head.text == "-" or head.text.starts-with("- ")) {
        if para.len() > 0 { out.push(para.join([ ])); para = () }
        let rest = if head.text == "-" { l.slice(1) } else { (text(head.text.slice(2)),) + l.slice(1) }
        while rest.len() > 0 and rest.first().func() == space { rest = rest.slice(1) }
        items.push(rest.join())
      } else {
        if items.len() > 0 { out.push(list(..items)); items = () }
        para.push(l.join())
      }
    }
    if para.len() > 0 { out.push(para.join([ ])) }
    if items.len() > 0 { out.push(list(..items)) }
    quote-block(out.join(parbreak()))
  }

  show link: set text(fill: blue.darken(20%))
  show link: underline

  // math mode drops `super`, so the raise is explicit; the inner rule strips the one text mode adds
  set footnote(numbering: n => text(size: 0.7em, baseline: -0.35em, fill: blue.darken(20%), str(n)))
  show footnote: it => { show super: s => s.body; it }

  show regex("!\\[[^\\]]*\\]\\([^)]+\\)"): it => {
    let path = it.text.match(regex("\\(([^)]+)\\)$")).captures.first()
    if img == none { panic("md: pass `img: p => image(p)` to render " + it.text) }
    img(path)
  }
  // typst autolinks the bare URL, splitting the text node, so we stash the
  // [label] in state, graft it onto the autolink, and eat the trailing paren
  let md-lbl = state("md-lbl", none)
  let md-eat = state("md-eat", false)
  show regex("\\[[^\\]]+\\]\\("): it => md-lbl.update(it.text.slice(1, -2))
  show link: it => context {
    let l = md-lbl.get()
    // autolinks only (body text == dest); reconstructed links have body == label, breaking recursion
    if l == none or it.body.func() != text or it.body.text != str(it.dest) { it }
    else { md-lbl.update(none) + md-eat.update(true) + link(it.dest, l) }
  }
  // must not match a lone `)`: in math that's the closing delimiter, and any rule firing on it costs its stretchiness.
  // so a link ending a paragraph keeps its `)` - the two are indistinguishable at that point
  show regex("(?s)^\\)."): it => context {
    if md-eat.get() { md-eat.update(false) + it.text.slice(1) } else { it }
  }

  // non-URL dests aren't autolinked, so the whole [label](dest) survives as one
  // text node; defined after the stash rule to win the same-position tie
  show regex("\\[[^\\]]+\\]\\([^)]+\\)"): it => {
    let m = it.text.match(regex("\\[([^\\]]+)\\]\\(([^)]+)\\)"))
    link(m.captures.at(1), m.captures.at(0))
  }

  doc
}
