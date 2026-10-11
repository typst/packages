// faboxyst manual — shared helpers (language switch, API entries, live examples).
#import "@preview/faboxyst:0.3.0" as fb
#import "@preview/cetz:0.5.2"
#import "_data.typ": chapters, fns, aliases, values

#let lang = sys.inputs.at("lang", default: "en")
#let T(en, fr) = if lang == "fr" { fr } else { en }
// package manifest, and the namespace shown in the code samples (--input ns=local for the local edition)
#let pkg = toml("../typst.toml").package
#let ns = sys.inputs.at("ns", default: "preview")
#let accent = rgb("#1b4f72")
#let soft = rgb("#eaf1f6")
#let scope = dictionary(fb) + (cetz: cetz)
#let mono = "DejaVu Sans Mono"

#let _ev(src) = eval(src, mode: "markup", scope: scope)

// Runs `src` (markup) beside its listing. The render is shrunk to fit its cell.
// Examples containing Arabic letters run in an Arabic context (`lang: "ar"`):
// faboxyst reads the direction from the text settings, not from the content.
#let _arabic = regex("[\u0600-\u06FF]")
// `fit` < 1: the example is laid out in a wider box (width / fit) and the whole
// render is then scaled down by `fit`, for examples whose natural size is
// larger than the cell. Values are measured by docs/_fit.typ.
#let _render(src, w, fit: 1.0) = {
  let ar = src.find(_arabic) != none
  set text(size: 8.5pt, fill: black)
  set text(lang: "ar", dir: rtl) if ar
  set text(lang: "en", dir: ltr) if not ar
  set par(justify: false, leading: 0.55em)
  let side = if ar { right } else { left }
  let c = _ev(src)
  if fit < 0.999 {
    align(side + top, scale(x: fit * 100%, y: fit * 100%, reflow: true, origin: side + top, box(width: w / fit, c)))
  } else {
    let m = measure(c, width: w)
    if m.width > w * 1.001 {
      let f = w / m.width
      align(side + top, scale(x: f * 100%, y: f * 100%, reflow: true, origin: side + top, box(width: m.width, c)))
    } else { align(side + top, c) }
  }
}

#let ex(src, cols: (1.15fr, 1fr), fit: 1.0) = {
  let src = src.trim("\n")
  block(breakable: false, width: 100%, grid(columns: cols, gutter: 7pt, align: (left + top, left + horizon),
    block(fill: luma(246), inset: 5pt, radius: 3pt, width: 100%, { set par(justify: false); set text(size: 6.6pt); raw(src, lang: "typ", block: true) }),
    block(stroke: 0.4pt + luma(205), inset: 6pt, radius: 3pt, width: 100%, layout(sz => _render(src, sz.width, fit: fit)))))
}

#let _lbl(en, fr) = block(sticky: true, above: 5pt, below: 2pt, text(size: 7.6pt, weight: "bold", fill: accent, upper(T(en, fr))))
#let _short(s, n: 44) = if s.len() > n { s.slice(0, n - 1) + "…" } else { s }

#let _ptable(ps) = {
  set text(size: 7.2pt)
  set par(justify: false)
  table(columns: (auto, auto, 1fr), stroke: (x: none, y: 0.25pt + luma(205)), inset: (x: 3pt, y: 2.4pt), align: left + horizon,
    table.header(..([#T("name", "nom")], [#T("default", "défaut")], [#T("description", "description")]).map(c => text(size: 6.8pt, fill: luma(110), c))),
    ..ps.map(q => (
      raw(q.n, lang: "typc"),
      if q.d == none { text(fill: luma(120))[#T("required", "obligatoire")] } else { raw(_short(q.d), lang: "typc") },
      T(q.en, q.fr),
    )).flatten())
}

// One API entry from the generated data.
#let entry(name) = {
  let f = fns.at(name)
  [#metadata(name) <api-entry>]
  block(breakable: true, above: 13pt, below: 4pt, width: 100%, {
    let als = aliases.at(name, default: ())
    block(width: 100%, below: 3pt, {
      heading(level: 3, raw(name))
      if als.len() > 0 { h(6pt); text(size: 7.6pt, fill: luma(110))[#T("also", "aussi") #als.map(a => raw(a)).join(", ")] }
    })
    block(fill: soft, inset: (x: 6pt, y: 4pt), radius: 2pt, width: 100%, { set par(justify: false); set text(size: 8pt); raw(f.sig, lang: "typc") })
    v(1pt)
    text(size: 8.6pt, T(f.en, f.fr))
    if f.params.len() > 0 {
      v(2pt)
      _lbl("Parameters", "Paramètres")
      let ps = f.params
      if ps.len() > 12 {
        let h = calc.ceil(ps.len() / 2)
        grid(columns: (1fr, 1fr), gutter: 6pt, _ptable(ps.slice(0, h)), _ptable(ps.slice(h)))
      } else { _ptable(ps) }
    }
    if f.code != none { _lbl("Usage (page layout, shown as code only)", "Utilisation (mise en page, code seul)"); block(fill: luma(246), inset: 5pt, radius: 3pt, width: 100%, { set text(size: 6.8pt); raw(f.code, lang: "typ", block: true) }) }
    if f.ex != none { _lbl("Example", "Exemple"); ex(f.ex, fit: f.at("fit", default: 1.0)) }
  })
}

#let chapter-head(c) = {
  pagebreak(weak: true)
  heading(level: 1, T(c.en, c.fr))
  block(width: 100%, inset: (bottom: 4pt), text(size: 9pt, _ev(T(c.intro-en, c.intro-fr))))
}

// compact table of values / constants
#let values-table(names) = {
  if names.len() > 0 {
    v(4pt)
    _lbl("Values and constants", "Valeurs et constantes")
    set text(size: 7.8pt)
    table(columns: (auto, 1fr), stroke: (x: none, y: 0.25pt + luma(205)), inset: (x: 3pt, y: 2.6pt),
      ..names.map(n => (raw(n, lang: "typc"), T(values.at(n).en, values.at(n).fr))).flatten())
  }
}
