#import "constants.typ" : *

#let template(body) = [
  // Общие настройки шрифта из 2.1.1
  #set text(
    font: main-font,
    size: font-size,

    // На... ~кхм~ зачем делать стандарты только под микрослоп ворд...
    top-edge: 1em,       // установка top-edge и bottom-edge 
    bottom-edge: 0em,    // чтобы правильно работал leading

    hyphenate: true,    // переносы

    lang: "ru",

    costs: (
      orphan: 0%,
      widow: 0%,
    )
  )

  // weak, чтобы перед первым разделом
  // не было пустой 
  #set pagebreak(
    weak: true,
  )

  // Размер листа из того же 2.1.1
  #set page(
    paper: "a4",
    numbering: "1",

    // поля
    margin: (
      top: 2cm,
      bottom: 2cm,
      right: 1.5cm,
      left: 3cm,
    ),

    // по дефолту номер страницы пишется
    // посередине, тут устанавливается
    // в нужное место
    footer: context {
      place(
        bottom + right,
        dy: -1cm,
        counter(page).display(),
      )
    }
  )

  // абзацы
  #set par(
    justify: true,
  
    // тот самый leading
    leading: right-leading, 
    spacing: right-leading,

    // абзацный отступ (красная строка)
    first-line-indent: (
      amount: 1.25cm,
      all: true
    ),
  )



  // простое перечисление 
  #set list(
    tight: true,
    marker: [--],
  )

  #show list.item: it => {
    par()[-- #it.body]

  }


  // по-дефолту будет нумерация просто 1, 2 и т.д.
  #set enum(
    numbering: default-enum-numbering,
    full: true,
  )

  #show enum.where(numbering: default-enum-numbering): it => {
    let start = 1

    // установка начального значения при задании
    // номера первого элемента
    if it.children.first().number != auto {
      start = it.children.first().number
    }

    let enumerated-enum = it.children.enumerate(start: start)

    for (number, item) in enumerated-enum {
      par[#str(number) #item.body]
    }
  }


  // Заголовки (названия разделов, подразделов, пунктов)
  // (пункты и подпункты могут быть с пустым заголовком)
  #set heading(
    numbering: "1.1.1.1",
    bookmarked: true,
    outlined: true,
  )

  // Настройки текста для заголовков из 2.1.1, 2.2.1 - 2.2.5
  #show heading: set text(
    font: main-font, 
    size: font-size,
    weight: "bold",
    hyphenate: false,         // отключение переносов
  )

  // добавление к заголовкам пробельной строки
  #show heading: it => {
    v(line-height + right-leading, weak: true)      // перед всеми заголовками 1 пробельная строка

    // не добавлять абзацный отступ к заголовкам,
    // которые располагаются по-центру
    if it.numbering != none and it.numbering != appendix-numbering {
      pad(left: 1.25cm, it)   // абзацный отступ для нумерованных разделов

    } else {                  // для ненумерованных разделов он не нужен
      it
    }

    if it.level < 3 {
      v(line-height + right-leading, weak: true)    // только после названий разделов, подразделов
    }
  } 

  // отдельные настройки для разделов
  #show heading.where(level: 1): it => {

    // сброс нумераций для рисунков, таблиц в разделе
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(math.equation).update(0)

    // добавление разрыва страницы (2.2.6) 
    // 
    // upper т.к. в тексте название д.б.
    // в верхнем регистре, а в содержании
    // в как обычный текст
    // т.е. в документе названия разделов писать по 
    // правилам, условно "Введение", "Обзор литературы"
    // будут отображаться как "ВВЕДЕНИЕ", "ОБЗОР ЛИТЕРАТУРЫ",
    // а в содержании все еще будут в исходном виде
    pagebreak() + upper(it)

  } 

  // Настройка для ненумерованных разделов, чтобы они
  // отображались по-центру
  //
  // Возможно, сделаю отдельные функции для 
  // создания введения, заключения и т.д. 
  #show heading.where(numbering: none): it => {
    show: set align(center)
    it
  }

  // настройки для пунктов 
  // 
  // !!!
  // В 2.2.5 сказано: "Пункты, как правило, заголовков не имеют"
  // но вообще ни слова, какие правила оформления этих заголовков,
  // так что для самих заголовков формат названий подразделов. 
  // Если же заголовка нет, то как и в примере остается только номер
  // пункта.
  //
  // upd: в 2.1.1 сказано "Названия разделов и подразделов
  // выделяются полужирным шрифтом" т.е. название пунктов, подпт. 
  // должны быть оформлены обычным шрифтом (?)
  //
  // upd2: в 2.2.7 сказано "В содержании заголовки выравнивают, соподчиняя по
  // разделам, подразделам и пунктам (если последние имеют заголовки)..." 
  // Т.е. в содержании нужно указывать пункты, имеющие заголовки

  // пункты не включаются в содержание,
  // если только у них нет заголовка
  #show heading.where(level: 3): set heading(
    outlined: false,
  )


  // TODO: если есть вариант это сделать по-нормальному без
  // ручного прописывания outlined
  //
  // или забить, оно же работает :)

  // в зависимости от того, пуст ли заголовок,
  // разное оформление
  #show heading.where(level: 3): it => {

    // если пуст - заголовка нет => номер пункта
    if is-heading-empty(it) {
      parbreak()
      v(line-height + right-leading, weak: true)            // почему-то этот отступ убрался (?)

      counter(heading).display()
      [ ]

      // если заголовок не пуст, но не включен в содержание
    } else if not it.outlined {
      
      // отнимаем от счетчика пунктов 1, т.к.
      // будем рекурсивно делать заголовок из
      // этого заголовка
      //
      // это ужасно, знаю
      counter(heading).update(
        (first, second, third) => (first, second, third - 1)
      )

      // рекурсивный заголовок (уже включаемый в содержание)
      heading(
        level: 3,
        outlined: true,
      )[
        #it.body
      ]
    
      // если уже включен - рекурсивный случай
    } else {
      
      // оформление загловка пункта
      parbreak()
      v(line-height + right-leading, weak: true)
      counter(heading).display()
      [ ]

      show text: set text(weight: "regular")
      
      it.body
      parbreak()
    }
  }


  // в самом СТП нумерация подпунктов выполнена
  // обычным шрифтом, но явно это не было сказано,
  // так что примем это как норму
  //
  // Подпункты 
  #show heading.where(level: 4): it => {
    show heading: set heading(
      outlined: false,
    )
    show text: set text(
      weight: "regular",
    )

    parbreak()
    counter(heading).display()
    [ ]

  }

  // содержание
  #set outline(
    title: none,
    depth: 3,
    indent: 1em,
  )
  // автоматическое добавление
  // слова "СОДЕРЖАНИЕ", 
  // потому что я не понял как сделать
  // это через title чтобы оно было
  // по-центру и с 1 пробельной строкой
  #show outline: it => {
    align(center)[*СОДЕРЖАНИЕ*] // слово "СОЖЕРЖАНИЕ" из 2.2.7
    v(1.0em, weak: false)       // пробельная строка
    it                          // собственно содержание
  }

  #show outline.entry: it => {
    set text(
      hyphenate: false,
    )
    it
  }


  #set figure(

    // устанавливает нумерацию раздел.номер
    // или буква приложения.номер
    numbering: (..nums) => {

      // просто номер фигуры
      let n = nums.pos().first()

      // если на данный момент нет приложений 
      // (т.е. фигура в обычном разделе)
      if appendix-counter.get().first() == 0 {
        numbering(
          "1.1",
          counter(heading).get().first(),
          n,
        )

      // если приложение уже обнаружено
      // (т.е. фигура в приложении т.к.
      // откуда взяться разделу после приложения)
      } else {
        appendix-letters.at( 
          appendix-counter.get().first() -1
        )
        [.]
        str(n)
      }
    }
  )

  #show figure.caption: set text(hyphenate: false)

  // разделитель "тире" (которое n-dash) из 2.5.5
  #set figure.caption(
    separator: [ -- ],
  )

  // настройки для рисунков (иллюстраций)
  // положение "подрисуночной подписи"
  #show figure.where(kind: image): set figure.caption(position: bottom)
  // надпись и её отступ от самого рисунка
  #show figure.where(kind: image): set figure(
    supplement: "Рисунок",
    gap: 1.0em,
  )
  // добавление отступов перед рисунком и после подписи
  #show figure.where(kind: image): it => {

    v(line-height + right-leading, weak: true)
    it
    v(line-height + right-leading, weak: true)

  }

  // настройки для таблиц
  //
  // TODO остальные настройки для таблиц
  #show figure.where(kind: table): set figure.caption(position: top)
  #show figure.caption.where(kind: table): set align(left)
  #show figure.where(kind: table): set figure(
    supplement: "Таблица",
    gap: table-caption-indent,
  )

  // добавление к таблице номера в специальном формате
  #show figure.where(kind: table): it => {
    v(1.0em + right-leading, weak: true)

    // обнуление счетчика шапок таблиц
    table-headers-counter.update(0)



    // разная нумерация в разделах и приложениях
    // 
    // впринципе, такое уже было в рисунках, еще
    // раз пояснять смысла не вижу
    let table-numbering = [
      #if appendix-counter.get().first() == 0 {
        context counter(figure.where(kind: table)).display()
      } else {
        context appendix-letters.at(appendix-counter.get().first() - 1)
        [.]
        context counter(figure.where(kind: table)).get().first()
      }
    ]

    // Название таблицы будет писаться как хедер
    show figure.caption: cap => {} 

    // Отключение переносов
    set text(hyphenate: false)
    // Отключение растягивания текста по ширине и отключение
    // аюзацев для хедера
    set par(first-line-indent: 0pt, justify: false)

    // создание новой таблицы со спец. header'ом
    table(
      fill: none,
      stroke: 0pt,

      // Просто заберите у меня typst, это закончится плохо
      //
      // Т.к. хедер у таблицы просчитывается только при создании,
      // разные хедеры в начале таблицы и в ее продолжении сделать
      // нельзя. По-факту мы сейчас делаем так, чтобы у таблицы 
      // сверху хедера на ее продолжении писалось "Продолжение таблицы X".
      // Я это делаю через счетчик со своим .display() 
      table.header(
        [
          // при создании этого хедера увеличиваем счетчик:
          // 1 = первый хедер => начало таблицы
          // 2 => продолжение
          #context table-headers-counter.step()

          #set text(hyphenate: false)

          #context {
            // Если насчитывается более одного хедера т.е. 
            // таблица продолжается на другой странице, ставим
            // "Продолжение таблицы X"
            if table-headers-counter.get().first() > 1 {
              align(left)[Продолжение таблицы #table-numbering]
            } else {
              // Для первого хедера добавляем название таблицы
              grid(
                columns: (auto, 1fr),
                column-gutter: 0.3em,

                // Таблица и ее номер
                box({
                  it.caption.supplement
                  [ ]
                  table-numbering
                  it.caption.separator
                }),
        
                // собственно текст названия таблицы
                align(left)[ 
                  #it.caption.body
                ]
              )
              // v(right-leading)
            }
          }
        ],
        // TODO: сделать чтобы можно было добавить повторяющийся
        // хедер с нумерованными столбцами, а не только текстом
      ),


      {
        // Запрет на разрыв ячеек настоящей таблицы 
        set table.cell(breakable: false)

        // остальное содержимое фигуры (реальная таблица)
        it
      }
    )

    // просто отступ 
    v(1.0em + right-leading, weak: true)
  }

  // делает таблицу разрываемой
  #show figure.where(kind: table): set block(breakable: true)

  // Просто ширина линий
  #set table(
    stroke: 0.75pt + black,

    // Просто дефолтное значение, если есть желание
    // можете менять в параметрах таблицы
    inset: (
      bottom: right-leading,
      top: 0pt,
      x: 3pt,
    ),
    // Выравнивание хедера по-центру, остальных клеток 
    // по левому краю
    align: (x,y) => if y == 0 {center} else {left},

  )

  // шапки таблицы повторяются
  #set table.header(
    repeat: true,
  )


  // Сноски 
  //
  // Почему так мало описано, как их делать...

  #set footnote(
    numbering: "1)",
  )

  #set footnote.entry(
    gap: right-leading,
    clearance: 0em,
  )

  #show footnote.entry: it => {

    set text(
      size: font-size,
    )
    set par(
      spacing: right-leading,
      leading: right-leading,
    )

    h(1.25cm, weak: false)        // абзацный отступ
    it.note
    [ ] 
    it.note.body
  }

  // Всё ?



  // Библиографический указатель
  #set bibliography(
    title: none,
    style: "gost-7-1-2003.csl",
  )

  #show bibliography: it => {
    // Добавление слов "Список использованных источников"
    heading(numbering: none)[Список использованных источников]

    // склеивание двух точек подряд, 
    // т.к. Typst такое не делает по дефолту
    show ".. –": ". –"

    // создание state для доступа к переменной из show-рула
    let bib = state("bib", ())

    // show-рул на вторую в строке клетку grid (источник)
    show grid.cell.where(x: 1): it => {
      // добавление его в массив bib
      context bib.update(old => {old.push(it.body); old})
    }

    // сокрытие Typst-овой библиграфии т.к. она дальше 
    // будет заменена нашей
    place(hide(it))
    
    // Построение "нашей" библиграфии
    context {
      // список источников, заново пронумерованный
      //
      // P.s. вы можете из этого списка доставать все 
      // содержимое каждого источника, это просто список
      // контента, не связанный с элементом библиографии
      let sources = bib.get().map(it => it.body).enumerate(start: 1)

      // создание из каждого источника нового абзаца
      for (number, source) in sources {
        // [#number] - чтоб номер был в скобочках 
        // я хз, просто мне легче получить список именно источников
        // и с ними уже работать, а не получать номер + источник 
        // и их как-то потом разделять
        par[ [#number] #source ]
      }
    }
  }



  // Формулы
  #set math.equation(
    // нумерация вида (1.1) из 2.4.6

    numbering: (..nums) => {
      // Установка шрифта для нумерации формул 
      // Спасибо https://github.com/artemious3/bsuir_typst
      show: set text(font: "Times New Roman")

      if appendix-counter.get().first() < 1 {
        numbering(
          "(1.1)",
          counter(heading).get().first(),
          nums.pos().first(),
        )
        // в очередной раз нумерация под
        // приложения бла-бла-бла
      } else {
        [(]
        appendix-letters.at(
          appendix-counter.get().first() - 1
        )
        [.]
        str(nums.pos().first())
        [)]
      }
    },
    // установка номера в правый нижний угол
    // чтобы на многострочных формулах он стоял
    // справа от последней строки
    number-align: right + bottom,
  )

  #show math.equation: set text(
    font: (
      "TeX Gyre Termes Math"
    ),
    fallback: true
  )

  // Добавление отступов из 2.4.3 
  // я в душе не чаю, как сделать их 
  // 6 и 8 пт в зависимости от наличия 
  // знаков суммы и т.д., поэтому они 
  // всегда 8, но это "Рекомендуется",
  // так что, наверное, можно
  #show math.equation.where(block: true): it => {
    v(1em + right-leading, weak: true)
    it 
    v(1em + right-leading, weak: true)
  }
  // остальное по формулам вроде зависит
  // уже от того, кто пишет работу

  #show math.equation: it => {
    // Десятичный разделитель
    show regex("^\d+\.\d+$"): num => {

      let (a, b) = num.text.split(".")
      a + math.class("normal", ",") + b
    }

    it
  }

  #show raw: set text(
    font: source-text-font,
  )

  #show raw.where(block: true): it => {
    it
    v(1.0em + right-leading, weak: true)
  }

  // Приложения начинаются с новой страницы
  #show figure.where(kind: "appendix"): it => {pagebreak() + it}

  #body

]

