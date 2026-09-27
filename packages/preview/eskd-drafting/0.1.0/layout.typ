// layout.typ — Менеджер страниц, штампов и раскладки по ГОСТ 2.104-2006
//
// Модуль организует сквозную или посекционную верстку ЕСКД-документов:
// - Базовое нижнее поле страницы — 25 мм (под последующий штамп 15 мм + 10 мм зазор).
// - На первой странице секции автоматически вставляется плавающий спейсер (h-diff)
//   для компенсации разницы высот заглавного (40/52/55 мм) и последующего (15 мм) штампов.
// - Смена секций маркируется метаданными `<eskd-drafting-sec-marker>`.

#import "math.typ": *
#import "state.typ": *
#import "validators.typ": *
#import "frames-core.typ": *
#import "frames-border.typ": *
#import "frames-left.typ": *
#import "frames-form-1.typ": *
#import "frames-form-2.typ": *
#import "frames-form-2a.typ": *
#import "frames-form-2b.typ": *

/// Создает новую секцию страниц с заданной комбинацией штампов и полей.
///
/// - paper (str, auto): Формат листа ("a4", "a3", "a2", "a1", "a0", "a4x3" и т.д.).
/// - orientation (str, auto): Ориентация ("portrait" или "landscape").
/// - bottom (function, none, auto): Основная надпись первого листа секции (по умолчанию Form 2a).
/// - left (function, none, auto): Левый боковой штамп первого листа (по умолчанию Left 5r).
/// - subsequent-bottom (function, none, auto): Основная надпись последующих листов (автовыбор Form 2a).
/// - subsequent-left (function, none, auto): Боковой штамп последующих листов (автовыбор Left 5r).
/// - frame (bool): Отображать внешнюю рабочую рамку листа.
/// - margin-bottom (length, auto): Пользовательское нижнее поле страницы.
/// - ..page-props: Дополнительные локальные свойства секции (например, code-inverted).
/// - body (content): Содержимое страниц секции.
#let eskd-page(
  paper: auto,
  orientation: auto,
  bottom: frame-form-2a,
  left: frame-left-5r,
  subsequent-bottom: auto,
  subsequent-left: auto,
  frame: true,
  margin-bottom: auto,
  ..page-props,
  body
) = {
  pagebreak(weak: true)

  // Автоматический выбор штампов для последующих листов
  let sub-bottom = if subsequent-bottom != auto {
    subsequent-bottom
  } else if bottom == frame-form-2 or bottom == frame-form-1 {
    frame-form-2a
  } else {
    bottom
  }

  let sub-left = if subsequent-left != auto {
    subsequent-left
  } else if left == frame-left-7r {
    frame-left-5r
  } else {
    left
  }

  let render-element(el, props-dict) = {
    if el == none or el == "none" {
      none
    } else if type(el) == function {
      el(..props-dict)
    } else {
      el
    }
  }

  let named-props = page-props.named()

  [#metadata((
    bottom: bottom,
    left: left,
    "sub-bottom": sub-bottom,
    "sub-left": sub-left,
    frame: frame,
    paper: paper,
    orientation: orientation,
    props: named-props,
  )) <eskd-drafting-sec-marker>]

  let calc-bottom = if margin-bottom != auto {
    margin-bottom
  } else {
    25mm
  }

  let page-bg = context {
    let s = eskd-state.get()
    let cur-page = here().page()

    let markers = query(selector(<eskd-drafting-sec-marker>)).filter(m => m.location().page() <= cur-page)
    if markers.len() > 0 {
      let m = markers.last()
      let is-first = (cur-page == m.location().page())
      let active-bottom = if is-first { m.value.bottom } else { m.value.at("sub-bottom") }
      let active-left = if is-first { m.value.left } else { m.value.at("sub-left") }
      let show-fr = m.value.frame

      // 1. Внешняя рамка листа (ГОСТ 2.104-2006 п. 4.1)
      if show-fr {
        frame-border
      }

      // 2. Повернутое обозначение в верхнем левом углу (Графа 26 ГОСТ 2.104-2006)
      let page-inv-arg = m.value.props.at("code-inverted", default: m.value.at("code-inverted", default: auto))
      let state-inv-arg = s.at("code-inverted", default: auto)
      let code-val = get-field(m.value.props, "code", s, default: [])
      let is-drawing-form = (active-bottom == frame-form-1)
      let inv-spec = resolve-code-inverted(
        page-inv-arg,
        state-inv-arg,
        code-val,
        is-drawing: is-drawing-form,
      )

      if show-fr and inv-spec.show {
        frame-code-inverted(
          text: inv-spec.text,
          frame: inv-spec.frame,
          size: inv-spec.size,
          min-size: inv-spec.at("min-size", default: auto),
          font-cfg: s.at("font-cfg", default: gost-fonts.at("type-b")),
          ..m.value.props,
        )
      }

      // 3. Левый боковой штамп инвентарного учета (графы 19-25)
      let active-paper = if m.value.paper != auto { m.value.paper } else { s.paper }
      let parsed-active-paper = parse-gost-paper(active-paper)
      let active-orient = if m.value.orientation != auto {
        m.value.orientation
      } else if parsed-active-paper.is-multiplied {
        "landscape"
      } else {
        s.orientation
      }
      let active-ignore = m.value.props.at("ignore-rules", default: s.at("ignore-rules", default: auto))
      assert-paper-format(active-paper, active-orient, ignore-rules: active-ignore)
      let left-props = (paper: active-paper, orientation: active-orient, ..m.value.props)

      if active-left != none {
        place(alignment.bottom + alignment.left, dx: 8mm, dy: -5mm, render-element(active-left, left-props))
      }

      // 4. Основная надпись (в правом нижнем углу листа)
      if active-bottom != none {
        let bottom-props = if is-first {
          m.value.props
        } else {
          let p = m.value.props
          let _ = p.remove("toc", default: none)
          p
        }
        place(alignment.bottom + alignment.right, dx: -5mm, dy: -5mm, render-element(active-bottom, bottom-props))
      }

      // 5. Графы 31 и 32 («Копировал» и «Формат» под внешней рамкой по ГОСТ 2.104-2006)
      let parsed-fmt = parse-gost-paper(active-paper)
      let default-fmt-str = parsed-fmt.display-name
      let is-it = if "font-italic" in s and s.at("font-italic") != auto { s.at("font-italic") == true } else { false }

      let raw-copier = if "copier" in m.value.props and m.value.props.at("copier") != auto {
        m.value.props.at("copier")
      } else if "copier" in s and s.at("copier") != auto {
        s.at("copier")
      } else {
        auto
      }

      let raw-format = if "format" in m.value.props and m.value.props.at("format") != auto {
        m.value.props.at("format")
      } else if "format" in s and s.at("format") != auto {
        s.at("format")
      } else {
        auto
      }

      // Запрет boolean (true/false) для copier
      assert(type(raw-copier) != bool, message: "Значение copier не может быть boolean (true/false). Допустимые значения: auto, none, str, content или dict.")

      // Статус отображения граф 31 и 32
      let has-copier = if raw-copier == none or (type(raw-copier) == dictionary and raw-copier.at("show", default: true) == false) {
        false
      } else {
        true
      }

      let has-format = if raw-format == none or raw-format == false or (type(raw-format) == dictionary and raw-format.at("show", default: true) == false) {
        false
      } else {
        true
      }

      // Извлечение значений и кеглей шрифта
      let (copier-val, copier-h) = if type(raw-copier) == dictionary {
        let c-text = raw-copier.at("text", default: [])
        let c-size = raw-copier.at("size", default: h2_5)
        (c-text, c-size)
      } else if raw-copier == auto {
        ([], h2_5)
      } else if raw-copier != none {
        (raw-copier, h2_5)
      } else {
        ([], h2_5)
      }

      let (format-val, format-h) = if type(raw-format) == dictionary {
        let f-text = raw-format.at("text", default: default-fmt-str)
        let f-size = raw-format.at("size", default: h2_5)
        (f-text, f-size)
      } else if raw-format == true or raw-format == auto {
        (default-fmt-str, h2_5)
      } else if raw-format != none and raw-format != false {
        (raw-format, h2_5)
      } else {
        (default-fmt-str, h2_5)
      }

      if show-fr and (has-copier or has-format) {
        place(
          alignment.bottom + alignment.right,
          dx: -5mm,
          dy: -1.2mm,
          box(width: 185mm)[
            #grid(
              columns: (120mm, 65mm),
              align: (
                alignment.left + alignment.horizon,
                alignment.right + alignment.horizon,
              ),
              // Графа 31 («Копировал») — 120 мм
              if has-copier {
                let copier-text = if copier-val == [] {
                  [Копировал]
                } else {
                  [Копировал #copier-val]
                }
                gost-text(h: copier-h, cfg: s.at("font-cfg", default: gost-fonts.at("type-b")), italic: is-it, ignore-rules: s.at("ignore-rules", default: auto))[#copier-text]
              } else { [] },
              // Графа 32 («Формат») — 65 мм
              if has-format {
                let format-text = if format-val == [] {
                  [Формат]
                } else {
                  [Формат #format-val]
                }
                gost-text(h: format-h, cfg: s.at("font-cfg", default: gost-fonts.at("type-b")), italic: is-it, ignore-rules: s.at("ignore-rules", default: auto))[#format-text]
              } else { [] },
            )
          ]
        )
      }
    }
  }

  let page-kwargs = (
    margin: (
      left: 25mm,
      right: 10mm,
      top: 15mm,
      bottom: calc-bottom,
    ),
    background: page-bg,
  )

  if paper != auto {
    let parsed = parse-gost-paper(paper)
    if parsed.ok and parsed.is-multiplied {
      let is-portrait = (orientation == "portrait")
      page-kwargs.insert("width", if is-portrait { parsed.height } else { parsed.width })
      page-kwargs.insert("height", if is-portrait { parsed.width } else { parsed.height })
    } else if parsed.ok {
      page-kwargs.insert("paper", parsed.key)
      if orientation != auto {
        page-kwargs.insert("flipped", orientation == "landscape")
      }
    } else if type(paper) == str {
      page-kwargs.insert("paper", paper)
      if orientation != auto {
        page-kwargs.insert("flipped", orientation == "landscape")
      }
    }
  } else {
    if orientation != auto {
      page-kwargs.insert("flipped", orientation == "landscape")
    }
  }

  set page(..page-kwargs)

  // Плавающий спейсер на первой странице блока для компенсации разницы высот штампов
  context {
    let s = eskd-state.get()
    let cur-page = here().page()
    let markers = query(selector(<eskd-drafting-sec-marker>)).filter(m => m.location().page() <= cur-page)
    if markers.len() > 0 {
      let m = markers.last()
      let is-first = (cur-page == m.location().page())
      if is-first {
        let h-diff = if m.value.bottom == frame-form-1 {
          40mm
        } else if m.value.bottom == frame-form-2 {
          let raw-toc = m.value.props.at("toc", default: none)
          if is-toc-active(raw-toc) {
            37mm
          } else {
            25mm
          }
        } else {
          0mm
        }
        if h-diff > 0mm {
          place(alignment.bottom, float: true, clearance: 0pt, block(height: h-diff, width: 0pt))
        }
      }
    }
  }

  body
}

// Готовые пресеты секций страниц

/// Титульный лист: рамка и боковой штамп без основной надписи (bottom: none).
#let page-title(paper: auto, orientation: auto, left: frame-left-5r, frame: true, ..props, body) = eskd-page(
  paper: paper,
  orientation: orientation,
  bottom: none,
  left: left,
  frame: frame,
  margin-bottom: 15mm,
  ..props,
  body
)

/// Первый лист текстового документа (Форма 2, 40 мм или 52 мм при передаче `toc`).
#let page-first-form2(paper: auto, orientation: auto, left: frame-left-5r, subsequent-left: frame-left-5r, frame: true, ..props, body) = eskd-page(
  paper: paper,
  orientation: orientation,
  bottom: frame-form-2,
  left: left,
  subsequent-bottom: frame-form-2a,
  subsequent-left: subsequent-left,
  frame: frame,
  ..props,
  body
)

