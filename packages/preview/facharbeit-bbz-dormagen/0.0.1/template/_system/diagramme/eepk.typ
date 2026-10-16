// ═══════════════════════════════════════════════════════════════════════════
// EEPK.TYP – eEPK als generiertes SVG (ARIS-Formen, verzweigender Graph)
// Text passt sich automatisch an jede Form an (siehe fit-text).
// ═══════════════════════════════════════════════════════════════════════════

#import "../design-system.typ"
#import "../einstellungen.typ"

// ── String-Helfer ───────────────────────────────────────────────────────────
#let f(v) = str(calc.round(v, digits: 2))
#let esc(t) = t.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
#let join-w(words, a, b) = words.slice(a, b).join(" ")

// ── nutzbare halbe Textbreite einer Form an vertikalem Offset dy ────────────
#let usable-half(typ, dy, hw, hh, q, rx, ry, sys-inset) = {
  if typ == "ereignis" { return hw - q * calc.abs(dy) / hh }
  if typ == "funktion" { return hw }
  if typ == "system" { return hw - sys-inset }
  if typ == "organisation" {
    if calc.abs(dy) >= ry { return 0.01 }
    return rx * calc.sqrt(1 - (dy / ry) * (dy / ry))
  }
  return hw
}

// ── balancierter Zeilenumbruch in 2 / 3 Zeilen ──────────────────────────────
#let balance2(words) = {
  if words.len() < 2 { return none }
  let best-i = 1
  let best-score = 100000
  for i in range(1, words.len()) {
    let l = join-w(words, 0, i)
    let r = join-w(words, i, words.len())
    let sc = calc.abs(l.len() - r.len())
    if sc < best-score { best-score = sc; best-i = i }
  }
  return (join-w(words, 0, best-i), join-w(words, best-i, words.len()))
}
#let balance3(words) = {
  if words.len() < 3 { return none }
  let bi = 1
  let bj = 2
  let bs = 100000
  for i in range(1, words.len() - 1) {
    for j in range(i + 1, words.len()) {
      let a = join-w(words, 0, i)
      let b = join-w(words, i, j)
      let c = join-w(words, j, words.len())
      let mx = calc.max(a.len(), b.len(), c.len())
      let mn = calc.min(a.len(), b.len(), c.len())
      let sc = mx - mn
      if sc < bs { bs = sc; bi = i; bj = j }
    }
  }
  return (join-w(words, 0, bi), join-w(words, bi, bj), join-w(words, bj, words.len()))
}

// ── Schriftgröße so wählen, dass alle Zeilen in die Form passen ─────────────
#let fit-text(t, typ, hw, hh, q, rx, ry, sys-inset, base, minsize) = {
  let charw = 0.6      // konservative Zeichenbreite -> garantiert Innenabstand
  let pad = 0.13       // gewünschter Abstand zum Formrand (cm)
  let words = t.split(" ")
  let chosen-lines = (t,)
  let chosen-s = -1
  for n in (1, 2, 3) {
    let lines = none
    if n == 1 { lines = (words.join(" "),) }
    else if n == 2 { lines = balance2(words) }
    else { lines = balance3(words) }
    if lines == none { continue }
    let s = base
    for it in range(6) {
      let lh = s * 1.2
      let s2 = s
      for i in range(lines.len()) {
        let dy = (i - (lines.len() - 1) / 2.0) * lh
        let uh = usable-half(typ, dy, hw, hh, q, rx, ry, sys-inset) - pad
        let need = lines.at(i).len() * charw
        if need > 0 {
          let smax = 2 * uh / need
          if smax < s2 { s2 = smax }
        }
      }
      let hmax = (2 * hh - 2 * pad) / ((lines.len() - 1) * 1.2 + 1)
      if hmax < s2 { s2 = hmax }
      if calc.abs(s2 - s) < 0.002 { s = s2; break }
      s = s2
    }
    if s > chosen-s { chosen-s = s; chosen-lines = lines }
  }
  let final-s = if chosen-s >= minsize { chosen-s } else { minsize }
  return (chosen-lines, final-s)
}

