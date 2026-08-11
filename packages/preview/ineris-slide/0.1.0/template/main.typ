#import "@preview/touying:0.6.1": *
#import "@preview/ineris-slide:0.1.0": *

#show: ineris-slideshow.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Objet du document],
    subtitle: [Sous-titre],
    author: [FH],
    date: datetime.today(),
  ),
)

#title-slide()

#outline-slide()

= Titre de la partie

#slide(title: [Lorem ipsum dolor sit amet])[
	#set page(columns:3)
	#lorem(80)
]

== Nouvelle diapositive
Texte racine
- Texte de niveau 1
	- Texte de niveau 2
		- Texte de niveau 3
			- Texte de niveau 4

= Blocs spéciaux

== Tableaux
#styled-table(columns: 4,
	table.header([Source],[Année],[Valeurs seuils aiguës (mg/L)],[Valeurs seuils chroniques (mg/L)]),
	[US EPA], [1998], [860], [230],
	[Canada (BC)], [2003], [600], [150],
)

== Blocs
#focus-block("Attention")[Ceci est important]

#shadow-block[L'ombre capte la lumière]

= Diapositives spéciales
#matrix-slide(title: "Plusieurs volets", columns: 2, rows: 4)[#lorem(20)][#lorem(20)][#lorem(20)][#lorem(20)]

#focus-slide[Merci de votre attention]

