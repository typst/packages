#import "@preview/silky-slides-insa:0.1.0": *

#show: insa-slides.with(
  title: "Titre du diaporama",
  title-visual: none,
  subtitle: "Sous-titre (noms et prénoms ?)",
  insa: "rennes"
)

= Titre de section

== Titre d'une slide

- Liste
  - dans
    - une liste

On peut aussi faire un #text(fill: insa-colors.secondary)[texte] avec les #text(fill: insa-colors.primary)[couleurs de l'INSA] !

== Une autre slide

Du texte

#pause

Et un autre texte qui apparaît plus tard !

#section-slide[Une autre section][Avec une petite description]

Coucou