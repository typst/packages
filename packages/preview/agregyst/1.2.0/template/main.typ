#import "@preview/agregyst:1.2.0" : tableau, dev, recap, item

#set text(lang: "fr")
#set document(title: [Titre de la leçon])
#show: tableau


#title()


= Première partie

== Première sous-partie @TOR

#item("Définition")[
  Un _mot_ est...
]

#item("Theorème")[
  *Lemme de l'étoile.* Soit $u$ un mot...
] <th:étoile>

// Le champs `summary` est utilisé dans le récap.
#item("Remarque", summary: [Utilité du @th:étoile])[
  Le @th:étoile est utile pour...
]

// Sous-partie sans référence bibliographique particulière.
== Deuxième sous-partie @NAN

#dev[
  #item("Exemple")[
    Le _langage de Dyck_ est...
  ]
]


= Deuxième partie

...


#recap()

// Impossible de spécifier le chemin directement dans la fonction `bibliography`
// pour des raisons techniques.
#bibliography(read("bib.yaml", encoding: none))
