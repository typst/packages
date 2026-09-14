#import "@preview/agregyst:1.0.0" : tableau, dev, recap, item

#set text(lang: "fr")
#set document(title: [Titre de la leçon])
#show: tableau


#title()


= Première partie

== Première sous-partie @TOR

#item("Définition")[Un mot][
  est...
]

#item("Theorème")[Lemme de l'étoile.][
  Soit $u$ un mot...
] <th:étoile>

// Sous-partie sans référence bibliographique particulière.
== Deuxième sous-partie @NAN

#dev[
  #item("Exemple")[Le langage de Dyck][
    est... Référence au @th:étoile.
  ]
]


= Deuxième partie

...


#recap()

// Impossible de spécifier le chemin directement dans la fonction `bibliography`
// pour des raisons techniques.
#bibliography(read("bib.yaml", encoding: none))
