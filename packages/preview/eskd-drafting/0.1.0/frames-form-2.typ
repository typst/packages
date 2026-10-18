// frames-form-2.typ — Основная надпись для текстовых документов (Форма 2 по ГОСТ 2.104-2006)
//
// Габариты:
// - 185 х 40 мм (базовая Форма 2 для заглавных листов текстовых документов по ГОСТ 2.104-2006)
// - 185 х 52 мм (Форма 2 с совмещенной шапкой содержания по ГОСТ 2.105-2019 / ГОСТ 2.106-96 при заданном параметре `toc`)
//
// Включает:
// - Графа 1: Наименование документа (70 х 25 мм)
// - Графа 2: Обозначение документа (120 х 15 мм)
// - Графа 4: Литеры (3 ячейки по 5 мм)
// - Графа 7: Лист (ячейка 15 х 5 мм)
// - Графа 8: Листов (ячейка 20 х 5 мм)
// - Графа 9: Предприятие/организация (50 х 15 мм)
// - Графы 10-13: До 5 строк подписей исполнителей (Разраб., Пров., Утв. и др.)
// - Графы 14-18: Таблица изменений
// - Совмещенная шапка содержания (120 х 12 мм над правой частью) при активном `toc`

#import "math.typ": *
#import "state.typ": *
#import "validators.typ": *
#import "frames-core.typ": *

/// Проверяет, активна ли шапка содержания (ГОСТ 2.105-2019 / ГОСТ 2.106-96).
#let is-toc-active(raw-toc) = {
  if raw-toc == none or raw-toc == auto {
    false
  } else if type(raw-toc) == dictionary or type(raw-toc) == array {
    true
  } else {
    false
  }
}