/// Первый лист чертежа или схемы (Форма 1, 55 мм).
#let page-first-form1(paper: auto, orientation: auto, left: frame-left-5r, subsequent-left: frame-left-5r, frame: true, ..props, body) = eskd-page(
  paper: paper,
  orientation: orientation,
  bottom: frame-form-1,
  left: left,
  subsequent-bottom: frame-form-2a,
  subsequent-left: subsequent-left,
  frame: frame,
  ..props,
  body
)

/// Последующие листы документа (Форма 2а, 15 мм).
#let page-body(paper: auto, orientation: auto, left: frame-left-5r, frame: true, ..props, body) = eskd-page(
  paper: paper,
  orientation: orientation,
  bottom: frame-form-2a,
  left: left,
  subsequent-bottom: frame-form-2a,
  subsequent-left: left,
  frame: frame,
  ..props,
  body
)

/// Последующие листы при двусторонней печати (зеркальная Форма 2б, 15 мм).
#let page-body-double(paper: auto, orientation: auto, left: frame-left-5r, frame: true, ..props, body) = eskd-page(
  paper: paper,
  orientation: orientation,
  bottom: frame-form-2b,
  left: left,
  subsequent-bottom: frame-form-2b,
  subsequent-left: left,
  frame: frame,
  ..props,
  body
)

