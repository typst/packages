//                      ttuile
//                    ~~~~~~~~~~
//             Find out more on github
//         https://github.com/vitto4/ttuile
//
//
// English-language report ?
//  >> https://github.com/vitto4/ttuile#-notes


// Imports : ttuile, appendices-section, appendix
#import "@preview/ttuile:0.2.0": *


#show: ttuile.with(
  // This is one way to set the headline, but the following also works :
  //  * headline: [You may supply just the title],
  //  * headline: text(fill: blue, weight: "regular")[And even style it\ however you wish],
  headline: (
    lead: [Compte rendu de TP n°1 :],
    title: [« #lorem(8) »],
  ),
  // Same as above :
  //  * authors: [You may also supply whatever you want],
  authors: (
    "Theresa Tungsten",
    "Jean Dupont",
    "Eugene Deklan",
  ),
  group: "TD0",
  footer-left: [Poste n°0],
  footer-right: datetime.today().display("[day]/[month]/[year]"),
  outlined: true,
  // Also remove the uni logo or insert your own :
  //  * logo: image("your-logo.png"),
  //  * logo: none,
)


// You may delete everything below this line to get stared.
//
// If you're feeling lazy, give `Ctrl + Shift + End` a try :p
//
// <><><><><><><><><><><><><><><><><><><><><><><><><><><><><> //


// ---------------------------------------------------------- //
//                      Corps du rapport                      //
// ---------------------------------------------------------- //

// ---------------------- Introduction ---------------------- //

= #lorem(1)

#lorem(30)

- #lorem(30)
- #lorem(25)


// Les équations sont numérotées par défaut
$
  E = m c^2 + "AI"
$

// Note de bas de page
#lorem(28) #footnote([#lorem(27)])


#{ 2 * linebreak() }


// Création d'une figure
#let liste-couleurs = (black, gray, silver, white, navy, blue, aqua, teal, eastern, purple, fuchsia, maroon, red, orange, yellow, olive, green, lime)

#let couleurs = grid(
  columns: 9 * (1fr,),
  rows: 2,
  row-gutter: 1em,
  ..liste-couleurs.map(c => {
    square(
      size: 45pt,
      fill: c,
      stroke: if (black, navy, maroon).contains(c) { 1.2pt + silver } else { 1.2pt },
    )
  })
)

#figure(
  couleurs,
  caption: [#lorem(10)],
)


// Saut de page après l'introduction
#pagebreak()


// ---------------------- Deuxième page --------------------- //

= #lorem(10) <h1>

// L'espacement entre les titres peut être modifié :
//  * #show heading: set block(above: 18pt, below: 5pt)
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
#math.equation(
  numbering: none,
  block: true,
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
  $,
)

#lorem(45)

==== #lorem(5)

#lorem(50) #linebreak()
#lorem(23)

// ------------------------- Annexes ------------------------ //

// Définition d'une annexe, elle reste pour l'instant simplement
// stockée dans une variable et n'est pas immédiatement affichée
// 
// https://github.com/vitto4/ttuile/blob/main/docs/DOCS.md#appendix
#let annexe-1 = appendix(
  title: [#lorem(5)],
  lbl: <annexe-1>,
)[
  // Le corps de l'annexe, i.e. ce qui est affiché sur la page en dessous du titre
  #lorem(50)

  #align(
    center,
  )[
    *95% of people cannot solve this!*
    #let rr = $thin \u{1f98f} thin$
    #let bb = $thin \u{1f37b} thin$
    #let ll = $thin \u{1f3ee} thin$

    #{
      set math.equation(numbering: none)
      $
        ll / (bb + rr) + bb / (ll + rr) + rr / (ll + bb) = 4
      $
    }

    *Can you find positive whole values for $ll$, $bb$ and $rr$?*
    // https://www.quora.com/How-do-you-find-the-positive-integer-solutions-to-frac-x-y+z-+-frac-y-z+x-+-frac-z-x+y-4/answer/Alon-Amit   >:3
  ]

  #lorem(45)
]

// https://github.com/vitto4/ttuile/blob/main/docs/DOCS.md#appendices-section
#appendices-section(
  // Ajouter les éventuelles autres annexes dans la liste
  appendices: (annexe-1,),
  // `true` par défaut, on demande l'affichage de la table des annexes
  outlined: true,
  pagebreak-after-outline: false,
)
