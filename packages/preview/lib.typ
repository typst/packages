// ======================================================================
// na-corexamen : قالب تصحيح الفروض والاختبارات (عربي + لاتيني)
// نفس ترويسة na-examen (باركود + المؤسسة + ...) ثم لكل تمرين جدول :
//   عناصر الإجابة | العلامة      وفي آخره سطر «المجموع» يُحسب تلقائيًا.
// تكتب الحل بحرية تامة (نص ومعادلات) بلا أقواس خاصة بكل سؤال ، وتضع العلامة
// في آخر كل خطوة بالأمر  #mk(0.5)  : الحزمة تقطع النص عند كل #mk وتضع
// كل قطعة في سطر من الجدول وعلامتها أمامها.
//
// الاستعمال :
//   #import "@preview/na-corexamen:0.1.0": *
//   #show: correction.with(school: [...], level: [...], ...)
//
//   #exercise[
//     #q[1] نص الحل بحرية ... $x = 3$ #mk(0.5)
//     #q[2] ... #mk(1)
//   ]
//   #summary(total: 20)
//
// na-corexamen: marking-scheme template for Typst (Arabic RTL + Latin LTR).
// Write the solution freely and put #mk(...) after each step: the package cuts
// the text at every #mk into the rows of a table (answer | marks) and adds up.
// ======================================================================

#import "@preview/tiaoma:0.3.0": barcode as _tiaoma

// ---------------------------------------------------------------------
// خطوط افتراضية / Default fonts
// ---------------------------------------------------------------------
#let _sans = ("Arial", "Liberation Sans", "Noto Sans Arabic", "DejaVu Sans")
#let _sans-latin = ("Arial", "Liberation Sans", "DejaVu Sans")
#let _serif-latin = ("Libertinus Serif", "Linux Libertine", "Times New Roman", "Liberation Serif", "DejaVu Serif")

#let _ordinals = (
  "الأول", "الثاني", "الثالث", "الرابع", "الخامس",
  "السادس", "السابع", "الثامن", "التاسع", "العاشر",
)
#let _ordinal(n) = if n <= _ordinals.len() { _ordinals.at(n - 1) } else { "رقم " + str(n) }

