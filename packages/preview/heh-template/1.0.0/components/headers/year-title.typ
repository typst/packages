#import "/utils/states.typ": heh-config

// Affiche le titre à gauche et l'académique à droite
#let year-title(
  title-left: true,
) = context {
  let config = heh-config.get()
  let year-content = [
    Année académique #text(config.document.year, fill: config.campus.style.primary-color)
  ]
  let title-content = config.document.title

  let lhs = if title-left { title-content } else { year-content }
  let rhs = if title-left { year-content } else { title-content }

  lhs
  h(1fr)
  rhs
}

