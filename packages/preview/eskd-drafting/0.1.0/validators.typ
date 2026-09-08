// validators.typ — Подсистема селективной валидации по стандартам ЕСКД
//
// Модуль реализует нормативный контроль параметров документа в соответствии
// со стандартами Единой системы конструкторской документации (ЕСКД):
// - ГОСТ 2.103-2013: Стадии разработки и литеры документов (Таблица 1).
// - ГОСТ 2.104-2006: Основные надписи, графы 5 (масса), 14-18 (изменения),
//                    геометрия штампов.
// - ГОСТ 2.301-68:   Форматы и ориентация листов (п. 4).
// - ГОСТ 2.302-68:   Масштабы (п. 2).
// - ГОСТ 2.303-68:   Линии (п. 2, толщины основных и тонких линий).
// - ГОСТ 2.304-81:   Шрифты чертежные (п. 2.1, ряд номинальных высот h).

/// Извлекает плоский строковый текст из произвольного Typst-объекта
/// (строка, число, контент с дочерними элементами, переносы строк).
///
/// - val (any): Входное значение для преобразования в строку.
/// -> str: Плоский текст без форматирования.
#let plain-text(val, depth: 0) = {
  if depth > 16 or val == auto or val == none or val == [] {
    return ""
  } else if type(val) == bool {
    if val { "true" } else { "false" }
  } else if type(val) == str {
    val
  } else if type(val) == int or type(val) == float {
    str(val)
  } else if type(val) == content {
    if val.has("text") {
      val.text
    } else if val.func() == [ ].func() {
      " "
    } else if val.has("children") {
      val.children.map(c => plain-text(c, depth: depth + 1)).join("")
    } else if val.has("body") {
      plain-text(val.body, depth: depth + 1)
    } else if val.has("child") {
      plain-text(val.child, depth: depth + 1)
    } else if val.func() == parbreak {
      "\n"
    } else {
      ""
    }
  } else {
    repr(val)
  }
}

/// Проверяет, должно ли правило валидации быть пропущено на основе списка
/// шаблонов ignore-rules (поддерживаются маски "*" и "?", а также true/"*").
///
/// - rule-id (str): Уникальный идентификатор правила стандарта.
/// - ignore-rules (array, str, bool, none, auto): Список правил или маска для отключения.
/// -> bool: true, если правило следует пропустить.
#let should-skip-rule(rule-id, ignore-rules) = {
  if ignore-rules == none or ignore-rules == () or ignore-rules == auto {
    return false
  }
  if ignore-rules == "*" {
    return true
  }

  let rules-list = if type(ignore-rules) == str {
    (ignore-rules,)
  } else if type(ignore-rules) == array {
    ignore-rules
  } else {
    ()
  }

  for pat in rules-list {
    if pat == "*" {
      return true
    }
    let pat-str = if type(pat) == bool { if pat { "true" } else { "false" } } else { str(pat) }
    // Преобразование шаблона с wildcards (*, ?) в регулярное выражение
    let escaped = pat-str.replace("\\", "\\\\")
      .replace(".", "\\.")
      .replace("+", "\\+")
      .replace("?", ".")
      .replace("*", ".*")
    if rule-id.match(regex("^" + escaped + "$")) != none {
      return true
    }
  }
  return false
}

/// Базовый ассерт правила ЕСКД с выводом форматированного идентификатора правила.
///
/// - rule-id (str): Идентификатор стандарта ЕСКД.
/// - condition (bool): Проверяемое условие.
/// - message (str): Пояснение ошибки.
/// - ignore-rules (array, str, bool, none, auto): Правила для подавления.
#let assert-rule(rule-id, condition, message, ignore-rules: auto) = {
  if should-skip-rule(rule-id, ignore-rules) { return }
  assert(condition, message: "[" + rule-id + "] " + message)
}

// 1. Стандартный ряд высот шрифта (ГОСТ 2.304-81, п. 2.1)
// Высота шрифта h — размер, определяемый высотой прописных букв в миллиметрах.
#let valid-gost-h-values = (
  1.8mm, 2.5mm, 3.5mm, 5.0mm, 7.0mm, 10.0mm, 14.0mm, 20.0mm, 28.0mm, 40.0mm
)

