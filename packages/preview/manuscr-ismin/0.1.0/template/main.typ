#import "@preview/manuscr-ismin:0.1.0": *

#show: manuscr-ismin.with(
  title: "Titre",
  subtitle: "Sous-titre",
  authors: (
    (
      name: "Auteur 1",
      affiliation: "Filière 1",
      year: "Année 1",
      class: "Classe 1"
    ),
    (
      name: "Auteur 2",
      affiliation: "Filière 2",
      year: "Année 2",
      class: "Classe 2"
    )
  ),
  logo: "assets/logo_emse_white.svg",
  header-title: "En-tête 1",
  header-subtitle: "En-tête 3",
  header-middle: [En-tête 2],
  date: "Date"
)

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

Ce _template_ est utilisé pour écrire les rapports à l'ISMIN.
Vous pouvez évidemment en modifier le contenu.
Ci-suit une présentation de ce que peut faire ce _template_.

= Titre de niveau 1

Les titres sont colorés.

== Titre de niveau 2

Les ```typ #smallcaps``` ont un espace entre les lettres augmenté, pour faciliter la lecture.
Cette _feature_ n'est pas disponible pour le texte en majuscule pour le moment.
#smallcaps[Les "petites majuscules" sont à utiliser avec parcimonie].


La fonction ```typst #lorem``` permet de générer du texte à l'infini.
Ici je m'en sers pour montrer l'agencement d'un paragraphe.
#lorem(80)

#lorem(76)

#lorem(41)

== Les tableaux

Les tableaux (dans une figure) dans ce _template_ ressemblent à ça.

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

Pour adapter la mise en forme à un tableau avec les titres verticaux:

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

== Code

Le code en ligne ressemble à ça ```c int main(void)``` ou à ça `par exemple`.
Le code en bloc se dote d'un exemple juste au dessus.

== Les mathématiques

Il en va de même pour les mathématiques.
3x + 7 = 8 deviendra $3x + 7 = 8$, ce qui n'est pas du tout la même chose.
Voici les équations de Maxwell en bloc au sein d'une figure :

#figure(
  caption: [Équations de Maxwell],
  kind: "equation"
  )[
  $
    op("div")(arrow(E)) &= rho / epsilon_0  \
    arrow(op("rot"))(arrow(E)) &= - (diff arrow(B)) / (diff t) \
    op("div")(arrow(B)) &= 0 \
    arrow(op("rot"))(arrow(B)) &= mu_0 arrow(j) + mu_0 epsilon_0 (diff arrow(E)) / (diff t)
  $
]

L'équation de Maxwell préférée de mon amie est celle dite de Maxwell-Faraday (locale) obtenue grâce au théorème de Stokes : $integral.cont_C arrow(E) dif arrow(cal(l)) = - dif / (dif t) (integral_S arrow(B) dif arrow(S))$.

== Les figures/les liens

Les figures permettent de centrer le contenu et d'ajouter sous-titres et références.
Pour une figure avec une image ou une équation, la légende est en bas, mais pour les tableaux et les listages elle est en haut.
Voici une image tirée de #link("https://x.com/chatmignon__")[Twitter] (j'ai fait un lien vers Twitter) :
#figure(caption: [Toto apprend à Tigre comment coder en C++])[
  #image("images/toto_tigre.jpg", height: 30%)
]

== Les liens

Les liens externes (vers l'extérieur du document) sont indiqués avec un cercle bleu.
Les liens internes eux sont indiqués avec un carré de la couleur principale du document.
#link(<tab1>)[Lien interne] et #link("https://www.youtube.com/shorts/YQjfUjAAlgs")[lien externe.]
Je sais que c'est non-usuel, mais selon Matthew Butterick, c'est mieux.

== Listes

=== Listes de puces

On peut utiliser ```typ -``` pour faire des listes de puces, comme suit :

- Oui
- Non
- Peut-être

On peut les faire plus espacées :

- Comme ça

- La différence est flagrante

- Impressionnant

=== Listes numérotées

Même principe pour les listes numérotées, mais avec un ```typ +``` :

+ Incroyable
  + On peut même inclure des listes dans des listes
  + La technologie est folle
+ Wow
+ Impressionant


Changeons de page.

== Les citations

#quote(block: true, attribution: [Lews Therin Thelamon @wot_8])[
  Moi, je n’ai jamais été vaincu !
  Je suis le Seigneur du Matin.
  Personne ne peut me battre.
]

D'après un autre individu (invincible également), il serait bon que tu #quote(attribution: <sam_2>)[adopte un chien].

== Autres

Typst offre énormément d'autres possibilités, n'hésitez pas à consulter la documentation !

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
