# modern-g7-32

![header](assets/header.png)

Шаблон для оформления работ в соответствии с ГОСТ 7.32-2017. Он был создан для автоматизации рутинных процессов при работе с научными работами. Шаблон может быть полезен студентам вуза при оформлении лабораторных, курсовых и дипломных работ.

<a href="https://typst.app/universe/package/modern-g7-32">![Typst Universe](https://img.shields.io/badge/dynamic/xml?url=https://typst.app/universe/package/modern-g7-32&query=/html/body/div/main/div[2]/aside/section[2]/dl/dd[3]&logo=typst&label=universe)</a>
<a href="https://github.com/typst-g7-32/modern-g7-32/actions"><img src="https://github.com/typst-g7-32/modern-g7-32/actions/workflows/ci.yml/badge.svg" alt="License badge"></a>
<a href="https://github.com/typst-g7-32/modern-g7-32/blob/main/LICENSE"><img src="https://img.shields.io/github/license/typst-g7-32/modern-g7-32" alt="License badge"></a>
<a href="https://typst-gost.ru"><img src="https://img.shields.io/website?url=https%3A%2F%2Ftypst-gost.ru" alt="Website badge"></a>

## Быстрый старт
Чтобы использовать этот шаблон, импортируйте его, как показано ниже:
```typst
#import "@preview/modern-g7-32": gost, abstract, title-templates, annexes, annex-heading

#show: gost.with(
  ministry: "Наименование министерства (ведомства) или другого структурного образования, в систему которого входит организация-исполнитель",
  organization: (full: "Полное наименование организации — исполнителя НИР", short: "Сокращённое наименование организации"),
  udk: "индекс УДК",
  research-number: "регистрационный номер НИР",
  report-number: "регистрационный номер отчета",
  approved-by: (
    name: "Фамилия И.О.", 
    position: "Должность, сокращ. наимен. орг", year: 2017
  ), // Гриф согласования
  agreed-by: (
    name: "Фамилия И.О.", 
    position: "Должность, сокращ. наимен. орг", year: auto
  ), // Гриф утверждения, год подставляется из аргумента year
  report-type: "отчёт",
  about: "О научно-исследовательской работе",
  research: "Наименование НИР",
  bare-subject: false, // Можно убрать "по теме"
  subject: "Наименование отчёта",
  manager: (name: "Фамилия И.О.", position: "Должность"),
  stage: (type: "вид отчёта", num: 1),
  federal: "Наименование федеральной программы",
  part: 2, // Номер книги отчёта
  city: "Город",
  year: auto, // Можно поменять год, auto - текущий год
  text-size: (default: 14pt, small: 10pt), // Можно указать размеры текста
  indent: 1.25cm, // Можно указать отступ
  hide-title: false, // Можно скрыть титульник
  performers: (
    "Организация",
    // Можно указать организацию, к которой относятся следующие исполнители
    (name: "И.О. Фамилия", position: "Должность", part: "введение, раздел 1"), // Можно добавить выполненную часть
    (name: "И.О. Фамилия", position: "Должность"),
    "Другая организация",
    (name: "И.О. Фамилия", position: "Должность"),
    (name: "И.О. Фамилия", position: "Должность", co-performer: true) // Поддерживаются соисполнители
  ), // Если исполнитель один - он будет перенесён на титульный лист
)
```

## Документация
Документация к проекту доступна на [сайте](https://typst-gost.ru/docs).

Если вам требуется помощь с шаблоном, можете обратиться на почту support@typst-gost.ru.

## Возможности
* Формирование титульного листа
* Встроенные шаблоны титульных листов
* Пользовательские шаблоны титульных листов
* Автоматическое создание списка исполнителей
* Оформление структурных заголовков
* Автоматическая генерация реферата
* Автоматизированная сборка содержания
* Форматирование и нумерация элементов отчёта
* Оформление списка использованных источников
* Автоматическое оформление и нумерация приложений