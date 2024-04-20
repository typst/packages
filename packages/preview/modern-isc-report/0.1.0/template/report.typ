#import "@preview/modern-isc-report:0.1.0" : *

#show: project.with(
  title: "Rapport de projet en filière ISC",
  sub-title: "Avec une mise en page avec Typst",

  course-name: "101.1 Programmation impérative",
  course-supervisor : "Prof. P.-A. Mudry",
  semester: "Semestre d'automne",
  academic-year : "2023-2024",

  cover-image: image("figs/cover_image_placeholder.png"),
  cover-image-height: 8cm, // Default value = 10cm
  cover-image-caption: "KNN graph, inspired by Marcus Volg",
  
  authors: (
    "P.-A. Mudry",  
    "Louis Lettry", 
    "Pamela Delgado"
  ),

  logo: image("figs/isc_logo.svg"),
  date: "20 avril 2024",
  language: "fr", // Or en if required
  version: "0.1.0",  
)    

//// If using acronyms
#import "@preview/acrostiche:0.3.0": *
#include "acronyms.typ" 

// Let's get started   
= Introduction  
Ecrire un rapport est un exercice autant *de fond que de forme*. Dans ce contexte, nous proposons dans ce document de quoi simplifier la rédaction de la forme sans avoir -- à priori -- d'avis sur le fond, ceci dans le contexte de la filière ISC#footnote[Voici d'ailleurs comment mettre une note de bas de page https://isc.hevs.ch].

Il convient tout d'abord pour présenter le contenu de se rendre compte que ce système de typesetting permet d'utiliser une forme de _markdown_ comme entrée. Comme dans tout `markdown` qui se respecte, il est tout à fait possible de faire des listes avec nombres, ce qui est aussi joli :

+ Un élément
+ Un autre élément de liste
+ Encore d'autres éléments si nécessaire

Voici un peu de #todo[texte mis en évidence] et qui sera discuté dans le @intro[point].

== Insertion de code
Nous pouvons également avoir du `code brut directement en ligne` mais cela peut également être fait avec du code Scala comme par exemple dans ```scala def foo(x: Int)```. Cela n'empêche pas d'avoir des blocs de code joliment mis en forme également : 
 
```scala 
def foo(val a : Any) : Int = {
  a match : 
    case a: Int  => 12
    case _ => 42
}  
```
 
On peut si on le souhaite également avoir des blocs encore plus "fancy" à l'aide d'un package : 

#sourcecode()[
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
```]


== Insertion d'images 

Une image vaut souvent mieux que mille mots ! Il est possible d'ajouter des images, bien entendu. La syntaxe est relativement simple comme vous pouvez le voir : 
   
#figure(
  image("figs/pixelize.png", height: 4cm), 
  caption: [Grace Hopper, informaticienne américaine]
) <fig_engineer>

Pour le reste, voici un texte pour voir de quoi il retourne. Vous allez réaliser une fonction appelée _mean_ qui va appliquer un filtre de moyenne à l'image. Ce filtre a pour but de flouter l'image et d'enlever ainsi ses aspérités.

Le principe est le suivant : la valeur d'un pixel est remplacée par la moyenne des pixels se trouvant dans une zone carrée de 3 par 3 pixels autour du pixel. Si on veut calculer la nouvelle valeur du pixel situé à la position $(x,y)$ selon la figure @fig_engineer, sa nouvelle valeur sera la moyenne des 9 valeurs affichées. 

La dérivée doit se calculer selon les deux axes. Le calcul est très simple : la dérivée selon `x` du pixel situé en $(x,y)$ vaut la valeur du pixel de droite $(x+1, y)$ moins la valeur du pixel de gauche $(x-1,y)$. Dans le cas de la figure, la dérivée selon $x$ vaut $D_x=234-255=-21$. 

De même, on peut calculer la dérivée selon $y$. Elle correspond au pixel du dessous $(x,y+1)$ moins le pixel $(x,y-1)$ du dessus. Dans le cas de la @fig_engineer, la dérivée selon $y$ vaut $D_y = 230-127 = 103$.

La norme de la dérivée est calculée selon le théorème de Pythagore :

$ D = sqrt(D_x^ 2 +D_y^2) $

On peut également avoir des notations plus complexes : 

$ sum_(n=1)^(infinity) 2^(-n) = 1 "ou encore" integral_(x = 0)^3 x^2 dif x $ 

#showybox(
  title: "Stokes' theorem", 
  frame: (
    border-color: blue,
    title-color: blue.lighten(30%),
    body-color: blue.lighten(95%),
    footer-color: blue.lighten(80%)
  ),
  // footer: "Information extracted from a well-known public encyclopedia"
)[
  Let $Sigma$ be a smooth oriented surface in $RR^3$ with boundary $diff Sigma equiv Gamma$. If a vector field $bold(F)(x,y,z)=(F_x (x,y,z), F_y (x,y,z), F_z (x,y,z))$ is defined and has continuous first order partial derivatives in a region containing $Sigma$, then

  $ integral.double_Sigma (bold(nabla) times bold(F)) dot bold(Sigma) = integral.cont_(diff Sigma) bold(F) dot dif bold(Gamma) $
]

// Same thing wihtout a plugin
#rect(
  width: 100%,
  radius: 10%,
  stroke: 0.5pt,
  fill: yellow.lighten(60%),
)[
  Note: This subsection should contain dynamic UML diagrams. These can be a UML state diagrams, UML communication diagrams or UML activity diagrams.*Important:* Make sure to describe the diagram and its rationale in the text. *Do not use UML sequence diagrams.*
]

== Citer ses sources

Il est important de citer les sources que l'on utilise. Par exemple, les deux travaux @mui_nasa_dod09, @mui_hybrid_06 et @mudry:133438 sont deux papiers très intéressants à lire et dont les références comlètes se trouvent dans la bibliographie à la fin de ce document. Il est également d'utiliser des acroymes comme par exemple [#acr("USB")]

==  Le filtre de Sobel
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

#bibliography("bibliography.bib", full: false, style: "ieee") 

#pagebreak()
#set heading(numbering: none)

= Annexes
// Table of acronyms
#print-index(title: "Acronymes")

// Table of figures
#pagebreak()
#outline(title: "Table des figures", depth: 1, indent: true, target: figure.where(kind: image))

// This is the end