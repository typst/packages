#import "@preview/glossy:0.8.0": *
#show: init-glossary.with(yaml("glossary.yaml"), term-links: true)
#import "abstract.typ": *
#import "acknowledgements.typ": *
#import "appendices.typ": *

#import "@preview/volt-internship-ensea:0.2.0": *

#show: internship.with(
  abstract: abstract(),
  acknowledgements: acknowledgements(),
  appendices: annexes(),
  references: bibliography("references.bib", full: true),

  // ============================
  // VARIABLES TO MODIFY
  // ============================

  // Path to the company logo
  company-logo: image("media/logo.png"),

  // Name(s) of the report author(s)
  authors: (
    "Jean DUPONT",
  ),

  // Information about the student(s)
  student-info: [*Élève ingénieur en X#super[ème] année* #linebreak()
    Promotion 20XX #linebreak()
    Année 20XX/20XX],

  // Title of the internship report
  title: [#lorem(10)],

  // Company name, location, duration, etc.
  internship-details: [Stage effectué du *1er mars au 30 août 2025*, au sein de la société *TechSolutions*, située à Paris.

    Sous la responsabilité de : #linebreak()
    - M. *Pierre LEFEVRE*, Directeur de la Stratégie #linebreak()
    - Mme *Marie DUBOIS*, Responsable des Opérations #linebreak()
  ],

  // Optional variable, check the README for a full list
  // https://github.com/Dawod-G/ENSEA_Typst-Template/blob/main/volt-internship-ensea/0.2.0/README.md

  // Enable the list of figures
  enable-list-figures: true,
  // Enable the list of equations
  enable-list-equations: true,
)

// ============================
// DELETE THE LINES BELOW THIS COMMENT
// ============================

= Introduction
#lorem(70)

== Une figure pour illustrer la "Liste des figures"
#figure(image("media/logo-ENSEA.png", width: 25%), caption: [Logo de l'ENSEA])

== Une tableau pour illustrer la "Liste des tableaux" et le "Glossaire"
#figure(
  table(
    columns: 3,
    align: (center, left, right),
    inset: 6pt,
    stroke: 1pt,
    fill: (none, none, none),

    // Header row
    table.header([N°], [Nom de l'étudiant], [Note finale]),

    // Body
    [001], [Alice Dupont], [16,5],
    [002], [Bruno Lefèvre], [14,8],
    [003], [Claire Noël], [12,7],
  ),
  caption: [Résultats des étudiants de l'@ENSEA à l'examen],
)

== Une citation pour illustrer la "Bibliographie"
Dans le traité "*Philosophiæ Naturalis Principia Mathematica*" @newton1833philosophiae, Newton énonce ses célèbres lois du mouvement et la loi de la gravitation universelle, posant ainsi les bases de la mécanique classique.

// Insert a page break
#pagebreak()

= Titre de niveau 1
Cette équation a un nom qui apparaît dans la "Liste des équations" :

#named-equation(
  $ P =I^2 times R $,
  <Effet-Joule>,
  [Effet Joule],
)

Celle-ci non : $ U =R times I $

== Titre de niveau 2
#lorem(50)

=== Titre de niveau 3
#lorem(35)

```java
// HelloWorld.java
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}
```

// Insert a page break
#pagebreak()

= Conclusion
#lorem(350)
