= Exemples de tableaux

== Tableaux de base

#table(
  columns: (auto, auto, auto),
  align: center,
  inset: 1em,
  [*Nom*], [*Âge*], [*Rôle*],
  [Alice], [28], [Designer],
  [Bob], [34], [Développeur],
  [Charlie], [45], [Manager],
)

== Tableau dans une figure

#figure(
  table(
    columns: (auto, auto, auto),
    align: center,
    inset: 1em,
    [*Nom*], [*Âge*], [*Rôle*],
    [Alice], [28], [Designer],
    [Bob], [34], [Développeur],
    [Charlie], [45], [Manager],
  ),
  caption: "Un tableau simple avec une légende",
)

== Style de tableau

#table(
  columns: (1fr, auto, auto),
  inset: 1em,
  fill: (_, row) => if row == 0 { rgb("#dfebf6") } else if calc.odd(row) {
    rgb("#f7f7f7")
  } else { white },
  stroke: 0.7pt + rgb("#5c8db7"),
  [*Produit*], [*Prix*], [*Quantité*],
  [Ordinateur portable], [\$999], [5],
  [Clavier], [\$25], [10],
  [Souris], [\$85], [7],
  [Écran], [\$249], [3],
)

== Dimensionnement des colonnes

#table(
  columns: (20%, 50%, 30%),
  inset: 1em,
  [*Colonne 1*], [*Colonne 2*], [*Colonne 3*],
  [Ceci est du texte dans la première colonne],
  [Cette colonne est plus large et offre plus d’espace pour le contenu],
  [Retour à une colonne plus étroite],
)
