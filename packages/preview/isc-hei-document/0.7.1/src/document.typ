#import "@preview/isc-hei-document:0.7.1" : *

#show: project.with(
  doc-type: "document",
  show-cover: false,
  show-toc: false, // Set to true if you want a table of contents, or 1, 2, 3... for a specific depth
  fancy-line: true,  

  title: "A simple template for ISC documents",
  subtitle: [Typeset with `Typst`],
  authors: ("A. Lovelace", "Prof. B. Liskov", "Prof. N. Wirth",),    
  
  date: datetime(year: 2026, month: 3, day: 24), // or datetime.today()
  revision: "1.0",
  language: "fr", // Valid values are en, fr, de
  logo: auto, // Set to none if you wish no logo at all
  
  code-theme: "bluloco-light", // See directory themes/ for available themes
)

// Let's get started folks!
= Introduction

Ce document présente un aperçu des fonctionnalités offertes par #link("https://typst.app")[Typst], un système de composition typographique moderne. Les sections suivantes illustrent la mise en forme de texte, les listes, les tableaux, les images, le code source, les formules mathématiques et bien plus encore.

#lorem(100)

#lorem(100)

= Mise en forme du texte

Typst offre une syntaxe simple et intuitive pour formater du texte. On peut écrire en *gras*, en _italique_, ou en *_gras italique_*. Il est aussi possible d'utiliser du `code en ligne` directement dans le texte.

Les #text(fill: blue)[couleurs] sont facilement applicables, tout comme les changements de #text(size: 14pt)[taille] ou de #text(font: "New Computer Modern")[police]. On peut également #underline[souligner], #strike[barrer] ou mettre en #smallcaps[petites capitales].

#quote(block: true, attribution: [Donald Knuth])[
  The best programs are written so that computing machines can perform them quickly and so that human beings can understand them clearly.
]

== Listes

Les listes à puces et numérotées sont très simples à créer :

- Premier élément
- Deuxième élément avec sous-éléments :
  - Sous-élément A
  - Sous-élément B
- Troisième élément

Et les listes numérotées :

+ Analyser le problème
+ Concevoir une solution
+ Implémenter et tester
+ Documenter le résultat

= Tableaux et figures

== Tableaux

Les tableaux permettent de présenter des données de manière structurée. Voici un comparatif de quelques langages de programmation :

#figure(
  table(
    columns: (auto, 1fr, 1fr, auto),
    align: (left, center, center, center),
    stroke: 0.5pt + luma(180),
    inset: 8pt,
    fill: (x, y) => if y == 0 { luma(230) } else if calc.odd(y) { luma(245) } else { white },
    table.header(
      [*Langage*], [*Paradigme*], [*Typage*], [*Année*],
    ),
    [Python], [Multi-paradigme], [Dynamique], [1991],
    [Scala], [Fonctionnel / OO], [Statique], [2004],
    [Rust], [Système], [Statique], [2010],
    [Typst], [Markup / Script], [Dynamique], [2023],
    [C], [Procédural], [Statique], [1972],
  ),
  caption: [Comparaison de langages de programmation],
) <tab:langages>

Comme le montre la @tab:langages, chaque langage a ses propres caractéristiques. On peut référencer les tableaux et figures automatiquement grâce aux labels.

== Insertion d'images

Les images s'insèrent facilement avec la fonction `image`. Voici un exemple :

#figure(
  image("figs/random_image.png", width: 30%),
  caption: [Une image d'exemple insérée dans le document],
) <fig:exemple>

La @fig:exemple montre comment inclure une image avec une légende. Les images peuvent être redimensionnées, alignées et référencées dans le texte.


= Code et mathématiques

== Blocs de code

Typst peut afficher du code source avec coloration syntaxique :

#code(
  ```python
  def fibonacci(n: int) -> list[int]:
      """Génère les n premiers nombres de Fibonacci."""
      fib = [0, 1]
      for i in range(2, n):
          fib.append(fib[-1] + fib[-2])
      return fib

  # Afficher les 10 premiers
  print(fibonacci(10))
  ```
)

Et un autre exemple en Scala :

#code(
  ```scala
  case class Student(name: String, grade: Double)

  val students = List(
    Student("Alice", 5.5),
    Student("Bob", 4.8),
    Student("Charlie", 5.9),
  )

  val average = students.map(_.grade).sum / students.length
  println(f"Moyenne: $average%.1f")
  ```
)

== Formules mathématiques

Typst dispose d'un excellent support des mathématiques. Par exemple, la formule d'Euler :

$ e^(i pi) + 1 = 0 $

Une intégrale classique :

$ integral_0^infinity e^(-x^2) dif x = sqrt(pi) / 2 $

Ou encore la définition d'une matrice et d'un système d'équations :

$ bold(A) = mat(
  a_(1,1), a_(1,2), dots.c, a_(1,n);
  a_(2,1), a_(2,2), dots.c, a_(2,n);
  dots.v, dots.v, dots.down, dots.v;
  a_(m,1), a_(m,2), dots.c, a_(m,n);
) $

Les formules en ligne comme $sum_(k=1)^n k = n(n+1)/2$ s'intègrent naturellement dans le texte.

== Boîtes et encadrés

On peut utiliser les boîtes de `showybox` pour mettre en valeur du contenu :

#todo[Compléter cette section avec d'autres exemples]

= Citer ses sources
Il est important de citer les sources que l'on utilise. Par exemple, les deux travaux @mui_nasa_dod09, @mui_hybrid_06 et @mudry:133438 sont des papiers très intéressants à lire et dont les références complètes se trouvent dans la bibliographie à la fin de ce document. 

#pagebreak()
#the-bibliography(bib-file: "bibliography.bib", full: true, style: "ieee")


// This is the end !