/// Проверяет принадлежность размера шрифта номинальному ряду высот ГОСТ 2.304-81.
///
/// - h (length): Проверяемая высота шрифта.
/// - param-name (str): Имя параметра для сообщения об ошибке.
/// - ignore-rules (array, str, bool, none, auto): Правила для подавления.
/// Проверяет допустимость размера основного шрифта при наличии надстрочных/подстрочных индексов (ГОСТ 2.304-81).
/// При наличии индексов размер основного шрифта не может быть меньше 2.5 мм, так как минимальный размер шрифта индексов по ГОСТ 2.304-81 составляет 1.8 мм.
///
/// - h (length): Номинальная высота основного шрифта.
/// - param-name (str): Имя параметра.
/// - ignore-rules (array, str, bool, none, auto): Правила для подавления.
#let assert-gost-subscript-base-h(h, param-name: "lit", ignore-rules: auto) = {
  if h == auto or h == none { return }
  assert-rule(
    "gost-2.304-81-subscript-base-height",
    h >= 2.45mm,
    "Размер основного шрифта при наличии индексов (" + param-name + ") не может быть меньше 2.5 мм (получено: " + repr(h) + "), так как минимальный размер шрифта индексов по ГОСТ 2.304-81 составляет 1.8 мм.",
    ignore-rules: ignore-rules
  )
}

#let assert-gost-h(h, param-name: "h", ignore-rules: auto) = {
  if h == auto or h == none { return }
  let is-valid = valid-gost-h-values.any(vh => calc.abs((vh - h) / 1mm) < 0.05)
  assert-rule(
    "gost-2.304-81-font-height",
    is-valid,
    "Недопустимый размер шрифта " + param-name + " = " + repr(h) + ". Допустимые высоты h по ГОСТ 2.304-81: " + repr(valid-gost-h-values) + ".",
    ignore-rules: ignore-rules
  )
}

// 2. Валидация масштабов (ГОСТ 2.302-68, п. 2)
// Масштабы уменьшения, увеличения и натуральная величина (1:1).
#let valid-scales-reduction = (
  "1:2", "1:2,5", "1:4", "1:5", "1:10", "1:15", "1:20", "1:25", "1:40", "1:50", "1:75",
  "1:100", "1:200", "1:400", "1:500", "1:800", "1:1000"
)
#let valid-scales-enlargement = (
  "2:1", "2,5:1", "4:1", "5:1", "10:1", "20:1", "40:1", "50:1", "100:1"
)
#let valid-scales = ("1:1",) + valid-scales-reduction + valid-scales-enlargement

/// Проверяет корректность указания масштаба в Графе 6 основной надписи (ГОСТ 2.302-68).
/// По ГОСТ запрещено указание буквы 'М' или 'М:', а разделителем должна быть запятая.
///
/// - scale-val (str, content): Значение масштаба.
/// - ignore-rules (array, str, bool, none, auto): Правила для подавления.
#let assert-scale(scale-val, ignore-rules: auto) = {
  if scale-val != [] and scale-val != none and scale-val != auto and scale-val != "" {
    let scale-str = plain-text(scale-val).trim()

    assert-rule(
      "gost-2.302-68-scale-m-prefix",
      not (scale-str.starts-with("М") or scale-str.starts-with("M") or scale-str.starts-with("м") or scale-str.starts-with("m")),
      "Ошибка в Графе 6 (Масштаб): \"" + scale-str + "\". Указание буквы 'М' или 'М:' запрещено ГОСТ 2.302-68.",
      ignore-rules: ignore-rules
    )

    assert-rule(
      "gost-2.302-68-scale-decimal-comma",
      not scale-str.contains("."),
      "Ошибка в Графе 6 (Масштаб): \"" + scale-str + "\". Десятичным разделителем по ГОСТ 2.302-68 является запятая.",
      ignore-rules: ignore-rules
    )

    assert-rule(
      "gost-2.302-68-scale-series",
      valid-scales.contains(scale-str),
      "Нестандартный масштаб: \"" + scale-str + "\". Допустимы только масштабы ряда ГОСТ 2.302-68: " + repr(valid-scales),
      ignore-rules: ignore-rules
    )
  }
}

