#import "@preview/typographix-polytechnique-reports:0.1.5" as template

// Defining variables for the cover page and PDF metadata
// Main title on cover page
#let title = [Rapport de stage en entreprise
#linebreak()
sur plusieurs lignes]
// Subtitle on cover page
#let subtitle = "Un sous-titre pour expliquer ce titre"
// Logo on cover page
#let logo = none // instead of none set to image("path/to/my-logo.png")
#let logo-horizontal = true // set to true if the logo is squared or horizontal, set to false if not
// Short title on headers
#let short-title = "Rapport de stage"
#let author = "Rémi Germe"
#let date-start = datetime(year: 2024, month: 06, day: 05)
#let date-end = datetime(year: 2024, month: 09, day: 05)
// Set to true for bigger margins and so on (good luck with your report)
#let despair-mode = false

#set text(lang: "fr")

// Set document metadata
#set document(title: title, author: author, date: datetime.today())
#show: template.apply.with(despair-mode: despair-mode)

// Cover page
#template.cover.cover(title, author, date-start, date-end, subtitle: subtitle, logo: logo, logo-horizontal: logo-horizontal)
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
#show: template.page.apply-header-footer.with(short-title: short-title)

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
