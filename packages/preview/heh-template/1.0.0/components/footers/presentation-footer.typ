#import "/utils/utils.typ": format-author-names
#import "/utils/states.typ": heh-config

#let presentation-footer() = context {
  set text(size: 14pt)
  let config = heh-config.get()
  grid(
    columns: (auto, 3fr, 1fr),
    {
      format-author-names(config.document.authors, false).join(
        ", ",
        last: " et ",
      )
    },
    {
      align(center, {
        config.document.title
      })
    },
    {
      // Affiche les numéros de page à droite
      align(
        right,
        counter(page).display(
          "1/1",
          both: true,
        ),
      )
    },
  )
}