// 3. Валидация массы (Графа 5, ГОСТ 2.104-2006)
// Для массы в килограммах единица измерения не указывается.
/// Проверяет запись массы изделия в Графе 5 по ГОСТ 2.104-2006.
///
/// - mass-val (str, content, int, float): Значение массы.
/// - ignore-rules (array, str, bool, none, auto): Правила для подавления.
#let assert-mass(mass-val, ignore-rules: auto) = {
  if mass-val != [] and mass-val != none and mass-val != auto and mass-val != "" {
    let s = plain-text(mass-val).trim()

    assert-rule(
      "gost-2.104-2006-mass-unit",
      not (s.ends-with("кг") or s.ends-with("kg") or s.ends-with("КГ") or s.ends-with("KG")),
      "Ошибка в Графе 5 (Масса): \"" + s + "\". Для массы в килограммах единица измерения НЕ указывается (ГОСТ 2.104-2006).",
      ignore-rules: ignore-rules
    )

    assert-rule(
      "gost-2.104-2006-mass-decimal-comma",
      not s.contains("."),
      "Ошибка в Графе 5 (Масса): \"" + s + "\". Десятичным разделителем является запятая.",
      ignore-rules: ignore-rules
    )
  }
}

// 4. Валидация литер документа (ГОСТ 2.103-2013, Таблица 1)
// Допустимые литеры стадий разработки:
// П — техническое предложение
// Э — эскизный проект
// Т — технический проект
// И — опытный образец (партия)
// О, О1, О2 — установочная серия, серийное производство
// А, Б — установившееся производство
// У — учебный документ
#let valid-lit-values = ("", " ", "П", "Э", "Т", "И", "О", "О1", "О2", "О₁", "О₂", "А", "Б", "У")

/// Нормализует строку литеры с заменой латинских гомоглифов на кириллицу.
///
/// - val (any): Исходное значение литеры.
/// -> str: Нормализованная строка.
#let normalize-lit-str(val) = {
  if val == none or val == auto or val == [] or val == "" { return "" }
  let s = plain-text(val)
  if s == none { return "" }
  let s-str = str(s).trim()
  s-str.replace("O", "О")
    .replace("o", "О")
    .replace("A", "А")
    .replace("a", "А")
    .replace("T", "Т")
    .replace("t", "Т")
    .replace("E", "Э")
    .replace("e", "Э")
    .replace("₁", "1")
    .replace("₂", "2")
}

/// Проверяет соответствие символа литеры стандарту ГОСТ 2.103-2013.
///
/// - lit-val (str, content): Значение литеры.
/// - field-name (str): Имя поля для сообщения об ошибке.
/// - ignore-rules (array, str, bool, none, auto): Правила для подавления.
#let assert-lit(lit-val, field-name: "lit", ignore-rules: auto) = {
  if lit-val != [] and lit-val != none and lit-val != auto {
    let lit-str = normalize-lit-str(lit-val)
    assert-rule(
      "gost-2.103-2013-litera-value",
      valid-lit-values.contains(lit-str),
      "Недопустимая литера в " + field-name + ": \"" + lit-str + "\". Разрешенные значения по ГОСТ 2.103-2013: " + repr(valid-lit-values),
      ignore-rules: ignore-rules
    )
  }
}

/// Разбивает сплошную строку литер (например, "О1А") на токены для 3 ячеек Графы 4.
///
/// - lit-str (str, content): Исходная строка литер.
/// -> array: Массив из 3 элементов (по одному на ячейку Графы 4).
#let split-lit-tokens(lit-str) = {
  let s = normalize-lit-str(lit-str)
  if s == "" { return ([], [], []) }
  let clusters = s.clusters()
  let tokens = ()
  let idx = 0
  while idx < clusters.len() {
    let ch = clusters.at(idx)
    if ch == "О" and idx + 1 < clusters.len() {
      let next-ch = clusters.at(idx + 1)
      if next-ch in ("1", "2", "₁", "₂") {
        tokens.push(ch + next-ch)
        idx += 2
        continue
      }
    }
    tokens.push(ch)
    idx += 1
  }
  while tokens.len() < 3 {
    tokens.push([])
  }
  tokens.slice(0, 3)
}

