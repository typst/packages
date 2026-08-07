#import "deps.typ": default-info, default-names, default-styles
#import "common.typ": *

#let default-outline-entry(x) = {
  let loc = x.element.location()
  let fill = box(width: 1fr, x.fill)
  link(loc, x.body() + fill + x.page() + v(0em))
}

#let book-outline-entry(x, depth, styles) = {
  let loc = x.element.location()
  let fill = box(width: 1fr, x.fill)
  let prefix = x.prefix()
  let entry(body) = link(loc, body + fill + x.page() + v(0em))
  let heading-entry(body) = entry(h(1em) + body)

  if (depth >= 1) and (x.element.func() == figure) {
    let entry-body = smallcaps(x.body())
    let kind = x.element.kind
    if kind == "part" {
      entry(strong(entry-body))
    } else if kind == "chapter" {
      let chapter-index = counter-chapter.at(loc).at(0)
      entry(str(chapter-index) + "." + h(0.5em) + strong(entry-body))
    } else if kind == "appendix" {
      let append-index = counter-appendix.at(loc).at(0)
      entry(appendix-number(append-index) + "." + h(0.5em) + strong(entry-body))
    } else {
      default-outline-entry(x)
    }
  } else if (depth == 2) and (x.level == 1) and (prefix != none) {
    let append-index = counter-appendix.at(loc).at(0)
    if prefix.has("children") {
      let title-index = if append-index == 0 {
        str(counter-chapter.at(loc).at(0))
      } else {
        appendix-number(append-index)
      }
      heading-entry(
        title-index + "." + prefix.children.at(1) + h(.5em) + x.body(),
      )
    } else if prefix.has("text") {
      heading-entry(prefix + h(.5em) + x.body())
    } else {
      default-outline-entry(x)
    }
  } else {
    default-outline-entry(x)
  }
}

#let note-outline-target(depth) = {
  let h1 = selector(heading.where(outlined: true, level: 1))
  if depth == 1 {
    h1
  } else {
    h1.or(heading.where(outlined: true, level: 2))
  }
}

#let book-outline-target(depth) = {
  let titles = selector(fig-chapter).or(fig-appendix)
  if depth == 1 {
    titles
  } else {
    titles.or(heading.where(outlined: true, level: 1))
  }
}

#let contents-style(
  body,
  depth: 1,
  lang: "en",
  names: default-names,
  styles: default-styles,
) = {
  assert(depth in (1, 2), message: "depth can only be either 1 or 2")

  show: book-style.with(styles: styles)
  show link: set text(black)
  show: cjk-latin-style.with(styles: styles, lang: lang, role: "contents", as-style: true)
  show heading.where(level: 1): it => {
    set text(
      size: styles.sizes.contents * 1pt,
      ..font-role-options(styles, lang, "contents"),
    )
    it
    v(.5em)
  }

  set outline(title: {
    heading(
      outlined: false,
      level: 1,
      names.sections.at(lang).content,
    )
  })

  show outline.entry: x => {
    context if book-state.get() {
      book-outline-entry(x, depth, styles)
    } else {
      default-outline-entry(x)
    }
  }
  cjk-latin-style(body, styles: styles, lang: lang, role: "contents")
}

#let contents(
  depth: 1,
  info: default-info,
  styles: default-styles,
) = {
  let lang = info.lang

  show: contents-style.with(
    lang: lang,
    depth: depth,
    styles: styles,
  )
  context outline(
    target: if book-state.get() {
      book-outline-target(depth)
    } else {
      note-outline-target(depth)
    },
    depth: depth,
  )
  pagebreak(to: "odd")
}
