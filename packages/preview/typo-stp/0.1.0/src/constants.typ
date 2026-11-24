// Размер шрифта основного текста
#let font-size = 14pt

// Шрифт основного текста
#let main-font = "Times New Roman"

// Шрифт исходного текста
#let source-text-font = "Courier New"

// Межстрочный интервал
#let line-height = 18pt

// в typst "leading" это не как расстояние между 
// базовыми линиями текста, а их расстояние типа 
// между верхней и нижней границами строки, которые
// указываются в параметрах текста, так что вычисляем
// разницу между межстрочным интервалом и высотой шрифта
#let right-leadind = line-height - font-size


// функция проверки заголовка на отсутствие текста
#let is-heading-empty(h) = {
  // typst не дает нормального способа проверить,
  // пуст ли заголовок, поэтому городим это непотребство
  //
  // (это понадобится для пунктов с заголовками)
  let empty-heading = heading()[]
  
  h.body == empty-heading.body
}

// просто буквы кириллического алфавита для перечислений
#let cyr-letters = "абвгдеёжзиклмнопрстуфхцчшщъыьэюя".clusters()

// специальная нумерация для 2.3.8
// Почему в typst нет стандартной нумерации
// "а.1)" только для кириллицы...
#let refed-enum-numbering(..nums) = {
  let nums = nums.pos()
  let n = nums.last()

  // если уровень перечисления 1 - самый верхний
  // то кириллические буквы
  if nums.len() == 1 {
    h(1.25cm, weak: false)
    cyr-letters.at(n - 1)
  
  // если 2, то число 
  } else {
    h(0.65cm, weak: false) 
    // самый худший костыль
    // просто подгон под 2.5см отступ от
    // левого края листа
    //
    // TODO: исправить это на что-то адекватное
    // Ну, если это возможно, я пока что не знаю как
    str(n)
  }
  [)]
  // добавление скобочки после буквы/числa
}

// 
#let default-enum-numbering(..nums) = {
  let nums = nums.pos()
  let n = nums.last()

  if nums.len() == 1 {
    h(1.25cm, weak: false)
    str(n)
  }
}

// Приложения 

// счетчик приложений
#let attachment-counter = counter("attachment")

// буквы, доступные для приложений 
// (ну за исключением тех, что в п. 2.7.2)
#let attachment-letters = "АБВГДЕЖИКЛМНПРСТУФХЦШЩЭЮЯ".clusters()


// специальная нумерация для приложений
// (объяснено в создании приложения)
#let attachment-numbering = (..nums) => {
  // получение буквы из массива по счетчику
  let letter = attachment-letters.at(
    attachment-counter.get().first() - 1
  )
  // добавление слова "Приложение"
  [
    Приложение
  ]
  // добавление полученной буквы 
  letter
}

#let table-headers-counter = counter("table-headers")

