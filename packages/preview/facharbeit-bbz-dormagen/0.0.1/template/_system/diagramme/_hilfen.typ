#import "../design-system.typ"
#import "@preview/cetz:0.5.2": canvas, draw

#let x-pos(wert, min, max, plot-breite) = {
  if max == min { return 0 }
  return (wert - min) / (max - min) * plot-breite
}
#let y-pos(wert, min, max, plot-hoehe) = {
  if max == min { return 0 }
  return (wert - min) / (max - min) * plot-hoehe
}
#let auto-ticks(min, max, anzahl: 5, plot-laenge: 10) = {
  let ticks = ()
  let schritt = (max - min) / (anzahl - 1)
  for i in range(anzahl) {
    let wert = min + i * schritt
    let pos = x-pos(wert, min, max, plot-laenge)
    ticks += ((pos, format-de(calc.round(wert, digits: 0))),)
  }
  return ticks
}
#let balken-mit-muster(x1, y1, x2, y2, kat-index) = {
  let farbe = kat-farbe(kat-index)
  draw.rect((x1, y1), (x2, y2), fill: farbe, stroke: bar-stroke + oklch(18%, 0.055, 258deg))
  muster-zeichnen(x1, y1, x2, y2, kat-index, oklch(20%, 0.04, 258deg))
}
#let pfeil(x1, y1, x2, y2, farbe: main-color, staerke: 0.8pt) = {
  draw.line((x1, y1), (x2, y2), stroke: staerke + farbe, cap: "round")
  let winkel = calc.atan2(y2 - y1, x2 - x1)
  let laenge = 0.2
  draw.line((x2, y2), (x2 + laenge * calc.cos(winkel + 150deg), y2 + laenge * calc.sin(winkel + 150deg)), stroke: staerke + farbe)
  draw.line((x2, y2), (x2 + laenge * calc.cos(winkel - 150deg), y2 + laenge * calc.sin(winkel - 150deg)), stroke: staerke + farbe)
}
// Gefülltes Rechteck für eEPK-Funktionen (OHNE radius -> Füllung bleibt!)
#let funktion-rechteck(cx, cy, b, h, fuellung: header-bg, rand: main-color) = {
  draw.rect((cx - b/2, cy - h/2), (cx + b/2, cy + h/2), fill: fuellung, stroke: 0.8pt + rand)
}
#let verknuepfung(cx, cy, typ: "xor", radius: 0.3) = {
  draw.circle((cx, cy), radius: radius, fill: oklch(100%, 0, 0deg), stroke: 1.0pt + main-color)
  let symbol = if typ == "xor" { "⊕" } else if typ == "and" { "∧" } else { "∨" }
  draw-text((cx, cy), symbol, size: 10pt, weight: "bold", fill: main-color, anchor: "center")
}
