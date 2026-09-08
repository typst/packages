#import "@preview/eskd-drafting:0.1.0": *

// Пример: Пользовательская (студенческая) рамка для курсовых и дипломных проектов
// Демонстрирует:
// 1. Внедрение нестандартного штампа последующих листов через модульный параметр subsequent-bottom;
// 2. Сохранение нормативного контроля рамок и отступов под подшивку;
// 3. Интеграцию кастомного штампа в менеджер страниц без модификации ядра пакета.

// 1. Описываем кастомную функцию штампа последующих листов
#let custom-student-form-2a(..args) = context {
  let s = eskd-state.get()
  let named = args.named()
  let cfg = named.at("font-cfg", default: s.at("font-cfg", default: gost-fonts.at("type-b")))
  let ps = preset-stroke(named, s)
  let cur-page = counter(page).display("1")

  let c(val, h: h3_5, weight: "regular", align-mode: center + horizon) = {
    align(align-mode, gost-text(h: h, cfg: cfg, weight: weight, ignore-rules: s.at("ignore-rules", default: auto))[#val])
  }

  set table(inset: (x: 0.3mm, y: 0.2mm))

  // Таблица шириной 185 мм и высотой 15 мм
  table(
    columns: (7mm, 10mm, 23mm, 15mm, 10mm, 110mm, 10mm),
    rows: (5mm, 5mm, 5mm),
    align: center + horizon,
    stroke: none,

    // Строка 1 (Шапка изменений)
    table.cell(x: 0, y: 0)[#c("Изм.", h: h2_5)],
    table.cell(x: 1, y: 0)[#c("Лист", h: h2_5)],
    table.cell(x: 2, y: 0)[#c("№ докум.", h: h2_5)],
    table.cell(x: 3, y: 0)[#c("Подпись", h: h2_5)],
    table.cell(x: 4, y: 0)[#c("Дата", h: h2_5)],

    // Строка 2 (Разработал)
    table.cell(x: 0, y: 1, colspan: 2, align: left + horizon, inset: text-inset-left)[#c("Разраб.", h: h2_5)],
    table.cell(x: 2, y: 1, align: left + horizon)[#c("Студентов", h: h3_5)],
    table.cell(x: 3, y: 1)[],
    table.cell(x: 4, y: 1)[#c("12.05", h: h2_5)],

    // Строка 3 (Нормоконтроль)
    table.cell(x: 0, y: 2, colspan: 2, align: left + horizon, inset: text-inset-left)[#c("Н.контр.", h: h2_5)],
    table.cell(x: 2, y: 2, align: left + horizon)[#c("Преподов", h: h3_5)],
    table.cell(x: 3, y: 2)[],
    table.cell(x: 4, y: 2)[#c("15.05", h: h2_5)],

    // Графа обозначения (Справа)
    table.cell(x: 5, y: 0, rowspan: 3)[
      #c(get-field(named, "code", s, default: []), h: h7_0, weight: "bold")
    ],

    // Графа номера листа (Крайняя справа)
    table.cell(x: 6, y: 0, rowspan: 3, inset: 0pt)[
      #table(
        columns: (10mm), rows: (7mm, 8mm), align: center + horizon, stroke: none,
        table.cell()[#c("Лист", h: h2_5)],
        table.cell()[#c(cur-page, h: h5_0)],
        table.hline(y: 1, stroke: thick),
      )
    ],

    // Отрисовка линий
    table.hline(y: 0, stroke: thick),
    table.hline(y: 3, stroke: thick),
    table.vline(x: 0, stroke: thick),
    table.vline(x: 5, stroke: thick),
    table.vline(x: 6, stroke: thick),
    table.vline(x: 7, stroke: thick),

    table.hline(y: 1, start: 0, end: 5, stroke: ps),
    table.hline(y: 2, start: 0, end: 5, stroke: thin),

    table.vline(x: 1, start: 0, end: 1, stroke: ps),
    table.vline(x: 2, start: 0, end: 3, stroke: ps),
    table.vline(x: 3, start: 0, end: 3, stroke: ps),
    table.vline(x: 4, start: 0, end: 3, stroke: ps),
  )
}

// 2. Инициализируем документ
#show: eskd-document.with(
  paper: "a4",                                 // Формат листа А4
  orientation: "portrait",                     // Вертикальная ориентация

  // Графы 10–13: Студенческий состав подписей (Разраб., Руковод., Консульт., Н.контр., Зав.каф.)
  members: (
    ("Разраб.",  "Студентов И.И.",   "12.05.26"),
    ("Руковод.", "Профессоров П.П.", "14.05.26"),
    ("Консульт.","Доцентов Д.Д.",    "15.05.26"),
    ("Н.контр.", "Преподов К.К.",    "16.05.26"),
    ("Зав.каф.", "Академиков А.А.",  "18.05.26"),
  ),

  // Основные графы штампа пояснительной записки к курсовому проекту:
  code: [КП.123456.789ПЗ],                     // Графа 2: Шифр курсового проекта
  name: [Проектирование планетарного редуктора\ Пояснительная записка к курсовому проекту], // Графа 1: Тема КП
  org: [МГТУ им. Н.Э. Баумана\ Кафедра РК-3], // Графа 9: Университет и кафедра
  lit: [У],                                    // Графа 4: Литера ("У" — учебный документ)

  copier: none,                                // Отключение ототбражения надписи "Копировал"
  format: none,                                // Отключение ототбражения надписи "Формат"
)

// Лист 1: Заглавный лист (Форма 2 по ГОСТ 2.104-2006)
#show: page-first-form2

= 1. Введение и постановка задачи
В курсовом проекте рассматривается проектирование двухступенчатого соосного планетарного редуктора по схеме $2 K - H$ с передаточным отношением $u = 24.5$ и передаваемой мощностью $P = 7.5 "кВт"$.

Исходные кинематические данные:
- частота вращения входного вала: $n_1 = 1450 "об/мин"$;
- требуемый ресурс передачи: $L_h = 10000 "часов"$;
- режим нагружения — умеренно-переменный.

// Листы 2+: Кастомная студенческая рамка с подписями на каждом листе
#show: eskd-page.with(
  bottom: custom-student-form-2a,
  left: frame-left-5r,
  frame: true,
)

= 2. Кинематический и силовой расчет
== 2.1. Определение передаточных чисел ступеней
Передаточное число разбивается по ступеням из условия минимальной радиальной массы планетарного механизма:
$ u_1 = sqrt(u) approx 4.95, quad u_2 = u / u_1 approx 4.95 $

Числа зубьев центральных колес и сателлитов выбираются из условий соосности, соседства и сборки по ГОСТ 21425-75:
$ z_a = 18, quad z_g = 71, quad z_b = 89, quad n_w = 3 "сателлита" $

== 2.2. Расчет крутящих моментов на валах
Крутящий момент на тихоходном валу с учетом коэффициента полезного действия $eta = 0.96$:
$ T_2 = frac(9550 P, n_2) eta approx 1158 "Н·м" $