/// Выполняет парсинг и валидацию содержимого 3 ячеек Графы 4 (Литеры).
///
/// - lit-val (str, content, array): Значение литер (строка "О1А" или массив ("О", "1", "А")).
/// - ignore-rules (array, str, bool, none, auto): Правила для подавления.
/// -> (content, content, content): Кортеж из 3 ячеек литер.
#let parse-lit-cells(lit-val, ignore-rules: auto) = {
  if lit-val == none or lit-val == auto or lit-val == [] or lit-val == "" {
    return ([], [], [])
  }

  if type(lit-val) == array {
    let l1 = if lit-val.len() > 0 and lit-val.at(0) != auto and lit-val.at(0) != none { lit-val.at(0) } else { [] }
    let l2 = if lit-val.len() > 1 and lit-val.at(1) != auto and lit-val.at(1) != none { lit-val.at(1) } else { [] }
    let l3 = if lit-val.len() > 2 and lit-val.at(2) != auto and lit-val.at(2) != none { lit-val.at(2) } else { [] }
    assert-lit(l1, field-name: "lit[0]", ignore-rules: ignore-rules)
    assert-lit(l2, field-name: "lit[1]", ignore-rules: ignore-rules)
    assert-lit(l3, field-name: "lit[2]", ignore-rules: ignore-rules)
    return (l1, l2, l3)
  }

  let txt = plain-text(lit-val)
  let (t1, t2, t3) = split-lit-tokens(txt)
  assert-lit(t1, field-name: "lit[0]", ignore-rules: ignore-rules)
  assert-lit(t2, field-name: "lit[1]", ignore-rules: ignore-rules)
  assert-lit(t3, field-name: "lit[2]", ignore-rules: ignore-rules)
  (t1, t2, t3)
}

// 5. Валидация формата и ориентации листа (ГОСТ 2.301-68, пп. 2, 4)
/// Базовые габариты основных форматов (N = 0..4) по ГОСТ 2.301-68 (короткая сторона, длинная сторона).
#let gost-base-paper-dimensions = (
  "4": (210mm, 297mm),
  "3": (297mm, 420mm),
  "2": (420mm, 594mm),
  "1": (594mm, 841mm),
  "0": (841mm, 1189mm),
)

/// Табличные габариты кратных форматов по ГОСТ 2.301-68 (Таблица 2): (ширина, высота).
#let gost-multiplied-paper-dimensions = (
  "a4x3": (630mm, 297mm),
  "a4x4": (841mm, 297mm),
  "a4x5": (1051mm, 297mm),
  "a4x6": (1261mm, 297mm),
  "a4x7": (1471mm, 297mm),
  "a4x8": (1682mm, 297mm),
  "a4x9": (1892mm, 297mm),
  "a3x3": (891mm, 420mm),
  "a3x4": (1189mm, 420mm),
  "a3x5": (1486mm, 420mm),
  "a3x6": (1783mm, 420mm),
  "a3x7": (2080mm, 420mm),
  "a2x3": (1261mm, 594mm),
  "a2x4": (1682mm, 594mm),
  "a2x5": (2102mm, 594mm),
  "a1x3": (1783mm, 841mm),
  "a1x4": (2378mm, 841mm),
  "a0x2": (1682mm, 1189mm),
  "a0x3": (2523mm, 1189mm),
)

/// Стандартные допустимые кратности M по ГОСТ 2.301-68 (Таблица 2).
#let gost-standard-multipliers = (
  "4": (3, 4, 5, 6, 7, 8, 9),
  "3": (3, 4, 5, 6, 7),
  "2": (3, 4, 5),
  "1": (3, 4),
  "0": (2, 3),
)

