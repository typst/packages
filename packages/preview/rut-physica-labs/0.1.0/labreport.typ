// Величина абзацного отступа (ГОСТ 7.32-2017: 1.25 см)
#let indent_value = 1.25cm
// Убрать абзацный отступ по требованию
#let noindent = h(-indent_value)
// Межстрочный интервал (ГОСТ 7.32-2017: полуторный)
// leading — расстояние между базовыми линиями внутри абзаца
// spacing — расстояние между абзацами
#let leading = 1.5em - 0.75em
#let spacing = 1.5em
// Размер шрифта (ГОСТ: 14 пт)
#let fontsize = 14pt

// Отступы заголовков
#let heading-margin = (above: 2em, below: 2em)

// Заголовки структурных разделов (без нумерации, по центру, прописными)
#let structural-heading-titles = (
  [Содержание],
  [Введение],
  [Заключение],
  [Список использованных источников],
)

// Стиль структурного заголовка
#let structure-heading-style(it) = {
  align(center)[#upper(it)]
}

// Функция для создания структурного заголовка
#let structure-heading(body) = {
  structure-heading-style(heading(numbering: none)[#body])
}

// ===== ПРИЛОЖЕНИЯ (ГОСТ 7.32-2017, п. 6.14) =====

// Русский алфавит для нумерации приложений (без Ё, З, Й, О, Ч, Ъ, Ы, Ь)
#let _appendix-alphabet = (
  "А", "Б", "В", "Г", "Д", "Е", "Ж",
  "И", "К", "Л", "М", "Н", "П", "Р",
  "С", "Т", "У", "Ф", "Х", "Ц", "Ш",
  "Щ", "Э", "Ю", "Я",
)

// Получить букву приложения по номеру
#let _get-appendix-letter(num) = {
  if num > 0 and num <= _appendix-alphabet.len() {
    _appendix-alphabet.at(num - 1)
  } else {
    str(num)
  }
}

// Нумерация заголовков в приложениях: А, А.1, А.1.1, ...
#let _appendix-heading-numbering(..nums) = {
  let n = nums.pos()
  let letter = _get-appendix-letter(n.first())
  let rest = n.slice(1).map(x => str(x))
  if rest.len() > 0 {
    (letter, ..rest).join(".")
  } else {
    letter
  }
}

// Проверка: находится ли заголовок в разделе приложений
#let _is-heading-in-appendix(heading) = state("appendixes", false).at(
  heading.location(),
)

// Нумерация элементов (рисунков, таблиц, формул) в приложениях: А.1, А.2, ...
#let _get-appendix-element-numbering(current-heading-numbering, element-numbering) = {
  if current-heading-numbering.first() <= 0 or element-numbering <= 0 {
    return
  }
  let letter = _get-appendix-letter(current-heading-numbering.first())
  (letter, numbering("1", element-numbering)).join(".")
}

