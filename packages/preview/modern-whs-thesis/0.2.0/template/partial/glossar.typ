#import "@preview/glossarium:0.5.1": (
  register-glossary,
  print-glossary,
)

#let glossar(acronyms) = {
  heading(outlined: false, numbering: none)[Abkürzungsverzeichnis]


  let default-print-title(entry) = {
    let caption = []
    let txt = text.with(weight: 600)

    if has-long(entry) {
      caption += txt(emph(entry.short) + [ -- ] + entry.long)
    } else {
      caption += txt(emph(entry.short))
    }
    return caption
  }

  let default-print-description(entry) = {
    return entry.at("description")
  }

  let default-print-back-references(entry) = {
    return get-entry-back-references(entry).join(", ")
  }

  let __glossary_label_prefix = "__gls:"

  let __query_labels_with_key(loc, key, before: false) = {
    if before {
      return query(
        selector(label(__glossary_label_prefix + key)).before(
          loc,
          inclusive: false,
        ),
      )
    } else {
      return query(selector(label(__glossary_label_prefix + key)))
    }
  }

  let count-refs(entry) = {
    let refs = __query_labels_with_key(here(), entry.key, before: true)
    return refs.len()
  }

  let default-print-gloss(
    entry,
    show-all: false,
    disable-back-references: false,
    user-print-title: default-print-title,
    user-print-description: default-print-description,
    user-print-back-references: default-print-back-references,
  ) = context {
    let caption = []

    if show-all == true or count-refs(entry) != 0 {
      // Title
      caption += user-print-title(entry)

      // Description
      if has-description(entry) {
        // Title - Description separator
        caption += ": "

        caption += user-print-description(entry)
      }

      // Back references
      if disable-back-references != true {
        caption += " "

        caption += user-print-back-references(entry)
      }
    }

    return caption
  }

  let __glossarium_figure = "glossarium_entry"

  let default-print-reference(
    entry,
    show-all: false,
    disable-back-references: false,
    user-print-gloss: default-print-gloss,
    user-print-title: default-print-title,
    user-print-description: default-print-description,
    user-print-back-references: default-print-back-references,
  ) = {
    return [
      #show figure.where(kind: __glossarium_figure): it => it.caption
      #par(
        hanging-indent: 1em,
        first-line-indent: 0em,
      )[
        #figure(
          supplement: "",
          kind: __glossarium_figure,
          numbering: none,
          caption: user-print-gloss(
            entry,
            show-all: show-all,
            disable-back-references: disable-back-references,
            user-print-title: user-print-title,
            user-print-description: user-print-description,
            user-print-back-references: user-print-back-references,
          ),
        )[] #label(entry.key)
        // Line below can be removed safely
        #figure(kind: __glossarium_figure, supplement: "")[] #label(
          entry.key + ":pl",
        )
      ]
      #parbreak()
    ]
  }


  register-glossary(acronyms)

  print-glossary(
    acronyms,
    disable-back-references: true,
    user-print-glossary: (entries, groups, ..) => {
      table(
        columns: (0pt, 0pt, auto, auto),
        stroke: 0pt,
        ..for group in groups {
          (
            table.cell(group, colspan: 2),
            ..for entry in entries.filter(x => x.group == group) {
              (
                text.with(weight: 600)(emph(entry.short)) + h(20pt),
                entry.long,
                entry.description,
                default-print-reference(entry),
              )
            },
          )
        }
      )
    },
  )
}
