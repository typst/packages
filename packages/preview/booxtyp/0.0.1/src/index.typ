// Copyright 2023 Rolf Bremer, Jutta Klebe
// Use of this code is governed by the License in the LICENSE.txt file.
// For a 'how to use this package', see the accompanying .md, .pdf + .typ documents.

// Classes for index entries. The class determines the visualization
// of the entries' page number.
#let classes = (main: "Main", simple: "Simple")

// Index Entry; used to mark an entry in the document to be included in the Index.
// An optional class may be provided.
#let index(
  content,
  // The text of the entry shown in the index page
  // If this is not provided, the content is used
  entry: none,
  // Optional class for the entry.
  class: classes.simple,
) ={
  locate(
    loc => {
      // Override the content with the entry text if provided
      let content = if entry != none { entry } else { content }

      // Convert the content to lowercase
      // let content = lower(content)

      [#metadata((class: class, content: content, location: loc.position(), loc: loc))<jkrb_index>]
    },
  )
  [
    *#content*
  ]
}

#let index-main(
  content,
  // Optional class for the entry.
  class: classes.main,
) = {
  locate(
    loc => [#metadata((class: class, content: content, location: loc.position(), loc: loc))<jkrb_index>],
  )
}

/// Create the index page.
#let make-index(title: none, outlined: false) = {
  // This function combines the text(s) of a content.
  let content-text(content) = {
    let ct = ""
    if content.has("text") {
      ct = content.text
    } else {
      for cc in content.children {
        if cc.has("text") {
          ct += cc.text
        }
      }
    }
    return ct
  }

  locate(
    loc => {
      let elements = query(<jkrb_index>, loc)
      let words = (:)
      for el in elements {
        let ct = content-text(el.value.content)

        // Have we already know that entry text? If not,
        // add it to our list of entry words
        if words.keys().contains(ct) != true {
          words.insert(ct, ())
        }

        // Add the new page entry to the list.
        // let ent = (class: el.value.class, page: el.value.location.page)
        let ent = (
          class: el.value.class,
          page: el.value.location.page,
          page-number: counter(page).at(el.value.loc).first(),
        )
        if not words.at(ct).contains(ent) {
          words.at(ct).push(ent)
        }
      }

      // Sort the entries.
      let sortedkeys = words.keys().sorted()

      // Output.
      let register = ""
      if title != none { heading(outlined: outlined, numbering: none, title) }
      for sk in sortedkeys [

        // Use class specific formatting for the page numbers.
        #let formattedPageNumbers = words.at(sk).map(en => {
          if en.class == classes.main {
            link((page: en.page, x: 0pt, y: 0pt))[#strong[#en.page]]
          } else {
            link((page: en.page, x: 0pt, y: 0pt))[*#en.page-number*]
          }
        })

        // The first character of the entry
        // It should be uppercase
        #let firstCharacter = upper(sk.first())

        #if firstCharacter != register {
          heading(level: 2, numbering: none, outlined: false, firstCharacter)
          register = firstCharacter
        }
        #sk
        #box(width: 1fr)
        #formattedPageNumbers.join(", ")
      ]
    },
  )
}

#let index-page(title: [Indices]) = {
  // The title of the index page
  heading(numbering: none)[#title]

  // Two column-layout
  columns(2)[
    #make-index()
  ]
}