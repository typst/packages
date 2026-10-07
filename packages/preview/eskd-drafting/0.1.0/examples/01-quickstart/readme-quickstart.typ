#import "@preview/eskd-drafting:0.1.0": *

// Пример: Быстрый старт (Quick Start)
// Демонстрирует:
// 1. Минимальную настройку и запуск проекта с eskd-document;
// 2. Заполнение основных граф штампа и таблицы участников;
// 3. Многостраничный переход: Титульный лист -> Содержание -> Основная часть.

#show: eskd-document.with(
  paper: "a4",              // Paper size per GOST 2.301-68
  orientation: "portrait",  // Portrait orientation (A4 only allows portrait per GOST 2.301)
  preset-lines: "industry", // "industry" (CAD 0.8 mm dividers) or "gost" (0.35 mm thin)
  members: (
    ("Разраб.", "Алексеев",  "12.05.26"),
    ("Пров.",   "Борисов",   "15.05.26"),
    ("Т.контр.","Васильев",  "18.05.26"),
    ("Н.контр.","Григорьев", "19.05.26"),
    ("Утв.",    "Дмитриев",  "20.05.26"),
  ),
  code: [АБВГ.000111.001РЭ],                            // Cell 2: Document code (120x15 mm)
  name: [Блок управления\ Руководство по эксплуатации], // Cell 1: Product & document name (70x25 mm)
  org: [НПК "Электроника"],                             // Cell 9: Enterprise / organization (50x15 mm)
  lit: [О1],                                            // Cell 4: Stage litera per GOST 2.103-2013
  mass: [0,05],                                         // Cell 5: Mass in kg (decimal comma, no "кг")
  scale: [1:1],                                         // Cell 6: Scale per GOST 2.302-68
  inv-orig: [12345],                                    // Cell 19: Original inventory number
  sig-date-orig: [12.05.26],                            // Cell 20: Date and signature
)

// 1. Title Page
#show: page-title
#align(center + horizon)[
  #gost-text(h: h7_0, weight: "bold")[РУКОВОДСТВО ПО ЭКСПЛУАТАЦИИ]
]

// 2. Table of Contents (Form 2 with TOC headers -> Form 2a)
#show: page-first-form2.with(
  left: frame-left-7r,
  toc: (num: [№], name: [Наименование], code: [Обозначение], note: [Примечание]),
)
#align(center)[#gost-text(h: h5_0, weight: "bold")[СОДЕРЖАНИЕ]]
#outline(title: none)

// 3. Document Body (Form 2 -> Form 2a)
#show: page-first-form2
= 1. Введение
Текст пояснительной записки...

#show: page-body
= 2. Расчетная часть
Продолжение документа...

