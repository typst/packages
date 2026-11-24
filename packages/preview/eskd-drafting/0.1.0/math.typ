// math.typ — Математические метрики и типографика по ГОСТ 2.304-81
//
// Модуль рассчитывает параметры чертежного шрифта в соответствии с ГОСТ 2.304-81:
// - Шрифт типа А: толщина линий d = (1/14)h, расстояние между буквами a = 2d (0.143h),
//   минимальный шаг строк b = 20d (1.429h), расстояние между словами e = 6d (0.429h),
//   высота строчных букв c = 10d (0.714h).
// - Шрифт типа Б: толщина линий d = (1/10)h, расстояние между буквами a = 2d (0.20h),
//   минимальный шаг строк b = 14d (1.40h), расстояние между словами e = 6d (0.60h),
//   высота строчных букв c = 7d (0.70h).

#import "validators.typ": *

/// Семейства шрифтов по САПР-экосистемам
#let gost-font-families = (
  ascon: ("Ascon GOST 2.304 Type B", "GOST 2.304 type B", "GOST type B"),
  tflex: ("T-FLEX GOST Type B", "T-FLEX GOST Type A"),
  solidworks: ("SolidWorks GOST", "SolidWorks GOST A", "Gost_B"),
  autocad: ("ISOCPEUR", "ISOCTEUR", "ISOCP", "ISOCT"),
  spds: ("SPDS GOST Type B", "CSC GOST Type B", "Mechanics GOST Type B"),
)

/// Предустановленные конфигурации чертежных шрифтов по ГОСТ 2.304-81
#let gost-fonts = {
  let default-type-b = (
    "OpenGost Type B",
    "OpenGost Type B TT",
    "osifont",
    "GOST type B",
    "GOST 2.304-81 Type B",
    "PT Astra Sans",
    "Arial",
  )

  let default-type-a = (
    "OpenGost Type A",
    "OpenGost Type A TT",
    "GOST type A",
    "GOST 2.304-81 Type A",
    "PT Astra Sans",
    "Arial",
  )

  (
    "type-b": (
      font: default-type-b,
      scale: 1.40,
      "cap-ratio": 0.70,
      "leading-ratio": 0.40,
      "letter-space-ratio": 0.20,
      "word-space-ratio": 0.60,
    ),
    "type-a": (
      font: default-type-a,
      scale: 1.286,
      "cap-ratio": 0.714,
      "leading-ratio": 0.429,
      "letter-space-ratio": 0.143,
      "word-space-ratio": 0.429,
    ),
  )
}

// Номинальный ряд высот шрифта по ГОСТ 2.304-81 (п. 2.1)
#let h1_8 = 1.8mm
#let h2_5 = 2.5mm
#let h3_5 = 3.5mm
#let h5_0 = 5.0mm
#let h7_0 = 7.0mm
#let h10_0 = 10.0mm
#let h14_0 = 14.0mm
#let h20_0 = 20.0mm
#let h28_0 = 28.0mm
#let h40_0 = 40.0mm

/// Возвращает размер шрифта для надстрочных и подстрочных индексов (на одну ступень меньше по ГОСТ 2.304-81).
///
/// - main-h (length): Номинальная высота основного шрифта.
/// -> length: Высота индекса на одну ступень меньше.
#let get-gost-subscript-h(main-h, ignore-rules: auto) = {
  assert-gost-subscript-base-h(main-h, ignore-rules: ignore-rules)
  let idx = 0
  let found = false
  for i in range(0, valid-gost-h-values.len()) {
    if calc.abs((valid-gost-h-values.at(i) - main-h) / 1mm) < 0.05 {
      idx = i
      found = true
      break
    }
  }
  if found and idx > 0 {
    valid-gost-h-values.at(idx - 1)
  } else if found and idx == 0 {
    valid-gost-h-values.at(0)
  } else {
    let smaller = valid-gost-h-values.filter(vh => vh < main-h - 0.05mm)
    if smaller.len() > 0 {
      smaller.last()
    } else {
      main-h * 0.7
    }
  }
}


/// Вычисляет геометрические габариты листа (width, height) по ГОСТ 2.301-68 с учетом ориентации.
///
/// - paper (str, array, dictionary, auto, none): Формат листа ("a4", "a3", "a4x3" и т.д.).
/// - orientation (str, auto, none): Ориентация листа ("portrait" или "landscape").
/// -> (length, length): (width, height)
#let get-paper-dimensions(paper, orientation, default-h: 297mm) = {
  let parsed = parse-gost-paper(paper)
  let o-str = if type(orientation) == str { lower(orientation).trim() } else { "portrait" }
  let is-landscape = (o-str == "landscape")

  if parsed.ok {
    if parsed.is-multiplied {
      // Кратные форматы aNxM по ГОСТ 2.301-68 ориентированы горизонтально (W = короткая * M, H = длинная)
      (parsed.width, parsed.height)
    } else {
      let (w0, h0) = (parsed.width, parsed.height)
      if is-landscape { (h0, w0) } else { (w0, h0) }
    }
  } else {
    if is-landscape { (default-h, 210mm) } else { (210mm, default-h) }
  }
}

