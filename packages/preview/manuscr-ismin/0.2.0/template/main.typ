#import "@preview/manuscr-ismin:0.2.0": *

#show: manuscr-ismin.with(
  uptitle: [surtitre],
  title: [Titre],
  subtitle: [Sous-titre],
  authors: (
    (
      name: "Auteur 1",
      affiliation: "Filière 1",
      year: "Année 1",
      class: "Classe 1",
      email: "auteur1@emse.fr"
    ),
    (
      name: "Auteur 2",
      affiliation: "Filière 2",
      year: "Année 2",
      class: "Classe 2",
      email: "auteur2@emse.fr"
    )
  ),
  logo: "assets/logo_emse_white.svg",
  header-title: "En-tête 1",
  header-subtitle: "En-tête 3",
  header-middle: [En-tête 2],
  date: "Date"
)

/*
 * Tables
 * Retirez celles dont vous ne vous servez pas
 */

#outline(indent: auto)

#heading(numbering: none)[Table des figures] <fig_outline>
#outline(target: figure.where(kind: image), title: none)

#heading(numbering: none)[Table des tableaux]
#outline(target: figure.where(kind: table), title: none)

#heading(numbering: none)[Table des équations]
#outline(target: figure.where(kind: "equation"), title: none)

#heading(numbering: none)[Table des listages]
#outline(target: figure.where(kind: raw), title: none)

#pagebreak()

/* Reste du document */

Ce _template_ est utilisé pour écrire les rapports à l'#smallcaps[ismin].
Vous pouvez évidemment en modifier le contenu.
Ci-suit une présentation de ce qu'il est possible de faire avec.

= Différences avec le "par défaut"

== Titres

Les titres sont colorés avec le violet #smallcaps[emse], mais il est possible de le modifier.
Pour générer des titres de différents niveaux :

#figure(
  ```typst
  = Premier titre de niveau 1

  == Premier titre de niveau 2

  === Premier titre de niveau 3

  == Second titre de niveau 1
  ```,
  caption: [Génération des titres]
)

Les titres servent à générer une table des matières et à segmenter le document.

== Tableaux

Les tableaux (dans une figure) dans ce _template_ ressemblent à ceci :

#figure(caption: [Un tableau])[
#table(
  align: center + horizon,
  columns: 2,
  table.header([#align(center)[*Chiffres*]], [#align(center)[*Lettres*]]),
  [0], [A],
  [1], [B],
  [2], [#sym.Gamma],
  [3], [#sym.Delta],
  [4], [#sym.Epsilon]
  )
] <tab1>

La fond de la première ligne est plus foncé, puis on a une alternance des couleurs en descendant.
Si on veut un tableau avec les titres "verticaux", voici le code à utiliser -- on change la fonction qui sert paramètre `fill` à la fonction `table` :

#figure(
```typ
  #table(
    fill: (x, y) => if x == 0 {
      body-color
      } else if calc.even(y) {
        block-color
      } else {
        none
      },
    align: horizon,
    [Contenu], [Contenu], [...]
  )
  ```,
  caption: [Adapter le coloriage pour un tableau "vertical"]
)

On a ceci :

#figure(caption: [Un autre tableau])[
  #show table.cell.where(y: 0): set text(
    style: "normal", weight: "regular"
  )
  #table(
    align: center + horizon,
    columns: 9,
    fill: (x, y) => if x == 0 {
      body-color
      } else if calc.even(y) {
        block-color
      } else {
        none
      },
    [$n$], [0], [1], [2], [3], [4], [5], [6], [7],
    [$F_n$], [0], [1], [1], [2], [3], [5], [8], [13],
    )
]

== Code

Le code en ligne ressemble à ça ```c int main(void)``` ou à ça `par exemple` ; le fond est coloré avec une nuance du violet #smallcaps[emse].
Voici un exemple pour du code en bloc :


