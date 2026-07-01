#import "@preview/unify:0.5.0": *
#import "@preview/codly:0.2.0": *
#import "@preview/tablex:0.0.8": *
#import "@preview/physica:0.9.3": *
#import "./glossarium.typ": *

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
#let template(
  author-first-name: "Имя Отчество",
  author-last-name: "Фамилия",
  author-initials: "И.О.",
  title: "Длинное-длинное название диссертации из достаточно большого количества сложных и непонятных слов",
  udk: "xxx.xxx", // Диссертация, УДК
  specialty-number: "XX.XX.XX",
  specialty-title: "Название специальности",
  degree: "кандидата физико-математических наук",
  degree-short: "канд. физ.-мат. наук",
  city: "Город",
  year: datetime.today().year(),
  organization: [Федеральное государственное автономное образовательное учреждение высшего образования "Длинное название образовательного учреждения \ "АББРЕВИАТУРА"],
  in-organization: "учреждении с длинным длинным длинным длинным названием, в котором выполнялась данная диссертационная работа", // в предложном падеже 
  organization-short: "Сокращенное название организации",
  supervisor-first-name: "Имя Отчество",
  supervisor-last-name: "Фамилия",
  supervisor-initials: "И.О.",
  supervisor-regalia: "уч. степень, уч. звание",
  supervisor-regalia-short: "уч. ст., уч. зв.",
  font-type: "Times New Roman",
  font-size: 14pt,
  link-color: blue.darken(60%),
  languages: (), 
  logo: "",
  body,
  ) = {

  // Определение новых переменных
  let author-name = author-last-name+" "+author-first-name
  let author-short = author-last-name+" "+author-initials
  let supervisor-name = supervisor-last-name+" "+supervisor-first-name
  let supervisor-short = supervisor-last-name+" "+supervisor-initials

  // Установка свойств к PDF файлу 
  set document(author: author-name, title: title)

  // Установки шрифта 
  set text(
    font: font-type,
    lang: "ru",
    size: font-size,
    fallback: true,
    hyphenate: false,
  )
  
  // Установка свойств страницы 
  set page(
    margin: (top:2cm, bottom:2cm, left:2.5cm, right:1cm), // размер полей (ГОСТ 7.0.11-2011, 5.3.7)
  )
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
      font: font-type, 
      size: font-size,)
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
  
  // титульный лист 
  set align(center)
  organization
  v(2em)
  table(
    columns: (1fr,1fr),
    stroke: none,
    align: (left+bottom, right+bottom),
    logo,
    "На правах рукописи"
  )
  set text(size:16pt)
  v(1em)
  author-name // ФИО автора 
  v(1em)
  [*#title*] // Название работы 
  set text(size:font-size)
  v(1em)
  [Специальность #specialty-number -- ] // Номер специальности
  v(0em)
  specialty-title // Название специальности
  v(1em)
  "Диссертация на соискание учёной степени"
  v(0em)
  degree
  v(5fr)
  set align(right)
  "Научный руководитель:"
  v(0em)
  supervisor-regalia 
  v(0em)
  supervisor-name
  v(0em)
  set align(center)
  [#city -- #year]
  set align(left)
  // конец титульной страницы

  set page(
    numbering: "1", // Установка сквозной нумерации страниц 
    number-align:center+top, // Нумерация страниц сверху, по центру 
  )
  counter(page).update(1)
  
  // Содержание 
  // #align(right)[Стр.]
  outline(title: "Содержание", indent: 1.5em, depth: 3,)

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

#let icon(image) = {
  box(
    height: .8em,
    baseline: 0.05em,
    image
  )
  h(0.1em)
}