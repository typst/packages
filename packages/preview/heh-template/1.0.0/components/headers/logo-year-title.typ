#import "/utils/utils.typ": heh-logo
#import "/utils/states.typ": heh-config

// Affiche le logo à gauche et l'année académique et le titre à droite
#let logo-year-title(
  show-year: true,
  show-title: true,
) = context {
  let config = heh-config.get()
  columns(2, {
    heh-logo(
      width: 200pt,
    )

    colbreak()
    align(right, {
      if show-year [
        Année académique #text(config.document.year, fill: config.campus.style.primary-color)
      ]
      if show-year and show-title {
        linebreak()
      }
      if show-title {
        config.document.title
      }
    })
  })
}