// ── SVG-Text (auto-fit, mehrzeilig, zentriert) ──────────────────────────────
#let svg-text(cx, cy, t, typ: "funktion", hw: 1.5, hh: 0.55, q: 0, rx: 0, ry: 0, sys-inset: 0, base: 0.40, do-fit: true) = {
  let lines = (t,)
  let size = base
  if do-fit {
    let res = fit-text(t, typ, hw, hh, q, rx, ry, sys-inset, base, 0.24)
    lines = res.at(0)
    size = res.at(1)
  }
  let n = lines.len()
  let lh = size * 1.2
  let y0 = cy - (n - 1) / 2.0 * lh
  let tsp = ""
  for i in range(n) {
    tsp = tsp + "<tspan x='" + f(cx) + "' y='" + f(y0 + i * lh) + "'>" + esc(lines.at(i)) + "</tspan>"
  }
  return "<text text-anchor='middle' dominant-baseline='central' font-size='" + f(size) + "' font-family='Noto Sans' fill='#1a1a1a'>" + tsp + "</text>"
}

// ── Geometrie-Helfer für Kanten ─────────────────────────────────────────────
#let bbox-hw(typ) = {
  if typ == "ereignis" { return (1.65, 0.58) }
  if typ == "funktion" { return (1.50, 0.55) }
  if typ == "organisation" { return (1.20, 0.46) }
  if typ == "system" { return (1.10, 0.46) }
  return (0.46, 0.46)
}
#let clip(cx, cy, hw, hh, tx, ty) = {
  let dx = tx - cx
  let dy = ty - cy
  if calc.abs(dx) < 0.0001 and calc.abs(dy) < 0.0001 { return (cx, cy) }
  let txv = if calc.abs(dx) < 0.0001 { 100000 } else { hw / calc.abs(dx) }
  let tyv = if calc.abs(dy) < 0.0001 { 100000 } else { hh / calc.abs(dy) }
  let t = calc.min(txv, tyv)
  return (cx + dx * t, cy + dy * t)
}
#let spitze(ex, ey, ux, uy) = {
  let L = 0.30
  let S = 0.12
  let b1x = ex - L * ux + S * (-uy)
  let b1y = ey - L * uy + S * (ux)
  let b2x = ex - L * ux - S * (-uy)
  let b2y = ey - L * uy - S * (ux)
  return "<polygon points='" + f(ex) + "," + f(ey) + " " + f(b1x) + "," + f(b1y) + " " + f(b2x) + "," + f(b2y) + "' fill='#ffffff' stroke='#1a1a1a' stroke-width='0.03'/>"
}

