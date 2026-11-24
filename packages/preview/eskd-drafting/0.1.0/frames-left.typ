// frames-left.typ — Боковые штампы инвентарного учета (ГОСТ 2.104-2006)
//
// Размещаются на левом поле подшивки (20 мм от левого края) с поворотом на -90°:
// - Графа 19: «Инв. № подп.» (инвентарный номер подлинника).
// - Графа 20: «Подп. и дата» (подпись лица, принявшего документ, и дата).
// - Графа 21: «Взам. инв. №» (взамен инвентарного номера).
// - Графа 22: «Инв. № дубл.» (инвентарный номер дубликата).
// - Графа 23: «Подп. и дата» (подпись и дата дубликата).
// - Графа 24: «Справ. №» (справочный номер).
// - Графа 25: «Перв. примен.» (первичное применение).
//
// Виды боковых штампов:
// 1. frame-left-3r (85 х 12 мм) — графы 19-21 (короткий штамп).
// 2. frame-left-5r (145 х 12 мм) — графы 19-23 (стандартный для большинства листов).
// 3. frame-left-7r (287 х 12 мм) — графы 19-25 (полная высота листа А4 с разрывом 47 мм).

#import "math.typ": *
#import "state.typ": *
#import "validators.typ": *
#import "frames-core.typ": *

/// Боковой штамп инвентарного учета на 3 графы (85 х 12 мм, графы 19-21).
///
/// - ..args: Дополнительные параметры (font-cfg, индивидуальные размеры).
#let frame-left-3r(..args) = context {
  let cols = (25mm, 35mm, 25mm)
  let rows = (5mm, 7mm)
  let s = eskd-state.get()
  let ignore-r = s.at("ignore-rules", default: auto)
  assert-stamp-geometry(cols, rows, 85mm, 12mm, "Боковой штамп 3r (ГОСТ 2.104)", ignore-rules: ignore-r)
  assert-line-thicknesses(thick, thin, ignore-rules: ignore-r)

  let named = args.named()
  let cfg = resolve-font-cfg(font: named.at("font", default: auto), font-type: named.at("font-type", default: auto), font-group: named.at("font-group", default: auto), font-cfg: named.at("font-cfg", default: s.at("font-cfg", default: gost-fonts.at("type-b"))))
  let is-it = if "font-italic" in named and named.at("font-italic") != auto { named.at("font-italic") == true } else { s.at("font-italic", default: false) == true }
  let c(k, grp, d-val: [], d-h: h3_5, max-w: none, max-h: none) = render-cell(
    k, grp, default-val: d-val, default-h: d-h, italic: is-it, max-w: max-w, max-h: max-h,
    named-args: named, state-dict: s, cfg: cfg
  )

  let label-h = get-font-h("labels", "labels", h2_5, named, s)

  set table(inset: (x: 0.3mm, y: 0.2mm))
  rotate(-90deg, reflow: true,
    table(
      columns: cols,
      rows: rows,
      align: alignment.center + alignment.horizon,
      stroke: none,
      // Заголовки граф (высота h = 2.5 мм)
      gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Инв. № подп.],
      gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Подп. и дата],
      gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Взам. инв. №],
      // Значения граф (высота h = 3.5 мм)
      c("inv-orig", "values", d-h: h3_5, max-w: 24mm, max-h: 6.5mm),
      c("sig-date-orig", "signs", d-h: h3_5, max-w: 34mm, max-h: 6.5mm),
      c("inv-repl", "values", d-h: h3_5, max-w: 24mm, max-h: 6.5mm),

      // Ограничивающие и разделительные линии (сплошная толстая 0.8 мм)
      table.hline(y: 0, stroke: thick),
      table.hline(y: 1, stroke: thick),
      table.hline(y: 2, stroke: thick),
      table.vline(x: 0, stroke: thick),
      table.vline(x: 1, stroke: thick),
      table.vline(x: 2, stroke: thick),
      table.vline(x: 3, stroke: thick),
    )
  )
}

