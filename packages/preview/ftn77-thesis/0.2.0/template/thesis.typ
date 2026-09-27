#import "@preview/ftn77-thesis:0.2.0": appendices, bibliography, ftn-logo-new, thesis

#import "metadata.typ": meta
#import "style.typ" as style

#show: thesis.with(
  ..meta,
  paper: "a4",
  // margin: 2cm,
  dedication: lorem(20),
  abstract-page: "sr",
  duplex: true,
  bibliography: bibliography("literature.bib"), // uses ieee with custom serbian cyrl translations by default
  glossary: yaml("glossary.yml"),
  style: style,
)

// Include your main chapters here

//region Remove before writing

= Увод

#lorem(100) @html

@dependency[Зависност] неки текст // untill glossy cap is fixed (for multi byte unicode chars) you can cap like this (or install vendored glossy from template repository then use @dependency:cap)

#lorem(20) #link("https://www.github.com")[www.github.com] #lorem(10) #link(
  "https://facebook.com",
)[Facebook] #lorem(10) @fig:logo #lorem(10) @cetkovic2026ftn77

#figure(
  caption: [Лого ФТН-а],
  ftn-logo-new,
) <fig:logo>

#lorem(1000)

Мала @dependency

== Дио увода

#lorem(200)

//endregion

#show: appendices

// Include your appendices here

//region Remove before writing

= Додатак

#lorem(50) @html

#figure(
  caption: [Опет Лого ФТН-а],
  ftn-logo-new,
)

#lorem(100) @json

//endregion
