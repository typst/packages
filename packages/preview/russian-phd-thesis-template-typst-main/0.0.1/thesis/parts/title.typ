#import "../template.typ": *

// Установки шрифта 
  #set text(
    font: phd-font-type,
    lang: "ru",
    size: phd-font-size,
    fallback: true,
    hyphenate: false,
  )
  
  // Установка свойств страницы 
  #set page(
    margin: (top:2cm, bottom:2cm, left:2.5cm, right:1cm), // размер полей (ГОСТ 7.0.11-2011, 5.3.7)
  )
    
  // Установка свойств параграфа 
  #set par(
    justify: true, 
    linebreaks: "optimized",
    first-line-indent: 2.5em, // Абзацный отступ. Должен быть одинаковым по всему тексту и равен пяти знакам (ГОСТ Р 7.0.11-2011, 5.3.7).
    leading: 1.5em, // Полуторный интервал (ГОСТ 7.0.11-2011, 5.3.6)
  ) 
#set align(center)

#thesis-organization

#v(2em)
#table(
  columns: (1fr,1fr),
  stroke: none,
  align: (left+bottom, right+bottom),
  image("../../images/logo.svg",width: 50%),
  "На правах рукописи"
)

#set text(size:16pt)
#v(1em)
#author-name // ФИО автора 
#v(1em)
*#thesis-title* // Название работы 

#set text(size:phd-font-size)
#v(1em)
Специальность #thesis-specialty-number -- // Номер специальности

"#thesis-specialty-title" // Название специальности
#v(1em)
Диссертация на соискание учёной степени 

#thesis-degree

#v(5fr)
#set align(right)
Научный руководитель: 

#supervisor-regalia 

#supervisor-fio

#v(1em)
#set align(center)

#thesis-city -- #thesis-year