/// Парсит обозначение формата листа по ГОСТ 2.301-68 (семейство aNxM, N in 0..4, M >= 2 для кратных, без xM для базовых).
///
/// - paper (any): Формат листа ("a4", "a3", "a4x3", "А4х3", "A3x4" и т.д.).
/// -> dictionary: (ok: bool, n: int, m: int, display-name: str, width: length, height: length, is-standard-ratio: bool, is-multiplied: bool, key: str)
#let parse-gost-paper(paper) = {
  if paper == auto or paper == none {
    return (
      ok: true, n: 4, m: 1, display-name: "А4",
      width: 210mm, height: 297mm, is-standard-ratio: true, is-multiplied: false, key: "a4"
    )
  }
  let s = if type(paper) == str {
    paper
  } else if type(paper) == content {
    plain-text(paper)
  } else {
    str(paper)
  }
  if s == none or s == "" {
    return (
      ok: false, n: 4, m: 1, display-name: "А4",
      width: 210mm, height: 297mm, is-standard-ratio: false, is-multiplied: false, key: "unknown"
    )
  }

  let s-norm = str(s).trim()
    .replace("А", "a")
    .replace("а", "a")
    .replace("Х", "x")
    .replace("х", "x")
    .replace("*", "x")
    .replace("X", "x")
  s-norm = lower(s-norm)

  if not s-norm.starts-with("a") {
    return (
      ok: false, n: -1, m: -1, display-name: upper(str(s)),
      width: 210mm, height: 297mm, is-standard-ratio: false, is-multiplied: false, key: s-norm
    )
  }

  let rest = s-norm.slice(1)
  let n-str = ""
  let m-str = "1"
  let has-mult-syntax = rest.contains("x")
  if has-mult-syntax {
    let parts = rest.split("x")
    n-str = parts.at(0)
    m-str = if parts.len() > 1 and parts.at(1) != "" { parts.at(1) } else { "0" }
  } else {
    n-str = rest
  }

  let valid-n = ("0", "1", "2", "3", "4")
  if not (n-str in valid-n) {
    return (
      ok: false, n: -1, m: -1, display-name: upper(str(s)),
      width: 210mm, height: 297mm, is-standard-ratio: false, is-multiplied: false, key: s-norm
    )
  }

  let n-val = int(n-str)
  let m-val = int(m-str)

  // Если указан суффикс кратности 'x', значение M обязано быть >= 2 (множитель x1 недопустим по ГОСТ 2.301-68)
  if has-mult-syntax and m-val < 2 {
    return (
      ok: false, n: n-val, m: m-val, display-name: upper(str(s)),
      width: 210mm, height: 297mm, is-standard-ratio: false, is-multiplied: true, key: s-norm
    )
  }

  let is-mult = has-mult-syntax
  let disp = if is-mult {
    "А" + str(n-val) + "х" + str(m-val)
  } else {
    "А" + str(n-val)
  }

  let std-list = gost-standard-multipliers.at(str(n-val), default: ())
  let is-std = if not is-mult { true } else { std-list.contains(m-val) }

  let norm-key = if is-mult { "a" + str(n-val) + "x" + str(m-val) } else { "a" + str(n-val) }

  // Определение геометрических размеров
  let (w, h) = if norm-key in gost-multiplied-paper-dimensions {
    gost-multiplied-paper-dimensions.at(norm-key)
  } else if not is-mult {
    let (w0, h0) = gost-base-paper-dimensions.at(str(n-val))
    (w0, h0)
  } else {
    // Произвольное M >= 2
    let (w0, h0) = gost-base-paper-dimensions.at(str(n-val))
    (w0 * m-val, h0)
  }

  (
    ok: true,
    n: n-val,
    m: m-val,
    display-name: disp,
    width: w,
    height: h,
    is-standard-ratio: is-std,
    is-multiplied: is-mult,
    key: norm-key,
  )
}

