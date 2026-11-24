#let __publication_figure_kind = "publication_entry"
#let __publication_text_map = state("publication-map", (:))

#let make-publication-list(
  body,
) = {
  show ref: it => {
    if (
      it.element != none
        and it.element.func() == figure
        and it.element.kind == __publication_figure_kind
    ) {
      let key = str(it.target)
      link(label(key), text(
        weight: "medium",
        [Publication~#__publication_text_map.final().at(key)],
      ))
    } else {
      return it
    }
  }
  body
}

#let publication-list-page(publications, index-font: "EB Garamond") = {
  if publications == none or publications.len() == 0 {
    return none
  }

  let grouped-publications = ("": ())
  for entry in publications {
    let group = entry.at("group", default: "")
    if group not in grouped-publications {
      grouped-publications.insert(group, ())
    }
    grouped-publications.at(group).push(entry)
  }

  [= Publications <outline:publications>]

  let publication-counter = counter("pub-list")
  publication-counter.step()

  let groups = grouped-publications.pairs().filter(it => it.at(1).len() > 0)
  for (group, pubs) in groups {
    block[
      #if group != "" {
        heading(
          level: 2,
          outlined: false,
          numbering: none,
          group,
        )
      }
      #grid(
        columns: (7%, 93%),
        align: (top + left, top + left),
        row-gutter: 2.0em,
        column-gutter: 0.0em,
        ..for ii in range(pubs.len()) {
          let publication = pubs.at(ii)
          (
            context {
              publication-counter.step()
              set text(fill: black, weight: "bold")
              let label-key = "pub:" + publication.key
              let pub-text = text(
                font: index-font,
                [#publication-counter.display(
                  "I",
                )],
              )
              __publication_text_map.update(d => {
                d.insert(label-key, pub-text)
                d
              })
              [
                #figure(
                  kind: __publication_figure_kind,
                  numbering: none,
                  supplement: "",
                  pub-text,
                )#label(label-key)
              ]
            },
            {
              let status = publication.at("status", default: none)
              if status != none {
                text(weight: "medium", [\[#status\] ])
              }
              show regex("^\[\d+\]\s*"): none
              text(publication.text)
            },
          )
        }
      )
    ]
  }
}
