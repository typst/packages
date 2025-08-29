#import "utils/state.typ": is-back-matter

#let toc-styles = rest => {
  set outline(depth: 2, indent: auto)

  show outline: set heading(outlined: true)
  show outline: set heading(bookmarked: true)

  show outline.entry.where(level: 1): it => {
    context if is-back-matter.get() {
      // List of Figures/...
      text(it, size: 1.1em)
    } else {
      // Actual ToC
      v(0.4em)
      strong(text(it, size: 1.4em))
    }
  }
  show outline.entry.where(level: 2): it => {
    text(it, size: 1.1em)
  }

  rest
}
