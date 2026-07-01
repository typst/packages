// Interlinear glossed examples with automatic numbering
// Creates aligned word-by-word glosses; wrap text in {} for small-caps
//
// Generates numbered glossed examples that share the (1), (2)... sequence with eg().
//
// Arguments:
// - body (content): List items — all but last are alignment lines, last is free translation
// - per (int or none): Lines per sub-gloss group (none = single gloss)
// - labels (array): Optional labels for sub-glosses (e.g., (<gl-a>, <gl-b>))
// - caption (string): Caption for outline (hidden in document; optional)
// - spacing (length): Vertical spacing between gloss lines (default: 0.75em)
// - title (content or none): Title line shown above the gloss (not space-parsed)
//
// Returns: Numbered glossed example that can be labeled and referenced
//
// Single gloss:
//   #gloss()[
//     - eu gosto de maçã
//     - I like-{1sg.prs} of apple
//     - 'I like apples'
//   ] <eg-pt>
//
// With title:
//   #gloss(title: [Inuktitut])[
//     - Qasuiirsarvigssarsingitluinarnarpuq
//     - tired not cause-to-be place-for suitable ...
//     - 'Someone did not find a completely suitable resting place.'
//   ]
//
// Sub-glosses:
//   #gloss(per: 3, labels: (<gl-a>, <gl-b>))[
//     - eu gosto de maçã
//     - I like-{1sg.prs} of apple
//     - 'I like apples'
//     - elle aime les pommes
//     - she like.{3sg.prs} the.{pl} apple.{pl}
//     - 'She likes apples'
//   ] <eg-multi>

#import "eg.typ": example-counter, subex-counter, letters

// Extract list items from body (may be nested in a sequence)
#let _extract-items(body) = {
  if body.func() == list.item { return (body,) }
  if body.has("children") {
    return body.children.filter(c => c.func() == list.item)
  }
  ()
}

// Recursively convert Typst content to a plain string
// Handles text nodes, sequences, and spaces
#let _content-to-string(c) = {
  if type(c) == str { return c }
  if c.has("text") { return c.text }
  if c.has("children") {
    let result = ""
    for child in c.children {
      if child.has("text") { result += child.text }
      else if child.has("children") {
        for grandchild in child.children {
          if grandchild.has("text") { result += grandchild.text }
          else { result += " " }
        }
      }
      else { result += " " }
    }
    return result
  }
  " "
}

