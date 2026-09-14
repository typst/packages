#import "dependencies.typ": default-info, default-names, default-styles
#import "common.typ": *

#let contents-style(
  body,
  depth: 2,
  info: default-info,
  names: default-names,
  styles: default-styles,
) = {
  assert(depth in (1, 2), message: "depth can only be either 1 or 2")

  show: book-style.with(styles: styles)
  show link: set text(black)
  let lang = info.lang

  show heading.where(level: 1): it => {
    set text(22pt)
    it
    v(.5em)
  }

  set outline(
    title: {
      heading(outlined: true, level: 1, names.sections.at(lang).content)
    },
  )

  show outline.entry: x => {
    let fill = box(width: 1fr, x.fill)
    let loc = x.element.location()
    let prefix = x.prefix()

    let chapter-index = counter-chapter.at(loc).at(0)
    let append-index = counter-appendix.at(loc).at(0)

    if (depth >= 1) and (x.element.func() == figure) {
      let entry-base = smallcaps(x.body()) + fill + x.page() + v(0em)
      let chap-prefix = str(chapter-index) + "." + h(0.5em)
      let append-prefix = "ABCD".at(append-index - 1) + "." + h(0.5em)

      let kind = x.element.kind
      if kind == "part" {
        link(loc, strong(entry-base))
      } else if kind == "chapter" {
        link(loc, strong(chap-prefix + entry-base))
      } else if kind == "appendix" {
        link(loc, strong(append-prefix + entry-base))
      }
    } else if (
      (depth == 2) and (x.level == 1) and (prefix != none) and (append-index == 0)
    ) {
      link(
        loc,
        (
          if prefix.has("children") {
            h(1.2em) + str(chapter-index) + "." + prefix.children.at(1) + h(.5em)
          } else if prefix.has("text") {
            prefix + h(.5em)
          }
            + x.body()
            + fill
            + x.page()
            + v(0em)
        ),
      )
    }
  }
  text(body, font: styles.fonts.at(lang).contents)
}

#let contents(depth: 2, info: default-info) = {
  show: contents-style.with(depth: depth, info: info)
  outline(
    target: selector(heading).or(fig-part).or(fig-chapter).or(fig-appendix),
    depth: depth,
  )
  pagebreak(to: "odd")

  show outline: it => if query(it.target) == () { }
}
