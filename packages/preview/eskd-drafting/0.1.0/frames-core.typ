// frames-core.typ — Ядро типографики штампов, расчет шрифтов и общие стили
//
// Модуль содержит базовые примитивы построения таблиц штампов по ГОСТ 2.104-2006:
// - Толщины линий по ГОСТ 2.303-68: thick (0.8 мм) и thin (0.35 мм).
// - Дискретная автоподгонка кегля auto-fit-gost по ряду высот ГОСТ 2.304-81.
// - Гармонизация шрифтов участников документа compute-group-font.
// - Унифицированные парсеры параметров повернутого обозначения (code-inverted), изменений (changes) и участников (members).

#import "math.typ": *
#import "state.typ": *
#import "validators.typ": *

/// Толщина основной сплошной линии по ГОСТ 2.303-68 (s = 0.8 мм)
#let thick = 0.8mm

/// Толщина сплошной тонкой линии по ГОСТ 2.303-68 (s_thin = 0.35 мм)
#let thin = 0.35mm

/// Стандартный внутренний отступ для текстовых ячеек с выравниванием по левому краю
#let text-inset-left = (left: 1.0mm, right: 0.3mm, y: 0.2mm)

/// Извлекает значение поля с каскадным поиском: локальные аргументы -> глобальное состояние -> значение по умолчанию.
/// Поддерживает как простые типы (content, str, int, float), так и словари `(text: ..., val: ..., value: ...)`.
///
/// - args (arguments, dictionary): Локальные именованные аргументы вызова.
/// - key (str): Ключ искомого параметра.
/// - state-dict (dictionary): Словарь глобального состояния eskd-state.
/// - default (any): Значение по умолчанию, если ключ не задан или равен `auto`.
/// -> any: Итоговое значение параметра.
#let get-field(args, key, state-dict, default: []) = {
  let dict = if type(args) == arguments { args.named() } else if type(args) == dictionary { args } else { (:) }
  let s-dict = if type(state-dict) == dictionary { state-dict } else { (:) }

  let raw = if key in dict and dict.at(key) != auto {
    dict.at(key)
  } else if key in s-dict and s-dict.at(key) != auto {
    s-dict.at(key)
  } else {
    default
  }

  if raw == none {
    return none
  }

  if type(raw) == dictionary {
    if "text" in raw {
      raw.text
    } else {
      raw
    }
  } else {
    raw
  }
}

/// Определяет толщину разделительной линии штампа на основе пресета preset-lines.
/// "industry" (САПР-стандарт) -> thick (0.8 мм), "gost" (буквальный ГОСТ) -> thin (0.35 мм).
///
/// - args (arguments, dictionary): Локальные аргументы.
/// - state-dict (dictionary): Глобальное состояние.
/// -> length: Толщина линии.
#let preset-stroke(args, state-dict) = {
  let p = get-field(args, "preset-lines", state-dict, default: "industry")
  let p-str = plain-text(p).trim()
  if p-str == "industry" { thick } else { thin }
}

