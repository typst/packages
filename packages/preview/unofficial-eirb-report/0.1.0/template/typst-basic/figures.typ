= Examples de figures

== Figure d'une image

#figure(
  image("./assets/figure.png", width: 70%),
  caption: "Une figure contenant une image et une description.",
) <basic-fig>

Noter la balise `<basic-fig>` permettant de réfrencer cette figure, vous pouvez
la réfrencer comme ceci: @basic-fig.

== Figure d'un tableau

#figure(
  table(
    columns: (auto, auto, auto),
    align: center,
    inset: 1em,
    [*Name*], [*Age*], [*Role*],
    [Alice], [28], [Designer],
    [Bob], [34], [Développeur],
    [Charlie], [45], [Manager],
  ),
  caption: "Une figure contenant un tableau et une description.",
) <table-fig>

Voir @table-fig pour les valeurs.

== Figure d'un code

#figure(
  block(
    stroke: 1pt + luma(150),
    fill: luma(240),
    inset: 1em,
    ```c
    #include <stdio.h>

    int main(int argc, char *argv[])
    {
      printf("Hello, World!\n");
      return 0;
    }
    ```,
  ),
  caption: "Une figure contenant du code.",
) <code-fig>

== Sous-figures

#figure(
  grid(
    columns: 2,
    gutter: 1em,
    figure(
      image("./assets/figure.png", width: 100%),
      caption: "Première sous-figure",
    ),
    figure(
      image("./assets/figure.png", width: 100%),
      caption: "Seconde sous-figure",
    ),
  ),
  caption: "Une figure contenant deux sous-figures.",
) <subfig>
