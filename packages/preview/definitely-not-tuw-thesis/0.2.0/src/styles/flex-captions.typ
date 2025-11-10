#let in-outline = state("in-outline", false)
#let flex-caption-styles = rest => {
  show outline: it => {
    in-outline.update(true)
    it
    in-outline.update(false)
  }
  rest
}

#let flex-caption(long, short) = (
  context (
    if in-outline.get() {
      short
    } else {
      long
    }
  )
)