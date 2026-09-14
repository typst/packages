#import "@preview/amsterdammetje-article:0.1.1": article, heading-author, abstract

#set text(lang: "nl")

#show: article(
  title: "Titel van het document",
  authors: ("Auteur 1", "Auteur 2"),
  ids: ("UvAnetID student 1", "UvAnetID student 2"),
  tutor: "Naam van de tutor",
  mentor: none,
  lecturer: none,
  group: "Naam van de groep",
  course: "Naam van de cursus",
  course-id: none,
  assignment-name: "Naam van de opdracht",
  assignment-type: "Type opdracht",
  link-outline: true
)

// #outline()
// #abstract(lorem(70))

= Introductie
#lorem(18)
Deze alinea eindigt met een referentie @vanwijk21.

== Paragraaf met auteur
#heading-author[Voornaam Achternaam]
#lorem(75)

#lorem(75)

#bibliography("references.bib")
