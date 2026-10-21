// ═══════════════════════════════════════════════════════════════════════════
// RADAR.TYP – primaviz-Adapter, buchdrucktauglich (kompakt, zentriert)
// ═══════════════════════════════════════════════════════════════════════════

#import "../design-system.typ"
#import "../einstellungen.typ"
#import "@preview/primaviz:0.8.0": *

#let _th() = if einstellungen.print-mode { themes.print } else { themes.default }
#let _sz(schrift) = if schrift == auto { einstellungen.diagramm-schrift } else { schrift }

#let diagramm-radar(
  kriterien: (), daten: (),
  max-wert: 10,
  caption-text: "", source-text: "",
  caption-position: auto,
  groesse: 8cm, schrift: auto,
  ..extra,
) = {
  let mapped = daten.map(d => (name: d.name, values: d.werte))
  diagramm-figur(
    caption-text: caption-text,
    source-text: source-text,
    caption-pos: caption-position,
    breite: 100%,
    align(center, text(size: _sz(schrift))[
      #radar-chart(
        (labels: kriterien, series: mapped),
        size: groesse,
        theme: _th(),
      )
    ]),
  )
}
