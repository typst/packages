#import "../polytechnique.typ"

// Defining variables for the cover page and PDF metadata
// Main title on cover page
#let title = [Rapport de stage en entreprise
#linebreak()
sur plusieurs lignes]
// Subtitle on cover page
#let subtitle = "Un sous-titre pour expliquer ce titre"
// Short title on headers
#let short_title = "Rapport de stage"
#let author = "Rémi Germe"
#let date-start = datetime(year: 2024, month: 06, day: 05)
#let date-end = datetime(year: 2024, month: 09, day: 05)
// Set to true for bigger margins and so on (good luck with your report)
#let despair-mode = false

#set text(lang: "fr")

// Set document metadata
#set document(title: title, author: author, date: datetime.today())
#show: polytechnique.apply.with(despair-mode: despair-mode)

// Cover page
#polytechnique.cover.cover(title, author, date-start, date-end, subtitle: subtitle)
#pagebreak()

// Acknowledgements
#heading(level: 1, numbering: none, outlined: false)[Remerciements]
#lorem(250)
#pagebreak()

// Executive summary
#heading(level: 1, numbering: none, outlined: false)[Executive summary]
#lorem(300)
#pagebreak()

// Table of contents
#outline(title: [Template contents], indent: 1em, depth: 2)

// Defining header and page numbering (will pagebreak)
#set page(header: { 
  grid(columns: (1fr, 1fr),
    align(horizon, smallcaps(text(fill: rgb("01426A"), size: 14pt, font: "New Computer Modern", weight: "regular")[#short_title])),
    align(right, image("../assets/logo-x-ip-paris.svg", height: 20mm)))
}, numbering: "1 / 1")
#counter(page).update(1)

// Introduction
#heading(level: 1, numbering: none)[Introduction]
#lorem(400)
#pagebreak()

// Here goes the main content
= Premier titre

== Un sous-titre
 
#lorem(30)

=== Un détail pas si inutile

==== Halte au sketch

#lorem(20)


=== Encore un autre décidément

#lorem(120)

==== Il en faut toujours plus

#lorem(80)

== L'inspiration se fait rare
Ne pas oublier d'expirer surtout. #lorem(20)

#lorem(35)

#pagebreak()


= Deuxième partie

#lorem(300)

#pagebreak()

= Troisième axe
Parce qu'on a beaucoup de choses à dire et qu'on en a gros.

#pagebreak()


// Conclusion
#heading(level: 1, numbering: none)[Conclusion]
#lorem(200)

// Bibliography (if necessary)
// #pagebreak()
// #bibliography("path-to-file.bib")