/// Определяет номинальную высоту шрифта h для конкретной ячейки или группы ячеек.
/// Поддерживает словари полей `(size: ...)` и словарь `sizes: (...)`.
///
/// - field-key (str): Имя конкретного поля (например, "code", "name").
/// - group-key (str): Имя группы полей (например, "labels", "values").
/// - default-h (length): Высота по умолчанию.
/// - named-args (dictionary): Локальные параметры.
/// - state-dict (dictionary): Глобальное состояние.
/// -> length: Высота шрифта h.
#let get-font-h(field-key, group-key, default-h, named-args, state-dict) = {
  let dict = if type(named-args) == arguments { named-args.named() } else if type(named-args) == dictionary { named-args } else { (:) }
  let s-dict = if type(state-dict) == dictionary { state-dict } else { (:) }
  let ignore-r = if type(s-dict) == dictionary { s-dict.at("ignore-rules", default: auto) } else { auto }

  // 1. Проверка поля field-key, если оно задано как dict (size: ...)
  let val-named = dict.at(field-key, default: auto)
  let val-state = s-dict.at(field-key, default: auto)
  let specific-size = if type(val-named) == dictionary and "size" in val-named and val-named.size != auto and val-named.size != none {
    val-named.size
  } else if type(val-state) == dictionary and "size" in val-state and val-state.size != auto and val-state.size != none {
    val-state.size
  } else {
    auto
  }

  if specific-size != auto {
    assert-gost-h(specific-size, param-name: field-key + ".size", ignore-rules: ignore-r)
    return specific-size
  }

  // 2. Проверка словаря sizes
  let sizes-dict = s-dict.at("sizes", default: (:))
  let local-sizes = dict.at("sizes", default: (:))
  let res-h = if type(local-sizes) == dictionary and field-key in local-sizes and local-sizes.at(field-key) != auto and local-sizes.at(field-key) != none {
    local-sizes.at(field-key)
  } else if type(local-sizes) == dictionary and group-key in local-sizes and local-sizes.at(group-key) != auto and local-sizes.at(group-key) != none {
    local-sizes.at(group-key)
  } else if type(sizes-dict) == dictionary and field-key in sizes-dict and sizes-dict.at(field-key) != auto and sizes-dict.at(field-key) != none {
    sizes-dict.at(field-key)
  } else if type(sizes-dict) == dictionary and group-key in sizes-dict and sizes-dict.at(group-key) != auto and sizes-dict.at(group-key) != none {
    sizes-dict.at(group-key)
  } else {
    default-h
  }

  assert-gost-h(res-h, param-name: field-key, ignore-rules: ignore-r)
  res-h
}

/// Разрешает параметры повернутого обозначения документа (Графа 26 ГОСТ 2.104-2006).
///
/// - page-arg (any): Значение параметра code-inverted на уровне страницы.
/// - state-arg (any): Значение параметра code-inverted из глобального состояния.
/// - code-val (content, str): Основное обозначение документа (Графа 2).
/// - is-drawing (bool): Признак чертежного документа (Форма 1).
/// -> dictionary: (show: bool, text: content, frame: bool, size: length/auto, min-size: length/auto)
#let resolve-code-inverted(page-arg, state-arg, code-val, is-drawing: false) = {
  let effective = if page-arg != auto {
    page-arg
  } else if state-arg != auto {
    state-arg
  } else {
    auto
  }

  if effective == auto {
    // По ГОСТ 2.104-2006 п. 4.1 для чертежей и схем (Форма 1) повернутое обозначение включается автоматически
    return (
      "show": is-drawing,
      text: code-val,
      frame: true,
      size: auto,
      "min-size": auto,
      shown: is-drawing,
    )
  }

  if effective == none {
    return (
      "show": false,
      text: [],
      frame: false,
      size: auto,
      "min-size": auto,
      shown: false,
    )
  }

  if type(effective) == dictionary {
    let is-shown = effective.at("show", default: effective.at("shown", default: true))
    let b-text = effective.at("text", default: effective.at("code", default: code-val))
    let b-frame = effective.at("frame", default: auto)
    let has-frame = if b-frame == false or b-frame == none { false } else { true }
    let b-size = effective.at("size", default: auto)
    let b-min = effective.at("min-size", default: auto)
    return (
      "show": is-shown,
      text: b-text,
      frame: has-frame,
      size: b-size,
      "min-size": b-min,
      shown: is-shown,
    )
  }

  // str, content, int, float — принудительный текст с рамкой по умолчанию
  (
    "show": true,
    text: effective,
    frame: true,
    size: auto,
    "min-size": auto,
    shown: true,
  )
}

