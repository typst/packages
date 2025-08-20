// this source code was obtained and corrected from: https://github.com/ENIB-Community/glossarium

// glossarium figure kind
#let __glossarium_figure = "glossarium_entry"
// prefix of label for references query
#let __glossary_label_prefix = "glossary:"
// global state containing the glossary entry and their location
#let __glossary_entries = state("__glossary_entries", (:))

#let __query_labels_with_key(loc, key, before: false) = {
  if before {
    query(
      selector(label(__glossary_label_prefix + key)).before(loc, inclusive: false),
      loc,
    )
  } else {
    query(
      selector(label(__glossary_label_prefix + key)),
      loc,
    )
  }
}

// Reference a term
#let gls(key, long: none, display: none) = {
  locate(
    loc => {
      let __glossary_entries = __glossary_entries.final(loc);
      if key in __glossary_entries {
        let entry = __glossary_entries.at(key)

        let gloss = __query_labels_with_key(loc, key, before: true)

        let is_first = gloss == ();
        let entlong = entry.at("long", default: "")
        let textLink = if display !=none {
            [#display]
        } else if (is_first or long == true) and entlong != [] and entlong != "" and long != false {
          [#entry.short (#entlong)]
        } else {
          [#entry.short]
        }

        [#link(label(entry.key), textLink)#label(__glossary_label_prefix + entry.key)]
      } else {
        text(fill: red, "Glossary entry not found: " + key)
      }
    },
  )
}

// reference to symbol 
#let sym(key) = {
  locate(
    loc => {
      let __glossary_entries = __glossary_entries.final(loc);
      if key in __glossary_entries {
        let entry = __glossary_entries.at(key)

        [#link(label(entry.key),[#entry.short])#label(__glossary_label_prefix + entry.key)]
      } else {
        text(fill: red, "Symbol entry not found: " + key)
      }
    },
  )
}
// equation include symbols 
#let print-eq-sym(..keys) = {
  "где"
  linebreak()
  for key in keys.pos() {
    locate(
    loc => {
      let __glossary_entries = __glossary_entries.final(loc);
      if key in __glossary_entries {
        let entry = __glossary_entries.at(key)

        let desc = if entry.desc != [] and entry.desc != none {
          [#entry.desc]
        } else {
          []
        }
        let linkText = [#h(2.5em)#entry.short --- #entry.long, #desc #linebreak()]
        [#link(label(entry.key),linkText)#label(__glossary_label_prefix + entry.key)]
      } else {
        text(fill: red, "Symbol entry not found: " + key)
      }
    },
    )
    
  }
}

// show rule to make the references for glossarium
#let make-glossary(body) = {
  show ref: r => {
    if r.element != none and r.element.func() == figure and r.element.kind == __glossarium_figure {
      // call to the general citing function
      gls(str(r.target))
    } else {
      r
    }
  }
  body
}

#let print-glossary(entries, show-all: false, disable-back-references: false) = {
  __glossary_entries.update(
    (x) => {
      for entry in entries {
        x.insert(
          entry.key,
          (
            key: entry.key,
            short: entry.short,
            long: entry.at("long", default: ""),
            desc: entry.at("desc", default: ""),
          ),
        )
      }

      x
    },
  )

  for entry in entries.sorted(key: (x) => x.key) {
    [
    #show figure.where(kind: __glossarium_figure): it => it.caption
    #par(
      hanging-indent: 1em,
      first-line-indent: 0em,
    )[
      #figure(
        supplement: "",
        kind: __glossarium_figure,
        numbering: none,
        caption: {
          locate(
            loc => {
              let term_references = __query_labels_with_key(loc, entry.key)
              if term_references.len() != 0 or show-all  {
                let desc = entry.at("desc", default: "")
                let long = entry.at("long", default: "")
                let hasLong = long != "" and long != []
                let hasDesc = desc != "" and desc != []

                {
                  set text(weight: 600)
                  if hasLong {
                    emph(entry.short) + [ -- ] + entry.long
                  }
                  else {
                    emph(entry.short)
                  }
                }
                if hasDesc [: #desc ] else [. ]
                if disable-back-references  != true { 
                  term_references.map((x) => x.location())
                  .sorted(key: (x) => x.page())
                  .fold(
                    (values: (), pages: ()),
                    ((values, pages), x) => if pages.contains(x.page()) {
                      (values: values, pages: pages)
                    } else {
                      values.push(x)
                      pages.push(x.page())
                      (values: values, pages: pages)
                    },
                  )
                  .values
                  .map(
                    (x) => link(
                      x,
                    )[#numbering(x.page-numbering(), ..counter(page).at(x))],
                  )
                  .join(", ")
                }
              }
            },
          )
        },
      )[] #label(entry.key)
      ]
    #parbreak()
    ]
  }
};
