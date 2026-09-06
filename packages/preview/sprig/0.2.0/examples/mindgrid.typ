// sprig 0.2.0 — mindgrid : disposition fixe, branches routées autour des cartes.
#import "@preview/sprig:0.2.0": *

#set page(width: 24cm, height: 14cm, margin: 0.8cm)
#set text(size: 9pt)

#mindgrid(
  [*Cycle de résolution*],
  cols: 3,
  route: true,
  theme: "poster",
  node(title: [*Observer*])[Lire l'énoncé et surligner les données.],
  node(title: [*Traduire*])[Écrire l'équation correspondante.],
  node(title: [*Résoudre*])[Isoler l'inconnue pas à pas.],
  node(title: [*Vérifier*], col: 2, row: 1)[Remplacer la valeur trouvée.],
  node(title: [*Conclure*], col: 0, row: 1)[Rédiger la réponse.],
)