// Format a single gloss token: text inside {} gets small-capped
// "like-{1prs.sg}" → like- + sc(1prs.sg)
#let _format-gloss-token(token) = {
  if not token.contains("{") { return [#token] }
  // Split by { and } to find small-cap regions
  let result = []
  let remaining = token
  while remaining.contains("{") {
    let open = remaining.position("{")
    let before = remaining.slice(0, open)
    remaining = remaining.slice(open + 1)
    if remaining.contains("}") {
      let close = remaining.position("}")
      let sc-text = remaining.slice(0, close)
      remaining = remaining.slice(close + 1)
      result = result + [#before] + smallcaps[#sc-text]
    } else {
      // No closing brace, treat { as literal
      result = result + [#before\{#remaining]
      remaining = ""
    }
  }
  if remaining != "" {
    result = result + [#remaining]
  }
  result
}

// Tokenize alignment lines into arrays of tokens
#let _tokenize-lines(line-strings) = {
  line-strings.map(line =>
    line.split(regex("\\s+")).filter(s => s != "")
  )
}

// Build a full gloss grid: optional prefix columns + aligned tokens + free translation row
// prefix-cols: number of extra columns before the token columns (for number/letter)
// prefix-cells: flat array of cells to prepend to each row (length = prefix-cols per row)
#let _build-full-gloss(items, spacing, title: none, prefix-cols: 0, prefix-cells: (), escape: ()) = {
  let n = items.len()
  let align-items = items.slice(0, n - 1)
  let free-trans = items.last().body

  let line-strings = align-items.map(it => _content-to-string(it.body))
  let tokenized = _tokenize-lines(line-strings)
  // Escaped lines don't contribute to column count (they span all columns)
  let non-escaped-tokens = tokenized.enumerate().filter(((i, _)) => i not in escape).map(((_, t)) => t)
  let max-token-cols = if non-escaped-tokens.len() > 0 {
    calc.max(..non-escaped-tokens.map(t => t.len()))
  } else {
    1
  }
  let total-cols = prefix-cols + max-token-cols

  let cells = ()

  // Title row (spans all columns; steals first alignment row's prefix cells)
  if title != none {
    if prefix-cols > 0 {
      for p in range(prefix-cols) {
        if p < prefix-cells.len() {
          cells.push(prefix-cells.at(p))
        } else {
          cells.push([])
        }
      }
    }
    cells.push(grid.cell(colspan: max-token-cols, title))
  }

  // Alignment rows
  for (row-idx, row) in tokenized.enumerate() {
    // Prefix cells for this row (skip first row's prefix if title already used them)
    if prefix-cols > 0 {
      let base = row-idx * prefix-cols
      for p in range(prefix-cols) {
        if title != none and row-idx == 0 {
          cells.push([])
        } else if base + p < prefix-cells.len() {
          cells.push(prefix-cells.at(base + p))
        } else {
          cells.push([])
        }
      }
    }
    // Token cells (escaped lines span all token columns without tokenization)
    if row-idx in escape {
      cells.push(grid.cell(colspan: max-token-cols, align-items.at(row-idx).body))
    } else {
      for col in range(max-token-cols) {
        if col < row.len() {
          cells.push(_format-gloss-token(row.at(col)))
        } else {
          cells.push([])
        }
      }
    }
  }

  // Free translation row (spans all token columns)
  if prefix-cols > 0 {
    for _ in range(prefix-cols) { cells.push([]) }
  }
  cells.push(grid.cell(colspan: max-token-cols, free-trans))

  let col-spec = ()
  for _ in range(prefix-cols) { col-spec.push(2em) }
  for _ in range(max-token-cols) { col-spec.push(auto) }

  grid(
    columns: col-spec,
    column-gutter: 0.75em,
    row-gutter: spacing,
    align: left + bottom,
    ..cells,
  )
}

// Main gloss function
#let gloss(
  per: none,
  labels: (),
  caption: none,
  spacing: 0.75em,
  title: none,
  escape: (),
  body,
) = {
  let items = _extract-items(body)

  let content = if per != none and items.len() > per {
    // Sub-glosses mode: chunk items into groups of `per`
    let groups = ()
    let i = 0
    while i + per <= items.len() {
      groups.push(items.slice(i, i + per))
      i += per
    }
    if i < items.len() {
      groups.push(items.slice(i))
    }

    // Build each sub-gloss as a flat grid, then stack them
    let sub-blocks = ()
    for (gi, group) in groups.enumerate() {
      // Build prefix cells: number (first row only) + letter (first row only)
      let n-align-lines = group.len() - 1  // all but free translation
      let prefix = ()
      for row in range(n-align-lines) {
        if row == 0 {
          // Number cell
          if gi == 0 {
            prefix.push(context {
              subex-counter.update(0)
              example-counter.step()
              [(#(example-counter.get().first() + 1))]
            })
          } else {
            prefix.push([])
          }
          // Letter cell
          let letter-fig = figure(
            box(baseline: 0pt, context {
              set par(first-line-indent: 0em)
              subex-counter.step()
              let n = subex-counter.get().first()
              [#letters.at(n).]
            }),
            kind: "linguistic-subexample",
            supplement: none,
            numbering: none,
          )
          let letter-cell = if labels != () and gi < labels.len() {
            [#letter-fig#labels.at(gi)]
          } else {
            letter-fig
          }
          prefix.push(letter-cell)
        } else {
          prefix.push([])  // empty number
          prefix.push([])  // empty letter
        }
      }

      let group-title = if gi == 0 { title } else { none }
      sub-blocks.push(_build-full-gloss(
        group, spacing,
        title: group-title,
        prefix-cols: 2,
        prefix-cells: prefix,
        escape: escape,
      ))
    }

    stack(dir: ttb, spacing: spacing * 2, ..sub-blocks)
  } else {
    // Single gloss mode: number in prefix column
    let n-align-lines = items.len() - 1
    let prefix = ()
    for row in range(n-align-lines) {
      if row == 0 {
        prefix.push(context {
          subex-counter.update(0)
          example-counter.step()
          [(#(example-counter.get().first() + 1))]
        })
      } else {
        prefix.push([])
      }
    }

    _build-full-gloss(
      items, spacing,
      title: title,
      prefix-cols: 1,
      prefix-cells: prefix,
      escape: escape,
    )
  }

  figure(
    align(left, content),
    caption: if caption != none { caption } else { none },
    outlined: caption != none,
    kind: "linguistic-example",
    supplement: none,
    numbering: "(1)",
    placement: none,
    gap: 0pt,
  )
}
