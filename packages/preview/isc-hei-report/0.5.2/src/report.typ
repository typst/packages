#import "@preview/isc-hei-report:0.5.2" : *

#let doc_language = "fr" // Valid values are en, fr

#show: project.with(
  title: "Rapport de projet pour la filière ISC",
  sub-title: [Avec une mise en page `Typst`],
  authors: ("D. Knuth", "L. Torvalds", "M. Odersky",),  
  date: datetime(year: 2025, month: 6, day: 24), // or datetime.today()
  language: doc_language, // Please change the value above if required
  
  course-name: "101.1 Programmation impérative",
  course-supervisor: "Prof. Dr P.-A. Mudry",
  semester: "Semestre de printemps",
  academic-year: "2025-2026",
  version: [Using template 0.5.2],
  
  cover-image: image("figs/cover_image_placeholder.png"), // Change this to your cover image
  cover-image-height: 8cm,
  cover-image-caption: [KNN graph -- Inspired by _Marcus Volg_],
  
  logo: image("figs/isc_logo.svg"),
  
  code-theme: "bluloco-light", // See directory themes/ for available themes
)

//// If using acronyms
#import "@preview/acrostiche:0.5.2": *
#include "acronyms.typ"

// Let's get started folks!

#table-of-contents(depth: 1)

= Introduction
Écrire un rapport est un exercice autant *de fond que de forme*. Dans ce contexte, nous proposons dans ce document de quoi simplifier la rédaction de la forme sans avoir -- à priori -- d'avis sur le fond, ceci dans le contexte de la filière ISC#footnote[Voici d'ailleurs comment mettre une note de bas de page https://isc.hevs.ch].

Il convient tout d'abord pour présenter le contenu de se rendre compte que ce système de mise en page permet d'utiliser une forme de _markdown_ comme entrée. Le _markdown_ est une manière de formatter des fichiers textes afin de pouvoir les transformer avec un programme afin de les afficher dans différents formats, comme PDF ou encore sous forme de page web.

Le langage _markdown_ utilise différents types de balises permettant de faire du *gras*, de _l'italique_ ou encore du _*gras et de l'italique*_. Il est également possible de faire des listes, des tableaux, des images, des liens hypertextes, des notes de bas de page, des équations mathématiques comme $x^2 = 3$, des blocs de code comme par exemple `def hello()` et encore bien d'autres choses.

Vous trouverez ici de la documentation sur la manière d'utiliser le langage `markdown` pour écrire des documents ici : https://www.markdownguide.org/basic-syntax/. Vous trouverez également une version spécifique sur l'écriture de documents en Typst ici https://typst.app/docs/reference/syntax/.

En plus des choses simples montrées ci-dessus, le `markdown` simplifie la création de listes avec des nombres comme suit :

+ Un élément
+ Un autre élément de liste
+ Encore d'autres éléments si nécessaire

Des choses plus exotiques, comme mettre du #todo[texte mis en évidence] sont également possibles, tout comme les références à d'autres parties, comme dans le @intro[point].

== Insertion de code

Nous pouvons également avoir du `code brut directement en ligne` mais cela peut également être fait avec du code Scala comme par exemple dans ```scala def foo(x: Int)```. Cela n'empêche pas d'avoir des blocs de code joliment mis en forme également. Ainsi, lorsque l'on souhaite avoir du code inséré dans une figure, on peut également utiliser le package `sourcecode` qui rajoute notamment les numéros de ligne. En complément avec une `figure`, il est possible d'avoir une _légende_, un numéro de figure ainsi que du code centré :

#figure(code()[
```scala
  def foo(val a : Any) : Int = {
    a match :
      case a: Int  => 12
      case _ => 42
  }
  ```
], caption: "Un tout petit listing en Scala")

On peut si on le souhaite également avoir des blocs de code plus long si nécessaire, sur plusieurs pages :

#figure(code()[
```scala
  object ImageProcessingApp_Animation extends App {
    val imageFile = "./res/grace_hopper.jpg"

    val org = new ImageGraphics(imageFile, "Original", -200, 0)
    val dest2 = new ImageGraphics(imageFile, "Threshold", 200, 0)

    var direction: Int = 1
    var i = 1

    while (true) {
      if (i == 255 || i == 0)
        direction *= -1

      i = i + direction
      dest2.setPixelsBW(ImageFilters_Solution.threshold(org.getPixelsBW(), i))
    }
  }
  ```
], caption: "Un autre exemple de code, plus long")

=== Insérer du code à partir d'un fichier
Il est tout à fait possible de mettre du code qui provient d'un fichier comme ci-dessous :

#let code_sample = read("code/sample.scala")
#figure(code()[
  #raw(code_sample, lang: "scala")
], caption: "Code included from the file `sample.scala`")

== Insertion d'images

Une image vaut souvent mieux que mille mots ! Il est possible d'ajouter des images, bien entendu. La syntaxe est relativement simple comme vous pouvez le voir dans l'exemple ci-dessous:

#figure(image("figs/pixelize.png", height: 4cm), caption: [Grace Hopper, informaticienne américaine]) <fig_engineer>

Pour le reste, voici un texte pour voir de quoi il retourne. Vous allez réaliser une fonction appelée _mean_ qui va appliquer un filtre de moyenne à l'image. Ce filtre a pour but de flouter l'image et d'enlever ainsi ses aspérités. Le principe est le suivant : la valeur d'un pixel est remplacée par la moyenne des pixels se trouvant dans une zone carrée de 3 par 3 pixels autour du pixel. Si on veut calculer la nouvelle valeur du pixel situé à la position $(x,y)$ selon la figure @fig_engineer, sa nouvelle valeur sera la moyenne des 9 valeurs affichées.