/// Проверяет допустимость комбинации формата бумаги и ориентации листа (ГОСТ 2.301-68).
///
/// - paper (str): Формат листа ("a4", "a3", "a2", "a1", "a0", "a4x3" и т.д.).
/// - orientation (str): Ориентация ("portrait" или "landscape").
/// - ignore-rules (array, str, bool, none, auto): Правила для подавления.
#let assert-paper-format(paper, orientation, ignore-rules: auto) = {
  if paper == auto or orientation == auto or paper == none or orientation == none {
    return
  }
  let parsed = parse-gost-paper(paper)
  assert-rule(
    "gost-2.301-68-paper-format",
    parsed.ok,
    "Недопустимый формат листа: " + repr(paper) + ". Ожидается базовый формат (А0..А4) или дополнительный кратный формат aNxM (где M >= 2) по ГОСТ 2.301-68 (Таблицы 1 и 2). Значение с множителем x1 недопустимо (для базового формата используйте 'a4', 'a3' и т.д. без суффикса 'x1').",
    ignore-rules: ignore-rules
  )
  if not parsed.ok { return }

  let orient-norm = lower(str(orientation)).trim()
  assert-rule(
    "gost-2.301-68-paper-orientation",
    orient-norm in ("portrait", "landscape"),
    "Недопустимая ориентация листа: " + repr(orientation) + ". Ожидается 'portrait' или 'landscape' (ГОСТ 2.301-68).",
    ignore-rules: ignore-rules
  )

  if parsed.n == 4 and not parsed.is-multiplied {
    assert-rule(
      "gost-2.301-68-a4-landscape",
      orient-norm == "portrait",
      "Формат А4 по ГОСТ 2.301-68 (п. 4) допускается использовать только с вертикальной ориентацией (portrait). Горизонтальная ориентация для А4 стандартом не предусмотрена. Для подавления укажите ignore-rules: \"gost-2.301-68-a4-landscape\".",
      ignore-rules: ignore-rules
    )
  }

  if parsed.is-multiplied {
    assert-rule(
      "gost-2.301-68-paper-multiplied-ratio",
      parsed.is-standard-ratio,
      "Нестандартный коэффициент кратности формата " + parsed.display-name + " по ГОСТ 2.301-68 (Таблица 2). Для А" + str(parsed.n) + " допустимы кратности: " + repr(gost-standard-multipliers.at(str(parsed.n))) + ". Для подавления укажите ignore-rules: \"gost-2.301-68-paper-multiplied-ratio\".",
      ignore-rules: ignore-rules
    )

    assert-rule(
      "gost-2.301-68-multiplied-landscape-only",
      orient-norm == "landscape",
      "Кратные форматы aNxM (" + parsed.display-name + ") по ГОСТ 2.301-68 (п. 3) и ГОСТ 2.501-2013 допускается использовать только в горизонтальной ориентации (landscape). Вертикальная ориентация для кратных форматов стандартами не предусмотрена. Для подавления укажите ignore-rules: \"gost-2.301-68-multiplied-landscape-only\".",
      ignore-rules: ignore-rules
    )
  }
}

// 6. Валидация толщин линий (ГОСТ 2.303-68, п. 2)
// Толщина основной линии s выбирается от 0.5 до 1.4 мм.
// Толщина сплошной тонкой линии — от s/3 до s/2.
/// Проверяет толщины основной и тонкой линий и их пропорцию (ГОСТ 2.303-68).
///
/// - s-thick (length): Толщина основной сплошной линии.
/// - s-thin (length): Толщина тонкой линии.
/// - ignore-rules (array, str, bool, none, auto): Правила для подавления.
#let assert-line-thicknesses(s-thick, s-thin, ignore-rules: auto) = {
  if s-thick == auto or s-thin == auto or s-thick == none or s-thin == none { return }
  assert-rule(
    "gost-2.303-68-line-thickness-s",
    s-thick >= 0.5mm and s-thick <= 1.4mm,
    "Толщина основной линии (s) должна быть от 0.5 мм до 1.4 мм (ГОСТ 2.303-68). Передано: " + repr(s-thick),
    ignore-rules: ignore-rules
  )
  assert-rule(
    "gost-2.303-68-line-thickness-ratio",
    s-thin >= (s-thick / 3 - 0.05mm) and s-thin <= (s-thick / 2 + 0.05mm),
    "Толщина сплошной тонкой линии должна быть от s/3 до s/2 (ГОСТ 2.303-68): s = " + repr(s-thick) + ", s_thin = " + repr(s-thin) + ".",
    ignore-rules: ignore-rules
  )
}

// 7. Валидация геометрии таблицы штампа (ГОСТ 2.104-2006)
// Проверяет сумму размеров колонок и строк штампа на совпадение с эталоном.
/// Проверяет геометрическую корректность структуры ячеек штампа.
///
/// - columns (array): Массив ширин колонок.
/// - rows (array): Массив высот строк.
/// - expected-w (length): Ожидаемая суммарная ширина штампа.
/// - expected-h (length): Ожидаемая суммарная высота штампа.
/// - stamp-name (str): Наименование штампа.
/// - ignore-rules (array, str, bool, none, auto): Правила для подавления.
#let assert-stamp-geometry(columns, rows, expected-w, expected-h, stamp-name, ignore-rules: auto) = {
  let calc-w = columns.fold(0mm, (acc, w) => acc + w)
  let calc-h = rows.fold(0mm, (acc, h) => acc + h)

  assert-rule(
    "gost-2.104-2006-stamp-width",
    calc.abs((calc-w - expected-w) / 1mm) < 0.01,
    "Ошибка ширины штампа (" + stamp-name + "): сумма колонок = " + repr(calc-w) + ", ожидалось " + repr(expected-w) + " (ГОСТ 2.104-2006).",
    ignore-rules: ignore-rules
  )
  assert-rule(
    "gost-2.104-2006-stamp-height",
    calc.abs((calc-h - expected-h) / 1mm) < 0.01,
    "Ошибка высоты штампа (" + stamp-name + "): сумма строк = " + repr(calc-h) + ", ожидалось " + repr(expected-h) + " (ГОСТ 2.104-2006).",
    ignore-rules: ignore-rules
  )
}

