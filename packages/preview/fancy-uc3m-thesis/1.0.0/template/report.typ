#import "@preview/fancy-uc3m-thesis:1.0.0": conf
#import "config/glossary.typ": glossary-entries
#import "config/gen-ai.typ": genai-declaration


#show: conf.with(
  degree: "Grado en Ingeniería Typstática",
  title: "Análisis, diseño, e implementación del mejor Trabajo de Fin de Grado de la historia",
  short-title: "La mejor Memoria de la Historia",
  author: "Nombre Extremadamente Largo e Incómodo de Escribir",
  advisors: ("Profesor Cuyos Padres Tenían Visión de Futuro",),
  location: "Leganés, Madrid",
  thesis-type: "TFG",
  date: datetime(year: 2025, month: 4, day: 20),
  language: "es",
  format: "ieee",
  style: "fancy",
  license: true,
  double-sided: true,
  flyleaf: true,
  bibliography-content: bibliography("references.bib", style: "ieee"),
  epigraph: (
    quote: [Cacaaaaaaaaaaaa.],
    author: "Uno que se cagaba",
    // source: "",
  ),
  abstract: (
    body: [Ta wapo.],
    keywords: ("Caca", "Culo", "Pedo", "Pis"), // for IEEE, see https://www.ieee.org/content/dam/ieee-org/ieee/web/org/pubs/ieee-taxonomy.pdf
  ),
  english-abstract: (
    body: ['tis cool.],
    keywords: ("Poop", "Butt", "Fart", "Pee"),
  ),
  acknowledgements: [Mi churri.],
  outlines: (
    // contents is compulsory
    figures: true,
    tables: true,
    listings: false,
    // custom: (
    //   outline(
    //     title: [List of algorithms],
    //     target: figure.where(kind: "algorithm"),
    //   ),
    // ),
  ),
  // appendixes: [],
  glossary: glossary-entries, // comment this line if you don't want a glossary
  // abbreviations: (TFG: "Trabajo de Fin de Grado"),
  genai-declaration: genai-declaration,
)


/* Custom set/show rules */

// prevent floating elements from spilling into the next section
#show heading.where(level: 2): it => {
  place.flush()
  it
}

// "booktab" table style
#show table: block.with(stroke: (y: 0.7pt))
#set table(column-gutter: .2em, stroke: none)
#set table.hline(stroke: 0.4pt)



/* Thesis */

#include "parts/introduction.typ"
#include "parts/state_of_the_art.typ"
#include "parts/analysis.typ"
#include "parts/design.typ"
#include "parts/implementation.typ"
#include "parts/evaluation.typ"
#include "parts/project_plan.typ"
#include "parts/conclusions.typ"


/* Examples */


// graph example

#import "@preview/lilaq:0.6.0" as lq

#let x = lq.linspace(0, 20)

#grid(
  columns: (1fr, 1fr),
  gutter: 2cm,
  align: center,
  lq.diagram(
    lq.plot(x, x => calc.sin(x + 0.541)),
    width: 7cm,
    height: 4cm,
  ),
  lq.diagram(
    lq.plot(
      (3, 6, 10, 16),
      (5, 3, 4, 2),
      mark: "o",
      color: red,
    ),
  ),
)


#lq.diagram(
  xaxis: (
    ticks: ("Apples", "Bananas", "Kiwis", "Mangos", "Papayas")
      .map(rotate.with(-45deg, reflow: true))
      .map(align.with(right))
      .enumerate(),
    subticks: none,
  ),
  lq.bar(range(5), (5, 3, 4, 2, 1)),
)


// figure example

#figure(
  image("img/Tux.svg", width: 30%),
  caption: [Tux, la mascota de Linux],
) <fig:logo>

@fig:logo.


// table example

#let yes = sym.checkmark
#figure(
  table(
    columns: 7,
    table.header(
      [*OS*],
      [*Silksong*],
      [*Ads*],
      [*Spyware*],
      [*Unix*],
      [*FOSS*],
      [*Penguins*],
    ),
    table.hline(),
    [Linux], [#yes], [], [], [#yes], [#yes], [#yes],
    [MacOS], [#yes], [], [#yes], [#yes], [], [],
    [Windows], [#yes], [#yes], [#yes], [], [], [],
  ),
  caption: [Comparison of desktop Operating Systems],
) <tab:os>

@tab:os.


@sdg-un // bibliography reference

// glossary
#import "@preview/glossarium:0.5.10": gls, glspl
#gls("API")

