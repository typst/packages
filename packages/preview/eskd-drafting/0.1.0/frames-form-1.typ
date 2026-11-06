// frames-form-1.typ — Основная надпись для чертежей и схем (Форма 1 по ГОСТ 2.104-2006)
//
// Габариты: 185 х 55 мм. Первый лист чертежей, схем и графических документов.
// Включает:
// - Графа 1: Наименование изделия (70 х 25 мм)
// - Графа 2: Обозначение документа (120 х 15 мм)
// - Графа 3: Материал детали (70 х 15 мм)
// - Графа 4: Литеры (3 ячейки по 5 мм)
// - Графа 5: Масса (17 х 15 мм)
// - Графа 6: Масштаб (18 х 15 мм)
// - Графа 7: Лист (ячейка 15 х 5 мм)
// - Графа 8: Листов (ячейка 17 х 5 мм)
// - Графа 9: Предприятие/организация (50 х 15 мм)
// - Графы 10-13: До 6 строк подписей исполнителей (Разраб., Пров., Т.контр. и др.)
// - Графы 14-18: Таблица изменений

#import "math.typ": *
#import "state.typ": *
#import "validators.typ": *
#import "frames-core.typ": *

/// Форма 1 (185 х 55 мм) — Основная надпись для чертежей и схем (первый лист) по ГОСТ 2.104-2006.
#let frame-form-1(..args) = context {
  let cols = (7mm, 10mm, 23mm, 15mm, 10mm, 70mm, 5mm, 5mm, 5mm, 5mm, 12mm, 18mm)
  let rows = (5mm,) * 11
  let named = args.named()
  let s = eskd-state.get()
  let ignore-r = if "ignore-rules" in named and named.at("ignore-rules") != auto { named.at("ignore-rules") } else { s.at("ignore-rules", default: auto) }
  if "toc" in named {
    assert-toc-unsupported(named.at("toc"), form-name: "Форме 1 (ГОСТ 2.104-2006)", ignore-rules: ignore-r)
  }
  assert-stamp-geometry(cols, rows, 185mm, 55mm, "Форма 1 (ГОСТ 2.104-2006)", ignore-rules: ignore-r)
  assert-line-thicknesses(thick, thin, ignore-rules: ignore-r)

  let cfg = resolve-font-cfg(font: named.at("font", default: auto), font-type: named.at("font-type", default: auto), font-group: named.at("font-group", default: auto), font-cfg: named.at("font-cfg", default: s.at("font-cfg", default: gost-fonts.at("type-b"))))
  let is-it = if "font-italic" in named and named.at("font-italic") != auto { named.at("font-italic") == true } else { s.at("font-italic", default: false) == true }
  let ps = preset-stroke(named, s)

  let c(k, grp, d-val: [], d-h: h3_5, weight: "regular", align-mode: center + horizon, wrap-box: false, single-line: false, max-w: none, max-h: none) = render-cell(
    k, grp, default-val: d-val, default-h: d-h, weight: weight, italic: is-it, align-mode: align-mode,
    wrap-box: wrap-box, single-line: single-line, max-w: max-w, max-h: max-h,
    named-args: named, state-dict: s, cfg: cfg
  )

  let p-val = get-field(named, "page", s, default: auto)
  let t-val = get-field(named, "total", s, default: auto)
  let cur-page = if p-val == none { [] } else if p-val != auto { p-val } else { counter(page).display("1") }
  let total-p = if t-val == none { [] } else if t-val != auto { t-val } else { counter(page).final().first() }
  let is-multi-page = if type(total-p) == int { total-p > 1 } else if type(total-p) == str { total-p != "1" and total-p != "" } else { false }

  let sheet-target-h = get-font-h("sheet", "sheet", h3_5, named, s)
  let label-h = get-font-h("labels", "labels", h2_5, named, s)

  let (lit1, lit2, lit3) = parse-lit-cells(get-field(named, "lit", s, default: auto), ignore-rules: ignore-r)
  let lit-target-h = get-font-h("lit", "lit", h3_5, named, s)
  let lit-items = (lit1, lit2, lit3).filter(l => l != [] and l != none and l != auto and l != "")
  let lit-spec = compute-group-font(lit-items, target-h: lit-target-h, min-h: h1_8, max-w: 4.4mm, max-h: 14.0mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)

  let sheet-items = (cur-page, total-p).filter(p => p != [] and p != none and p != auto and p != "")
  let sheet-spec = compute-group-font(sheet-items, target-h: sheet-target-h, min-h: h1_8, max-w: 12mm, max-h: 4.0mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)

  let mass-val = get-field(named, "mass", s, default: [])
  assert-mass(mass-val, ignore-rules: ignore-r)
  let scale-val = get-field(named, "scale", s, default: [])
  assert-scale(scale-val, ignore-rules: ignore-r)

  let raw-members = get-field(named, "members", s, default: ())
  assert-members-capacity(raw-members, max-rows: 6, form-name: "Форма 1", ignore-rules: ignore-r)
  let m-rows = range(0, 6).map(i => resolve-member-field(i, named, s))
  let m-labels-spec = compute-group-font(m-rows.filter(r => r.at("label-size") == auto).map(r => r.label), target-h: get-font-h("labels", "labels", h2_5, named, s), min-h: h1_8, max-w: 16mm, max-h: 4.5mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)
  let m-values-spec = compute-group-font(m-rows.filter(r => r.at("name-size") == auto).map(r => r.name), target-h: get-font-h("values", "values", h3_5, named, s), min-h: h1_8, max-w: 22mm, max-h: 4.5mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)
  let m-dates-spec  = compute-group-font(m-rows.filter(r => r.at("date-size") == auto).map(r => r.date),   target-h: get-font-h("dates", "dates", h2_5, named, s),   min-h: h1_8, max-w: 9.5mm, max-h: 4.5mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)
  let m-signs-spec  = compute-group-font(m-rows.filter(r => r.at("sign-size") == auto).map(r => r.sign),   target-h: get-font-h("signs", "signs", h3_5, named, s),   min-h: h1_8, max-w: 14mm, max-h: 4.5mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)

  let raw-changes = get-field(named, "changes", s, default: auto)
  assert-changes-capacity(raw-changes, max-rows: 4, form-name: "Форма 1", ignore-rules: ignore-r)
  let c-rows = range(0, 4).map(i => resolve-change-field(i, named, s))
  let c-nums-spec   = compute-group-font(c-rows.filter(r => r.at("num-size") == auto).map(r => r.num),     target-h: get-font-h("values", "values", h3_5, named, s), min-h: h1_8, max-w: 6.5mm, max-h: 4.5mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)
  let c-sheets-spec = compute-group-font(c-rows.filter(r => r.at("sheet-size") == auto).map(r => r.sheet), target-h: get-font-h("values", "values", h3_5, named, s), min-h: h1_8, max-w: 9.5mm, max-h: 4.5mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)
  let c-docs-spec   = compute-group-font(c-rows.filter(r => r.at("doc-size") == auto).map(r => r.doc),     target-h: get-font-h("values", "values", h3_5, named, s), min-h: h1_8, max-w: 22mm, max-h: 4.5mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)
  let c-sigs-spec   = compute-group-font(c-rows.filter(r => r.at("sig-size") == auto).map(r => r.sig),     target-h: get-font-h("signs", "signs", h3_5, named, s),   min-h: h1_8, max-w: 14mm, max-h: 4.5mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)
  let c-dates-spec  = compute-group-font(c-rows.filter(r => r.at("date-size") == auto).map(r => r.date),   target-h: get-font-h("dates", "dates", h2_5, named, s),   min-h: h1_8, max-w: 9.5mm, max-h: 4.5mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)

  set table(inset: (x: 0.3mm, y: 0.2mm))

  table(
    columns: cols,
    rows: rows,
    align: alignment.center + alignment.horizon,
    stroke: none,

    table.cell(x: 5, y: 3, colspan: 1, rowspan: 5)[#c("name", "name", d-h: h5_0, max-w: 68mm, max-h: 24mm)],
    table.cell(x: 5, y: 0, colspan: 7, rowspan: 3)[#c("code", "code", d-h: h7_0, weight: "bold", wrap-box: true, single-line: true, max-w: 118mm, max-h: 14mm)],
    table.cell(x: 5, y: 8, colspan: 1, rowspan: 3)[#c("material", "material", d-h: h5_0, max-w: 68mm, max-h: 14mm)],

    table.cell(x: 6, y: 3, colspan: 3, rowspan: 1)[#gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Лит.]],
    table.cell(x: 6, y: 4, colspan: 1, rowspan: 3)[#render-lit-cell(lit1, base-h: lit-spec.h, max-w: 4.4mm, max-h: 14.0mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)],
    table.cell(x: 7, y: 4, colspan: 1, rowspan: 3)[#render-lit-cell(lit2, base-h: lit-spec.h, max-w: 4.4mm, max-h: 14.0mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)],
    table.cell(x: 8, y: 4, colspan: 1, rowspan: 3)[#render-lit-cell(lit3, base-h: lit-spec.h, max-w: 4.4mm, max-h: 14.0mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)],

    table.cell(x: 9, y: 3, colspan: 2, rowspan: 1)[#gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Масса]],
    table.cell(x: 9, y: 4, colspan: 2, rowspan: 3)[#auto-fit-gost(mass-val, target-h: h5_0, min-h: h3_5, max-w: 16mm, max-h: 14mm, italic: is-it, single-line: true, cfg: cfg, ignore-rules: ignore-r)],
    table.cell(x: 11, y: 3, colspan: 1, rowspan: 1)[#gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Масштаб]],
    table.cell(x: 11, y: 4, colspan: 1, rowspan: 3)[#auto-fit-gost(scale-val, target-h: h5_0, min-h: h3_5, max-w: 17mm, max-h: 14mm, italic: is-it, single-line: true, cfg: cfg, ignore-rules: ignore-r)],

    table.cell(x: 6, y: 7, colspan: 4, rowspan: 1, inset: (x: 0.5mm, y: 0mm))[
      #if cur-page != [] and (is-multi-page or p-val != auto) {
        grid(
          columns: (auto, 1fr),
          align: (alignment.left + alignment.horizon, alignment.center + alignment.horizon),
          gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Лист],
          render-group-item(cur-page, sheet-spec, item-size: get-field(named, "sheet", s, default: auto), max-w: 12mm, max-h: 4.0mm, italic: is-it, align-mode: center + horizon, cfg: cfg, ignore-rules: ignore-r),
        )
      }
    ],
    table.cell(x: 10, y: 7, colspan: 2, rowspan: 1, inset: (x: 0.5mm, y: 0mm))[
      #if total-p != [] {
        grid(
          columns: (auto, 1fr),
          align: (alignment.left + alignment.horizon, alignment.center + alignment.horizon),
          gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Листов],
          render-group-item(total-p, sheet-spec, item-size: get-field(named, "sheet", s, default: auto), max-w: 18mm, max-h: 4.0mm, italic: is-it, align-mode: center + horizon, cfg: cfg, ignore-rules: ignore-r),
        )
      }
    ],

    table.cell(x: 6, y: 8, colspan: 6, rowspan: 3)[#c("org", "org", d-h: h5_0, max-w: 48mm, max-h: 14mm)],

    ..range(0, 4).map(i => {
      let r = c-rows.at(i)
      let y-pos = 3 - i
      (
        table.cell(x: 0, y: y-pos)[#render-group-item(r.num, c-nums-spec, item-size: r.at("num-size"), max-w: 6.5mm, max-h: 4.5mm, italic: is-it, align-mode: center + horizon, cfg: cfg, ignore-rules: ignore-r)],
        table.cell(x: 1, y: y-pos)[#render-group-item(r.sheet, c-sheets-spec, item-size: r.at("sheet-size"), max-w: 9.5mm, max-h: 4.5mm, italic: is-it, align-mode: center + horizon, cfg: cfg, ignore-rules: ignore-r)],
        table.cell(x: 2, y: y-pos)[#render-group-item(r.doc, c-docs-spec, item-size: r.at("doc-size"), max-w: 22mm, max-h: 4.5mm, italic: is-it, align-mode: center + horizon, cfg: cfg, ignore-rules: ignore-r)],
        table.cell(x: 3, y: y-pos)[#render-group-item(r.sig, c-sigs-spec, item-size: r.at("sig-size"), max-w: 14mm, max-h: 4.5mm, italic: is-it, align-mode: center + horizon, cfg: cfg, ignore-rules: ignore-r)],
        table.cell(x: 4, y: y-pos)[#render-group-item(r.date, c-dates-spec, item-size: r.at("date-size"), max-w: 9.5mm, max-h: 4.5mm, italic: is-it, align-mode: center + horizon, cfg: cfg, ignore-rules: ignore-r)],
      )
    }).join(),

    table.cell(x: 0, y: 4)[#gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Изм.]],
    table.cell(x: 1, y: 4)[#gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Лист]],
    table.cell(x: 2, y: 4)[#gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[№ докум.]],
    table.cell(x: 3, y: 4)[#gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Подп.]],
    table.cell(x: 4, y: 4)[#gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Дата]],

    ..range(0, 6).map(i => {
      let r = m-rows.at(i)
      let y-pos = 5 + i
      (
        table.cell(x: 0, y: y-pos, colspan: 2, inset: text-inset-left, align: alignment.left + alignment.horizon)[
          #render-group-item(r.label, m-labels-spec, item-size: r.at("label-size"), max-w: 16mm, max-h: 4.5mm, italic: is-it, align-mode: left + horizon, cfg: cfg, ignore-rules: ignore-r)
        ],
        table.cell(x: 2, y: y-pos, inset: text-inset-left, align: alignment.left + alignment.horizon)[
          #render-group-item(r.name, m-values-spec, item-size: r.at("name-size"), max-w: 22mm, max-h: 4.5mm, italic: is-it, align-mode: left + horizon, cfg: cfg, ignore-rules: ignore-r)
        ],
        table.cell(x: 3, y: y-pos)[
          #render-group-item(r.sign, m-signs-spec, item-size: r.at("sign-size"), max-w: 14mm, max-h: 4.5mm, italic: is-it, align-mode: center + horizon, cfg: cfg, ignore-rules: ignore-r)
        ],
        table.cell(x: 4, y: y-pos)[
          #render-group-item(r.date, m-dates-spec, item-size: r.at("date-size"), max-w: 9.5mm, max-h: 4.5mm, italic: is-it, align-mode: center + horizon, cfg: cfg, ignore-rules: ignore-r)
        ],
      )
    }).flatten(),

    table.hline(y: 0, stroke: thick),
    table.hline(y: 11, stroke: thick),
    table.vline(x: 0, stroke: thick),
    table.vline(x: 12, stroke: thick),

    table.vline(x: 5, stroke: thick),
    table.hline(y: 5, start: 0, end: 5, stroke: thick),
    table.hline(y: 3, start: 5, end: 12, stroke: thick),
    table.vline(x: 6, start: 3, end: 11, stroke: thick),
    table.hline(y: 7, start: 6, end: 12, stroke: thick),
    table.hline(y: 8, start: 5, end: 12, stroke: thick),
    table.vline(x: 9, start: 3, end: 7, stroke: thick),
    table.vline(x: 11, start: 3, end: 7, stroke: thick),
    table.vline(x: 10, start: 7, end: 8, stroke: thick),

    table.hline(y: 4, end: 5, stroke: ps),
    table.vline(x: 1, start: 0, end: 5, stroke: ps),
    table.vline(x: 2, stroke: ps),
    table.vline(x: 3, stroke: ps),
    table.vline(x: 4, stroke: ps),

    table.hline(y: 1, end: 5, stroke: thin),
    table.hline(y: 2, end: 5, stroke: thin),
    table.hline(y: 3, end: 5, stroke: thin),
    table.hline(y: 6, end: 5, stroke: thin),
    table.hline(y: 7, end: 5, stroke: thin),
    table.hline(y: 8, end: 5, stroke: thin),
    table.hline(y: 9, end: 5, stroke: thin),
    table.hline(y: 10, end: 5, stroke: thin),

    table.vline(x: 7, start: 4, end: 7, stroke: thin),
    table.vline(x: 8, start: 4, end: 7, stroke: thin),
    table.hline(y: 4, start: 6, end: 12, stroke: thin),
  )
}