// 8. Валидация пресета толщины линий
// "industry" — САПР-стандарт (0.8 мм толстые разделители блока изменений и подписей)
// "gost"     — буквальное следование тексту ГОСТ 2.104-2006 (0.35 мм тонкие разделители)
#let valid-line-presets = ("industry", "gost")

/// Проверяет допустимость значения пресета линий.
///
/// - preset-val (str): Значение пресета.
/// - ignore-rules (array, str, bool, none, auto): Правила для подавления.
#let assert-preset-lines(preset-val, ignore-rules: auto) = {
  if preset-val == auto or preset-val == none { return }
  assert-rule(
    "eskd-drafting-preset-lines",
    preset-val in valid-line-presets,
    "Недопустимое значение preset-lines: " + repr(preset-val) + ". Допустимо: " + repr(valid-line-presets),
    ignore-rules: ignore-rules
  )
}

// 9. Валидация номеров страниц (ГОСТ 2.104-2006, графы 7 и 8)
/// Проверяет корректность номеров текущего и общего числа листов.
///
/// - current (int, none, auto): Номер текущего листа.
/// - total (int, none, auto): Общее число листов.
/// - ignore-rules (array, str, bool, none, auto): Правила для подавления.
#let assert-page-numbers(current, total, ignore-rules: auto) = {
  if current != none and current != auto {
    assert-rule(
      "eskd-drafting-page-numbers",
      type(current) == int and current >= 1,
      "Номер текущего листа (Графа 7) должен быть целым положительным числом >= 1. Передано: " + repr(current),
      ignore-rules: ignore-rules
    )
  }
  if total != none and total != auto {
    assert-rule(
      "eskd-drafting-page-numbers",
      type(total) == int and total >= 1,
      "Общее число листов (Графа 8) должно быть целым положительным числом >= 1. Передано: " + repr(total),
      ignore-rules: ignore-rules
    )
  }
  if current != none and current != auto and total != none and total != auto {
    assert-rule(
      "eskd-drafting-page-numbers",
      current <= total,
      "Номер текущего листа (" + str(current) + ") превышает общее число листов (" + str(total) + ") по ГОСТ 2.104-2006.",
      ignore-rules: ignore-rules
    )
  }
}

// 10. Валидация масштабирования текста при автоподгонке (ГОСТ 2.304-81, 2.004-88)
/// Проверяет допустимость масштабирования текста при автоподгонке auto-fit-gost.
///
/// По ГОСТ 2.304-81 (п. 2.1) и ГОСТ 2.004-88 (п. 1.8), сжатие текста по ширине более чем
/// на 30% (< 70%) ухудшает читаемость надписи и нарушает пропорции чертежного шрифта.
/// Сжатие ниже 40% (< 40%) делает текст нечитаемым при уменьшении и тиражировании.
///
/// - scale-val (float): Рассчитанный коэффициент масштабирования (0.0..1.0).
/// - text-val (any): Исходное значение текста.
/// - ignore-rules (array, str, bool, none, auto): Правила для подавления.
#let assert-text-scale(scale-val, text-val: [], ignore-rules: auto) = {
  if scale-val >= 0.999 { return }

  let txt-str = plain-text(text-val).trim()
  let chars = txt-str.clusters()
  let txt-preview = if chars.len() > 30 { chars.slice(0, 27).join("") + "..." } else { txt-str }

  if scale-val < 0.70 {
    assert-rule(
      "gost-text-scale-warning",
      false,
      "Текст «" + txt-preview + "» сжат до " + str(calc.round(scale-val * 100, digits: 1)) + "% (< 70%), что нарушает читаемость чертежного шрифта (ГОСТ 2.304-81 п. 2.1, ГОСТ 2.004-88 п. 1.8). Для подавления укажите ignore-rules: \"gost-text-scale-warning\".",
      ignore-rules: ignore-rules
    )
  }

  if scale-val < 0.40 {
    assert-rule(
      "gost-text-scale-extreme",
      false,
      "Экстремальное сжатие текста «" + txt-preview + "» до " + str(calc.round(scale-val * 100, digits: 1)) + "% (< 40%). Текст абсолютно нечитаем (ГОСТ 2.304-81, ГОСТ 2.004-88). Для подавления укажите в ignore-rules оба правила: (\"gost-text-scale-extreme\", \"gost-text-scale-warning\").",
      ignore-rules: ignore-rules
    )
  }
}

