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
// UPD: функция теперь создает фигуру с кастомным kind
// "appendix" - "приложение" что позволяет давать ссылки
// на него, боже почему я так плохо знаю этот язык, что
// только сейчас это смог сделать...
#let appendix(type, name) = figure(
  kind: "appendix",
  // Нумерация - буква приложения
  numbering: (..nums) => {
    appendix-letters.at(
      appendix-counter.get().first()
    )
  },
  supplement: [Приложение], 
  // Никто этим не будет пользоваться, но это нужно для
  // ссылки на приложения

  // Тут идет тело приложения, как было до этого 
  {

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
)

// двухуровневая нумерация для перечислений
// взято из проекта https://github.com/artemious3/bsuir_typst
//
// TODO: если это получится, сделать возможность
// ссылаться на элементы перечислений
#let abclist(..a) = {
  set enum(indent: 25mm, numbering: "1)")

  let items = a.pos().enumerate().map(
    ((idx,item)) => cyr-letters.at(idx) + ") " + item + parbreak()
  )
  parbreak()+items.join()
}

#let explanation(terms) = {
  set grid(
    columns: (auto, 1fr),
    column-gutter: 0.3em,
  )

  grid(
    [где], 
    {
      terms.children
        .filter(x => x != [ ])
        .map(x => grid(
          {
            x.term + [ -- ]
          },
          par(
            first-line-indent: 0pt,
            x.description
          )
        ))
        .join()

    }
  )
}

