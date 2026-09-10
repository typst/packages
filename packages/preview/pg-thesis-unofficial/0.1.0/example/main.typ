#import "@preview/pg-thesis-unofficial:0.1.0" as pg

// dla plików pdf i bibliografii podawana jest ścieżka do pliku, ponieważ są one podawane dalej w szablonie do wbudowanych funkcji typst (np. `image()`)
// streszczenia i wykaz skrótów są parsowane as-is i w wyniku tego jest zwracany blok tekstu typu `content`, dlatego używamy dyrektywy `include`
// nic nie stoi na przeszkodzie by zamiast tego wstawić w te miejsca bezpośrednio blok contentu w taki sposób:
// abstract-pl: [normalny blok tekstu w którym może znaleźć się cokolwiek, nagłówki, zdjęcia, pogrubienia, itd.]
#show: pg.praca-dyplomowa.with(
  title-page-path: path("./assets/strona-tytulowa.pdf"),
  disclaimer-page-path: path("./assets/oswiadczenie.pdf"),

  abstract-pl: include "chapters/meta/streszczenie.typ",
  keywords-pl: "tutaj, należy, podać, słowa, kluczowe",
  oecd-pl: "dziedzina, technika, ...",

  abstract-eng: include "chapters/meta/abstract.typ",
  keywords-eng: "tutaj, należy, podać, słowa, kluczowe, w, języku, angielskim",
  oecd-eng: "dziedzina po angielsku, ...",

  abbreviations: include "chapters/meta/wykaz-skrotow.typ",
  bibliography-path: path("bibliography.bib"),

  appendices: (
    include "chapters/dodatki/dodatek-a.typ",
  ),
)

// Po zaincjalizowaniu szablonu reszta pliku stanowi ciało pracy dyplomowej:
#include "chapters/wstep.typ"
#include "chapters/dokumenty-elektroniczne.typ"
#include "chapters/jeszcze-jeden-rozdzial.typ"
#include "chapters/podsumowanie.typ"


