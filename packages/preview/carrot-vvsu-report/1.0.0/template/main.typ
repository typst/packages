#import "@preview/carrot-vvsu-report:1.0.0": *

#show: vvsu.with()

#title-page(
  title: [Отчет по лабораторной работе],
  title2: [по дисциплине "Название дисциплины"],
  title3: [Название работы],
  department: vvsu-depart-its,
  members: (
    member(role: [Студент\ гр. ZZZ-YY-XX], name: [И.И. Иванов]),
    member(role: [Преподаватель], name: [П.П. Петров]),
  ),
)

= Заголовок

Текст отчета.

== Подраздел

Будущий текст отчета в подразделе.

#conclusion[
  В ходе выполнения работы...
]
