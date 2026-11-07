#import "doc.typ": current
// #embed(include "child.typ") resolves relative paths at the call site.
#let _embed(body, offset: true) = {
  (current.enter)()
  context {
    if offset {
      set heading(offset: heading.offset + 1)
      body
    } else {
      body
    }
  }
  (current.leave)()
}