/// Разрешает и формирует итоговую конфигурацию шрифта с сохранением ГОСТ-пропорций.
/// Позволяет пользователю задать собственный шрифт (строку или массив гарнитур)
/// или выбрать САПР-группу (font-group), которая будет применена для всего документа.
///
/// - font (str, array, dictionary, auto, none): Конкретная гарнитура шрифта или список альтернатив.
/// - font-type (str, auto): Тип начертания по ГОСТ ("type-b" или "type-a").
/// - font-group (str, auto, none): Пресет группы САПР-шрифтов ("ascon", "tflex", "solidworks", "autocad", "spds").
/// - font-cfg (dictionary, auto): Готовая конфигурация шрифта.
/// -> dictionary: Полная конфигурация со свойствами font, scale, leading-ratio и т.д.
#let resolve-font-cfg(font: auto, font-type: auto, font-group: auto, font-cfg: auto) = {
  let ftype = if font-type != auto and font-type != none { lower(str(font-type)) } else { "type-b" }
  let default-base = if ftype in ("type-a", "a") {
    gost-fonts.at("type-a")
  } else {
    gost-fonts.at("type-b")
  }

  let group-fonts = if font-group != auto and font-group != none {
    let gkey = lower(str(font-group))
    if gkey in gost-font-families {
      gost-font-families.at(gkey)
    } else {
      ()
    }
  } else {
    ()
  }

  let base-cfg = if font-cfg != auto and font-cfg != none and type(font-cfg) == dictionary {
    default-base + font-cfg
  } else {
    default-base
  }

  let base-font-chain = if group-fonts.len() > 0 {
    group-fonts + base-cfg.font
  } else {
    base-cfg.font
  }

  if font == auto or font == none {
    let updated = base-cfg
    updated.insert("font", base-font-chain)
    return updated
  }

  let resolved-font = if type(font) == str {
    (font,) + base-font-chain
  } else if type(font) == array {
    font
  } else if type(font) == dictionary {
    return base-cfg + font
  } else {
    base-font-chain
  }

  let updated = base-cfg
  updated.insert("font", resolved-font)
  updated
}

/// Вычисляет размер кегля шрифта Typst для обеспечения заданной высоты прописных букв h.
///
/// - h (length): Номинальная высота шрифта по ГОСТ.
/// - cfg (dictionary): Конфигурация чертежного шрифта.
/// - ignore-rules (array, str, bool, none, auto): Правила для подавления валидации.
/// -> length: Размер шрифта Typst.
#let gost-calc-size(h, cfg: gost-fonts.at("type-b"), ignore-rules: auto) = {
  assert-gost-h(h, param-name: "h", ignore-rules: ignore-rules)
  let sc = cfg.at("scale", default: 1.40)
  h * sc
}

/// Вычисляет интерлиньяж (расстояние между строками) по ГОСТ 2.304-81.
///
/// - h (length): Номинальная высота шрифта.
/// - cfg (dictionary): Конфигурация шрифта.
/// - ignore-rules (array, str, bool, none, auto): Правила для подавления валидации.
/// -> length: Межстрочный интервал Typst.
#let gost-calc-leading(h, cfg: gost-fonts.at("type-b"), ignore-rules: auto) = {
  assert-gost-h(h, param-name: "h", ignore-rules: ignore-rules)
  let lr = cfg.at("leading-ratio", default: 0.40)
  h * lr
}

/// Вычисляет трекинг (межбуквенное расстояние) по ГОСТ 2.304-81.
///
/// - h (length): Номинальная высота шрифта.
/// - cfg (dictionary): Конфигурация шрифта.
/// - ignore-rules (array, str, bool, none, auto): Правила для подавления валидации.
/// -> length: Дополнительное межбуквенное расстояние.
#let gost-calc-tracking(h, cfg: gost-fonts.at("type-b"), ignore-rules: auto) = {
  assert-gost-h(h, param-name: "h", ignore-rules: ignore-rules)
  let tr = cfg.at("letter-space-ratio", default: 0.20)
  h * tr
}

/// Применяет типографические параметры чертежного текста по ГОСТ 2.304-81.
///
/// - h (length): Номинальная высота шрифта (по умолчанию h3_5 = 3.5 мм).
/// - cfg (dictionary): Конфигурация шрифта.
/// - weight (str): Начертание ("regular", "bold" и т.д.).
/// - italic (bool): Флаг наклонного начертания (ГОСТ 2.304-81, наклон ~75°). По умолчанию `false`.
/// - tracking (length): Трекинг (по умолчанию 0pt).
/// - ignore-rules (array, str, bool, none, auto): Правила для подавления валидации.
/// - body (content): Содержимое текста.
/// -> content: Стилизованный блок текста.
#let gost-text(
  h: h3_5,
  cfg: gost-fonts.at("type-b"),
  weight: "regular",
  italic: false,
  tracking: 0pt,
  ignore-rules: auto,
  body,
) = {
  assert-gost-h(h, param-name: "h", ignore-rules: ignore-rules)
  let is-italic = if italic == true { "italic" } else { "normal" }
  set text(
    font: cfg.font,
    size: gost-calc-size(h, cfg: cfg, ignore-rules: ignore-rules),
    weight: weight,
    style: is-italic,
    tracking: tracking,
    top-edge: "cap-height",
    bottom-edge: "baseline",
    hyphenate: false,
  )
  set par(
    leading: gost-calc-leading(h, cfg: cfg, ignore-rules: ignore-rules),
    justify: false,
  )
  body
}