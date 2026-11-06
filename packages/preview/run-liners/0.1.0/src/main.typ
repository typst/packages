#let run-in-join(
  // Determines the in-between separator for all but the last item.
  // - If set to "auto", we'll detect whether content has commas.
  // - Otherwise, use it literally (e.g., ", ", " / ", etc.).
  separator: "auto",

  // The word or phrase (e.g., "and", "or", "and/or") that comes before the last item.
  // - If set to `none`, we skip any coordinator.
  coordinator: "and",

  // Content items you want to join.
  // e.g., `[ [#(1) " item one"], [#(2) " item two"], ... ]`
  ..content,
) = {
  // 1. Decide on the base separator.
  let sep = if separator == "auto" {
    // naive check: if any item in the content sequence includes a comma, use semicolons
    if content.pos().any((item) => repr(item).find(regex("\[[^]]*,[^]]*\]")) != none) {
      "; "
    } else {
      ", "
    }
  } else {
    separator
  }

  // 2. Figure out how to handle the last separator.
  //    If `coordinator` is none, just do a normal join.
  //    If `oxford` is true and there are 3+ items, insert a comma before coordinator.
  let final-sep = if coordinator != none and content.pos().len() == 2 {
    // For 3 or more items, we do something like: ", and "
    // That is, a final comma plus the coordinator
    " " + coordinator + " "
  } else if coordinator != none and content.pos().len() > 2 {
    // For 3 or more items, we do something like: ", and "
    // That is, a final comma plus the coordinator
    sep + coordinator + " "
  } else {
    // No coordinator or too few items; the final separator is just `sep`.
    sep
  }

  // 3. Perform the join:
  content.pos().join(
    sep,
    last: final-sep
  )
}

#let run-in-enum(separator: "auto", coordinator: "and", numbering-pattern: "(1)", numbering-formatter: (it) => [#it], ..items) = {
  let contents = items.pos().enumerate(start: 1).map(((index, item)) => {
    [#numbering-formatter(numbering(numbering-pattern, index))~#item]
  })
  run-in-join(separator: separator, coordinator: coordinator, ..contents)
}

#let run-in-list(separator: "auto", coordinator: "and", marker: [•], ..items) = {
  let contents = items.pos().map((item) => {
    [#marker~#item]
  })
  run-in-join(separator: separator, coordinator: coordinator, ..contents)
}

#let run-in-terms(separator: "auto", coordinator: "and", term-formatter: (it) => [#strong(it)], ..terms) = {
  let contents = terms.pos().map((t) => {
    if type(t) != array or t.len() != 2 {
      panic("arguments to run-in-terms must be arrays of the form (term, definition)")
    }
    [#term-formatter(t.at(0)):~#t.at(1)]
  })
  run-in-join(separator: separator, coordinator: coordinator, ..contents)
}

#let run-in-verse(separator: [ /~], coordinator: none, ..verses) = {
  let contents = verses
  run-in-join(separator: separator, coordinator: coordinator, ..contents)
}
