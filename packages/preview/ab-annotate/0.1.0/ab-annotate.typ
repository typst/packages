// ab-annotate.typ
// Annotated bibliography support for Typst.
//
// Because Typst's bibliography() function renders as a monolithic block
// with no per-entry hooks, we take a different approach:
//   1. Parse the .bib file to extract abstract/annotation fields
//   2. For each entry, emit a formatted block with the citation key
//      as a label and the abstract/annotation underneath
//   3. Use Typst's native bibliography() in a hidden block so that
//      cite() works correctly for formatting
//
// Usage:
//   #import "ab-annotate.typ": annotated-bib, parse-bib
//
//   // At the end of your document:
//   #annotated-bib("references.bib")

// ── .bib parser ─────────────────────────────────────────────────
// Extracts key, abstract, annotation/annote from BibLaTeX .bib files.

#let parse-bib(bib-content) = {
  let entries = ()
  let text = bib-content
  
  // Find each @type{key block
  let entry-starts = ()
  let i = 0
  let chars = text.clusters()
  while i < chars.len() {
    if chars.at(i) == "@" {
      entry-starts.push(i)
    }
    i += 1
  }
  
  for (idx, start) in entry-starts.enumerate() {
    let end = if idx + 1 < entry-starts.len() {
      entry-starts.at(idx + 1)
    } else {
      chars.len()
    }
    let chunk = chars.slice(start, end).join()
    
    // Get entry type and key
    let header = chunk.match(regex("@(\w+)\s*\{\s*([^,\s]+)"))
    if header == none { continue }
    let entry-type = header.captures.at(0).trim()
    let key = header.captures.at(1).trim()
    
    // Skip @comment, @preamble, @string
    if entry-type in ("comment", "preamble", "string") { continue }
    
    // Helper: extract a brace-delimited field value
    let extract-field(field-name, chunk) = {
      let pattern = regex(field-name + "\s*=\s*\{")
      let m = chunk.match(pattern)
      if m == none { return none }
      let s = m.end
      let depth = 1
      let pos = s
      let c = chunk.clusters()
      while pos < c.len() and depth > 0 {
        if c.at(pos) == "{" { depth += 1 }
        if c.at(pos) == "}" { depth -= 1 }
        if depth > 0 { pos += 1 }
      }
      c.slice(s, pos).join().replace(regex("\s+"), " ").trim()
    }
    
    let abst = extract-field("abstract", chunk)
    let annot = extract-field("annotation", chunk)
    let annote = extract-field("annote", chunk)
    
    // Merge: annotation takes priority over annote
    let final-annotation = if annot != none { annot } else { annote }
    
    entries.push((
      key: key,
      abstract: abst,
      annotation: final-annotation,
    ))
  }
  
  entries
}

// ── Render annotated bibliography ───────────────────────────────

#let annotated-bib(
  bib-source,
  title: "Annotated Bibliography",
  style: "apa",
  show-abstract: true,
  show-annotation: true,
  show-labels: true,
  abstract-label: "Abstract",
  annotation-label: "Annotation",
  indent: 1.5em,
  block-spacing: 0.5em,
  entry-spacing: 1.2em,
) = {
  // `bib-source` must be bytes from `read(path, encoding: none)` called
  // at the user's document site — Typst resolves `read()` paths relative
  // to the file that syntactically contains the call, so the user must
  // do the reading themselves.
  let bib-content = if type(bib-source) == bytes {
    str(bib-source)
  } else {
    bib-source
  }
  let entries = parse-bib(bib-content)

  if title != none {
    heading(level: 1, numbering: none, title)
  }

  // Declare the bibliography so `cite()` keys resolve and formatting
  // comes from the chosen CSL style — but suppress its grouped
  // rendering so we can interleave each entry with its annotation.
  show bibliography: _ => none
  bibliography(bib-source, title: none, style: style, full: true)

  // Render each entry manually using `cite(form: "full")`, followed
  // by any abstract/annotation blocks.
  for entry in entries {
    let has-abs = entry.abstract != none and show-abstract
    let has-ann = entry.annotation != none and show-annotation

    block(breakable: false, width: 100%, below: entry-spacing)[
      #cite(label(entry.key), form: "full")

      #if has-abs or has-ann {
        v(block-spacing)
        block(
          inset: (left: indent, top: 0.3em, bottom: 0.3em),
          stroke: (left: 1.5pt + luma(180)),
          width: 100%,
        )[
          #if has-abs [
            #if show-labels [
              #text(weight: "bold", size: 0.9em)[#abstract-label:]
              #h(0.3em)
            ]
            #text(size: 0.9em, style: "italic")[#entry.abstract]
          ]

          #if has-abs and has-ann { v(0.3em) }

          #if has-ann [
            #if show-labels [
              #text(weight: "bold", size: 0.9em)[#annotation-label:]
              #h(0.3em)
            ]
            #text(size: 0.9em)[#entry.annotation]
          ]
        ]
      }
    ]
  }
}