// 11. Вместимость строк участников документа (ГОСТ 2.104-2006, графы 10-13)
/// Проверяет, что количество переданных строк участников не превышает
/// физическую вместимость соответствующей формы штампа (Форма 1 — 6 строк, Форма 2 — 5 строк).
///
/// - members-list (any): Массив участников.
/// - max-rows (int): Максимальное допустимое количество строк.
/// - form-name (str): Название формы для сообщения об ошибке.
/// - ignore-rules (array, str, bool, none, auto): Правила для подавления.
#let assert-members-capacity(members-list, max-rows: 6, form-name: "Форма 1", ignore-rules: auto) = {
  if members-list == none or members-list == auto or type(members-list) != array { return }
  assert-rule(
    "gost-2.104-2006-members-overflow",
    members-list.len() <= max-rows,
    "Количество строк участников (members: " + str(members-list.len()) + ") превышает вместимость штампа " + form-name + " (максимум " + str(max-rows) + " по ГОСТ 2.104-2006). " + str(members-list.len() - max-rows) + " строк не будут отображены. Для подавления укажите ignore-rules: \"gost-2.104-2006-members-overflow\".",
    ignore-rules: ignore-rules
  )
}

// 12. Вместимость таблицы изменений (ГОСТ 2.104-2006, графы 14-18)
/// Проверяет, что количество записей об изменениях не превышает
/// физическую вместимость штампа текущего листа.
///
/// - changes-val (any): Запись или массив записей таблицы изменений.
/// - max-rows (int): Максимальное количество отображаемых строк.
/// - form-name (str): Название формы для сообщения об ошибке.
/// - ignore-rules (array, str, bool, none, auto): Правила для подавления.
#let assert-changes-capacity(changes-val, max-rows: 1, form-name: "Форма", ignore-rules: auto) = {
  if changes-val == none or changes-val == auto { return }
  let count = if type(changes-val) == array { changes-val.len() } else { 0 }
  assert-rule(
    "gost-2.104-2006-changes-overflow",
    count <= max-rows,
    "Количество записей об изменениях (changes: " + str(count) + ") превышает вместимость штампа " + form-name + " (максимум " + str(max-rows) + " по ГОСТ 2.104-2006). " + str(count - max-rows) + " записей не будут отображены. Для подавления укажите ignore-rules: \"gost-2.104-2006-changes-overflow\".",
    ignore-rules: ignore-rules
  )
}

// 13. Валидация поддержки таблицы содержания (ГОСТ 2.104-2006, ГОСТ 2.105-2019)
/// Проверяет недопустимость передачи параметра оглавления (toc) в формы, которые его не поддерживают.
/// Шапка содержания по ГОСТ 2.105-2019 / ГОСТ 2.106-96 поддерживается исключительно в Форме 2.
///
/// - toc (any): Значение параметра toc.
/// - form-name (str): Имя проверяемой формы.
/// - ignore-rules (array, str, bool, none, auto): Правила для подавления.
#let assert-toc-unsupported(toc, form-name: "Форма", ignore-rules: auto) = {
  if toc == none or toc == auto {
    return
  }
  assert-rule(
    "gost-2.104-2006-toc-unsupported",
    false,
    "Параметр таблицы содержания (toc) не поддерживается в " + form-name + ". Шапка содержания (ГОСТ 2.105-2019) поддерживается только в Форме 2. Для подавления укажите ignore-rules: \"gost-2.104-2006-toc-unsupported\".",
    ignore-rules: ignore-rules
  )
}


