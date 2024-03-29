#import "../common/data.typ": * // Данные пользователя 
#import "../common/style.typ": * // Общие настройки стиля 
#import "@preview/glossarium:0.2.6":*
#import "@preview/codly:0.2.0": *
#import "@preview/tablex:0.0.8": tablex, vlinex, hlinex, colspanx, rowspanx, cellx

// Установка свойств к PDF файлу 
#set document(author: author-name, title: thesis-title)
  
// Счетчики  
#let part_count = counter("parts")
#let total_part = context[#part_count.final().at(0)]
#let appendix_count = counter("appendix")
#let total_appendix = context[#appendix_count.final().at(0)]
#let total_page = context[#counter(page).final().at(0)]
#let total_fig = context[#counter(figure).final().at(0)]
#let total_table = context[#counter(figure.where(kind:table)).final().at(0)]

#let bib_count = counter("bib_refs")
#let total_bib = context[#bib_count.final().at(0)]

// Это входная точка - общий шаблон  
#let phd-template(
  languages: (), 
  body,
) = {
  // Установки шрифта 
  set text(
    font: phd-font-type,
    lang: "ru",
    size: phd-font-size,
    fallback: true,
    hyphenate: false,
  )
  
  // Установка свойств страницы 
  set page(
    margin: (top:2cm, bottom:2cm, left:2.5cm, right:1cm), // размер полей (ГОСТ 7.0.11-2011, 5.3.7)
    numbering: "1", // Установка сквозной нумерации страниц 
    number-align:center+top, // Нумерация страниц сверху, по центру 
  )
  counter(page).update(1)
    
  // Установка свойств параграфа 
  set par(
    justify: true, 
    linebreaks: "optimized",
    first-line-indent: 2.5em, // Абзацный отступ. Должен быть одинаковым по всему тексту и равен пяти знакам (ГОСТ Р 7.0.11-2011, 5.3.7).
    leading: 1.5em, // Полуторный интервал (ГОСТ 7.0.11-2011, 5.3.6)
  ) 

  // форматирование заголовков
  set heading(numbering: "1.", outlined: true, supplement: [Раздел])
  show heading: it => {
    set align(center)
    set text(
      font: phd-font-type, 
      size: phd-font-size,)
    set block(above:3em,below:3em) // Заголовки отделяют от текста сверху и снизу тремя интервалами (ГОСТ Р 7.0.11-2011, 5.3.5)
    
    if it.level == 1 {
      pagebreak() // новая страница для разделов 1 уровня 
      counter(figure).update(0) // сброс значения счетчика рисунков 
      counter(math.equation).update(0) // сброс значения счетчика уравнений 
      }
      else{
      }
    it
  }

  show ref: it => {
  it 
  if it.element != none {
    return 
  }
  bib_count.step() // Счетчик библиографии
  }

  // Настройка блоков кода 
  show: codly-init.with()
  codly(languages: languages)
  
  // Инициализация глоссария 
  show: make-glossary
  show link: set text(fill: link-color)

  // Нумерация уравнений 
  let eq_number(it) = {
    let part_number = counter(heading.where(level:1)).get()
    part_number 

    it
  }
  set math.equation(numbering: num => 
    ("("+(counter(heading.where(level:1)).get() + (num,)).map(str).join(".")+")"),
    supplement: [Уравнение],)
  
  // Настройка рисунков 
  show figure: align.with(center)
  set figure(supplement: [Рисунок])
  set figure.caption(separator: [ -- ])
  set figure(numbering: num => 
    ((counter(heading.where(level:1)).get() + (num,)).map(str).join(".")),
    supplement: [Рисунок],)
  
  // Настройка таблиц
  show figure.where(kind:table): set figure.caption(position: top)
  show figure.where(kind:table): set figure(supplement: [Таблица])
  show figure.where(kind:table): set figure(numbering: num => 
    ((counter(heading.where(level:1)).get() + (num,)).map(str).join(".")),
    supplement: [Таблица],)
  // Разбивать таблицы по страницам 
  show figure: set block(breakable: true)
  
  // Настройка списков 
  set enum(indent: 2.5em)

  // Set that we're in the body
  state("section").update("body")
  
  body
}

// Нужно начать первый абзац в разделе с этой функции для отступа первой строки 
#let ident-par(it) = par[#h(2.5em)#it]

// Set up the styling of the appendix.
#let phd-appendix(body) = {
  
  // Reset the title numbering.
  counter(heading).update(0)
  
  // Number headings using letters.
  show heading.where(level:1): set heading(numbering: "Приложение A. ", supplement: [Приложение])
  show heading.where(level:2): set heading(numbering: "A.1 ", supplement: [Приложение])
  
  // Set the numbering of the figures.
  set figure(numbering: (x) => locate(loc => {
    let idx = numbering("A", counter(heading).at(loc).first())
    [#idx.#numbering("1", x)]
  }))
  
  // Additional heading styling to update sub-counters.
  show heading: it => {
    appendix_count.step() // Обновление счетчика приложений
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: math.equation)).update(0)
    counter(figure.where(kind: raw)).update(0)
    
    it
  }
  
  // Set that we're in the annex
  state("section").update("annex")
  
  body
}

#let icon(codepoint) = {
  box(
    height: .8em,
    baseline: 0.05em,
    image(codepoint)
  )
  h(0.1em)
}