/// Боковой штамп инвентарного учета на 5 граф (145 х 12 мм, графы 19-23).
/// Стандартный боковой штамп по ГОСТ 2.104-2006 для большинства конструкторских документов.
///
/// - ..args: Дополнительные параметры (font-cfg, индивидуальные размеры).
#let frame-left-5r(..args) = context {
  let cols = (25mm, 35mm, 25mm, 25mm, 35mm)
  let rows = (5mm, 7mm)
  let s = eskd-state.get()
  let ignore-r = s.at("ignore-rules", default: auto)
  assert-stamp-geometry(cols, rows, 145mm, 12mm, "Боковой штамп 5r (ГОСТ 2.104)", ignore-rules: ignore-r)
  assert-line-thicknesses(thick, thin, ignore-rules: ignore-r)

  let named = args.named()
  let cfg = resolve-font-cfg(font: named.at("font", default: auto), font-type: named.at("font-type", default: auto), font-group: named.at("font-group", default: auto), font-cfg: named.at("font-cfg", default: s.at("font-cfg", default: gost-fonts.at("type-b"))))
  let is-it = if "font-italic" in named and named.at("font-italic") != auto { named.at("font-italic") == true } else { s.at("font-italic", default: false) == true }
  let label-h = get-font-h("labels", "labels", h2_5, named, s)
  let c(k, grp, d-val: [], d-h: h3_5, max-w: none, max-h: none) = render-cell(
    k, grp, default-val: d-val, default-h: d-h, italic: is-it, max-w: max-w, max-h: max-h,
    named-args: named, state-dict: s, cfg: cfg
  )

  set table(inset: (x: 0.3mm, y: 0.2mm))
  rotate(-90deg, reflow: true,
    table(
      columns: cols,
      rows: rows,
      align: alignment.center + alignment.horizon,
      stroke: none,
      // Заголовки граф (h = 2.5 мм)
      gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Инв. № подп.],
      gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Подп. и дата],
      gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Взам. инв. №],
      gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Инв. № дубл.],
      gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Подп. и дата],
      // Значения граф (h = 3.5 мм)
      c("inv-orig", "values", d-h: h3_5, max-w: 24mm, max-h: 6.5mm),
      c("sig-date-orig", "signs", d-h: h3_5, max-w: 34mm, max-h: 6.5mm),
      c("inv-repl", "values", d-h: h3_5, max-w: 24mm, max-h: 6.5mm),
      c("inv-dup", "values", d-h: h3_5, max-w: 24mm, max-h: 6.5mm),
      c("sig-date-dup", "signs", d-h: h3_5, max-w: 34mm, max-h: 6.5mm),

      // Ограничивающие и разделительные линии (сплошная толстая 0.8 мм)
      table.hline(y: 0, stroke: thick),
      table.hline(y: 1, stroke: thick),
      table.hline(y: 2, stroke: thick),
      ..range(0, 6).map(n => table.vline(x: n, stroke: thick)),
    )
  )
}

