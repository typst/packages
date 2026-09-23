// frames-border.typ — Внешняя рамка листа и повернутое обозначение документа (ГОСТ 2.104-2006, п. 4.1)
//
// Поля листа по ГОСТ 2.104-2006:
// - Слева: 20 мм (поле для подшивки).
// - Сверху, справа, снизу: по 5 мм.
//
// Графа 26 — Обозначение документа, повернутое на 180°:
// - Размеры: 70 х 14 мм.
// - Расположение: в левом верхнем углу внешней рамки (dx: 20 мм, dy: 5 мм).

#import "math.typ": *
#import "state.typ": *
#import "validators.typ": *
#import "frames-core.typ": *

/// Обозначение документа, повернутое на 180° в верхнем левом углу внешней рамки (Графа 26 ГОСТ 2.104-2006).
///
/// Размеры ячейки: 70 х 14 мм.
/// Рамка ячейки рисуется сплошной толстой линией (0.8 мм), если `frame` не равен `false` или `none`.
///
/// - ..args: Именованные параметры (text, frame, size, min-size, font-cfg).
#let frame-code-inverted(..args) = context {
  let s = eskd-state.get()
  let named = args.named()
  let cfg = resolve-font-cfg(font: named.at("font", default: auto), font-type: named.at("font-type", default: auto), font-group: named.at("font-group", default: auto), font-cfg: named.at("font-cfg", default: s.at("font-cfg", default: gost-fonts.at("type-b"))))
  let is-it = if "font-italic" in named and named.at("font-italic") != auto { named.at("font-italic") == true } else { s.at("font-italic", default: false) == true }
  let ignore-r = s.at("ignore-rules", default: auto)

  let custom-text = named.at("text", default: auto)
  let code = if custom-text != auto and custom-text != none {
    custom-text
  } else {
    get-field(named, "code", s, default: [])
  }

  let draw-frame = named.at("frame", default: true)
  let border-stroke = if draw-frame == false or draw-frame == none { none } else { thick + black }

  let target-h = named.at("size", default: auto)
  let resolved-target-h = if target-h != auto and target-h != none { target-h } else { h5_0 }
  let min-h-val = named.at("min-size", default: auto)
  let resolved-min-h = if min-h-val != auto and min-h-val != none { min-h-val } else { h2_5 }

  place(
    alignment.top + alignment.left,
    dx: 20mm,
    dy: 5mm,
    rect(
      width: 70mm,
      height: 14mm,
      stroke: border-stroke,
      outset: 0pt,
      inset: 0pt,
      align(center + horizon)[
        #rotate(180deg)[
          #auto-fit-gost(
            code,
            target-h: resolved-target-h,
            min-h: resolved-min-h,
            max-w: 66mm,
            max-h: 12mm,
            weight: "bold",
            italic: is-it,
            single-line: true,
            cfg: cfg,
            ignore-rules: ignore-r,
          )
        ]
      ]
    )
  )
}

/// Внешняя рабочая рамка листа по ГОСТ 2.104-2006 (п. 4.1).
/// Выполняется сплошной толстой линией (s = 0.8 мм) с отступами 20 мм слева и по 5 мм с остальных сторон.
#let frame-border = place(
  alignment.top + alignment.left,
  dx: 20mm,
  dy: 5mm,
  rect(
    width: 100% - 25mm,
    height: 100% - 10mm,
    stroke: thick + black,
    outset: 0pt,
  )
)