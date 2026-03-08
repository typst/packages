#import "scan_util.typ": runes
#import "parse.typ": next
#import "execute.typ": execute
#import "util.typ": ok, error

// json-path-b is like `json-path` but returns `(result, err)` instead of panicking on error.
#let json-path-b(obj, path, ..filters) = {
  let runes = runes(path)
  let pos = 0
  let result = ()
  while true {
    let (node, err) = next(runes, pos)
    if err != none {
      return error(err)
    }
    if node == none {
      break
    }
    pos = node.pos.end
    (result, err) = execute(obj, node, result, ..filters)
    if err != none {
      return error(err)
    }
  }
  return ok(result)
}

// json-path extracts values from dictionary or array using a JSONPath expression as per RFC 9535, except the filter syntax is different (see Filter Example section below).
// It always returns an array of results. If there are no results, it returns an empty array.
// = Example:
// ```typst
// #{
//   let obj = json("rfc9535-1-5.json")
//   let result = json-path(obj, "$.store.book.*.title")
// }
// ```
// = Filter Example:
// ```typst
// #{
//   let obj = (o: (1, 2, 3, 5, (u: 6)))
//   // equivalent to $.o[?@<3, ?@<3] which is not supported.
//   let result = json-path(
//     obj, 
//     "$.o[?,?]", // or "$.o[?0,?0]",
//     it => type(it) in (int, float) and it < 3,
//   )
// }
// ```
#let json-path(obj, path, ..filters) = {
  let (r, err) = json-path-b(obj, path, ..filters)
  if err != none {
    panic(err)
  }
  return r
}