#figure(
  caption: [Fichier ],
  ```sv
  `timescale  1ns / 1ps

  module xor_down import ascon_pack::*; (
    input  logic[255:0] data_xor_down_i,
    input  logic[1:0]   ena_xor_down_i,
    input  type_state   state_i,
    output type_state   state_o
  );
    // Downstream XOR
    assign state_o[0] = state_i[0];
    assign state_o[1] = (ena_xor_down_i)? state_i[1] ^ data_xor_down_i[255:192]: state_i[1];
    assign state_o[2] = (ena_xor_down_i)? state_i[2] ^ data_xor_down_i[191:128]: state_i[2];
    assign state_o[3] = (ena_xor_down_i)? state_i[3] ^ data_xor_down_i[127: 64]: state_i[3];
    assign state_o[4] = (ena_xor_down_i)? state_i[4] ^ data_xor_down_i[ 63:  0]: state_i[4];
  endmodule: xor_down
  ```
)

== Les mathématiques

Attention à bien utiliser le mode mathématique pour
3x + 7/8y >= 23 deviendra $3x + 7/8y >= 23$, ce qui n'est pas du tout la même chose.
Voici les équations de #smallcaps[Maxwell] en bloc au sein d'une figure -- pour montrer un peu ce qu'il est possible de faire :

#figure(
  caption: [Équations de #smallcaps[Maxwell]],
  kind: "equation"
)[
$
op("div")(arrow(E)) &= rho / epsilon_0  \
arrow(op("rot"))(arrow(E)) &= - (partial arrow(B)) / (partial t) \
op("div")(arrow(B)) &= 0 \
arrow(op("rot"))(arrow(B)) &= mu_0 arrow(j) + mu_0 epsilon_0 (partial arrow(E)) / (partial t)
$
]

L'équation de #smallcaps[Maxwell] préférée de mon amie est celle dite de #smallcaps[Maxwell-Faraday] (locale) obtenue grâce au théorème de #smallcaps[Stokes] : $integral.cont_C arrow(E) dif arrow(cal(l)) = - dif / (dif t) (integral_S arrow(B) dif arrow(S))$.

Le séparateur décimal par défaut est le point en Typst, donc ils sont automatiquement convertis en virgules dans le mode math par le _template_ :
$ 3.8 != 3, 8 $
On utilisera les virgules plutôt comme séparateur (comme les points-virgules) :
$ A = {1, 2, 3} $


== Les figures

Les figures permettent de centrer le contenu et d'ajouter sous-titres et références.
Pour une figure avec une image ou une équation, la légende est en bas, mais pour les tableaux et les listages elle est en haut.
Voici une image tirée de #link("https://x.com/chatmignon__")[Twitter] (j'ai fait un lien vers Twitter) :
#figure(caption: [Toto apprend à Tigre comment coder en C++])[
#image("images/toto_tigre.jpg", height: 7cm)
]

== Les liens

Les liens externes (vers l'extérieur du document) sont indiqués avec un cercle bleu.
Les liens internes eux sont indiqués avec un carré de la couleur principale du document.
#link(<tab1>)[Lien interne] et #link("https://http.cat/")[lien externe.]
Je sais que c'est non-usuel, mais selon Matthew #smallcaps[Butterick], c'est mieux.

== Listes

=== Listes de puces

On peut utiliser ```typ -``` pour faire des listes de puces, comme suit :

- oui,
- non
- peut-être.

On peut les faire plus espacées :

- comme ça,

- la différence est flagrante,

- impressionnant.

=== Listes numérotées

Même principe pour les listes numérotées, mais avec un ```typ +``` :

+ Incroyable ;
  + on peut même inclure des listes dans des listes,
  + la technologie est folle.
+ Wow.
+ Impressionant.

== Les citations

#quote(block: true, attribution: [Lews Therin Thelamon @wot_8])[
Moi, je n’ai jamais été vaincu !
Je suis le Seigneur du Matin.
Personne ne peut me battre.
]

D'après un autre individu (invincible également), il serait bon que tu #quote(attribution: <sam_2>)[adopte un chien].

== Autres

Typst offre énormément d'autres possibilités, n'hésitez pas à consulter la documentation !
Le reste du document est rempli avec du vide.

= Partie 2

#lorem(67)

= Partie 3

#lorem(67)

#lorem(42)

#bibliography("bibs.yaml", style: "ieee")

#heading(numbering: none)[Glossaire]

/ Terme: Une définition de ce terme.
/ Autre terme: Une définition de cet autre terme.
/ UAVM: Un Acronyme Vraiment Mystérieux.