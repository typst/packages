// state.typ — Централизованное состояние реквизитов документа и типографики
//
// Модуль хранит глобальное состояние документа в Typst-состоянии "eskd-doc-state".
// Значения параметров по умолчанию инициализируются как `auto` (авторасчет по ГОСТ).
// Значение `none` означает принудительное отключение или отсутствие поля/элемента.

#import "math.typ": *
#import "validators.typ": *

/// Словарь параметров документа по умолчанию.
/// Все параметры имеют унифицированные значения `auto` (вычисляются автоматически по правилам ЕСКД).
#let eskd-default-state = (
  // 1. Формат, ориентация и пресеты линий
  paper: "a4",
  orientation: "portrait",
  "ignore-rules": auto,
  "preset-lines": "industry",

  // 2. Типографика и шрифты
  font: auto,
  "font-type": auto,
  "font-group": auto,
  "font-italic": auto,
  "font-cfg": gost-fonts.at("type-b"),

  // 3. Реквизиты изделия и документа (графы 1-9 ГОСТ 2.104-2006)
  // Принимают: auto / none / content / str / dict (text: ..., size: ..., min-size: ...)
  code: auto,
  name: auto,
  org: auto,
  material: auto,
  lit: auto,
  mass: auto,
  scale: auto,

  // 4. Повернутое обозначение документа в верхнем левом углу (Графа 26 ГОСТ 2.104-2006)
  // auto — включено для чертежей (Форма 1), скрыто для текстовых форм
  // none — принудительно отключено
  // str / content — принудительно включено с этим текстом и рамкой
  // dict — детальная конфигурация (text: ..., frame: true/false/auto, size: ..., min-size: ..., show: true/false)
  "code-inverted": auto,

  // 5. Участники документа (графы 10-13)
  // auto / none — без подписей
  // array — массив кортежей ("Разраб.", "Иванов", ...) или словарей
  members: auto,

  // 6. Таблица изменений (графы 14-18)
  // auto / none — пустые строки
  // array — массив словарей-записей ((num: [1], sheet: [Зам.], doc: [ИИ-100], sig: [Иванов], date: [01.09.26]), ...)
  changes: auto,

  // 7. Боковые штампы инвентарного учета (графы 19-25)
  "inv-orig": auto,
  "sig-date-orig": auto,
  "inv-repl": auto,
  "inv-dup": auto,
  "sig-date-dup": auto,
  "ref-num": auto,
  "prim-apply": auto,

  // 8. Графы 31 и 32 под внешней рамкой («Копировал» и «Формат»)
  copier: auto,
  format: auto,

  // 9. Групповые размеры шрифтов (ГОСТ 2.304-81)
  sizes: (
    labels: h2_5,
    values: h3_5,
    dates: h2_5,
    signs: h3_5,
    code: h7_0,
    name: h5_0,
    org: h5_0,
    material: h5_0,
    params: h5_0,
    lit: h3_5,
    sheet: h3_5,
    toc: h3_5,
  ),

  // 11. Принудительные переопределения номеров страниц
  page: auto,
  total: auto,
)

/// Экземпляр глобального Typst-состояния документа ЕСКД
#let eskd-state = state("eskd-doc-state", eskd-default-state)

/// Инициализирует или обновляет параметры глобального состояния ЕСКД-документа.
/// Выполняет нормативную валидацию переданных аргументов.
///
/// - ..args: Именованные аргументы конфигурации документа.
#let eskd-init(..args) = {
  let named = args.named()
  let ignore-r = named.at("ignore-rules", default: auto)

  if "paper" in named or "orientation" in named {
    let p = named.at("paper", default: "a4")
    let parsed-p = parse-gost-paper(p)
    let def-orient = if parsed-p.is-multiplied {
      "landscape"
    } else if p == "a4" {
      "portrait"
    } else {
      "landscape"
    }
    let o = named.at("orientation", default: def-orient)
    if o == auto { o = def-orient }
    assert-paper-format(p, o, ignore-rules: ignore-r)
  }

  if "copier" in named {
    assert(type(named.at("copier")) != bool, message: "Значение copier не может быть boolean (true/false). Допустимые значения: auto, none, str, content или dict.")
  }

  if "lit" in named {
    let _ = parse-lit-cells(
      named.at("lit", default: auto),
      ignore-rules: ignore-r
    )
  }

  if "scale" in named { assert-scale(named.at("scale"), ignore-rules: ignore-r) }
  if "mass" in named { assert-mass(named.at("mass"), ignore-rules: ignore-r) }
  if "preset-lines" in named { assert-preset-lines(named.at("preset-lines"), ignore-rules: ignore-r) }

  // Проверка типографических высот h в словаре sizes
  if "sizes" in named and type(named.sizes) == dictionary {
    for (k, v) in named.sizes {
      if type(v) == length {
        assert-gost-h(v, param-name: "sizes." + k, ignore-rules: ignore-r)
      }
    }
  }

  // Обновление состояния
  eskd-state.update(curr => {
    let updated = curr
    for (k, v) in named {
      updated.insert(k, v)
    }

    // Разрешение конфигурации шрифта, если переданы font, font-type, font-group или font-cfg
    if "font" in named or "font-type" in named or "font-group" in named or "font-cfg" in named {
      let resolved = resolve-font-cfg(
        font: updated.at("font", default: auto),
        font-type: updated.at("font-type", default: auto),
        font-group: updated.at("font-group", default: auto),
        font-cfg: updated.at("font-cfg", default: auto),
      )
      updated.insert("font-cfg", resolved)
    }

    updated
  })
}

/// Динамически изменяет реквизиты документа в произвольный момент.
/// Полный синоним функции `eskd-init`.
///
/// - ..args: Именованные параметры для обновления.
#let eskd-set(..args) = eskd-init(..args)