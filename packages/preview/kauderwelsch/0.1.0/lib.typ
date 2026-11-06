// lib.typ
#import "data.typ"

/// Generiert Platzhaltertext.
#let blindtext(
  paragraphs: 4,
  length: "long", 
  lang: "en",
  math: false,
  math-frequency: 1,
  offset: 0
) = {
  // Input Validation
  assert(type(paragraphs) == int and paragraphs >= 0, message: "blindtext: 'paragraphs' must be a non-negative integer.")
  assert(length in ("short", "medium", "long"), message: "blindtext: 'length' must be 'short', 'medium', or 'long'.")
  assert(lang in data.texts.keys(), message: "blindtext: 'lang' must be one of: " + data.texts.keys().join(", "))
  assert(type(offset) == int, message: "blindtext: 'offset' must be an integer.")

  let source = data.texts.at(lang)

  for i in range(paragraphs) {
    let raw-text = source.at(calc.rem(i + offset, source.len()))
    let sentences = raw-text.split(". ").filter(s => s != "")
    
    let target-count = if length == "short" {
      calc.min(2, sentences.len())
    } else if length == "medium" {
      calc.max(2, calc.min(5, sentences.len()))
    } else {
      sentences.len()
    }

    let output-text = sentences.slice(0, target-count).join(". ") + "."
    output-text = output-text.replace("..", ".") 

    if math and calc.rem(i + 1, math-frequency) == 0 {
      let formula = data.formulas.at(calc.rem(i, data.formulas.len()))
      [#output-text #formula]
    } else {
      [#output-text]
    }
    
    parbreak()
  }
}

/// Generiert ein komplettes, organisches Dummy-Dokument.
#let blinddocument(
  size: "medium",
  length: "long",
  lang: "en",
  math: false,
  lists: true,
  tables: true,
  figures: false,
  code: false
) = {
  // Input Validation
  assert(size in ("small", "medium", "large"), message: "blinddocument: 'size' must be 'small', 'medium', or 'large'.")
  assert(length in ("short", "medium", "long"), message: "blinddocument: 'length' must be 'short', 'medium', or 'long'.")
  assert(lang in data.texts.keys(), message: "blinddocument: 'lang' must be one of: " + data.texts.keys().join(", "))
  
  let active-features = ()
  if lists { active-features.push("list-simple"); active-features.push("enum-simple"); active-features.push("list-nested"); active-features.push("enum-nested"); active-features.push("terms") }
  if tables { active-features.push("table-simple"); active-features.push("table-large") }
  if figures { active-features.push("figure") }
  if code { active-features.push("code") }

  let total-features = active-features.len()

  let organic-patterns = (
    (1, 2, 2, 3, 2, 3, 2),
    (1, 2, 3, 4, 3, 2, 2),
    (1, 2, 2),
    (1, 2, 3, 2, 2, 3, 2),
    (1, 2, 2, 3, 2)
  )

  let chapter-count = if size == "small" { 1 } else if size == "medium" { 3 } else { 12 }
  
  let total-headings = 0
  for c in range(chapter-count) {
    total-headings += organic-patterns.at(calc.rem(c, organic-patterns.len())).len()
  }

  let element-counter = 0

  for c in range(chapter-count) {
    let pattern = organic-patterns.at(calc.rem(c, organic-patterns.len()))
    
    for lvl in pattern {
      element-counter += 1
      
      let heading-list = data.headings.at(lang).at("level" + str(lvl))
      let heading-text = heading-list.at(calc.rem(element-counter, heading-list.len()))
      
      heading(level: lvl, heading-text)

      let p-count = if lvl == 1 { 1 } else if lvl == 4 { 1 } else { calc.rem(element-counter, 3) + 2 }
      
      blindtext(
        paragraphs: p-count, 
        length: length, 
        lang: lang,
        math: math, 
        math-frequency: 4,
        offset: element-counter // Shiftet den Startabsatz organisch weiter
      )

      if total-features > 0 {
        let features-per-heading = calc.ceil(total-features / total-headings)
        let start-idx = (element-counter - 1) * features-per-heading
        let end-idx = start-idx + features-per-heading

        for i in range(start-idx, end-idx) {
          let feature-idx = if total-headings >= total-features { calc.rem(i, total-features) } else { i }

          if feature-idx < total-features {
            let feature = active-features.at(feature-idx)

            if feature == "list-simple" {
              for item in data.lists.at(lang) { list.item(item) }
              parbreak()
            } else if feature == "enum-simple" {
              for item in data.lists.at(lang) { enum.item(item) }
              parbreak()
            } else if feature == "list-nested" {
              [#data.nested-lists.at(lang).list]
              parbreak()
            } else if feature == "enum-nested" {
              [#data.nested-lists.at(lang).enum]
              parbreak()
            } else if feature == "terms" {
              for item in data.terms.at(lang) { terms.item(item.at(0), item.at(1)) }
              parbreak()
            } else if feature == "table-simple" {
              let table-args = ()
              for h in data.table-data.header { table-args.push(strong(h)) }
              for cell in data.table-data.cells { table-args.push(cell) }
              figure(
                table(
                  columns: data.table-data.header.len(),
                  fill: (col, row) => if row == 0 { luma(230) } else { none },
                  ..table-args
                ),
                caption: if lang == "de" [Eine einfache Übersicht.] else if lang == "fr" [Un simple aperçu.] else if lang == "la" [Conspectus simplex.] else [A simple overview.]
              )
            } else if feature == "table-large" {
              let table-args = ()
              for h in data.large-table-data.header { table-args.push(strong(h)) }
              for cell in data.large-table-data.cells { table-args.push(cell) }
              figure(
                table(
                  columns: data.large-table-data.header.len(),
                  fill: (col, row) => if row == 0 { luma(230) } else { none },
                  ..table-args
                ),
                caption: if lang == "de" [Ein größerer Datensatz.] else if lang == "fr" [Un jeu de données.] else if lang == "la" [Notitiae ampliores.] else [A larger dataset.]
              )
            } else if feature == "figure" {
              let cap = data.captions.at(lang).at(calc.rem(element-counter, data.captions.at(lang).len()))
              figure(
                rect(width: 80%, height: 150pt, fill: luma(240), radius: 4pt),
                caption: cap
              )
            } else if feature == "code" {
              let snippet = data.code-snippets.at(calc.rem(element-counter, data.code-snippets.len()))
              raw(snippet.code, lang: snippet.lang, block: true)
            }
          }
        }
      }
    }
  }
}