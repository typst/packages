# jsonpath

jsonpath extracts values from dictionary or array using a JSONPath expression as per [RFC 9535](https://www.rfc-editor.org/rfc/rfc9535.html), except the filter syntax is different.

## Examples

Import the package `jsonpath` before using it.

```typst
#import "@preview/jsonpath:0.1.0": *
```

Extract all titles of books from the store.

```typst
#{
  let obj = json("rfc9535-1-5.json")
  let result = json-path(obj, "$.store.book.*.title")
}
```

Filter elements using custom filter functions.

```typst
#{
  let obj = (o: (1, 2, 3, 5, (u: 6)))
  // equivalent to "$.o[?@<3, ?@<3]" which is not supported.
  let result = json-path(
    obj,
    "$.o[?,?]", // or "$.o[?0,?0]",
    it => type(it) in (int, float) and it < 3,
  )
}
```

See [jsonpath_test.typ](https://github.com/qjebbs/typst-jsonpath/blob/main/tests/jsonpath_test.typ) for more examples.
