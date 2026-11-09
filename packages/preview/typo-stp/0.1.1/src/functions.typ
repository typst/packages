#import "constants.typ" : *

// функция листинга файла
#let source-text(path, name) = {
  // чтение содержимого файла

  let file-content = read(path)
    // обрезка переносов строк в файле 
    .trim(at: end, "\n")
    .trim(at: start, "\n")

  [
    // отображаемое название файла
    #text[
      #name
    ]

    // исходный текст файла
    #raw(
      file-content,
      block: true,
    )
  ]
}

#let introduction = {
  heading(numbering: none)[
    Введение
  ]
}

#let abstract = {
  heading(numbering: none)[
    Реферат
  ]
}

#let conclusion = {
  heading(numbering: none)[
    Заключение
  ]
}

// функция создания приложения
#let appendix(type, name) = {
  // увеличение счетчика приложений (номер в массиве с буквами)
  appendix-counter.step()

  // сброс счетчиков для рисунков, таблиц в приложениях
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(math.equation).update(0)


  // Полу-костыль, чтобы название приложения 
  // отличалось от того, что в содержании
  show heading: it => {
    align(center)[
      #pagebreak()
      ПРИЛОЖЕНИЕ #context appendix-letters.at(appendix-counter.get().first() - 1)
    ]
  }

  // Формирование приложения как заголовка 1-го уровня,
  // но со специальной нумерацией вида "Приложение Я".
  // Да, именно со всем словом "Приложение"
  heading(
    numbering: appendix-numbering,
  )[(#type) #name]

  // Добавление подписи типа приложения и его названия 
  align(center)[ * (#type) \ #name * ]

  v(1.0em, weak: true)
}


