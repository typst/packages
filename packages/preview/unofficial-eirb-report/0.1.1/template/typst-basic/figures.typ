#import "@preview/unofficial-eirb-report:0.1.1": subfig

= Exemples de figures

== Figure d'une image

#figure(
  image("./assets/figure.png", width: 70%),
  caption: [Une figure contenant une image et une description.],
) <basic-fig>

Noter la balise `<basic-fig>` permettant de référencer cette figure, vous pouvez
la référencer comme ceci : @basic-fig.

== Figure d'un tableau

#figure(
  table(
    columns: (auto, auto, auto),
    table.header([*Nom*], [*Âge*], [*Rôle*]),
    [Alice], [28], [Designer],
    [Bob], [34], [Développeur],
    [Charlie], [45], [Manager],
  ),
  caption: [Une figure contenant un tableau et une description.],
) <table-fig>

Voir @table-fig pour les valeurs.

== Figure d'un code

#figure(
  ```c
  #include <stdio.h>
  int main(int argc, char *argv[])
  {
    printf("Hello, World!\n");
    return 0;
  }
  ```,
  caption: [Une figure contenant du code.],
) <code-fig>

== Sous-figures

#subfig(
  figure(image("./assets/figure.png"), caption: [Première sous-figure]),
  <fig-a>,
  figure(image("./assets/figure.png"), caption: [Seconde sous-figure]),
  <fig-b>,
  columns: (1fr, 1fr),
  caption: [Une figure contenant deux sous-figures.],
  label: <fig-full>,
)