La dérivée doit se calculer selon les deux axes. Le calcul est très simple : la dérivée selon `x` du pixel situé en $(x,y)$ vaut la valeur du pixel de droite $(x+1, y)$ moins la valeur du pixel de gauche $(x-1,y)$. Dans le cas de la figure, la dérivée selon $x$ vaut $D_x=234-255=-21$.

De même, on peut calculer la dérivée selon $y$. Elle correspond au pixel du dessous $(x,y+1)$ moins le pixel $(x,y-1)$ du dessus. Dans le cas de la @fig_engineer, la dérivée selon $y$ vaut $D_y = 230-127 = 103$.

La norme de la dérivée est calculée selon le théorème de Pythagore :

$ D = sqrt(D_x^ 2 +D_y^2) $

On peut également avoir des notations plus complexes :

$ sum_(n=1)^(infinity) 2^(-n) = 1 "ou encore" integral_(x = 0)^3 x^2 dif x $

#inc.showybox(
  title: "Stokes' theorem",
  frame: (
    border-color: blue,
    title-color: blue.lighten(30%),
    body-color: blue.lighten(95%),
    footer-color: blue.lighten(80%),
  ),
  // footer: "Information extracted from a well-known public encyclopedia"
)[
  Let $Sigma$ be a smooth oriented surface in $RR^3$ with boundary $diff Sigma equiv Gamma$. If a vector field $bold(F)(x,y,z)=(F_x (x,y,z), F_y (x,y,z), F_z (x,y,z))$ is defined and has continuous first order partial derivatives in a region containing $Sigma$, then

  $ integral.double_Sigma (bold(nabla) times bold(F)) dot bold(Sigma) = integral.cont_(diff Sigma) bold(F) dot dif bold(Gamma) $
]

// You can create a new page with a pagebreak
#pagebreak()

== Des tables

Il est possible d'insérer des tables simples :

#figure(table(
  align: left,
  columns: 4,
  stroke: none,
  [*Monday*],
  [11.5],
  [13.0],
  [4.0],
  [*Tuesday*],
  [8.0],
  [14.5],
  [5.0],
  [*Wednesday*],
  [9.0],
  [18.5],
  [13.0],
), caption: "Une table simple")

Des tables plus compliquées sont également possible. La page https://typst.app/docs/guides/table-guide/ donne d'ailleurs de bonnes informations.

#set table(stroke: (x, y) => (left: if x > 0 { 0.8pt }, top: if y > 0 { 1.5pt }))

#figure(table(
  // Table with 3 columns and 3 rows
  // There are 3 columns, the first one is twice as large as the two others
  columns: (2fr, 1fr, 1fr),
  align: center + horizon,
  table.header[*Technique*][*Advantage*][*Drawback*],
  [Diegetic],
  [Immersive],
  [May be contrived],
  [Extradiegetic],
  [Breaks immersion],
  [Obstrusive],
  [Omitted],
  [Fosters engagement],
  [May fracture audience],
), caption: [Une table plus complexe])

== Citer ses sources
Il est important de citer les sources que l'on utilise. Par exemple, les deux travaux @mui_nasa_dod09, @mui_hybrid_06 et @mudry:133438 sont deux papiers très intéressants à lire et dont les références complètes se trouvent dans la bibliographie à la fin de ce document. Il est également d'utiliser des acronymes comme par exemple #acr("USB"). Si on l'utilise une deuxième fois, seul l'acronyme apparaît, ainsi #acr("USB") est suffisant.

Si l'on souhaite citer des références issues d'une page ou d'un site web et que cette référence est importante, on utilisera la syntaxe @WinNT qui cite une référence de la bibliographie. Pour les autres cas, il est possible de référer au site uniquement avec son URL.

== Un exemple de texte : le filtre de Sobel
Une autre méthode pour extraire les contours à l'intérieur d'une image est d'utiliser #link("https://fr.wikipedia.org/wiki/Détection_de_contours")[l'algorithme de Sobel] Cette méthode est très similaire à celle de la dérivée, mais un peu plus compliquée et donne de meilleurs résultats.

Pour l'exemple, la valeur du filtre de Sobel selon _x_ vaudrait :

$ S_x= 100 + 2 dot 234 + 84 -128-2 dot 255-123=-109 $

De même la valeur du filtre de Sobel selon _y_ vaudrait:

$ S_y= 123+2 dot 230+84-128-2 dot 127-100 $

Comme auparavant, la norme du filtre de Sobel se calcule selon Pythagore et vaut pour cet exemple :

$ S = sqrt(S_x^2+S_y^2) = sqrt(109^2+185^2) =214.47 $

== Problématique <intro>
#lorem(20)

== Plan du travail
#lorem(40)

#pagebreak()

= Conclusion
#lorem(500)

#pagebreak()
#the-bibliography(bib-file: "bibliography.bib", full: true, style: "ieee")

//////////////
// Appendices
//////////////
#pagebreak()
#appendix-page()
#pagebreak()

// Table of acronyms, NOT COMPULSORY
#print-index(
  title: heavy-title(i18n(doc_language, "acronym-table-title"), mult:1, top:1em, bottom: 1em),
  sorted: "up",
  delimiter: " : ",
  row-gutter: 0.7em,
  outlined: false,
)

#pagebreak()

// Table of listings
#table-of-figures()

// Code inclusion
#pagebreak()
#code-samples()

#let code_sample = read("code/sample.scala")

#figure(code()[
  #raw(code_sample, lang: "scala")
], caption: "Code included from the file example.scala")

#figure(code()[
  #raw(code_sample, lang: "scala")
], caption: "Code included from the file example.scala")

#figure(code()[
  #raw(read("code/sort.py"), lang: "python")
], caption: "Code included from the file sort.py")

// This is the end !