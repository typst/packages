#import "@preview/oh-my-gost:0.1.0": gost-report, introduction, conclusion

#show: gost-report.with(
  lang: "ru",
  title: "Название исследовательской работы",
  author: "И. О. Фамилия",
  group: "M0000",
  institution: "Название университета",
  faculty: "Название факультета",
  department: "Название кафедры",
  city: "Москва",
  year: "2026",
  supervisor: "И. О. Фамилия",
  keywords: ("ГОСТ 7.32-2017", "Typst", "отчет"),
  bibliography-file: none,
)

#introduction(lang: "ru")[
  Введение описывает актуальность, цель и задачи исследования.
]

= Основная часть

Текст основной части пишется обычным Typst-контентом.

#conclusion(lang: "ru")[
  Заключение кратко фиксирует результаты работы.
]