// ═══════════════════════════════════════════════════════════════════════════
#let diagramm-eepk(
  knoten: (),
  kanten: (),
  caption-text: "",
  source-text: "",
  caption-position: auto,
  breite: auto,
) = {
  let evf = einstellungen.eepk-ev-fill.to-hex();    let evs = einstellungen.eepk-ev-stroke.to-hex()
  let fnf = einstellungen.eepk-fn-fill.to-hex();    let fns = einstellungen.eepk-fn-stroke.to-hex()
  let orf = einstellungen.eepk-org-fill.to-hex();   let ors = einstellungen.eepk-org-stroke.to-hex()
  let syf = einstellungen.eepk-sys-fill.to-hex();   let sys = einstellungen.eepk-sys-stroke.to-hex()
  let xof = einstellungen.eepk-xor-fill.to-hex()
  let xos = einstellungen.eepk-xor-stroke.to-hex()
  let edg = einstellungen.eepk-edge.to-hex()

  let kn = (:)
  let bb = (:)
  for k in knoten {
    let hw-hh = bbox-hw(k.typ)
    kn.insert(k.id, k)
    bb.insert(k.id, (k.x, k.y, hw-hh.at(0), hw-hh.at(1)))
  }

  let xs = knoten.map(k => k.x)
  let ys = knoten.map(k => k.y)
  let minx = calc.min(..xs) - 2.0
  let maxx = calc.max(..xs) + 2.0
  let miny = calc.min(..ys) - 1.0
  let maxy = calc.max(..ys) + 1.0
  let W = maxx - minx
  let H = maxy - miny

  let svg-str = ""
  svg-str += "<svg xmlns='http://www.w3.org/2000/svg' width='" + f(W) + "cm' height='" + f(H) + "cm' viewBox='" + f(minx) + " " + f(miny) + " " + f(W) + " " + f(H) + "'>"

  // Kanten (unter den Formen)
  for e in kanten {
    let a = bb.at(e.von)
    let b = bb.at(e.nach)
    let stil = if "stil" in e.keys() { e.stil } else { "pfeil" }
    let p1 = clip(a.at(0), a.at(1), a.at(2), a.at(3), b.at(0), b.at(1))
    let p2 = clip(b.at(0), b.at(1), b.at(2), b.at(3), a.at(0), a.at(1))
    let dx = p2.at(0) - p1.at(0)
    let dy = p2.at(1) - p1.at(1)
    let ln = calc.sqrt(dx * dx + dy * dy)
    if ln > 0.001 {
      let ux = dx / ln
      let uy = dy / ln
      svg-str += "<line x1='" + f(p1.at(0)) + "' y1='" + f(p1.at(1)) + "' x2='" + f(p2.at(0)) + "' y2='" + f(p2.at(1)) + "' stroke='" + edg + "' stroke-width='0.03'/>"
      if stil == "pfeil" or stil == "doppelpfeil" {
        svg-str += spitze(p2.at(0), p2.at(1), ux, uy)
      }
      if stil == "doppelpfeil" {
        svg-str += spitze(p1.at(0), p1.at(1), -ux, -uy)
      }
    }
  }

  // Formen + Text (über den Kanten)
  for k in knoten {
    let cx = k.x
    let cy = k.y
    let typ = k.typ
    if typ == "ereignis" {
      let hw = 1.65; let hh = 0.58; let q = 0.5
      let pts = f(cx - hw) + "," + f(cy) + " " + f(cx - hw + q) + "," + f(cy - hh) + " " + f(cx + hw - q) + "," + f(cy - hh) + " " + f(cx + hw) + "," + f(cy) + " " + f(cx + hw - q) + "," + f(cy + hh) + " " + f(cx - hw + q) + "," + f(cy + hh)
      svg-str += "<polygon points='" + pts + "' fill='" + evf + "' stroke='" + evs + "' stroke-width='0.04'/>"
      svg-str += svg-text(cx, cy, k.text, typ: "ereignis", hw: hw, hh: hh, q: q)
    } else if typ == "funktion" {
      let hw = 1.50; let hh = 0.55
      svg-str += "<rect x='" + f(cx - hw) + "' y='" + f(cy - hh) + "' width='" + f(2 * hw) + "' height='" + f(2 * hh) + "' fill='" + fnf + "' stroke='" + fns + "' stroke-width='0.04'/>"
      svg-str += svg-text(cx, cy, k.text, typ: "funktion", hw: hw, hh: hh)
    } else if typ == "organisation" {
      let rx = 1.20; let ry = 0.46
      svg-str += "<ellipse cx='" + f(cx) + "' cy='" + f(cy) + "' rx='" + f(rx) + "' ry='" + f(ry) + "' fill='" + orf + "' stroke='" + ors + "' stroke-width='0.04'/>"
      svg-str += svg-text(cx, cy, k.text, typ: "organisation", hw: rx, hh: ry, rx: rx, ry: ry, base: 0.36)
    } else if typ == "system" {
      let hw = 1.10; let hh = 0.46
      svg-str += "<rect x='" + f(cx - hw) + "' y='" + f(cy - hh) + "' width='" + f(2 * hw) + "' height='" + f(2 * hh) + "' fill='" + syf + "' stroke='" + sys + "' stroke-width='0.04'/>"
      svg-str += "<line x1='" + f(cx - hw + 0.22) + "' y1='" + f(cy - hh) + "' x2='" + f(cx - hw + 0.22) + "' y2='" + f(cy + hh) + "' stroke='" + sys + "' stroke-width='0.04'/>"
      svg-str += svg-text(cx, cy, k.text, typ: "system", hw: hw, hh: hh, sys-inset: 0.30, base: 0.36)
    } else {
      let label = if typ == "and" { "AND" } else if typ == "or" { "OR" } else { "XOR" }
      svg-str += "<circle cx='" + f(cx) + "' cy='" + f(cy) + "' r='0.45' fill='" + xof + "' stroke='" + xos + "' stroke-width='0.05'/>"
      svg-str += svg-text(cx, cy, label, do-fit: false, base: 0.32)
    }
  }

  svg-str += "</svg>"

  let gb = if breite == auto { W * 1cm } else { breite }
  diagramm-figur(
    caption-text: caption-text,
    source-text: source-text,
    caption-pos: caption-position,
    breite: gb,
    image(bytes(svg-str), width: gb),
  )
}