/// Пустой чистый лист без штампов и рамки (для вкладышей и обложек).
#let page-blank(paper: auto, orientation: auto, ..props, body) = eskd-page(
  paper: paper,
  orientation: orientation,
  bottom: none,
  left: none,
  frame: false,
  margin-bottom: 15mm,
  ..props,
  body
)

/// Корневая функция инициализации и оформления документа ЕСКД.
///
/// Устанавливает глобальные свойства (формат, ориентацию, шрифты, правила ЕСКД)
/// и применяет базовые параметры страницы Typst.
///
/// - paper (str): Формат бумаги ("a4", "a3" и др., по умолчанию "a4").
/// - orientation (str): Ориентация ("portrait" или "landscape").
/// - font (str, array, dictionary, auto, none): Пользовательский шрифт для документа.
/// - font-type (str, auto): Тип начертания по ГОСТ 2.304 ("type-b" или "type-a").
/// - font-italic (bool, auto): Наклонное начертание шрифта около 75° по ГОСТ 2.304-81.
/// - font-cfg (dictionary, auto): Готовая конфигурация шрифта.
/// - ignore-rules (array, str, bool, none, auto): Правила для подавления валидации.
/// - preset-lines (str): Пресет линий ("industry" или "gost").
/// - members (array): Список участников документа.
/// - ..args: Дополнительные параметры реквизитов изделия и штампов.
/// - body (content): Содержимое документа.
#let eskd-document(
  paper: "a4",
  orientation: auto,
  font: auto,
  font-type: auto,
  font-group: auto,
  font-italic: auto,
  font-cfg: auto,
  ignore-rules: auto,
  preset-lines: "industry",
  members: (),
  ..args,
  body,
) = {
  let named = args.named()

  let doc-paper = named.at("paper", default: paper)
  let parsed-doc = parse-gost-paper(doc-paper)
  let def-doc-orient = if parsed-doc.is-multiplied {
    "landscape"
  } else if doc-paper == "a4" {
    "portrait"
  } else {
    "landscape"
  }
  let raw-orient = named.at("orientation", default: orientation)
  let doc-orient = if raw-orient == auto { def-doc-orient } else { raw-orient }
  let doc-ignore = named.at("ignore-rules", default: ignore-rules)
  let doc-preset = named.at("preset-lines", default: preset-lines)

  assert-paper-format(doc-paper, doc-orient, ignore-rules: doc-ignore)
  assert-preset-lines(doc-preset, ignore-rules: doc-ignore)

  let init-dict = (
    paper: doc-paper,
    orientation: doc-orient,
    "ignore-rules": doc-ignore,
    "preset-lines": doc-preset,
    font: if "font" in named { named.font } else { font },
    "font-type": if "font-type" in named { named.at("font-type") } else { font-type },
    "font-group": if "font-group" in named { named.at("font-group") } else { font-group },
    "font-italic": if "font-italic" in named { named.at("font-italic") } else { font-italic },
    members: if "members" in named { named.members } else { members },
  )

  if font-cfg != auto and font-cfg != none {
    init-dict.insert("font-cfg", font-cfg)
  }

  eskd-init(..init-dict, ..args)

  if parsed-doc.ok and parsed-doc.is-multiplied {
    let is-portrait = (doc-orient == "portrait")
    set page(
      width: if is-portrait { parsed-doc.height } else { parsed-doc.width },
      height: if is-portrait { parsed-doc.width } else { parsed-doc.height },
    )
    body
  } else if parsed-doc.ok {
    set page(
      paper: parsed-doc.key,
      flipped: doc-orient == "landscape",
    )
    body
  } else {
    set page(
      paper: doc-paper,
      flipped: doc-orient == "landscape",
    )
    body
  }
}