/// Боковой штамп инвентарного учета (графы 19-25 по ГОСТ 2.104-2006).
/// Включает нижний блок (графы 19-23, 145 мм) и верхний блок (графа 24 «Справ. №», 35 мм и графа 25 «Перв. примен.», 60 мм).
///
/// Параметр `gap`:
/// - `auto`: фиксированный интервал 47 мм (по умолчанию). Все 7 граф укладываются в базовые 287 мм высоты от низа листа,
///   что строго соответствует правилам фальцовки чертежей по ГОСТ 2.501-2013 для подшивки в папки формата А4.
/// - `"max"`: максимально возможный интервал (H_frame - 240 мм), при котором графы 24 и 25 примыкают к противоположному (верхнему) углу листа.
/// - length (например, 47mm, 100mm): явная величина разрыва.
/// - none: без разрыва (0 мм).
///
/// - ..args: Дополнительные параметры (paper, orientation, gap, font-cfg, индивидуальные размеры).
#let frame-left-7r(..args) = context {
  let named = args.named()
  let s = eskd-state.get()
  let ignore-r = s.at("ignore-rules", default: auto)

  let paper = get-field(named, "paper", s, default: "a4")
  let orientation = get-field(named, "orientation", s, default: "portrait")

  let (page-w, page-h) = get-paper-dimensions(paper, orientation)
  let frame-h = page-h - 10mm
  let gap-arg = named.at("gap", default: auto)
  let gap = if gap-arg == "max" {
    calc.max(0mm, frame-h - 240mm)
  } else if gap-arg == auto {
    47mm
  } else if gap-arg == none {
    0mm
  } else {
    gap-arg
  }

  let cols = (25mm, 35mm, 25mm, 25mm, 35mm, gap, 35mm, 60mm)
  let rows = (5mm, 7mm)
  let total-w = cols.fold(0mm, (acc, w) => acc + w)

  assert-stamp-geometry(cols, rows, total-w, 12mm, "Боковой штамп 7r (ГОСТ 2.104)", ignore-rules: ignore-r)
  assert-line-thicknesses(thick, thin, ignore-rules: ignore-r)

  let cfg = resolve-font-cfg(font: named.at("font", default: auto), font-type: named.at("font-type", default: auto), font-group: named.at("font-group", default: auto), font-cfg: named.at("font-cfg", default: s.at("font-cfg", default: gost-fonts.at("type-b"))))
  let is-it = if "font-italic" in named and named.at("font-italic") != auto { named.at("font-italic") == true } else { s.at("font-italic", default: false) == true }
  let label-h = get-font-h("labels", "labels", h2_5, named, s)
  let c(k, grp, d-val: [], d-h: h3_5, max-w: none, max-h: none) = render-cell(
    k, grp, default-val: d-val, default-h: d-h, italic: is-it, max-w: max-w, max-h: max-h,
    named-args: named, state-dict: s, cfg: cfg
  )

  set table(inset: (x: 0.3mm, y: 0.2mm))
  rotate(-90deg, reflow: true,
    table(
      columns: cols,
      rows: rows,
      align: alignment.center + alignment.horizon,
      stroke: none,
      // Заголовки граф (h = 2.5 мм)
      gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Инв. № подп.],
      gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Подп. и дата],
      gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Взам. инв. №],
      gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Инв. № дубл.],
      gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Подп. и дата],
      table.cell(rowspan: 2)[], // Разрыв 47 мм
      gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Справ. №],
      gost-text(h: label-h, cfg: cfg, italic: is-it, ignore-rules: ignore-r)[Перв. примен.],

      // Значения граф (h = 3.5 мм)
      c("inv-orig", "values", d-h: h3_5, max-w: 24mm, max-h: 6.5mm),
      c("sig-date-orig", "signs", d-h: h3_5, max-w: 34mm, max-h: 6.5mm),
      c("inv-repl", "values", d-h: h3_5, max-w: 24mm, max-h: 6.5mm),
      c("inv-dup", "values", d-h: h3_5, max-w: 24mm, max-h: 6.5mm),
      c("sig-date-dup", "signs", d-h: h3_5, max-w: 34mm, max-h: 6.5mm),
      c("ref-num", "values", d-h: h3_5, max-w: 34mm, max-h: 6.5mm),
      c("prim-apply", "values", d-h: h3_5, max-w: 59mm, max-h: 6.5mm),

      // Линии левой секции (графы 19-23)
      table.hline(y: 0, start: 0, end: 5, stroke: thick),
      table.hline(y: 1, start: 0, end: 5, stroke: thick),
      table.hline(y: 2, start: 0, end: 5, stroke: thick),
      ..range(0, 6).map(n => table.vline(x: n, stroke: thick)),

      // Линии правой секции (графы 24-25)
      table.hline(y: 0, start: 6, end: 8, stroke: thick),
      table.hline(y: 1, start: 6, end: 8, stroke: thick),
      table.hline(y: 2, start: 6, end: 8, stroke: thick),
      ..range(6, 9).map(n => table.vline(x: n, stroke: thick)),
    )
  )
}