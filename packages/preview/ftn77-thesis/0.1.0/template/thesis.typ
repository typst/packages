#import "@local/ftn77-thesis:0.1.0": appendices, bibliography, ftn-logo-new, thesis

#import "metadata.typ": meta
#import "style.typ" as style

#show: thesis.with(
  ..meta,
  paper: "a4",
  // margin: 2cm,
  duplex: true,
  bibliography: bibliography("thesis.bib"), // uses ieee with custom serbian cyrl translations by default
  style: style,
  glossary: (
    json: (
      short: "JSON",
      long: "JavaScript Object Notation",
      group: "abbr",
    ),
    html: (
      short: "HTML",
      long: "HyperText Markup Language",
      description: [
        Описни језик специјално намењен опису веб страница. Помоћу њега се једноставно могу одвојити
        елементи као што су наслови, параграфи, цитати и слично.
      ],
      // in both
    ),
  ),
)

= Увод

#lorem(100) @html

#lorem(20) @fig:logo #lorem(10) @cetkovic2026ftn77

#figure(
  caption: [Лого ФТН-а],
  ftn-logo-new,
) <fig:logo>

#lorem(1000)

== Дио увода

#lorem(200)

#show: appendices

= Додатак

#lorem(50) @html

#figure(
  caption: [Опет Лого ФТН-а],
  ftn-logo-new,
)

#lorem(100) @json