// ---------------------------------------------------------------------
// قوالب اللغات / Language presets
// ---------------------------------------------------------------------
#let _ar = (
  dir: rtl,
  font: ("Amiri", "Noto Naskh Arabic", "DejaVu Sans"),
  title-font: _sans,
  size: 16pt,
  school: "اسم المؤسسة",
  year: "2026-2027",
  level: "المستوى",
  term: "الفصل الأول",
  kind: "فروض",
  exam: "الفرض المحروس",
  subject: "الرياضيات",
  duration: "2 ســا",
  year-label: "السنة الدراسية : ",
  level-label: "المستوى : ",
  duration-label: "المدة : ",
  page-label: "صفحة",
  of-label: "من",
  ex-name: n => [التمرين #_ordinal(n)],
  part-name: n => [الجزء #_ordinal(n)],
  pt-one: "نقطة",
  pt-many: "نقاط",
  title-fn: (e, s) => [تصحيح #e في مادة #s],
  ex-label: "التمرين",
  ans-label: "عناصر الإجابة",
  mark-label: "العلامة",
  total-label: "المجموع",
  summary-label: "جدول التنقيط الإجمالي",
  expected-label: "المعلن : ",
)

#let _latin-base = (
  dir: ltr,
  font: _serif-latin,
  title-font: _sans-latin,
  size: 12pt,
  year: "2026-2027",
  kind: none,
)

#let _fr = _latin-base + (
  school: "Nom de l’établissement",
  level: "Niveau",
  term: "Premier trimestre",
  exam: "Devoir surveillé",
  subject: "Mathématiques",
  duration: "2 h",
  year-label: "Année scolaire : ",
  level-label: "Niveau : ",
  duration-label: "Durée : ",
  page-label: "Page",
  of-label: "sur",
  ex-name: n => [Exercice #n],
  part-name: n => [Partie #numbering("A", n)],
  pt-one: "point",
  pt-many: "points",
  title-fn: (e, s) => [Corrigé — #e de #s],
  ex-label: "Exercice",
  ans-label: "Éléments de réponse",
  mark-label: "Barème",
  total-label: "Total",
  summary-label: "Récapitulatif du barème",
  expected-label: "annoncé : ",
)

#let _en = _latin-base + (
  school: "School name",
  level: "Level",
  term: "First Term",
  exam: "Test",
  subject: "Mathematics",
  duration: "2 h",
  year-label: "School year: ",
  level-label: "Level: ",
  duration-label: "Duration: ",
  page-label: "Page",
  of-label: "of",
  ex-name: n => [Exercise #n],
  part-name: n => [Part #numbering("A", n)],
  pt-one: "point",
  pt-many: "points",
  title-fn: (e, s) => [#s #e — Marking scheme],
  ex-label: "Exercise",
  ans-label: "Solution",
  mark-label: "Marks",
  total-label: "Total",
  summary-label: "Marks summary",
  expected-label: "stated: ",
)

#let _es = _latin-base + (
  school: "Nombre del centro",
  level: "Nivel",
  term: "Primer trimestre",
  exam: "Examen",
  subject: "Matemáticas",
  duration: "2 h",
  year-label: "Curso: ",
  level-label: "Nivel: ",
  duration-label: "Duración: ",
  page-label: "Página",
  of-label: "de",
  ex-name: n => [Ejercicio #n],
  part-name: n => [Parte #numbering("A", n)],
  pt-one: "punto",
  pt-many: "puntos",
  title-fn: (e, s) => [Solucionario — #e de #s],
  ex-label: "Ejercicio",
  ans-label: "Respuesta",
  mark-label: "Puntos",
  total-label: "Total",
  summary-label: "Resumen de la puntuación",
  expected-label: "indicado: ",
)

#let _de = _latin-base + (
  school: "Name der Schule",
  level: "Klassenstufe",
  term: "1. Halbjahr",
  exam: "Klassenarbeit",
  subject: "Mathematik",
  duration: "2 Std.",
  year-label: "Schuljahr: ",
  level-label: "Klassenstufe: ",
  duration-label: "Dauer: ",
  page-label: "Seite",
  of-label: "von",
  ex-name: n => [Aufgabe #n],
  part-name: n => [Teil #numbering("A", n)],
  pt-one: "Punkt",
  pt-many: "Punkte",
  title-fn: (e, s) => [Lösung — #e in #s],
  ex-label: "Aufgabe",
  ans-label: "Antwort",
  mark-label: "Punkte",
  total-label: "Summe",
  summary-label: "Punkteübersicht",
  expected-label: "angegeben: ",
)

#let _presets = (ar: _ar, fr: _fr, en: _en, es: _es, de: _de)
#let _preset(lang) = if lang in _presets { _presets.at(lang) } else { _en }

// ---------------------------------------------------------------------
// إعدادات داخلية / Internal settings
// ---------------------------------------------------------------------
#let _cfg = state("na-corexamen-cfg", (
  title-font: _sans,
  title-size: 16pt,
  part-size: 15pt,
  ex-name: _ar.ex-name,
  part-name: _ar.part-name,
  pt-one: _ar.pt-one,
  pt-many: _ar.pt-many,
  pad-points: true,
  sep: ".",
  ex-label: _ar.ex-label,
  ans-label: _ar.ans-label,
  mark-label: _ar.mark-label,
  total-label: _ar.total-label,
  summary-label: _ar.summary-label,
  expected-label: _ar.expected-label,
  head-fill: luma(215),
  sub-fill: luma(238),
  stroke: 0.6pt + black,
  inset: 7pt,
  mark-width: 2.4cm,
))

// مجاميع كل التمارين (لبناء الجدول الإجمالي)
#let _totals = state("na-corexamen-totals", ())

// ---------------------------------------------------------------------
// أدوات الأعداد / Number helpers
// ---------------------------------------------------------------------
// 1.5 -> "1.5" ، 2.0 -> "2" ، 0.1+0.2 -> "0.3"
#let _fmt(x, sep: ".") = {
  let v = calc.round(x, digits: 2)
  let s = if calc.fract(v) == 0 { str(int(v)) } else { str(v) }
  s.replace(".", sep)
}

// (08 نقاط) / (08 points)
#let _points-text(p, c) = {
  if p == none {
    none
  } else if type(p) == str or type(p) == content {
    [(#p)]
  } else {
    let s = _fmt(p, sep: c.sep)
    if c.pad-points and p >= 1 and p < 10 and calc.fract(p) == 0 { s = "0" + s }
    [(#s #if p == 1 [#c.pt-one] else [#c.pt-many])]
  }
}

// ---------------------------------------------------------------------
// عنوان بخط عريض ومسطّر
// ---------------------------------------------------------------------
#let title-style(body) = context {
  let c = _cfg.get()
  text(font: c.title-font, weight: "bold", size: c.title-size)[
    #underline(stroke: 0.8pt, offset: 4pt)[#body]
  ]
}

// ---------------------------------------------------------------------
// مربّع رقم السؤال : #q[1]   (الاسم القديم coB مُصدَّر أيضًا)
// ---------------------------------------------------------------------
#let q(body) = {
  box(
    stroke: 1pt + black,
    fill: white,
    radius: 0.5pt,
    inset: 2.2pt,
    baseline: 0%,
    text(fill: black, strong(body)),
  )
}
#let coB = q

// ---------------------------------------------------------------------
// علامات تقسيم داخلية : mk و section و part لا ترسم شيئًا بنفسها ،
// بل تترك «علامة» (metadata) يقرؤها exercise فيقطع النص عندها.
// ---------------------------------------------------------------------

// العلامة : #mk(0.5)  أو  #mk(0.5, 0.5)  (الأعداد تُجمع)
//   تُكتب في آخر خطوة الحل : كل ما قبلها (منذ العلامة السابقة) يصير سطرًا في الجدول.
#let mk(..marks) = metadata((na: "mk", sum: marks.pos().sum(default: 0)))

// عنوان فرعي يمتد على عرض الجدول : #section[I.]
#let section(body) = metadata((na: "sec", body: body))

// جزء داخل تمرين : #part[ ... #mk(1) ... ]  ← «الجزء الأول (01 نقطة)»
//   نقاطه مجموع علاماته ؛ ويُعاد ترقيمه مع كل تمرين.
#let part(title: auto, body) = metadata((na: "part", title: title, body: body))

// ---------------------------------------------------------------------
// قطع النص إلى أسطر : (kind: "row", body, mark) | "sec" | "part"
// ---------------------------------------------------------------------
#let _blank(k) = type(k) == content and repr(k.func()) in ("space", "parbreak")

// حذف الفراغات وفواصل الفقرات من طرفي القطعة
#let _trim(arr) = {
  let a = arr
  while a.len() > 0 and _blank(a.first()) { a = a.slice(1) }
  while a.len() > 0 and _blank(a.last()) { a = a.slice(0, a.len() - 1) }
  a.join()
}

#let _parse(body) = {
  let kids = if body.has("children") { body.children } else { (body,) }
  let items = ()
  let cur = ()
  for k in kids {
    let v = if type(k) == content and repr(k.func()) == "metadata" { k.value } else { none }
    if type(v) == dictionary and "na" in v {
      if v.na == "mk" {
        items.push((kind: "row", body: _trim(cur), mark: v.sum))
      } else {
        let left = _trim(cur)
        if left != none { items.push((kind: "row", body: left, mark: none)) }
        if v.na == "sec" {
          items.push((kind: "sec", body: v.body))
        } else if v.na == "part" {
          let sub = _parse(v.body)
          items.push((kind: "part", title: v.title, items: sub.items, sum: sub.sum))
        }
      }
      cur = ()
    } else {
      cur.push(k)
    }
  }
  let left = _trim(cur)
  if left != none { items.push((kind: "row", body: left, mark: none)) }

  let sum = 0
  for it in items {
    if it.kind == "row" and it.mark != none {
      sum += it.mark
    } else if it.kind == "part" {
      sum += it.sum
    }
  }
  (items: items, sum: sum)
}

// ---------------------------------------------------------------------
// خلايا الجدول من الأسطر
// ---------------------------------------------------------------------
#let _cells(items, c) = {
  let cells = ()
  let pn = 0
  for it in items {
    if it.kind == "row" {
      cells.push(if it.body == none { [] } else { it.body })
      cells.push(if it.mark == none { [] } else { strong(_fmt(it.mark, sep: c.sep)) })
    } else if it.kind == "sec" {
      cells.push(table.cell(colspan: 2, fill: c.sub-fill, align: start + horizon, strong(it.body)))
    } else if it.kind == "part" {
      pn += 1
      let name = if it.title == auto { (c.part-name)(pn) } else { it.title }
      let pts = if it.sum > 0 { _points-text(it.sum, c) } else { none }
      cells.push(table.cell(colspan: 2, fill: c.sub-fill, align: start + horizon, strong({
        name
        if pts != none { [ ]; pts }
      })))
      cells += _cells(it.items, c)
    }
  }
  cells
}

// ---------------------------------------------------------------------
// تمرين مصحَّح : لا يرسم شيئًا بنفسه ، بل يترك «علامة» (metadata) تحمل أسطره ؛
//   ثم يجمع القالب correction كل التمارين المتتالية في جدول واحد متصل
//   (عناصر الإجابة | العلامة) يمتد على عدة صفحات (يقبل الانقسام بين الصفحات) :
//   عنوان التمرين سطر بعرض الجدول ، ثم أسطر الحل ، ثم سطر «المجموع» ،
//   ثم يبدأ التمرين التالي مباشرةً في نفس الجدول دون فاصل ودون جدول جديد.
//   points : auto = المجموع المحسوب ؛ أو عدد معلن (يُقارَن بالمجموع المحسوب
//            ويظهر تحذير أحمر ⚠ إن اختلفا) ؛ none = بدون نقاط في العنوان
//   title  : auto = «التمرين الأول (08 نقاط)» ، أو محتوى تكتبه بنفسك
//   gap    : بقي للتوافق مع الإصدارات السابقة ولم يعد له أثر (لا فاصل بين التمارين)
//   قاعدة : اكتب #exercise في المستوى الأعلى من الوثيقة (لا داخل أمر آخر)،
//           واكتب #mk و #section و #part مباشرةً في جسم التمرين،
//           ولا تضع #set أو #show بعد #show: correction ولا داخل جسم التمرين.
// ---------------------------------------------------------------------
#let exercise(points: auto, title: auto, gap: 1cm, body) = metadata((
  na: "ex",
  points: points,
  title: title,
  parsed: _parse(body),
))

// خلايا تمرين واحد داخل الجدول الكبير :
//   سطر العنوان + أسطر الحل + سطر المجموع
#let _ex-cells(ex, n, c) = {
  let sum = ex.parsed.sum
  let shown = if ex.points == auto { sum } else { ex.points }
  let name = if ex.title == auto { (c.ex-name)(n) } else { ex.title }
  let pts = _points-text(shown, c)

  let mismatch = type(ex.points) in (int, float) and calc.abs(ex.points - sum) > 0.001
  let total-cell = if mismatch {
    [#strong(_fmt(sum, sep: c.sep)) #text(fill: red, size: 0.75em)[⚠ #c.expected-label#_fmt(ex.points, sep: c.sep)]]
  } else {
    strong(_fmt(sum, sep: c.sep))
  }

  let head = table.cell(
    colspan: 2,
    fill: c.head-fill,
    align: start + horizon,
    text(font: c.title-font, weight: "bold", size: c.title-size, {
      name
      if pts != none { [ ]; pts }
    }),
  )

  (
    head,
    .._cells(ex.parsed.items, c),
    table.cell(fill: c.sub-fill, align: center + horizon, strong(c.total-label)),
    table.cell(fill: c.sub-fill, align: center + horizon, total-cell),
  )
}

// الجدول الكبير الوحيد : سطر عناوين واحد (يتكرر أعلى كل صفحة) ثم كل التمارين
#let _big-table(cells, c) = table(
  columns: (1fr, c.mark-width),
  align: (start + horizon, center + horizon),
  stroke: c.stroke,
  inset: c.inset,
  fill: (x, y) => if y == 0 { c.head-fill } else { none },
  table.header(strong(c.ans-label), strong(c.mark-label)),
  ..cells,
)

// يقرأ جسم الوثيقة : كل #exercise متتالية تُدمج في جدول واحد ؛ وأي محتوى آخر
// (جدول إجمالي ، نص ...) يغلق الجدول ويُرسم كما هو.
#let _render(body, c) = {
  let kids = if body.has("children") { body.children } else { (body,) }
  let out = ()
  let cells = ()
  let sums = ()
  let n = 0
  for k in kids {
    let v = if type(k) == content and repr(k.func()) == "metadata" { k.value } else { none }
    if type(v) == dictionary and "na" in v and v.na == "ex" {
      n += 1
      sums.push(v.parsed.sum)
      cells += _ex-cells(v, n, c)
    } else if cells.len() > 0 and _blank(k) {
      // فراغ بين تمرينين : يُهمل حتى لا ينقطع الجدول
    } else {
      if cells.len() > 0 {
        out.push(_big-table(cells, c))
        cells = ()
      }
      out.push(k)
    }
  }
  if cells.len() > 0 { out.push(_big-table(cells, c)) }
  // مجاميع التمارين للجدول الإجمالي
  out.push(_totals.update(sums))
  out.join()
}