/// Разрешает поля одной строки Таблицы изменений по индексу (графы 14-18 ГОСТ 2.104-2006):
/// Графа 14 («Изм.»), Графа 15 («Лист»), Графа 16 («№ докум.»),
/// Графа 17 («Подп.»), Графа 18 («Дата»).
/// Формат: строго массив словарей (array of dictionary).
///
/// - idx (int): Индекс строки изменений (0..3).
/// - named-args (dictionary): Локальные параметры вызова.
/// - state-dict (dictionary): Словарь глобального состояния.
/// -> dictionary: Поля num, sheet, doc, sig, date и размеры num-size, sheet-size, doc-size, sig-size, date-size.
#let resolve-change-field(idx, named-args, state-dict) = {
  let raw-changes = get-field(named-args, "changes", state-dict, default: auto)
  let ignore-r = if type(state-dict) == dictionary { state-dict.at("ignore-rules", default: auto) } else { auto }

  let raw-item = (:)
  if type(raw-changes) == array and idx < raw-changes.len() {
    let item = raw-changes.at(idx)
    if type(item) == dictionary {
      raw-item = item
    }
  }

  let num-val = raw-item.at("num", default: [])
  let sheet-val = raw-item.at("sheet", default: [])
  let doc-val = raw-item.at("doc", default: [])
  let sig-val = raw-item.at("sig", default: [])
  let date-val = raw-item.at("date", default: [])

  let gen-size = raw-item.at("size", default: auto)
  let num-sz = raw-item.at("num-size", default: gen-size)
  let sheet-sz = raw-item.at("sheet-size", default: gen-size)
  let doc-sz = raw-item.at("doc-size", default: gen-size)
  let sig-sz = raw-item.at("sig-size", default: gen-size)
  let date-sz = raw-item.at("date-size", default: gen-size)

  if num-sz != auto and num-sz != none { assert-gost-h(num-sz, param-name: "changes.num-size", ignore-rules: ignore-r) }
  if sheet-sz != auto and sheet-sz != none { assert-gost-h(sheet-sz, param-name: "changes.sheet-size", ignore-rules: ignore-r) }
  if doc-sz != auto and doc-sz != none { assert-gost-h(doc-sz, param-name: "changes.doc-size", ignore-rules: ignore-r) }
  if sig-sz != auto and sig-sz != none { assert-gost-h(sig-sz, param-name: "changes.sig-size", ignore-rules: ignore-r) }
  if date-sz != auto and date-sz != none { assert-gost-h(date-sz, param-name: "changes.date-size", ignore-rules: ignore-r) }

  (
    num: if num-val == auto or num-val == none { [] } else { num-val },
    sheet: if sheet-val == auto or sheet-val == none { [] } else { sheet-val },
    doc: if doc-val == auto or doc-val == none { [] } else { doc-val },
    sig: if sig-val == auto or sig-val == none { [] } else { sig-val },
    date: if date-val == auto or date-val == none { [] } else { date-val },
    "num-size": num-sz,
    "sheet-size": sheet-sz,
    "doc-size": doc-sz,
    "sig-size": sig-sz,
    "date-size": date-sz,
  )
}

