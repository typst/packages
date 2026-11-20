// Affiche les numéros de page à droite ou à gauche, avec une barre pour savoir s'il s'agit de la page de droite ou de gauche
// Assume que la page de garden'est pas la première page (mais la "page 0")
#let page-numbers-side(
  show-total: true,
  ..args,
) = {
  let pagenr = counter(page).get().first()
  let alignment = if calc.rem(pagenr, 2) == 0 { right } else { left }

  align(
    alignment,
    counter(page).display(
      if (alignment == left) { "1/1 |" } else { "| 1/1" },
      both: show-total,
    ),
  )
}

