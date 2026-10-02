#import "constants.typ" : *

#let template(body) = [
  // Общие настройки шрифта из 2.1.1
  #set text(
    font: main-font,
    size: font-size,
    top-edge: 1em,      // установка top-edge и bottom-edge 
    bottom-edge: 0em,   // чтобы правильно работал leading

    hyphenate: true,    // переносы

    lang: "ru",
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
    leading: right-leadind, 
    spacing: right-leadind,

    // абзацный отступ (красная строка)
    first-line-indent: (
      amount: 1.25cm,
      all: true
    ),
  )



  // TODO сделать остальные варианты перечислений

  // простое перечисление 
  #set list(
    tight: true,
    marker: [--],
  )

  #show list.item: it => {
    par()[-- #it.body]

  }


  // Перечисление со ссылками на его элементы
  //
  // Как адекватно сделать выбор типа перечисления...
  // TODO: решить это
  

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

  // TODO: двухуровневая нумерация для перечислений
  // с ссылками на его элементы



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
    v(1.0em, weak: true)      // перед всеми заголовками 1 пробельная строка

    // не добавлять абзацный отступ к заголовкам,
    // которые располагаются по-центру
    if it.numbering != none and it.numbering != attachment-numbering {
      pad(left: 1.25cm, it)   // абзацный отступ для нумерованных разделов

    } else {                  // для ненумерованных разделов он не нужен
      it
    }

    if it.level < 3 {
      v(1.0em, weak: true)    // только после названий разделов, подразделов
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
      v(1.0em, weak: true)            // почему-то этот отступ убрался (?)

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
      v(1.0em, weak: true)
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
    show: set text(
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
      if attachment-counter.get().first() == 0 {
        numbering(
          "1.1",
          counter(heading).get().first(),
          n,
        )

      // если приложение уже обнаружено
      // (т.е. фигура в приложении т.к.
      // откуда взяться разделу после приложения)
      } else {
        attachment-letters.at( 
          attachment-counter.get().first() -1
        )
        [.]
        str(n)
      }
    }
  )

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

    v(1.0em + right-leadind, weak: true)
    it
    v(1.0em, weak: true)

  }

  // настройки для таблиц
  //
  // TODO остальные настройки для таблиц
  #show figure.where(kind: table): set figure.caption(position: top)
  #show figure.caption.where(kind: table): set align(left)
  #show figure.where(kind: table): set figure(
    supplement: "Таблица",
    gap: right-leadind,
  )

  // добавление к таблице номера в специальном формате
  #show figure.where(kind: table): it => {
    v(1.0em, weak: true)

    // обнуление счетчика шапок таблиц
    table-headers-counter.update(0)



    // разная нумерация в разделах и приложениях
    // 
    // впринципе, такое уже было в рисунках, еще
    // раз пояснять смысла не вижу
    let table-numbering = [
      #if attachment-counter.get().first() == 0 {
        context counter(figure.where(kind: table)).display()
      } else {
        context attachment-letters.at(attachment-counter.get().first() - 1)
        [.]
        context counter(figure.where(kind: table)).get().first()
      }
    ]

    // Название таблицы (Таблица X -- название)
    //
    // TODO: сделать чтобы название таблицы 
    // не вылазило за пределы таблицы
    show figure.caption: cap => {
      // grid т.к. название д.б. выравнено по левому краю
      // независимо от номера таблицы
      grid(
        columns: (auto, auto),
        column-gutter: 0.3em,

        // Таблица и ее номер
        box({
          cap.supplement
          [ ]
          table-numbering
          cap.separator
        }),
        
        // собственно текст названия таблицы
        align(left)[ 
          #cap.body
        ]
      )
    } 

    // отключение абзацных отступов для названия таблицы
    set par(first-line-indent: 0pt)

    // создание новой таблицы со спец. header'ом
    table(
      fill: none,
      inset: 0pt,
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

          // вот тут я не понимаю, почему оно не работает, 
          // если это убрать
          // TODO: исправить это недоразумение
          #if table-headers-counter.get().first() == 1 {
            [
              // довавление текста "Продолжение таблицы X"
              #context table-headers-counter.display((..nums) => {
                if table-headers-counter.get().first() > 1 {
                  align(left)[Продолжение таблицы #table-numbering]
                  v(right-leadind)
                }
              })
            ]
          }
        ],
        // TODO: сделать чтобы можно было добавить повторяющийся
        // хедер с нумерованными столбцами, а не только текстом
      ),


      // отступ, т.к. таблица не текст, поэтому тут надо 
      // добавить leading (?)
      v(right-leadind),

      // оставляем старый хедер
      it
    )
    
    // просто отступ 
    v(1.0em, weak: true)
  }

  // делает таблицу разрываемой
  #show figure.where(kind: table): set block(breakable: true)

  // Просто ширина линий
  #set table(
    stroke: 0.75pt + black,

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
    gap: right-leadind,
  )

  #show footnote.entry: it => {

    set text(
      size: font-size,
    )
    set par(
      spacing: right-leadind,
      leading: right-leadind,
    )

    h(1.25cm, weak: false)        // абзацный отступ
    it.note
    [ ] 
    it.note.body
  }

  // Всё ?



  // Библиографический указатель
  //
  // ПОЧЕМУ ТУТ НЕТ НОРМАЛЬНОГО bibliography.entry
  // ?????
  // НИКАК НЕЛЬЗЯ ПО-НОРМАЛЬНОМУ СДЕЛАТЬ
  // АБЗАЦНЫЙ ОТСТУП ДЛЯ ИСТОЧНИКОВ
  //
  // P.s. в стилях тоже нельзя сделать именно
  // абзацный отступ
  //
  // TODO Решить вопрос с абзацным отступом для
  // источников в библ. указателе
  #set bibliography(
    title: none,
    style: "gost-7-1-2003.csl",
    full: true,

  )

  #show bibliography: it => {
    heading(
      numbering: none,
    )[
      Список использованных источников
    ]
    it
  }
  


  // Формулы
  #set math.equation(
    // нумерация вида (1.1) из 2.4.6
    numbering: (..nums) => {
      if attachment-counter.get().first() < 1 {
        numbering(
          "(1.1)",
          counter(heading).get().first(),
          nums.pos().first(),
        )
        // в очередной раз нумерация под
        // приложения бла-бла-бла
      } else {
        [(]
        attachment-letters.at(
          attachment-counter.get().first() - 1
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

  // Добавление отступов из 2.4.3 
  // я в душе не чаю, как сделать их 
  // 6 и 8 пт в зависимости от наличия 
  // знаков суммы и т.д., поэтому они 
  // всегда 8, но это "Рекомендуется",
  // так что, наверное, можно
  #show math.equation.where(block: true): it => {
    v(8pt, weak: true)
    it 
    v(8pt, weak: true)
  }
  // остальное по формулам вроде зависит
  // уже от того, кто пишет работу

  #show raw: set text(
    font: source-text-font,
  )

  #show raw.where(block: true): it => {
    v(1.0em, weak: false)
    it
    v(1.0em, weak: false)
  }

  #body

]

