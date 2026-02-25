
#import "@preview/bullseye:0.1.0": *

#let TITLEBOX-END-MARKER = "tracl-titlebox-end"

// each component dictionary is a dict(key -> symbol)
#let affiliations-state = state("affiliations", (numbered: (:), named: (:)))


#let make-author-block(author-block, layout-options) = {
  assert(type(author-block) == dictionary)
  assert("name" in author-block)
  assert("affiliation" in author-block)

  // permit string (one author name) or array of strings
  let authors = if type(author-block.name) == str or type(author-block.name) == content {
    (author-block.name,)
  } else {
    author-block.name
  }

  box[
    #set text(layout-options.font-size)
    #set par(leading: 0.5em)
    #set align(center)

    // #let (authors, affiliation) = author-block
    #for (i, author) in authors.enumerate() {
      if i > 0 {
        h(layout-options.name-spacing)
      }
      strong(author)
    }
    #parbreak()
    #author-block.affiliation
  ]
}

#let make-author-row(author-row, layout-options) = {
  // author-row could be just a single block - force it into array of blocks
  let author-blocks = if type(author-row) == dictionary {
    (author-row,)
  } else {
    author-row
  }

  // set author blocks side by side
  box[
    #set align(center)
    #for (i, author-block) in author-blocks.enumerate() {
      if i > 0 {
        h(layout-options.block-spacing)
      }
      make-author-block(author-block, layout-options)
    }
  ]
}

// default parameters for make-authors layout
#let author-layout-parameters = (
  name-spacing: 2em,
  block-spacing: 3em,
  row-spacing: 1em,
  font-size: 12pt,
)

#let make-authors(..author-table) = {
  let author-rows = author-table.pos()
  let layout-options = author-layout-parameters
  let authors-in-named = (:)

  for (key, value) in author-table.named().pairs() {
    if key in layout-options {
      layout-options.insert(key, value)
    } else {
      authors-in-named.insert(key, value)
    }
  }

  author-rows = if author-rows.len() == 0 {
    // only one block specified, through named arguments
    (authors-in-named,)
  } else {
    author-rows
  }

  author-rows = if type(author-rows.at(0)) == dictionary {
    // single author row
    (author-rows,)
  } else {
    author-rows
  }

  for (i, row) in author-rows.enumerate() {
    if i > 0 {
      v(layout-options.row-spacing)
    }
    make-author-row(row, layout-options)
  }
}



// For footnotes that arise in the titlebox, but should be displayed at the bottom
// of the page.

// first element: ordered list of footnotes
// second element: dictionary with keys = labels that were previously added
#let title-footnote-collection = state("title-footnote-collection", ((), (:)))

#let title-footnote(footnote-text, lbl, numbering: "*") = {
  context match-target(
    paged: {
      ref(label(lbl))
      title-footnote-collection.update(x => {
        if not lbl in x.at(1) {
          x.at(0).push((footnote-text, lbl, numbering))
          x.at(1).insert(lbl, 1)
        }
        
        x
      })
    },

    html: {
      footnote(numbering: numbering, footnote-text)
    }
  )
}

#let print-title-footnotes() = context {
  hide()[
    #for (footnote-text, lbl, numbering) in title-footnote-collection.get().at(0) {
      [#footnote(numbering: numbering)[#footnote-text]#label(lbl)]
    }
  ]

  // reset everything
  counter(footnote).update(0)
  title-footnote-collection.update(x => ((), (:)))
}


// For "footnotes" indicating affiliations within the titlebox


// Returns the metadata element at the end of the titlebox.
// If (as in main.typ) there are multiple titleboxes, it finds the next one.
#let find-titlebox-end() = {
  let upcoming = query(selector(metadata).after(here()))
  let matching = upcoming.filter(m => {
    let v = m.value
    type(v) == dictionary and v.at("kind", default: none) == TITLEBOX-END-MARKER
  })
  
  if matching.len() > 0 {
    matching.first()
  } else {
    none
  }
}

// Typesets an author's affiliation symbols.
#let affil-ref(..keys) = context {
  let all-keys = affiliations-state.at(find-titlebox-end().location())
  let labels = ()
  
  for key in keys.pos() {
    if key in all-keys.numbered {
      labels.push(all-keys.numbered.at(key))
    } else if key in all-keys.named {
      labels.push(all-keys.named.at(key))
    } else {
      labels.push([*??*])
    }
  }

  h(0.1em)
  super(labels.join(", "))
}

// Defines an affiliation
#let affiliation(key, symbol: none, affiliation-numbering: "1") = {
  h(0.1em)

  if symbol == none {
    // assign a number
    affiliations-state.update(x => {
      let symbol = numbering(affiliation-numbering, x.numbered.len() + 1)
      x.numbered.insert(key, symbol)
      x
    })
    
    context { super(str(affiliations-state.get().numbered.len())) }
  } else {
    // use the provided symbol
    affiliations-state.update(x => {
      x.named.insert(key, symbol)
      x
    })

    context { super(symbol) }
  }
}