/// Форма 2 (185 х 40 мм или 185 х 52 мм при активном `toc`) —
/// Основная надпись для заглавных листов текстовых документов по ГОСТ 2.104-2006 / ГОСТ 2.105-2019.
#let frame-form-2(..args) = context {
  let named = args.named()
  let s = eskd-state.get()
  let ignore-r = if "ignore-rules" in named and named.at("ignore-rules") != auto { named.at("ignore-rules") } else { s.at("ignore-rules", default: auto) }

  let raw-toc = named.at("toc", default: none)
  let has-toc = is-toc-active(raw-toc)

  let cols = (7mm, 10mm, 23mm, 15mm, 10mm, 70mm, 5mm, 5mm, 5mm, 15mm, 20mm)
  let rows = if has-toc {
    (5mm, 7mm, 5mm, 5mm, 5mm, 5mm, 5mm, 5mm, 5mm, 5mm)
  } else {
    (5mm,) * 8
  }
  let stamp-h = if has-toc { 52mm } else { 40mm }
  let stamp-title = if has-toc {
    "Заглавный лист содержания (Форма 2 по ГОСТ 2.104 + ГОСТ 2.105 / 2.106)"
  } else {
    "Форма 2 (ГОСТ 2.104-2006)"
  }

  assert-stamp-geometry(cols, rows, 185mm, stamp-h, stamp-title, ignore-rules: ignore-r)
  assert-line-thicknesses(thick, thin, ignore-rules: ignore-r)

  let cfg = resolve-font-cfg(
    font: named.at("font", default: auto),
    font-type: named.at("font-type", default: auto),
    font-group: named.at("font-group", default: auto),
    font-cfg: named.at("font-cfg", default: s.at("font-cfg", default: gost-fonts.at("type-b")))
  )
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

  let (lit1, lit2, lit3) = parse-lit-cells(get-field(named, "lit", s, default: auto), ignore-rules: ignore-r)
  let lit-target-h = get-font-h("lit", "lit", h3_5, named, s)
  let lit-items = (lit1, lit2, lit3).filter(l => l != [] and l != none and l != auto and l != "")
  let lit-spec = compute-group-font(lit-items, target-h: lit-target-h, min-h: h1_8, max-w: 4.4mm, max-h: 4.4mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)

  let sheet-items = (cur-page, total-p).filter(p => p != [] and p != none and p != auto and p != "")
  let sheet-spec = compute-group-font(sheet-items, target-h: sheet-target-h, min-h: h1_8, max-w: 14mm, max-h: 4.0mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)

  let raw-members = get-field(named, "members", s, default: ())
  assert-members-capacity(raw-members, max-rows: 5, form-name: stamp-title, ignore-rules: ignore-r)
  let m-rows = range(0, 5).map(i => resolve-member-field(i, named, s))
  let m-labels-spec = compute-group-font(m-rows.filter(r => r.at("label-size") == auto).map(r => r.label), target-h: get-font-h("labels", "labels", h2_5, named, s), min-h: h1_8, max-w: 16mm, max-h: 4.5mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)
  let m-values-spec = compute-group-font(m-rows.filter(r => r.at("name-size") == auto).map(r => r.name), target-h: get-font-h("values", "values", h3_5, named, s), min-h: h1_8, max-w: 22mm, max-h: 4.5mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)
  let m-dates-spec  = compute-group-font(m-rows.filter(r => r.at("date-size") == auto).map(r => r.date),   target-h: get-font-h("dates", "dates", h2_5, named, s),   min-h: h1_8, max-w: 9.5mm, max-h: 4.5mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)
  let m-signs-spec  = compute-group-font(m-rows.filter(r => r.at("sign-size") == auto).map(r => r.sign),   target-h: get-font-h("signs", "signs", h3_5, named, s),   min-h: h1_8, max-w: 14mm, max-h: 4.5mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)
  let label-h = get-font-h("labels", "labels", h2_5, named, s)

  let raw-changes = get-field(named, "changes", s, default: auto)
  assert-changes-capacity(raw-changes, max-rows: 2, form-name: stamp-title, ignore-rules: ignore-r)
  let c-rows = range(0, 2).map(i => resolve-change-field(i, named, s))
  let c-nums-spec   = compute-group-font(c-rows.filter(r => r.at("num-size") == auto).map(r => r.num),     target-h: get-font-h("values", "values", h3_5, named, s), min-h: h1_8, max-w: 6.5mm, max-h: 4.5mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)
  let c-sheets-spec = compute-group-font(c-rows.filter(r => r.at("sheet-size") == auto).map(r => r.sheet), target-h: get-font-h("values", "values", h3_5, named, s), min-h: h1_8, max-w: 9.5mm, max-h: 4.5mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)
  let c-docs-spec   = compute-group-font(c-rows.filter(r => r.at("doc-size") == auto).map(r => r.doc),     target-h: get-font-h("values", "values", h3_5, named, s), min-h: h1_8, max-w: 22mm, max-h: 4.5mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)
  let c-sigs-spec   = compute-group-font(c-rows.filter(r => r.at("sig-size") == auto).map(r => r.sig),     target-h: get-font-h("signs", "signs", h3_5, named, s),   min-h: h1_8, max-w: 14mm, max-h: 4.5mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)
  let c-dates-spec  = compute-group-font(c-rows.filter(r => r.at("date-size") == auto).map(r => r.date),   target-h: get-font-h("dates", "dates", h2_5, named, s),   min-h: h1_8, max-w: 9.5mm, max-h: 4.5mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)

  set table(inset: (x: 0.3mm, y: 0.2mm))

  if not has-toc {
    // Базовая Форма 2 (185 х 40 мм)
    table(
      columns: cols,
      rows: rows,
      align: alignment.center + alignment.horizon,
      stroke: none,

      table.cell(x: 5, y: 0, colspan: 6, rowspan: 3)[#c("code", "code", d-h: h7_0, weight: "bold", wrap-box: true, single-line: true, max-w: 118mm, max-h: 14mm)],
      table.cell(x: 5, y: 3, colspan: 1, rowspan: 5)[#c("name", "name", d-h: h5_0, max-w: 68mm, max-h: 24mm)],
      table.cell(x: 6, y: 5, colspan: 5, rowspan: 3)[#c("org", "org", d-h: h5_0, max-w: 48mm, max-h: 14mm)],

      table.cell(x: 6, y: 3, colspan: 3, rowspan: 1)[#gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Лит.]],
      table.cell(x: 6, y: 4, colspan: 1, rowspan: 1)[#render-lit-cell(lit1, base-h: lit-spec.h, max-w: 4.4mm, max-h: 4.4mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)],
      table.cell(x: 7, y: 4, colspan: 1, rowspan: 1)[#render-lit-cell(lit2, base-h: lit-spec.h, max-w: 4.4mm, max-h: 4.4mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)],
      table.cell(x: 8, y: 4, colspan: 1, rowspan: 1)[#render-lit-cell(lit3, base-h: lit-spec.h, max-w: 4.4mm, max-h: 4.4mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)],

      table.cell(x: 9, y: 3, colspan: 1, rowspan: 1)[
        #if cur-page != [] and (is-multi-page or p-val != auto) {
          gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Лист]
        }
      ],
      table.cell(x: 9, y: 4, colspan: 1, rowspan: 1)[
        #if cur-page != [] and (is-multi-page or p-val != auto) {
          render-group-item(cur-page, sheet-spec, item-size: get-field(named, "sheet", s, default: auto), max-w: 14mm, max-h: 4.0mm, italic: is-it, align-mode: center + horizon, cfg: cfg, ignore-rules: ignore-r)
        }
      ],
      table.cell(x: 10, y: 3, colspan: 1, rowspan: 1)[
        #if total-p != [] {
          gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Листов]
        }
      ],
      table.cell(x: 10, y: 4, colspan: 1, rowspan: 1)[
        #if total-p != [] {
          render-group-item(total-p, sheet-spec, item-size: get-field(named, "sheet", s, default: auto), max-w: 19mm, max-h: 4.0mm, italic: is-it, align-mode: center + horizon, cfg: cfg, ignore-rules: ignore-r)
        }
      ],

      ..range(0, 2).map(i => {
        let r = c-rows.at(i)
        let y-pos = 1 - i
        (
          table.cell(x: 0, y: y-pos)[#render-group-item(r.num, c-nums-spec, item-size: r.at("num-size"), max-w: 6.5mm, max-h: 4.5mm, italic: is-it, align-mode: center + horizon, cfg: cfg, ignore-rules: ignore-r)],
          table.cell(x: 1, y: y-pos)[#render-group-item(r.sheet, c-sheets-spec, item-size: r.at("sheet-size"), max-w: 9.5mm, max-h: 4.5mm, italic: is-it, align-mode: center + horizon, cfg: cfg, ignore-rules: ignore-r)],
          table.cell(x: 2, y: y-pos)[#render-group-item(r.doc, c-docs-spec, item-size: r.at("doc-size"), max-w: 22mm, max-h: 4.5mm, italic: is-it, align-mode: center + horizon, cfg: cfg, ignore-rules: ignore-r)],
          table.cell(x: 3, y: y-pos)[#render-group-item(r.sig, c-sigs-spec, item-size: r.at("sig-size"), max-w: 14mm, max-h: 4.5mm, italic: is-it, align-mode: center + horizon, cfg: cfg, ignore-rules: ignore-r)],
          table.cell(x: 4, y: y-pos)[#render-group-item(r.date, c-dates-spec, item-size: r.at("date-size"), max-w: 9.5mm, max-h: 4.5mm, italic: is-it, align-mode: center + horizon, cfg: cfg, ignore-rules: ignore-r)],
        )
      }).join(),

      table.cell(x: 0, y: 2)[#gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Изм.]],
      table.cell(x: 1, y: 2)[#gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Лист]],
      table.cell(x: 2, y: 2)[#gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[№ докум.]],
      table.cell(x: 3, y: 2)[#gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Подп.]],
      table.cell(x: 4, y: 2)[#gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Дата]],

      ..range(0, 5).map(i => {
        let r = m-rows.at(i)
        let y-pos = 3 + i
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
      table.hline(y: 8, stroke: thick),
      table.vline(x: 0, stroke: thick),
      table.vline(x: 11, stroke: thick),

      table.vline(x: 5, stroke: thick),
      table.hline(y: 3, stroke: thick),
      table.vline(x: 6, start: 3, end: 8, stroke: thick),
      table.vline(x: 9, start: 3, end: 5, stroke: thick),
      table.vline(x: 10, start: 3, end: 5, stroke: thick),
      table.hline(y: 5, start: 6, end: 11, stroke: thick),

      table.hline(y: 2, start: 0, end: 5, stroke: ps),
      table.vline(x: 1, start: 0, end: 3, stroke: ps),
      table.vline(x: 2, start: 0, end: 8, stroke: ps),
      table.vline(x: 3, start: 0, end: 8, stroke: ps),
      table.vline(x: 4, start: 0, end: 8, stroke: ps),

      table.hline(y: 1, start: 0, end: 5, stroke: thin),
      table.hline(y: 4, start: 0, end: 5, stroke: thin),
      table.hline(y: 5, start: 0, end: 5, stroke: thin),
      table.hline(y: 6, start: 0, end: 5, stroke: thin),
      table.hline(y: 7, start: 0, end: 5, stroke: thin),

      table.vline(x: 7, start: 4, end: 5, stroke: thin),
      table.vline(x: 8, start: 4, end: 5, stroke: thin),
      table.hline(y: 4, start: 6, end: 11, stroke: thin),
    )
  } else {
    // Форма 2 с совмещенной шапкой содержания (185 х 52 мм)
    let clean-toc(val) = if val == auto or val == none { [] } else { val }
    let (toc-num, toc-name, toc-code, toc-note) = if type(raw-toc) == dictionary {
      (
        clean-toc(raw-toc.at("num", default: [])),
        clean-toc(raw-toc.at("name", default: [])),
        clean-toc(raw-toc.at("code", default: [])),
        clean-toc(raw-toc.at("note", default: [])),
      )
    } else if type(raw-toc) == array {
      (
        clean-toc(if raw-toc.len() > 0 { raw-toc.at(0) } else { [] }),
        clean-toc(if raw-toc.len() > 1 { raw-toc.at(1) } else { [] }),
        clean-toc(if raw-toc.len() > 2 { raw-toc.at(2) } else { [] }),
        clean-toc(if raw-toc.len() > 3 { raw-toc.at(3) } else { [] }),
      )
    } else {
      ([], [], [], [])
    }

    table(
      columns: cols,
      rows: rows,
      align: alignment.center + alignment.horizon,
      stroke: none,

      table.cell(x: 5, y: 0, colspan: 6, rowspan: 2, inset: 0pt)[
        #table(
          columns: (15mm, 1fr, 35mm), rows: (5mm, 7mm), stroke: none, align: alignment.center + alignment.horizon,
          table.cell()[#auto-fit-gost(toc-num, target-h: h3_5, min-h: h1_8, max-w: 14mm, max-h: 4.5mm, italic: is-it, single-line: true, cfg: cfg, ignore-rules: ignore-r)],
          table.cell()[#auto-fit-gost(toc-name, target-h: h3_5, min-h: h1_8, max-w: 68mm, max-h: 4.5mm, italic: is-it, single-line: true, cfg: cfg, ignore-rules: ignore-r)],
          table.cell()[#auto-fit-gost(toc-code, target-h: h3_5, min-h: h1_8, max-w: 34mm, max-h: 4.5mm, italic: is-it, single-line: true, cfg: cfg, ignore-rules: ignore-r)],
          table.cell(colspan: 3)[#auto-fit-gost(toc-note, target-h: h3_5, min-h: h1_8, max-w: 118mm, max-h: 6.5mm, italic: is-it, single-line: true, cfg: cfg, ignore-rules: ignore-r)],
          table.hline(y: 1, stroke: thick),
          table.vline(x: 1, start: 0, end: 1, stroke: thick),
          table.vline(x: 2, start: 0, end: 1, stroke: thick),
        )
      ],

      table.cell(x: 5, y: 2, rowspan: 3, colspan: 6)[#c("code", "code", d-h: h7_0, weight: "bold", wrap-box: true, single-line: true, max-w: 118mm, max-h: 14mm)],
      table.cell(x: 5, y: 5, rowspan: 5, colspan: 1)[#c("name", "name", d-h: h5_0, max-w: 68mm, max-h: 24mm)],
      table.cell(x: 6, y: 7, rowspan: 3, colspan: 5)[#c("org", "org", d-h: h5_0, max-w: 48mm, max-h: 14mm)],

      table.cell(x: 6, y: 5, rowspan: 1, colspan: 3)[#gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Лит.]],
      table.cell(x: 6, y: 6, rowspan: 1, colspan: 1)[#render-lit-cell(lit1, base-h: lit-spec.h, max-w: 4.4mm, max-h: 4.4mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)],
      table.cell(x: 7, y: 6, rowspan: 1, colspan: 1)[#render-lit-cell(lit2, base-h: lit-spec.h, max-w: 4.4mm, max-h: 4.4mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)],
      table.cell(x: 8, y: 6, rowspan: 1, colspan: 1)[#render-lit-cell(lit3, base-h: lit-spec.h, max-w: 4.4mm, max-h: 4.4mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)],

      table.cell(x: 9, y: 5, rowspan: 1, colspan: 1)[
        #if cur-page != [] and (is-multi-page or p-val != auto) {
          gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Лист]
        }
      ],
      table.cell(x: 9, y: 6, rowspan: 1, colspan: 1)[
        #if cur-page != [] and (is-multi-page or p-val != auto) {
          render-group-item(cur-page, sheet-spec, item-size: get-field(named, "sheet", s, default: auto), max-w: 14mm, max-h: 4.0mm, italic: is-it, align-mode: center + horizon, cfg: cfg, ignore-rules: ignore-r)
        }
      ],
      table.cell(x: 10, y: 5, rowspan: 1, colspan: 1)[
        #if total-p != [] {
          gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Листов]
        }
      ],
      table.cell(x: 10, y: 6, rowspan: 1, colspan: 1)[
        #if total-p != [] {
          render-group-item(total-p, sheet-spec, item-size: get-field(named, "sheet", s, default: auto), max-w: 19mm, max-h: 4.0mm, italic: is-it, align-mode: center + horizon, cfg: cfg, ignore-rules: ignore-r)
        }
      ],

      ..range(0, 2).map(i => {
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

      ..range(0, 5).map(i => {
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

      table.hline(y: 0, start: 5, end: 11, stroke: thick),
      table.hline(y: 2, start: 0, end: 11, stroke: thick),
      table.hline(y: 10, start: 0, end: 11, stroke: thick),
      table.vline(x: 0, start: 2, end: 10, stroke: thick),
      table.vline(x: 11, start: 0, end: 10, stroke: thick),

      table.vline(x: 5, start: 0, end: 10, stroke: thick),
      table.hline(y: 5, start: 0, end: 5, stroke: thick),
      table.hline(y: 5, start: 5, end: 11, stroke: thick),
      table.vline(x: 6, start: 5, end: 10, stroke: thick),
      table.vline(x: 9, start: 5, end: 7, stroke: thick),
      table.vline(x: 10, start: 5, end: 7, stroke: thick),
      table.hline(y: 7, start: 6, end: 11, stroke: thick),

      table.hline(y: 4, start: 0, end: 5, stroke: ps),
      table.vline(x: 1, start: 2, end: 5, stroke: ps),
      table.vline(x: 2, start: 2, end: 10, stroke: ps),
      table.vline(x: 3, start: 2, end: 10, stroke: ps),
      table.vline(x: 4, start: 2, end: 10, stroke: ps),

      table.hline(y: 3, start: 0, end: 5, stroke: thin),
      table.hline(y: 6, start: 0, end: 5, stroke: thin),
      table.hline(y: 7, start: 0, end: 5, stroke: thin),
      table.hline(y: 8, start: 0, end: 5, stroke: thin),
      table.hline(y: 9, start: 0, end: 5, stroke: thin),

      table.vline(x: 7, start: 6, end: 7, stroke: thin),
      table.vline(x: 8, start: 6, end: 7, stroke: thin),
      table.hline(y: 6, start: 6, end: 11, stroke: thin),
    )
  }
}
