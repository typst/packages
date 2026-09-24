// ═══════════════════════════════════════════════════════════════════════════
// BREAK-EVEN.TYP – Break-even-Diagramm (CeTZ 0.3.3)
// ═══════════════════════════════════════════════════════════════════════════

#import "../design-system.typ"
#import "_hilfen.typ"
#import "@preview/cetz:0.5.2": canvas, draw

#let diagramm-break-even(
  fixkosten: 0,
  var-kosten-pro-einheit: 0,
  erloes-pro-einheit: 0,
  max-einheiten: 100,
  x-label: "Menge",
  y-label: "EUR",
  x-einheit: "",
  caption-text: "",
  source-text: "",
  caption-position: auto,
  breite: 14cm,
  hoehe: 9cm,
) = {
  let deckungsbeitrag = erloes-pro-einheit - var-kosten-pro-einheit
  let bep = if deckungsbeitrag > 0 { calc.round(fixkosten / deckungsbeitrag, digits: 0) } else { max-einheiten }
  let max-y = calc.max(erloes-pro-einheit * max-einheiten, fixkosten + var-kosten-pro-einheit * max-einheiten) * 1.1
  let plot-b = 10.0
  let plot-h = 6.5
  let ox = 2.0
  let oy = 1.0

  diagramm-figur(
    caption-text: caption-text,
    source-text: source-text,
    caption-pos: caption-position,
    breite: breite,
    {
      canvas(length: 1cm, {
        
        draw.line((ox, oy), (ox + plot-b, oy), stroke: axis-width + main-color)
        draw.line((ox, oy), (ox, oy + plot-h), stroke: axis-width + main-color)
        // Obere und rechte Begrenzung
        draw.line((ox, oy + plot-h), (ox + plot-b, oy + plot-h), stroke: axis-width + main-color)
        draw.line((ox + plot-b, oy), (ox + plot-b, oy + plot-h), stroke: axis-width + main-color)
        let x-ticks = auto-ticks(0, max-einheiten, anzahl: 6, plot-laenge: plot-b)
        let y-ticks = auto-ticks(0, max-y, anzahl: 6, plot-laenge: plot-h)
        for tick in x-ticks {
          let x = ox + tick.at(0)
          draw.line((x, oy), (x, oy - 0.15), stroke: 0.5pt + main-color)
          draw-text((x, oy - 0.4), tick.at(1), size: axis-label-size, fill: label-color, anchor: "north")
          draw.line((x, oy), (x, oy + plot-h), stroke: (paint: stroke-color, thickness: grid-width, dash: "dashed"))
        }
        for tick in y-ticks {
          let y = oy + tick.at(0)
          draw.line((ox, y), (ox - 0.15, y), stroke: 0.5pt + main-color)
          draw-text((ox - 0.3, y), tick.at(1), size: axis-label-size, fill: label-color, anchor: "east")
          draw.line((ox, y), (ox + plot-b, y), stroke: (paint: stroke-color, thickness: grid-width, dash: "dashed"))
        }
        draw-text((ox + plot-b / 2, oy - 1.0), x-label, size: axis-title-size, weight: "medium", fill: main-color, anchor: "north")
        draw-text((ox - 1.5, oy + plot-h / 2), y-label, size: axis-title-size, weight: "medium", fill: main-color, anchor: "south", angle: -90deg)
        // Fixkosten
        let y-fix = oy + y-pos(fixkosten, 0, max-y, plot-h)
        draw.line((ox, y-fix), (ox + plot-b, y-fix), stroke: (paint: accent-2, thickness: data-line-width, dash: "dashed"))
        draw-text((ox + plot-b + 0.2, y-fix), "Fixkosten", size: 7pt, fill: accent-2, anchor: "west")
        // Gesamtkosten
        let y-kosten-start = oy + y-pos(fixkosten, 0, max-y, plot-h)
        let y-kosten-end = oy + y-pos(fixkosten + var-kosten-pro-einheit * max-einheiten, 0, max-y, plot-h)
        draw.line((ox, y-kosten-start), (ox + plot-b, y-kosten-end), stroke: data-line-width + accent-3)
        draw-text((ox + plot-b + 0.2, y-kosten-end), "Gesamtkosten", size: 7pt, fill: accent-3, anchor: "west")
        // Erlöse
        let y-erloes-end = oy + y-pos(erloes-pro-einheit * max-einheiten, 0, max-y, plot-h)
        draw.line((ox, oy), (ox + plot-b, y-erloes-end), stroke: data-line-width + main-color)
        draw-text((ox + plot-b + 0.2, y-erloes-end), "Erlöse", size: 7pt, fill: main-color, anchor: "west")
        // BEP
        if bep <= max-einheiten {
          let x-bep = ox + x-pos(bep, 0, max-einheiten, plot-b)
          let y-bep = oy + y-pos(erloes-pro-einheit * bep, 0, max-y, plot-h)
          draw.line((x-bep, oy), (x-bep, y-bep), stroke: (paint: oklch(55%, 0.15, 25deg), thickness: 0.8pt, dash: "dashed"))
          draw.circle((x-bep, y-bep), radius: 0.12, fill: oklch(55%, 0.15, 25deg), stroke: 1.0pt + oklch(100%, 0, 0deg))
          datenlabel(x-bep + 0.5, y-bep + 0.4, "BEP: " + format-de(bep) + " " + x-einheit)
        }
      })
    },
  )
}
