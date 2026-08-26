#import "@preview/eskd-drafting:0.1.0": *

// Пример: Пользовательский отраслевой штамп предприятия (Custom Enterprise Stamp)
// Демонстрирует:
// 1. Создание собственной формы отраслевого штампа предприятия;
// 2. Интеграцию в менеджер страниц через параметр bottom;
// 3. Сохранение полной функциональности рамок и боковиков без правки ядра.

#let custom-enterprise-stamp(..args) = context {
  let s = eskd-state.get()
  let named = args.named()
  let cfg = named.at("font-cfg", default: s.at("font-cfg", default: gost-fonts.at("type-b")))
  let cur-page = counter(page).display("1")

  let c(val, h: h3_5, weight: "regular", align-mode: center + horizon) = {
    align(align-mode, gost-text(h: h, cfg: cfg, weight: weight, ignore-rules: s.at("ignore-rules", default: auto))[#val])
  }

  set table(inset: (x: 0.3mm, y: 0.2mm))

  table(
    columns: (45mm, 95mm, 45mm),
    rows: (10mm, 10mm),
    align: center + horizon,
    stroke: none,

    // Верхняя строка
    table.cell(x: 0, y: 0)[#c("АО «СпецТех»", h: h5_0, weight: "bold")],
    table.cell(x: 1, y: 0)[#c(get-field(named, "name", s, default: []), h: h5_0)],
    table.cell(x: 2, y: 0)[#c([Лист #cur-page], h: h3_5)],

    // Нижняя строка
    table.cell(x: 0, y: 1, colspan: 2)[#c(get-field(named, "code", s, default: []), h: h7_0, weight: "bold")],
    table.cell(x: 2, y: 1)[#c("Контроль ОТК", h: h3_5)],

    table.hline(y: 0, stroke: thick),
    table.hline(y: 1, stroke: thin),
    table.hline(y: 2, stroke: thick),
    table.vline(x: 0, stroke: thick),
    table.vline(x: 1, start: 0, end: 1, stroke: thin),
    table.vline(x: 2, stroke: thin),
    table.vline(x: 3, stroke: thick),
  )
}

#show: eskd-document.with(
  paper: "a4",                                 // Формат листа А4
  orientation: "portrait",                     // Вертикальная ориентация
  code: [СТ.2026.001-ЭТ],                      // Обозначение протокола испытаний
  name: [Протокол приемочных испытаний],       // Наименование документа
  copier: none,                                // Отключение ототбражения надписи "Копировал"
  format: none,                                // Отключение ототбражения надписи "Формат"
)

#show: eskd-page.with(
  bottom: custom-enterprise-stamp,             // Пользовательская функция нижнего штампа
  left: frame-left-5r,                         // Стандартный левый штамп 5r на поле подшивки
  frame: true,                                 // Внешняя рамка листа (20-5-5-5 мм)
)

= 1. Общие сведения об объекте испытаний
Приемочные испытания опытной партии высоковольтных контакторов типа КВ-250 проведены на испытательном стенде ИС-04 отдела технического контроля АО «СпецТех» в соответствии с утвержденной программой и методикой ПМ.СТ.2026.

= 2. Результаты измерений и заключение комиссии

#table(
  columns: (35mm, 45mm, 45mm, 40mm),
  align: (center, center, center, center),
  [Параметр], [Норма ТУ], [Результат замера], [Заключение],
  [Сопротивление изоляции], [не менее 100 МОм], [1450 МОм], [Соответствует],
  [Время срабатывания], [не более 45 мс], [32 мс], [Соответствует],
  [Падение напряжения], [не более 15 мВ], [8.4 мВ], [Соответствует],
  [Износостойкость], [не менее 50000 циклов], [52000 циклов], [Соответствует]
)

Все образцы партии выдержали испытания в полном объеме. Изделие допускается к серийному производству.
