// nibframe manual — shared helpers (language switch, API entry layout, live examples).
#import "../lib.typ" as nf
#import "@preview/nibart:0.3.0" as nib

#let lang = sys.inputs.at("lang", default: "en")
#let T(en, fr) = if lang == "fr" { fr } else { en }
// package manifest (author, repository) and namespace shown in the code samples: --input ns=local for the local-install edition
#let pkg = toml("../typst.toml").package
#let ns = sys.inputs.at("ns", default: "preview")
#let accent = rgb("#7a2e0e")
#let soft = rgb("#f6ede8")
// inline markdown-ish: `code` segments become raw
#let md(s) = s.split("`").enumerate().map(((i, p)) => if calc.odd(i) { raw(p) } else { p }).join()

// ── type names (French display)
#let _ty-fr = (
  "length": "longueur", "path": "chemin", "paths": "chemins", "number": "nombre", "string": "chaîne", "array": "tableau",
  "bool": "booléen", "color": "couleur", "function": "fonction", "dictionary": "dictionnaire", "content": "contenu",
  "or": "ou", "of": "de", "pen": "plume", "pens": "plumes", "integer": "entier", "list": "liste", "alignment": "alignement",
  "point": "point", "points": "points", "pair": "couple", "pairs": "couples", "time": "temps", "times": "temps", "items": "objets",
  "drawable": "dessinable", "stroke": "trait", "ratio": "proportion", "per": "par", "one": "un", "frame": "repère",
)
#let _ty(s) = if lang == "fr" {
  let r = s
  for (k, v) in _ty-fr { r = r.replace(regex("\\b" + k + "\\b"), v) }
  r
} else { s }

// ── code with bilingual comments:  `// english § français`
#let _loc(code) = code.split("\n").map(l => {
  if l.contains("§") {
    let (a, b) = l.split("§")
    if lang == "fr" { a.split("//").first() + "//" + b } else { a.trim(at: end) }
  } else { l }
}).join("\n")

// Runs `code` (code mode; the value of the last expression is shown) next to its listing.
#let _show-val(v) = if type(v) == content { v } else if type(v) == str { text(font: "DejaVu Sans Mono", size: 8pt, v) } else { text(font: "DejaVu Sans Mono", size: 8pt, repr(v)) }
#let ex(code, cols: (2fr, 1fr), live: none) = {
  let src = _loc(if type(code) == content { code.text } else { code })
  let src = src.trim("\n")
  let res = eval(if live == none { src } else { (if type(live) == content { live.text } else { live }).trim("\n") }, mode: "code", scope: (nib: nib) + dictionary(nf))
  block(breakable: false, width: 100%, grid(columns: cols, gutter: 8pt, align: (left + top, center + horizon),
    block(fill: luma(246), inset: 6pt, radius: 3pt, width: 100%, { set par(justify: false); set text(size: 7pt); raw(src, lang: "typc", block: true) }),
    block(stroke: 0.4pt + luma(205), inset: 7pt, radius: 3pt, width: 100%, {
      set align(center + horizon)
      layout(sz => context {
        let c = _show-val(res)
        let m = measure(c)
        if m.width > sz.width and m.width > 0pt { { let k = sz.width / m.width; box(width: sz.width, height: m.height * k, align(left + top, scale(k * 100%, origin: top + left, box(width: m.width, height: m.height, c)))) } } else { c }
      })
    })))
}

#let ex-fn = ex

// ── parameter row
#let P(name, ty, def, en, fr) = (name: name, ty: ty, def: def, desc: T(en, fr))

#let _lbl(en, fr) = text(size: 8pt, weight: "bold", fill: accent, upper(T(en, fr)))

// ── one API entry
#let api(name, sig, desc, params: (), ret: none, ex: none, note: none, see: none, live: none, cols: (2fr, 1fr)) = {
  [#metadata(name) <api-entry>]
  block(breakable: true, above: 16pt, below: 6pt, width: 100%, {
    heading(level: 3, raw(name))
    block(fill: soft, inset: (x: 7pt, y: 5pt), radius: 2pt, width: 100%, { set par(justify: false); text(size: 9pt, raw(sig, lang: "typc")) })
    v(2pt)
    desc
    if params.len() > 0 {
      v(3pt)
      _lbl("Parameters", "Paramètres")
      v(1pt)
      set text(size: 9pt)
      table(columns: (auto, auto, auto, 1fr), stroke: (x: none, y: 0.3pt + luma(200)), inset: (x: 4pt, y: 3.2pt), align: (left, left, left, left),
        table.header(..([#T("name", "nom")], [#T("type", "type")], [#T("default", "défaut")], [#T("description", "description")]).map(c => text(size: 8pt, fill: luma(110), c))),
        ..params.map(q => (raw(q.name, lang: "typc"), text(fill: rgb("#1a4f8b"), _ty(q.ty)), if q.def == none { text(fill: luma(120))[#T("required", "obligatoire")] } else { raw(q.def, lang: "typc") }, q.desc)).flatten())
    }
    if ret != none { v(3pt); _lbl("Returns", "Renvoie"); [ ] ; ret }
    if note != none { v(3pt); _lbl("Note", "Remarque"); [ ]; note }
    if ex != none { v(4pt); _lbl("Example", "Exemple"); v(1pt); ex-fn(ex, live: live, cols: cols) }
  })
}
