
#import "supports-text.typ": plain-text

#let _labeled-meta(label) = locate(loc => {
  let res = query(label, loc)
  if res.len() <= 0 {
    none
  } else if res.len() == 1 {
    res.at(0).value
  } else {
    res.map(it => it.value)
  }
})

#let _store-content(ct) = (
  kind: "plain-text",
  content: plain-text(ct),
)

/// helper function to get (and print/use) the final book metadata
#let get-book-meta() = _labeled-meta(<shiroa-book-meta>)

/// helper function to get (and print/use) the final build metadata
#let get-build-meta() = _labeled-meta(<shiroa-build-meta>)
