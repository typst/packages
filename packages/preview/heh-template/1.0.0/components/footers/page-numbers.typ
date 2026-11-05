// Affiche les numéros de page à droite
#let page-numbers(
  show-total: true,
) = {
  align(
    right,
    counter(page).display(
      "1/1",
      both: show-total,
    ),
  )
}

