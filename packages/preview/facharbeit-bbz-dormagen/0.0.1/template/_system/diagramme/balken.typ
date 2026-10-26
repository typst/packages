// ═══════════════════════════════════════════════════════════════════════════
// BALKEN.TYP – primaviz-Adapter, buchdrucktauglich
//   - kompakte, zentrierte Buchmasse (nicht volle Seitenbreite)
//   - Mindestschrift per text(size: einstellungen.diagramm-schrift) vererbt (best-effort)
//   - Hoehe horizontaler Balken skaliert mit Balkenanzahl
// Schnittstelle nach aussen UNVERAENDERT -> 051-anhang.typ bleibt wie es ist.
// ═══════════════════════════════════════════════════════════════════════════

#import "../design-system.typ"
#import "../einstellungen.typ"
#import "@preview/primaviz:0.8.0": *

#let _th() = if einstellungen.print-mode { themes.print } else { themes.default }
#let _sz(schrift) = if schrift == auto { einstellungen.diagramm-schrift } else { schrift }

#let diagramm-saeulen(
  kategorien: (), werte: (),
  y-label: "", x-label: "",
  caption-text: "", source-text: "",
  caption-position: auto,
  breite: 9.5cm, hoehe: 5.8cm, schrift: auto,
  ..extra,
) = {
  diagramm-figur(
    caption-text: caption-text,
    source-text: source-text,
    caption-pos: caption-position,
    breite: 100%,
    align(center, text(size: _sz(schrift))[
      #bar-chart(
        (labels: kategorien, values: werte),
        width: breite, height: hoehe,
        theme: _th(),
      )
    ]),
  )
}

#let diagramm-saeulen-gruppiert(
  kategorien: (), serien: (),
  y-label: "", x-label: "",
  caption-text: "", source-text: "",
  caption-position: auto,
  breite: 11cm, hoehe: 6.5cm, schrift: auto,
  ..extra,
) = {
  let mapped = serien.map(s => (name: s.name, values: s.werte))
  diagramm-figur(
    caption-text: caption-text,
    source-text: source-text,
    caption-pos: caption-position,
    breite: 100%,
    align(center, text(size: _sz(schrift))[
      #grouped-bar-chart(
        (labels: kategorien, series: mapped),
        width: breite, height: hoehe,
        theme: _th(),
      )
    ]),
  )
}

#let diagramm-balken-horizontal(
  kategorien: (), werte: (),
  x-label: "",
  caption-text: "", source-text: "",
  caption-position: auto,
  breite: 10cm, hoehe: auto, schrift: auto,
  ..extra,
) = {
  let h = if hoehe == auto { 0.95cm * kategorien.len() } else { hoehe }
  diagramm-figur(
    caption-text: caption-text,
    source-text: source-text,
    caption-pos: caption-position,
    breite: 100%,
    align(center, text(size: _sz(schrift))[
      #horizontal-bar-chart(
        (labels: kategorien, values: werte),
        width: breite, height: h,
        theme: _th(),
      )
    ]),
  )
}
