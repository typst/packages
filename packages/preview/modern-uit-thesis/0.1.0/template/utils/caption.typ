#import "../chapters/global.typ": in-outline

#let dynamic-caption(long, short) = (
  context {
    if in-outline.get() {
      short
    } else {
      long
    }
  }
)
