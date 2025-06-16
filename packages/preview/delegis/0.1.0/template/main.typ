#import "@preview/delegis:0.1.0": *

#show: it => delegis(
  // Metadata
  title: "Vereinsordnung zu ABCDEF",
  abbreviation: "ABCDEFVO",
  resolution: "3. Beschluss des Vorstands vom 24.01.2024",
  in-effect: "24.01.2024",
  draft: false,
  // Template
  logo: image("wuespace.jpg", alt: "WüSpace e. V."),
  // Content
  it
)

/// Usage
//
//  "§ 123abc Section title" for a section "§ 123abc" with the title "Section title"
//  "#s~" for sentence numbers in multi-sentence paragraphs
//  (normal Typst headings) such as "= ABC" for grouping sections together
//
///

#unnumbered(level: 1, outlined: false)[Vorbemerkung]

Fußnoten dienen als redaktionelle Anmerkungen oder Interpretationshilfen und sind nicht selbst Teil der Beschlussfassung.

#v(2em)

#outline()

#unnumbered[Präambel]

#lorem(30)

= Allgemeiner Teil

§ 1 Grundlegendes

(1)
#lorem(20)

(2)
#s~#lorem(10)
#s~#lorem(10)

§ 2 Bestimmungen

#lorem(30)

= Spezieller Teil

§ 2a Ergänzende Bestimmungen

(1)
#lorem(5)

(2)
#s~#lorem(3) 
#s~#lorem(8)
