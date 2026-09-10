# pg-thesis-unofficial

[![Napisane przez człowieka, nie przez AI](./images/Written-By-a-Human-Not-By-AI-Badge-white.svg)](https://notbyai.fyi/)

Nieoficjalny szablon Typst pracy inżynierskiej/magisterskiej na Politechnice Gdańskiej, stworzony w celu zapewnienia alternatywy dla LaTeXa i Overleafa przy pisaniu pracy.

## Sposób użycia

### `typst init` w wierszu poleceń

```bash
typst init @preview/pg-thesis-unofficial:0.1.0
```

W folderze w którym uruchomiono komendę zostanie utworzony folder z nowym projektem będącym kopią [folderu `example`](./example/). Projekt ten zawiera wystarczająco dużo przykładów jak pracować z *Typst*, by samodzielnie kontunować w nim pisanie pracy inżynierskiej/magisterskiej. 

### Manualny import

`main.typ`:
```typst
#import "@preview/pg-thesis-unofficial:0.1.0" as pg

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

Tutaj można już pisać reszte pracy lub zaimportować treść rodziałów z innego pliku.
```

kompilacja w wierszu poleceń:
```bash 
typst compile "main.typ"
```

śledzenie zmian na żywo:
```bash
typst watch "main.typ"
```
### Edytor Typst online

Po założeniu konta na [typst.app](https://typst.app/), w głównym dashboardzie należy wybrać przycisk *"Start from template"*, po czym wyszukać nazwę `pg-thesis-unofficial`. Zostanie utworzony nowy projekt będący kopią [folderu `example`](./example/).

## Parametry funckji `praca-dyplomowa`

| Parametr             | Typ            | Opis                                                                                                |
|----------------------|----------------|-----------------------------------------------------------------------------------------------------|
| title-page-path      | path           | ścieżka do pliku pdf strony tytułowej                                                               |
| disclaimer-page-path | path           | ścieżka do pliku pdf z oświadczeniem o samodzielnej pracy                                           |
| abstract-pl          | content        | treść streszczenia w języku polskim                                                                 |
| keywords-pl          | str            | słowa kluczowe w języku polskim                                                                     |
| oecd-pl              | str            | dziedzina nauki i techniki, zgodnie z wymogami OECD w języku polskim                                |
| abstract-eng         | content        | treść streszczenia w języku angielskim                                                              |
| keywords-eng         | str            | słowa kluczowe w języku angielskim                                                                  |
| oecd-eng             | str            | dziedzina nauki i techniki, zgodnie z wymogami OECD w języku angielskim                             |
| abbreviations        | content        | treść wykazu skrótów, zalecane jest użycie wbudowanego elementu listy definicji (term list) w typst |
| bibliography-path    | path           | ścieżka do pliku .bib z bibliografią,                                                               |
| appendices           | array<content> | lista bloków contentu które zostaną dołączone w tej kolejności na końcu dokumentu                   |

## Przykład

 - [`example/main.typ`](./example/main.typ) - przykładowe użycie szablonu, rozdziały i dodatki znajdują się w folderze `chapters`

