// frames-form-2a.typ — Основная надпись для последующих листов (Форма 2а по ГОСТ 2.104-2006)
//
// Габариты: 185 х 15 мм. Последующие листы текстовых и графических документов.
// Включает:
// - Графа 2: Обозначение документа (110 х 15 мм)
// - Графа 7: Лист (ячейка 10 х 15 мм с горизонтальным разделителем: верх 7 мм, низ 8 мм)
// - Графы 14-18: Таблица изменений (колонки 7, 10, 23, 15, 10 мм)

#import "math.typ": *
#import "state.typ": *
#import "validators.typ": *
#import "frames-core.typ": *

/// Форма 2а (185 х 15 мм) — Основная надпись для последующих листов всех видов документов по ГОСТ 2.104-2006.
#let frame-form-2a(..args) = context {
  let cols = (7mm, 10mm, 23mm, 15mm, 10mm, 110mm, 10mm)
  let rows = (5mm, 5mm, 5mm)
  let named = args.named()
  let s = eskd-state.get()
  let ignore-r = if "ignore-rules" in named and named.at("ignore-rules") != auto { named.at("ignore-rules") } else { s.at("ignore-rules", default: auto) }
  if "toc" in named {
    assert-toc-unsupported(named.at("toc"), form-name: "Форме 2а (ГОСТ 2.104-2006)", ignore-rules: ignore-r)
  }
  assert-stamp-geometry(cols, rows, 185mm, 15mm, "Форма 2а (ГОСТ 2.104-2006)", ignore-rules: ignore-r)
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
  let cur-page = if p-val == none { [] } else if p-val != auto { p-val } else { counter(page).display("1") }
  let sheet-target-h = get-font-h("sheet", "sheet", h3_5, named, s)
  let sheet-spec = compute-group-font((cur-page,), target-h: sheet-target-h, min-h: h1_8, max-w: 9.0mm, max-h: 7.0mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)
  let label-h = get-font-h("labels", "labels", h2_5, named, s)

  let raw-changes = get-field(named, "changes", s, default: auto)
  assert-changes-capacity(raw-changes, max-rows: 1, form-name: "Форма 2а", ignore-rules: ignore-r)
  let c-rows = (resolve-change-field(0, named, s),)
  let nums-spec   = compute-group-font(c-rows.filter(r => r.at("num-size") == auto).map(r => r.num),     target-h: get-font-h("values", "values", h3_5, named, s), min-h: h1_8, max-w: 6.5mm, max-h: 4.5mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)
  let sheets-spec = compute-group-font(c-rows.filter(r => r.at("sheet-size") == auto).map(r => r.sheet), target-h: get-font-h("values", "values", h3_5, named, s), min-h: h1_8, max-w: 9.5mm, max-h: 4.5mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)
  let docs-spec   = compute-group-font(c-rows.filter(r => r.at("doc-size") == auto).map(r => r.doc),     target-h: get-font-h("values", "values", h3_5, named, s), min-h: h1_8, max-w: 22mm, max-h: 4.5mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)
  let sigs-spec   = compute-group-font(c-rows.filter(r => r.at("sig-size") == auto).map(r => r.sig),     target-h: get-font-h("signs", "signs", h3_5, named, s),   min-h: h1_8, max-w: 14mm, max-h: 4.5mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)
  let dates-spec  = compute-group-font(c-rows.filter(r => r.at("date-size") == auto).map(r => r.date),   target-h: get-font-h("dates", "dates", h2_5, named, s),   min-h: h1_8, max-w: 9.5mm, max-h: 4.5mm, italic: is-it, cfg: cfg, ignore-rules: ignore-r)
  let ch = c-rows.at(0)

  set table(inset: (x: 0.3mm, y: 0.2mm))

  table(
    columns: cols,
    rows: rows,
    align: alignment.center + alignment.horizon,
    stroke: none,

    table.cell(x: 5, y: 0, rowspan: 3, colspan: 1)[#c("code", "code", d-h: h7_0, weight: "bold", wrap-box: true, single-line: true, max-w: 108mm, max-h: 14mm)],
    table.cell(x: 6, y: 0, rowspan: 3, colspan: 1, inset: 0pt)[
      #if cur-page != [] {
        table(
          columns: (10mm), rows: (7mm, 8mm), align: alignment.center + alignment.horizon, stroke: none,
          table.cell()[#gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Лист]],
          table.cell()[#render-group-item(cur-page, sheet-spec, item-size: get-field(named, "sheet", s, default: auto), max-w: 9.0mm, max-h: 7.0mm, italic: is-it, align-mode: center + horizon, cfg: cfg, ignore-rules: ignore-r)],
          table.hline(y: 1, stroke: thick),
        )
      }
    ],

    table.cell(x: 0, y: 0)[], table.cell(x: 1, y: 0)[], table.cell(x: 2, y: 0)[], table.cell(x: 3, y: 0)[], table.cell(x: 4, y: 0)[],
    table.cell(x: 0, y: 1)[#render-group-item(ch.num, nums-spec, item-size: ch.at("num-size"), max-w: 6.5mm, max-h: 4.5mm, italic: is-it, align-mode: center + horizon, cfg: cfg, ignore-rules: ignore-r)],
    table.cell(x: 1, y: 1)[#render-group-item(ch.sheet, sheets-spec, item-size: ch.at("sheet-size"), max-w: 9.5mm, max-h: 4.5mm, italic: is-it, align-mode: center + horizon, cfg: cfg, ignore-rules: ignore-r)],
    table.cell(x: 2, y: 1)[#render-group-item(ch.doc, docs-spec, item-size: ch.at("doc-size"), max-w: 22mm, max-h: 4.5mm, italic: is-it, align-mode: center + horizon, cfg: cfg, ignore-rules: ignore-r)],
    table.cell(x: 3, y: 1)[#render-group-item(ch.sig, sigs-spec, item-size: ch.at("sig-size"), max-w: 14mm, max-h: 4.5mm, italic: is-it, align-mode: center + horizon, cfg: cfg, ignore-rules: ignore-r)],
    table.cell(x: 4, y: 1)[#render-group-item(ch.date, dates-spec, item-size: ch.at("date-size"), max-w: 9.5mm, max-h: 4.5mm, italic: is-it, align-mode: center + horizon, cfg: cfg, ignore-rules: ignore-r)],

    table.cell(x: 0, y: 2)[#gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Изм.]],
    table.cell(x: 1, y: 2)[#gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Лист]],
    table.cell(x: 2, y: 2)[#gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[№ докум.]],
    table.cell(x: 3, y: 2)[#gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Подп.]],
    table.cell(x: 4, y: 2)[#gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Дата]],

    table.hline(y: 0, stroke: thick),
    table.hline(y: 3, stroke: thick),
    table.vline(x: 0, stroke: thick),
    table.vline(x: 5, stroke: thick),
    table.vline(x: 6, stroke: thick),
    table.vline(x: 7, stroke: thick),

    table.hline(y: 2, start: 0, end: 5, stroke: ps),
    ..range(1, 5).map(n => table.vline(x: n, start: 0, end: 3, stroke: ps)),

    table.hline(y: 1, start: 0, end: 5, stroke: thin),
  )
}
