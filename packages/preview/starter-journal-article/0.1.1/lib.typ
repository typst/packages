#let author-meta(
  ..affiliation,
  email: none,
  alias: none,
  address: none,
  cofirst: false
) = {
  let info = (
    "affiliation": affiliation
  )
  if email != none {
    info.insert("email", email)
  }
  if alias != none {
    info.insert("name", alias)
  }
  if address != none {
    info.insert("address", address)
  }
  if cofirst != none {
    info.insert("cofirst", cofirst)
  }
  info
}

#let article(
  // Article's Title
  title: "Article Title",
  
  // A dictionary of authors.
  // Dictionary keys are authors' names.
  // Dictionary values are meta data of every author, including
  // label(s) of affiliation(s), email, contact address,
  // or a self-defined name (to avoid name conflicts).
  // Once the email or address exists, the author(s) will be labelled
  // as the corresponding author(s), and their address will show in footnotes.
  // 
  // Example:
  // (
  //   "Auther Name": (
  //     "affiliation": "affil-1",
  //     "email": "author.name@example.com", // Optional
  //     "address": "Mail address",  // Optional
  //     "name": "Alias Name", // Optional
  //     "cofirst": false // Optional, identify whether this author is the co-first author
  //   )
  // )
  authors: ("Author Name": author-meta("affiliation-label")),

  // A dictionary of affiliation.
  // Dictionary keys are affiliations' labels.
  // These labels show be constent with those used in authors' meta data.
  // Dictionary values are addresses of every affiliation.
  //
  // Example:
  // (
  //   "affiliation-label": "Institution Name, University Name, Road, Post Code, Country"
  // )
  affiliations: ("affiliation-label": "Affiliation address"),

  // The paper's abstract.
  abstract: [],

  // The paper's keywords.
  keywords: (),

  // The bibliography. Accept value from the built-in `bibliography` function.
  bib: none,

  // Paper's content
  body
) = {
  // Set document properties
  set document(title: title, author: authors.keys())
  set page(numbering: "1", number-align: center)
  set text(font: ("Times New Roman", "STIX Two Text", "serif"), lang: "en")
  show footnote.entry: it => [
    #set par(hanging-indent: 0.54em)
    #it.note #it.note.body
  ]
  set footnote(numbering: "*")
  show "cofirst-author-mark": [These authors contributed equally to this work.]

  // Title block
  align(center)[
    #block(text(size: 1.75em, weight: "bold", title))
  ]

  v(1em)

  // Authors and affiliations
  align(left)[

    // Restore affiliations' keys for looking up later
    // to show superscript labels of affiliations for each author.
    #let inst_keys = affiliations.keys()

    // Find co-fisrt authors
    #let cofirst_index = authors.values().enumerate().filter(
      meta => "cofirst" in meta.at(1) and meta.at(1).at("cofirst") == true
    ).map(it => it.at(0))

    // Authors' block
    #block([
      // Process the text for each author one by one
      #for (ai, au) in authors.keys().enumerate() {
        let au_meta = authors.at(au)
        // Don't put comma before the first author
        if ai != 0 {
          text([, ])
        }
        // Write auther's name
        if au_meta.keys().contains("name") and au_meta.name != none {
          text([#au_meta.name])
        } else {
          text([#au])
        }
        
        // Get labels of author's affiliation
        let au_inst_id = au_meta.affiliation.pos()
        let au_inst_primary = ""
        // Test whether the author belongs to multiple affiliations
        if type(au_inst_id) == array {
          // If the author belongs to multiple affiliations,
          // record the first affiliation as the primary affiliation,
          au_inst_primary = affiliations.at(au_inst_id.first())
          // and convert each affiliation's label to index
          let au_inst_index = au_inst_id.map(id => inst_keys.position(key => key == id) + 1)
          // Output affiliation
          super(typographic: false, size: 0.6em, (au_inst_index.map(it => str(it)).join(",")))
        } else if (type(au_inst_id) == str) {
          // If the author belongs to only one affiliation,
          // set this as the primary affiliation
          au_inst_primary = affiliations.at(au_inst_id)
          // convert the affiliation's label to index
          let au_inst_index = inst_keys.position(key => key == au_inst_id) + 1
          // Output affiliation
          super(typographic: false)[#au_inst_index]
        }

        // Corresponding author
        if au_meta.keys().contains("email") or au_meta.keys().contains("address") {
          footnote[
            Corresponding author. Address:
            #if not au_meta.keys().contains("address") or au_meta.address == "" {
              [#au_inst_primary.]
            }
            #if au_meta.keys().contains("email") and au_meta.email != none {
              [Email: #underline(au_meta.email).]
            }
          ]
        }

        if cofirst_index.len() > 0 {
          if ai == 0 {
            footnote("cofirst-author-mark")
          } else if cofirst_index.contains(ai) {
            locate(loc => query(footnote.where(body: [cofirst-author-mark]), loc).last())
          }
        }

      }
    ])

    #v(-0.2em)

    // Affiliation block
    #block([
      #set par(leading: 0.4em)
      #for (ik, key) in inst_keys.enumerate() {
        text(size: 0.8em, [#super([#(ik+1)]) #(affiliations.at(key))])
        linebreak()
      }
    ])
  ]

  // Abstract and keyword block
  if abstract != [] {
    v(1em)
    
    block([
      #heading([Abstract])
      #abstract
  
      #if keywords.len() > 0 {
        text(weight: "bold", [Key words: ])
        text([#keywords.join([; ]).])
      }
    ])

    v(1em)
  }

  // Display contents

  show heading.where(level: 1): it => block(above: 1.5em, below: 1.5em)[
    #set pad(bottom: 2em, top: 1em)
    #it.body
  ]

  set par(first-line-indent: 2em)

  set footnote(numbering: "1")
  
  body

  // Display bibliography.
  if bib != none {
    show bibliography: set text(1em)
    show bibliography: set par(first-line-indent: 0em)
    set bibliography(title: [References], style: "apa")
    bib
  }
}
