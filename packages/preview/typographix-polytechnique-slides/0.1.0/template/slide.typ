#import "@preview/typographix-polytechnique-slides:0.1.0" as template

/// Available options:
/// - ratio: a float, typically 16/9 or 4/3
/// - h1-theme: the theme for section title slides, one of
///   - "light"
///   - "light-dark": light with a dark frame
///   - "dark"
///   - "dark-light": dark with a light frame
///  - frame-theme: either "light" or "dark".
/// More information and previews on the README:
/// https://github.com/remigerme/typst-polytechnique/tree/main/slide
#show: template.apply.with(ratio: 16 / 9, h1-theme: "light", frame-theme: "light")


/// Cover page (optional), available options:
/// - title
/// - speaker
/// - date
/// - background-image: should `image("path/to/image.png", width: 100%, height: 100%)`
#template.cover(
  title: "Soutenance de stage",
  speaker: "Rémi Germe",
  date: "22/08/2025",
)


/// A fancy table of contents with custom layout (optional)
#outline(title: "Sommaire")

/// Everything below here is just a demo, erase it and create your own slides. Good luck!
= Branchez-vous

== Introduction

- On va être impactant
- Faut toujours 3 points
- J'ai appris ça en semcom (j'ai validé)

#v(1cm)
Un espace vertical pour aérer le tout. Et maintenant une grille avec deux éléments (ici, des tableaux):

#grid(
  columns: (1fr, 1fr),
  align: horizon + center,
  table(
    columns: (2fr, 1fr, 1fr),
    inset: 20pt,
    [*Volume horaire*], [*Fun*], [*Ennui*],
    [au moins 3h par jour], [oui], [non],
    [au moins 7h par jour], table.cell(colspan: 2, rect(fill: red, width: 100%)),
  ),
  table(
    stroke: (x, y) => if y == 0 { (bottom: 1pt) } else { none },
    [*Top cinq des gares*],
    [L'Argentière-la-Bessée],
    [Paris Gare de Lyon],
    [Cassis],
    [Saint-Pierre des Corps],
    [Montparnasse],
  ),
)

= CHARGEZ

== Conclusion

#align(center + horizon, text(size: 40pt, "Waouh on a bien bossé."))

#align(center, text(fill: template.PALETTE.gold, "Merci de votre attention."))
