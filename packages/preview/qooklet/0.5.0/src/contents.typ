#import "dependencies.typ": default-info, default-styles, default-names
#import "common.typ": *

#let contents-style(body, depth: 2, info: default-info, names: default-names, styles: default-styles) = {
  assert(depth in (1, 2), message: "depth can only be either 1 or 2")

  show: book-style.with(styles: styles)
  show link: set text(black)

  set page(paper: styles.paper.booklet, margin: 10%)
  let lang = info.lang

  show heading.where(level: 1): it => {
    set text(22pt)
    it
    v(.5em)
  }

  set outline(
    title: {
      heading(
        outlined: true,
        level: 1,
        names.sections.at(lang).content,
      )
    },
  )

  show outline.entry: x => {
    let fill = box(width: 1fr, x.fill)
    let loc = x.element.location()
    let prefix = x.prefix()

    // filter first part page
    let chap-index = counter(label-chapter).at(loc).at(0)
    // filter chapter
    let appd-index = counter(label-appendix).at(loc).at(0)

    if (depth >= 1) and (x.element.func() == figure) {
      let entry-base = smallcaps(x.body()) + fill + x.page() + v(0em)
      let chap-prefix = str(chap-index) + "." + h(0.5em)
      let appd-prefix = "ABCD".at(appd-index - 1) + "." + h(0.5em)

      let chap-index2 = x.element.kind
      let kind = x.element.kind

      if kind == "part" {
        link(loc, strong(entry-base))
      } else if kind == "title" {
        if appd-index == 0 {
          link(loc, strong(chap-prefix + entry-base))
        } else {
          link(loc, strong(appd-prefix + entry-base))
        }
      }
    } else if (depth == 2) and (x.level == 1) and (prefix != none) and (appd-index == 0) {
      link(
        loc,
        (
          if prefix.has("children") {
            h(1.2em) + str(chap-index) + "." + prefix.children.at(1) + h(.5em)
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
  outline(target: selector(heading).or(label-part).or(label-chapter).or(label-appendix), depth: depth)
  pagebreak(to: "odd")

  show outline: it => if query(it.target) == () { }
}
