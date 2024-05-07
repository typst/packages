// ttuile template, find out more on github https://github.com/vitto4/ttuile
// Documentation available in the readme file.

// * : ttuile, equation-anonyme, annexe, afficher-annexes, figure-emboitee
#import "@preview/ttuile:0.1.1": *

#show: ttuile.with(
  titre: [« #lorem(8) »],
  auteurs: (
      "Theresa Tungsten",
      "Jean Dupont",
      "Eugene Deklan",
  ),
  groupe: "TD0",
  numero-tp: 0,
  numero-poste: "0",
  date: datetime.today(),
  // sommaire: false,
  // logo: image("path_to/logo.png"),
  // point-legende: true,
)


// Supprimez tout ce qu'il y a en dessous de cette ligne pour commencer.
// Delete everything below this line to get stared.
//
// If you're feeling lazy, give `Ctrl + Shift + End` a try :p
//
// <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> //




// ---------------------------------------------------------------------------- //
//                               Corps du rapport                               //
// ---------------------------------------------------------------------------- //

// ------------------------------- Introduction ------------------------------- //

= #lorem(1)

#lorem(30)

- #lorem(30)
- #lorem(25)


// Les équations sont numérotées par défaut
$
E = m c^2 + italic("AI")
$

// Note de bas de page
#lorem(28) #footnote([#lorem(27)])


#{2*linebreak()}


// Création d'une figure
#let liste-couleurs = (black, gray, silver, white, navy, blue, aqua, teal, eastern, purple, fuchsia, maroon, red, orange, yellow, olive, green, lime)

#let couleurs = grid(
  columns: 9*(1fr,),
  rows: 2,
  row-gutter: 1em,
  ..liste-couleurs.map(c => {
    square(
      size: 45pt,
      fill: c,
      stroke: if (black, navy, maroon).contains(c) {1.2pt + silver} else {1.2pt},
    )
  })
)

#figure(
  couleurs,
  caption: [#lorem(10)]
)


// Saut de page après l'introduction
#pagebreak()


// ------------------------------- Deuxième page ------------------------------ //

= #lorem(10)

// L'espacement entre les titres est géré automatiquement
== #lorem(7)

#lorem(26)

// Il est possible de référencer une annexe définie à la fin du rapport
@annexe-1 #lorem(10)

== #lorem(2)

#lorem(18)

=== #lorem(6)

#lorem(45) #linebreak()
#lorem(35)

// Les titres de niveau 4 ne sont pas affichés dans la table des matière
// C'est le plus bas niveau actuellement supporté par le template, un titre de niveau 5 ne sera pas stylisé adéquatement
==== #lorem(1)

#lorem(30)

// Cette équation n'est pas numérotée (contrairement à celle en introduction)
#equation-anonyme(
  $
  tilde(cal(T)) =
  mat(
      delim: "|",
      1, 2, ..., 10;
      2, 2, ..., 10;
      dots.v, dots.v, dots.down, dots.v;
      10, 10, ..., 10;
      gap: #0.3em
  )
  $
)

#lorem(45)

==== #lorem(5)

#lorem(50) #linebreak()
#lorem(23)


// ---------------------------------- Annexes --------------------------------- //

// Définition d'une annexe, elle reste pour l'instant simplement stockée dans une variable et n'est pas immédiatement affichée
#let annexe-1 = annexe(
  titre: [#lorem(5)],
  reference: <annexe-1>,
)[
  // Le corps de l'annexe, c'est ce qui est affiché sur la page en dessous du titre
  #lorem(50)
  
  #align(
    center
  )[
    *95% of people cannot solve this!*
    #let rr = $thin \u{1f98f} thin$
    #let bb = $thin \u{1f37b} thin$
    #let ll = $thin \u{1f3ee} thin$

    #equation-anonyme(
      $
      ll / (bb + rr) + bb / (ll + rr) + rr / (ll + bb) = 4
      $
    )
    
    *Can you find positive whole values for $ll$, $bb$ and $rr$?*
  ]

  #lorem(45)
]

#afficher-annexes(
  annexes: (annexe-1,),   // Ajouter les autres annexes dans la liste
  table: true,            // `true` par défaut, on demande l'affichage de la table des annexes
)