// ---------------------------------------------------------------------
// الجدول الإجمالي : كل تمرين وعلامته + المجموع الكلي (مثلا /20)
//   total : auto = المجموع المحسوب فقط ؛ أو عدد معلن (مثلا 20) يُقارَن
//   title : auto = «جدول التنقيط الإجمالي» ، أو محتوى ، أو none
// ---------------------------------------------------------------------
#let summary(total: auto, title: auto, gap: 1cm) = context {
  let c = _cfg.get()
  let items = _totals.final()
  let grand = items.sum(default: 0)

  v(gap, weak: true)
  if title != none {
    block(sticky: true, title-style(if title == auto { c.summary-label } else { title }))
    v(0.2cm)
  }

  let cells = ()
  for (i, s) in items.enumerate() {
    cells.push((c.ex-name)(i + 1))
    cells.push(_fmt(s, sep: c.sep))
  }

  let mismatch = type(total) in (int, float) and calc.abs(total - grand) > 0.001
  let total-cell = if mismatch {
    [#strong(_fmt(grand, sep: c.sep)) #text(fill: red, size: 0.75em)[⚠ #c.expected-label#_fmt(total, sep: c.sep)]]
  } else if type(total) in (int, float) {
    strong(text(dir: ltr)[#_fmt(grand, sep: c.sep) / #_fmt(total, sep: c.sep)])
  } else {
    strong(_fmt(grand, sep: c.sep))
  }

  block(width: 100%, table(
    columns: (1fr, c.mark-width + 1cm),
    align: center + horizon,
    stroke: c.stroke,
    inset: c.inset,
    fill: (x, y) => if y == 0 { c.head-fill } else { none },
    table.header(strong(c.ex-label), strong(c.mark-label)),
    ..cells,
    table.cell(fill: c.sub-fill, strong(c.total-label)),
    table.cell(fill: c.sub-fill, total-cell),
  ))
}

// ---------------------------------------------------------------------
// القالب : #show: correction.with(...)   (نفس خيارات na-examen)
// ---------------------------------------------------------------------
#let correction(
  school: auto,
  year: auto,
  level: auto,
  term: auto,
  kind: auto,
  term-label: auto,
  exam: auto,
  subject: auto,
  title: auto,                            // نص السطر كاملًا بدل «تصحيح + exam + subject»
  duration: auto,
  code: "na-corexamen",
  year-label: auto,
  level-label: auto,
  duration-label: auto,
  page-label: auto,
  of-label: auto,
  // ---- كلمات الجدول ----
  ex-label: auto,
  ans-label: auto,
  mark-label: auto,
  total-label: auto,
  summary-label: auto,
  // ---- الجدول ----
  decimal: ".",                           // فاصلة الأعداد : "." أو "،" أو ","
  head-fill: luma(215),                   // لون سطر العناوين
  sub-fill: luma(238),                    // لون العناوين الفرعية وسطر المجموع
  table-stroke: 0.6pt + black,
  table-inset: 7pt,
  mark-width: 2.4cm,                      // عرض عمود العلامات
  // ---- الباركود ----
  barcode: true,
  barcode-type: "Code128",
  barcode-data: auto,
  barcode-height: 0.64cm,
  barcode-width: 5cm,
  barcode-cut: 0.25,
  // ---- اللغة والخطوط والصفحة ----
  lang: "ar",
  dir: auto,
  font: auto,
  title-font: auto,
  size: auto,
  pad-points: true,
  paper: "a4",
  margin: (top: 2.7cm, bottom: 2cm, left: 1.4cm, right: 1.4cm),
  body,
) = {
  let P = _preset(lang)
  let pick(v, key) = if v == auto { P.at(key) } else { v }

  let school = pick(school, "school")
  let year = pick(year, "year")
  let level = pick(level, "level")
  let term = pick(term, "term")
  let kind = pick(kind, "kind")
  let exam = pick(exam, "exam")
  let subject = pick(subject, "subject")
  let duration = pick(duration, "duration")
  let year-label = pick(year-label, "year-label")
  let level-label = pick(level-label, "level-label")
  let duration-label = pick(duration-label, "duration-label")
  let page-label = pick(page-label, "page-label")
  let of-label = pick(of-label, "of-label")
  let dir = pick(dir, "dir")
  let font = pick(font, "font")
  let title-font = pick(title-font, "title-font")
  let size = pick(size, "size")

  let cfg = (
    title-font: title-font,
    title-size: size,
    part-size: size - 1pt,
    ex-name: P.ex-name,
    part-name: P.part-name,
    pt-one: P.pt-one,
    pt-many: P.pt-many,
    pad-points: pad-points,
    sep: decimal,
    ex-label: pick(ex-label, "ex-label"),
    ans-label: pick(ans-label, "ans-label"),
    mark-label: pick(mark-label, "mark-label"),
    total-label: pick(total-label, "total-label"),
    summary-label: pick(summary-label, "summary-label"),
    expected-label: P.expected-label,
    head-fill: head-fill,
    sub-fill: sub-fill,
    stroke: table-stroke,
    inset: table-inset,
    mark-width: mark-width,
  )
  _cfg.update(cfg)

  // ---- الباركود ----
  let bc-value = if barcode-data != auto { barcode-data } else if type(code) == str { code } else { "na-corexamen" }
  let draw-barcode(h, w) = box(width: w, height: h, clip: true,
    _tiaoma(bc-value, barcode-type, width: w, height: h / (1 - barcode-cut)))

  // ---- الترويسة ----
  let head-items = ()
  if barcode { head-items.push(draw-barcode(barcode-height, barcode-width)) }
  if code != none { head-items.push(text(size: 12pt, code)) }
  head-items.push(line(length: 100%, stroke: 0.5pt + black))

  set page(
    paper: paper,
    margin: margin,
    footer: context {
      align(center)[
        #line(length: 100%, stroke: 0.5pt + black)
        #v(-0.4cm)
        #page-label #counter(page).display() #of-label #counter(page).final().at(0)
      ]
    },
    header: align(center, stack(dir: ttb, spacing: 5pt, ..head-items)),
  )
  set text(dir: dir, lang: lang, font: font, size: size)

  // ---- كتلة المعلومات ----
  let k = size / 16pt
  let bs(b) = text(font: title-font, weight: "bold", size: size, b)
  let term-line = if term-label != auto { term-label } else if kind == none { term } else { [#kind #term] }
  let title-line = if title != auto { title } else { (P.title-fn)(exam, subject) }

  bs(school)
  h(1fr)
  bs([#year-label#year])
  v(5pt)
  bs([#level-label#level])
  h(1fr)
  bs(term-line)
  line(length: 100%, stroke: 1pt + black)
  v(-0.4cm * k)
  bs(title-line)
  h(1fr)
  if duration != none { bs([#duration-label#duration]) }
  v(-0.3cm * k)
  line(length: 100%, stroke: 1pt + black)
  v(0.4cm)

  _render(body, cfg)
}

// اختصارات / Shortcuts
#let correction-latin = correction.with(lang: "fr")
#let correction-fr = correction.with(lang: "fr")
#let correction-en = correction.with(lang: "en")