// Заголовок приложения с указанием статуса (обязательное/справочное)
#let appendix-heading(status, level: 1, body) = {
  heading(level: level)[(#status)\ #body]
}

// Функция-обёртка для раздела приложений
#let appendixes(content) = {
  set heading(numbering: _appendix-heading-numbering)

  // Заголовок 1-го уровня (само приложение): по центру, прописными
  show heading.where(level: 1): set heading(hanging-indent: 0pt)
  show heading.where(level: 1): set align(center)
  show heading.where(level: 1): it => context {
    // Сброс счётчиков для каждого нового приложения
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    counter(math.equation).update(0)
    pagebreak(weak: true)
    block[#upper([приложение]) #numbering(
        it.numbering,
        ..counter(heading).at(it.location()),
      ) \ #text(weight: "medium")[#it.body]]
  }

  // Нумерация рисунков/таблиц/кода в приложениях: А.1, А.2, ...
  set figure(numbering: it => {
    let current-heading = counter(heading).get()
    _get-appendix-element-numbering(current-heading, it)
  })

  // Нумерация формул в приложениях: (А.1), (А.2), ...
  set math.equation(numbering: it => {
    let current-heading = counter(heading).get()
    [(#_get-appendix-element-numbering(current-heading, it))]
  })

  state("appendixes").update(true)
  counter(heading).update(0)
  content
}


#let labreport(
  designation: [],
  authors: (),
  affilation: (),
  teacher: (),
  lector: (),
  abstract: [],
  doc
) = {
  set text(
    font: "STIX Two Text",
    lang: "ru",
    size: fontsize,
    hyphenate: false,
  )

  // Поля страницы по ГОСТ 7.32-2017:
  // левое — 30 мм, правое — 15 мм, верхнее — 20 мм, нижнее — 20 мм
  set page(
    paper: "a4",
    margin: (
      left: 30mm,
      right: 15mm,
      top: 20mm,
      bottom: 20mm,
    ),
    // Нумерация страниц: внизу по центру (ГОСТ 7.32-2017, п. 6.3)
    // Титульный лист включают в общую нумерацию, но номер на нём не ставят
    footer: context {
      let page_num = counter(page).get().first()
      if page_num == 1 {
        // Футер титульной страницы
        set text(size: 11pt)
        align(center)[Москва, #datetime.today().year()]
      } else {
        // Номер страницы для всех остальных листов
        align(center)[#counter(page).display()]
      }
    }
  )

  place(
    top + center,
    float: true,
    scope: "parent",
    {
      grid(
        columns: (2fr, 3fr),
        align: (left, center),
        [#image("лого.png", width: 70%)],
        text(size: 10pt)[
          *Федеральное государственное автономное \ образовательное учреждение высшего образования \ «Российский университет транспорта» (РУТ (МИИТ)) \
          Кафедра «Физика» им. П.Н. Лебедева \
          Академия базовой подготовки*
        ],
      )
      
      v(1cm)
      
      text(size: 16pt, tracking: 2pt)[
        Работа #upper(designation)
      ]
      v(-0.5em)
      
      upper(title())
      v(1cm)

      par(justify: false)[
        Выполнили студенты группы~#upper(affilation.group), подгруппа~#affilation.subgroup, бригада~#affilation.crew
      ]
      v(1em)
      
      let count = authors.len()
      let ncols = calc.min(count, 3)
      grid(
        columns: (1fr,) * ncols,
        row-gutter: 0.8em,
        ..authors.map(author => [
          #author.name
        ]),
      )

      v(1cm)
      grid(
        columns: (1fr, 1fr),
        row-gutter: 0.8em,
        [Преподаватель:\ #teacher], [Лектор:\ #lector],
      )

      v(3em)
      grid(
        columns: (1fr, 1fr, 5fr),
        rows: 4,
        row-gutter: 2em,
        column-gutter: 0.5em,
        align: (right, left, left),
        [Допуск:], [\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_], [],
        [Измерение:], [\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_], [],
        [Защита:], [\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_], [],
        [Оценка:], [\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_], [],
      )

      v(2cm)
    }
  )

  
  pagebreak()


  // ===== НАСТРОЙКИ ОСНОВНОГО ТЕКСТА =====

  // Настройка абзацев (ГОСТ 7.32-2017)
  set par(
    first-line-indent: (amount: indent_value, all: true),
    justify: true,
    leading: leading,
    spacing: spacing,
  )

  // Списки
  // - маркированные (ГОСТ: маркер — тире)
  set list(
    marker: [–],
    indent: indent_value,
    body-indent: 0.5em,
    spacing: 1em,
    tight: false,
  )
  // - нумерованные
  set enum(
    numbering: "1)",
    indent: indent_value,
    body-indent: 0.5em,
    spacing: 1em,
    tight: false,
  )

  // Выравнивание по ширине для элементов списков
  show list.item: it => {
    set par(justify: true)
    it
  }
  show enum.item: it => {
    set par(justify: true)
    it
  }

  // Ссылки: убираем автоматическое дополнение (supplement)
  set ref(supplement: none)

  // Заголовки (ГОСТ 7.32-2017, п. 6.1)
  set heading(numbering: "1.1")
  show heading: set text(size: fontsize, weight: "bold")
  show heading: set block(..heading-margin)
  show heading: set par(justify: false)

  // Все заголовки — с отступом слева (кроме структурных)
  show heading: it => {
    if it.body not in structural-heading-titles {
      pad(it, left: indent_value)
    } else {
      it
    }
  }

  // Заголовки 1-го уровня: с новой страницы
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    it
  }

  // Структурные заголовки: без нумерации, по центру, прописными
  let structural-heading-selector = structural-heading-titles
    .fold(selector, (acc, title) => acc.or(heading.where(body: title, level: 1)))

  show structural-heading-selector: set heading(numbering: none)
  show structural-heading-selector: it => {
    pagebreak(weak: true)
    structure-heading-style(it)
  }

  // Подписи рисунков и таблиц (ГОСТ 7.32-2017)
  set figure.caption(separator: [~---~])

  // Рисунки (figure) — ГОСТ 7.32-2017, п. 6.5
  show figure: pad.with(bottom: 0.5em)
  show image: set align(center)
  show figure.where(kind: image): set figure(supplement: [Рисунок])

  // Таблицы — ГОСТ 7.32-2017, п. 6.6
  show figure.where(kind: table): it => {
    set figure.caption(position: top)
    it
  }
  show figure.where(kind: table): set block(breakable: true)
  show figure.caption.where(kind: table): set align(left)
  show table.cell: set align(left)

  // Блоки кода — разрешаем разрыв на несколько страниц
  show figure.where(kind: raw): set block(breakable: true)

  // Математика
  // Шрифт
  show math.equation: set text(font: "STIX Two Math")
  // Нумерация формул: справа в скобках (ГОСТ 7.32-2017, п. 6.4)
  // По умолчанию нумерация отключена.
  // Чтобы пронумеровать формулу, укажите numbering явно:
  //   #set math.equation(numbering: "(1)")
  // или используйте label и включите нумерацию локально.
  // Межстрочные интервалы
  show math.equation: set block(
    above: spacing + 0.35em,
    below: spacing + 0.35em,
  )
  // Замена десятичного разделителя: "." → ","
  show math.equation: it => {
    show regex("\d+\.\d+"): it => {
      show ".": {","+h(0pt)}
      it
    }
    it
  }
  // Прямое начертание для греческих символов
  show math.equation: it => {
    show regex("[\u{0370}-\u{03FF}]"): math.upright
    it
  }

  // Библиография (ГОСТ Р 7.0.5-2008)
  set bibliography(style: "gost-r-705-2008-numeric")

  // Цвет гиперссылок
  // show link: set text(fill: black)

  // Содержание (ГОСТ 7.32-2017, п. 6.10)
  set outline(indent: indent_value, depth: 3)
  show outline: set block(below: indent_value / 2)
  // Отображение приложений в содержании:
  // — уровень 1: «Приложение А Название»
  // — уровень 2+: «А.1 Название» (без слова «Приложение»)
  show outline.entry: it => {
    show linebreak: [ ]
    if _is-heading-in-appendix(it.element) {
      let body = if it.element.level == 1 {
        [Приложение #it.prefix(). #it.element.body]
      } else {
        [#it.prefix() #it.element.body]
      }
      link(it.element.location(), it.indented(
        none,
        body
          + sym.space
          + box(width: 1fr, it.fill)
          + sym.space
          + sym.wj
          + it.page(),
      ))
    } else {
      it
    }
  }

  context {
    let total-pages = counter(page).final().first()
    if total-pages > 10 {
      {
        show heading: it => align(center)[#upper(it.body)]
        heading(outlined: false, numbering: none)[Содержание]
      }
      outline(title: none)
      pagebreak()
    }
  }

  align(center)[
    #par(justify: false, leading: 0.8em)[
      *Аннотация* \
      #text(size: 11pt)[#abstract]
    ]
  ]
  v(1.5em)

  doc
}