/// Дискретная автоподгонка размера чертежного шрифта под границы ячейки (ГОСТ 2.304-81).
///
/// Алгоритм:
/// 1. Перебирает стандартные высоты шрифта h от target-h до min-h.
/// 2. Проверяет вхождение в границы max-w и max-h, а также переполнение отдельных слов.
/// 3. В случае выхода за пределы даже при min-h применяет масштабирование scale(reflow: true).
///
/// - val (content, str): Текст ячейки.
/// - target-h (length): Исходная целевая высота шрифта по ГОСТ.
/// - min-h (length): Минимально допустимая высота шрифта по ГОСТ.
/// - max-w (length): Максимальная ширина ячейки.
/// - max-h (length): Максимальная высота ячейки.
/// - weight (str): Начертание шрифта.
/// - single-line (bool): Режим строго одной строки (запрет переносов).
/// - align-mode (alignment): Выравнивание текста в ячейке.
/// - cfg (dictionary): Конфигурация чертежного шрифта.
/// - ignore-rules (array, str, bool, none, auto): Правила для подавления валидации.
/// -> content: Отрендеренный и подогнанный блок текста.
#let auto-fit-gost(
  val,
  target-h: h5_0,
  min-h: h1_8,
  max-w: 1000mm,
  max-h: 1000mm,
  weight: "regular",
  italic: false,
  single-line: false,
  align-mode: center + horizon,
  cfg: gost-fonts.at("type-b"),
  ignore-rules: auto,
) = context {
  if val == [] or val == none or val == auto or val == "" { return [] }

  let candidates = valid-gost-h-values.filter(vh => vh <= target-h + 0.05mm and vh >= min-h - 0.05mm).rev()
  if candidates.len() == 0 { candidates = (target-h,) }

  let txt-raw = plain-text(val)
  let words = txt-raw.split().filter(w => w != "")
  if words.len() == 0 { words = (txt-raw,) }

  if single-line {
    for h in candidates {
      let t = gost-text(h: h, cfg: cfg, weight: weight, italic: italic, ignore-rules: ignore-rules)[#val]
      let m = measure(box(t))
      if m.width <= max-w + 0.05mm and m.height <= max-h + 0.05mm {
        return box(t)
      }
    }
    let t-min = gost-text(h: min-h, cfg: cfg, weight: weight, italic: italic, ignore-rules: ignore-rules)[#val]
    let m-min = measure(box(t-min))
    let sf = calc.min(1.0, (max-w / m-min.width), (max-h / m-min.height))
    assert-text-scale(sf, text-val: val, ignore-rules: ignore-rules)
    return scale(x: sf * 100%, y: sf * 100%, reflow: true)[#box(t-min)]
  } else {
    for h in candidates {
      let word-overflow = words.any(w => {
        let wt = gost-text(h: h, cfg: cfg, weight: weight, italic: italic, ignore-rules: ignore-rules)[#w]
        measure(box(wt)).width > (max-w + 0.05mm)
      })

      if not word-overflow {
        let t-block = gost-text(h: h, cfg: cfg, weight: weight, italic: italic, ignore-rules: ignore-rules)[#val]
        let m = measure(block(width: max-w, t-block))
        if m.height <= max-h + 0.05mm {
          return block(width: max-w, align(align-mode, t-block))
        }
      }
    }

    let t-min = gost-text(h: min-h, cfg: cfg, weight: weight, italic: italic, ignore-rules: ignore-rules)[#val]
    let max-word-w = words.map(w => {
      let wt = gost-text(h: min-h, cfg: cfg, weight: weight, italic: italic, ignore-rules: ignore-rules)[#w]
      measure(box(wt)).width
    }).fold(0mm, calc.max)

    let eff-w = calc.max(max-w, max-word-w)
    let m-min = measure(block(width: eff-w, t-min))
    let sf-x = if eff-w > max-w { max-w / eff-w } else { 1.0 }
    let sf-y = if m-min.height > max-h { max-h / m-min.height } else { 1.0 }
    let sf = calc.min(sf-x, sf-y, 1.0)
    assert-text-scale(sf, text-val: val, ignore-rules: ignore-rules)

    return scale(x: sf * 100%, y: sf * 100%, reflow: true)[
      #block(width: eff-w, align(align-mode, t-min))
    ]
  }
}

/// Вычисляет единый гармоничный кегль шрифта для группы строк (например, всех фамилий участников).
///
/// - items (array): Список значений элементов группы.
/// - target-h (length): Исходная целевая высота.
/// - min-h (length): Минимальная высота.
/// - max-w (length): Максимальная ширина ячейки.
/// - max-h (length): Максимальная высота ячейки.
/// - weight (str): Начертание.
/// - italic (bool): Наклонный шрифт 75°.
/// - single-line (bool): Однострочный режим.
/// - cfg (dictionary): Конфигурация шрифта.
/// - ignore-rules (array, str, bool, none, auto): Правила для подавления.
/// -> dictionary: (h: length, scale: float)
#let compute-group-font(
  items,
  target-h: h3_5,
  min-h: h1_8,
  max-w: 22mm,
  max-h: 4.5mm,
  weight: "regular",
  italic: false,
  single-line: true,
  cfg: gost-fonts.at("type-b"),
  ignore-rules: auto,
) = {
  let non-empty = items.filter(it => it != [] and it != none and it != auto and it != "")
  if non-empty.len() == 0 {
    return (h: target-h, scale: 1.0)
  }

  let candidates = valid-gost-h-values.filter(vh => vh <= target-h + 0.05mm and vh >= min-h - 0.05mm).rev()
  if candidates.len() == 0 { candidates = (target-h,) }

  for h in candidates {
    let all-fit = non-empty.all(val => {
      let t = gost-text(h: h, cfg: cfg, weight: weight, italic: italic, ignore-rules: ignore-rules)[#val]
      let m = measure(box(t))
      m.width <= max-w + 0.05mm and m.height <= max-h + 0.05mm
    })
    if all-fit {
      return (h: h, scale: 1.0)
    }
  }

  let min-sf = 1.0
  let worst-val = non-empty.first()
  for val in non-empty {
    let t-min = gost-text(h: min-h, cfg: cfg, weight: weight, italic: italic, ignore-rules: ignore-rules)[#val]
    let m = measure(box(t-min))
    let sf = calc.min(1.0, max-w / m.width, max-h / m.height)
    if sf < min-sf {
      min-sf = sf
      worst-val = val
    }
  }

  assert-text-scale(min-sf, text-val: worst-val, ignore-rules: ignore-rules)
  (h: min-h, scale: min-sf)
}

/// Отрисовывает отдельный элемент группы подписей с учетом общего или индивидуального кегля.
#let render-group-item(
  val,
  font-spec,
  item-size: auto,
  max-w: 22mm,
  max-h: 4.5mm,
  weight: "regular",
  italic: false,
  align-mode: left + horizon,
  cfg: gost-fonts.at("type-b"),
  ignore-rules: auto,
) = {
  if val == [] or val == none or val == auto or val == "" { return [] }

  if item-size != auto and item-size != none {
    let body = auto-fit-gost(
      val,
      target-h: item-size,
      min-h: h1_8,
      max-w: max-w,
      max-h: max-h,
      weight: weight,
      italic: italic,
      single-line: true,
      align-mode: align-mode,
      cfg: cfg,
      ignore-rules: ignore-rules,
    )
    return align(align-mode, body)
  }

  let t = gost-text(h: font-spec.h, cfg: cfg, weight: weight, italic: italic, ignore-rules: ignore-rules)[#val]
  let res = if font-spec.scale < 0.999 {
    scale(x: font-spec.scale * 100%, y: font-spec.scale * 100%, reflow: true)[#box(t)]
  } else {
    box(t)
  }
  align(align-mode, res)
}

/// Универсальный рендерер ячейки штампа с поддержкой автоподгонки и индивидуальных размеров.
#let render-cell(
  field-key,
  group-key,
  default-val: [],
  default-h: h3_5,
  weight: "regular",
  italic: false,
  align-mode: center + horizon,
  wrap-box: false,
  single-line: false,
  max-w: none,
  max-h: none,
  named-args: (:),
  state-dict: (:),
  cfg: gost-fonts.at("type-b"),
) = {
  let val = get-field(named-args, field-key, state-dict, default: default-val)
  if val == none or val == auto or val == [] or val == "" {
    return []
  }
  let target-h = get-font-h(field-key, group-key, default-h, named-args, state-dict)
  let ignore-r = if type(state-dict) == dictionary { state-dict.at("ignore-rules", default: auto) } else { auto }
  let is-it = if italic != false {
    italic
  } else if "font-italic" in named-args and named-args.at("font-italic") != auto {
    named-args.at("font-italic") == true
  } else if type(state-dict) == dictionary and state-dict.at("font-italic", default: false) == true {
    true
  } else {
    false
  }

  if max-w != none and max-h != none {
    auto-fit-gost(
      val,
      target-h: target-h,
      min-h: h1_8,
      max-w: max-w,
      max-h: max-h,
      weight: weight,
      italic: is-it,
      single-line: single-line or wrap-box,
      align-mode: align-mode,
      cfg: cfg,
      ignore-rules: ignore-r,
    )
  } else {
    let body = gost-text(h: target-h, cfg: cfg, weight: weight, italic: is-it, ignore-rules: ignore-r, val)
    if wrap-box or single-line {
      body = box(body)
    }
    if align-mode != auto {
      align(align-mode, body)
    } else {
      body
    }
  }
}

/// Отрисовывает отдельную литеру в ячейке Графы 4 с безопасными отступами от рамок и поддержкой составных индексов.
#let render-lit-cell(
  val,
  base-h: h3_5,
  max-w: 4.4mm,
  max-h: 4.4mm,
  italic: false,
  cfg: gost-fonts.at("type-b"),
  ignore-rules: auto,
) = {
  if val == [] or val == none or val == auto or val == "" { return [] }
  let txt = normalize-lit-str(val)
  if txt == "" { return [] }

  let chars = txt.clusters()

  if chars.len() == 1 {
    auto-fit-gost(
      chars.at(0),
      target-h: base-h,
      min-h: h1_8,
      max-w: max-w,
      max-h: max-h,
      italic: italic,
      single-line: true,
      align-mode: center + horizon,
      cfg: cfg,
      ignore-rules: ignore-rules,
    )
  } else if chars.len() == 2 {
    let ch1 = chars.at(0)
    let ch2 = chars.at(1)
    // Составная литера (например, О1, О2): основной символ и индекс на один размер меньше по ГОСТ 2.304-81
    let main-h = if base-h >= h5_0 { h3_5 } else { base-h }
    let sub-h = get-gost-subscript-h(main-h, ignore-rules: ignore-rules)
    let t1 = gost-text(h: main-h, cfg: cfg, italic: italic, ignore-rules: ignore-rules)[#ch1]
    let t2 = gost-text(h: sub-h, cfg: cfg, italic: italic, ignore-rules: ignore-rules)[#ch2]
    let content-box = box(
      grid(
        columns: (auto, auto),
        align: alignment.bottom,
        t1,
        t2,
      )
    )
    let m = measure(content-box)
    if m.width <= max-w and m.height <= max-h {
      align(alignment.center + alignment.horizon, content-box)
    } else {
      auto-fit-gost(
        val,
        target-h: main-h,
        min-h: h1_8,
        max-w: max-w,
        max-h: max-h,
        italic: italic,
        single-line: true,
        align-mode: center + horizon,
        cfg: cfg,
        ignore-rules: ignore-rules,
      )
    }
  } else {
    auto-fit-gost(
      val,
      target-h: base-h,
      min-h: h1_8,
      max-w: max-w,
      max-h: max-h,
      italic: italic,
      single-line: true,
      align-mode: center + horizon,
      cfg: cfg,
      ignore-rules: ignore-rules,
    )
  }
}

/// Разрешает поля участника документа по индексу строки (графы 10-13).
/// Поддерживает как плоские кортежи ("Должность", "Фамилия", "Дата", "Подпись"),
/// так и словари с точечной настройкой размеров шрифта.
///
/// - idx (int): Индекс строки подписи (0..5).
/// - named-args (dictionary): Локальные параметры.
/// - state-dict (dictionary): Глобальное состояние.
/// -> dictionary: Поля label, value, date, sign и соответствующие размеры.
#let resolve-member-field(idx, named-args, state-dict) = {
  let members-list = get-field(named-args, "members", state-dict, default: ())

  let lbl = []
  let val = []
  let dat = []
  let sig = []
  let gen-size = auto
  let lbl-size = auto
  let val-size = auto
  let dat-size = auto
  let sig-size = auto

  if type(members-list) == array and idx < members-list.len() {
    let m = members-list.at(idx)
    if m == none or m == auto or m == () or m == "" {
      // Пустая строка
    } else if type(m) == array {
      lbl = if m.len() > 0 and m.at(0) != auto and m.at(0) != none { m.at(0) } else { [] }
      val = if m.len() > 1 and m.at(1) != auto and m.at(1) != none { m.at(1) } else { [] }
      dat = if m.len() > 2 and m.at(2) != auto and m.at(2) != none { m.at(2) } else { [] }
      sig = if m.len() > 3 and m.at(3) != auto and m.at(3) != none { m.at(3) } else { [] }
    } else if type(m) == dictionary {
      lbl = m.at("label", default: [])
      val = m.at("name", default: [])
      dat = m.at("date", default: [])
      sig = m.at("sign", default: [])
      gen-size = m.at("size", default: auto)
      lbl-size = m.at("label-size", default: gen-size)
      val-size = m.at("name-size", default: gen-size)
      dat-size = m.at("date-size", default: gen-size)
      sig-size = m.at("sign-size", default: gen-size)
    }
  }

  (
    label: if lbl == auto or lbl == none { [] } else { lbl },
    name: if val == auto or val == none { [] } else { val },
    value: if val == auto or val == none { [] } else { val },
    date: if dat == auto or dat == none { [] } else { dat },
    sign: if sig == auto or sig == none { [] } else { sig },
    "label-size": lbl-size,
    "name-size": val-size,
    "date-size": dat-size,
    "sign-size": sig-size,
  )
}