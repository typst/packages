// ======================================================================
// na-examen : قالب فروض واختبارات عربي + لاتيني (فرنسية، إنجليزية، ...)
// ترويسة (باركود + نص تحته + المؤسسة + السنة + المستوى + الفصل + المادة + المدة)
// وتذييل «صفحة X من Y» وتمارين مرقّمة تلقائيًا.
//
// الاستعمال (عربي) :
//   #import "@preview/na-examen:1.1.0": *
//   #show: examen.with(school: [...], year: "2026-2027", ...)
//   #exercise(points: 8)[ ... #q[1] ... ]
//
// الاستعمال (لاتيني : fr / en / es / de) :
//   #show: examen.with(lang: "fr", school: "Lycée ...", ...)
//   #show: examen-latin.with(school: "Lycée ...", ...)      // = lang: "fr"
//   #exercise(points: 8)[ ... #q[1] ... ]                    // « Exercice 1 (08 points) »
//
// na-examen : exam template for Typst — Arabic (RTL) and Latin (LTR: French,
// English, Spanish, German) — header with barcode, footer "page X of Y",
// auto-numbered exercises / parts and question boxes.
// ======================================================================

#import "@preview/tiaoma:0.3.0": barcode as _tiaoma

// ---------------------------------------------------------------------
// خطوط افتراضية / Default fonts
// ---------------------------------------------------------------------
#let _sans = ("Arial", "Liberation Sans", "Noto Sans Arabic", "DejaVu Sans")
#let _sans-latin = ("Arial", "Liberation Sans", "DejaVu Sans")
#let _serif-latin = ("Libertinus Serif", "Linux Libertine", "Times New Roman", "Liberation Serif", "DejaVu Serif")

// الترتيبيات : التمرين الأول ، الثاني ... (للعربية فقط)
#let _ordinals = (
  "الأول", "الثاني", "الثالث", "الرابع", "الخامس",
  "السادس", "السابع", "الثامن", "التاسع", "العاشر",
)
#let _ordinal(n) = if n <= _ordinals.len() { _ordinals.at(n - 1) } else { "رقم " + str(n) }

// ---------------------------------------------------------------------
// قوالب اللغات : كل لغة = اتجاه + خطوط + كلمات ثابتة + أسماء التمارين والأجزاء
// Language presets : direction + fonts + fixed words + exercise/part names
// لإضافة لغة جديدة : انسخ إحدى القوائم أدناه وأضفها إلى _presets
// To add a language: copy one preset below and add it to _presets
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
  title-fn: (e, s) => [#e في مادة #s],
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
  title-fn: (e, s) => [#e de #s],
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
  title-fn: (e, s) => [#s #e],
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
  title-fn: (e, s) => [#e de #s],
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
  title-fn: (e, s) => [#e in #s],
)

#let _presets = (ar: _ar, fr: _fr, en: _en, es: _es, de: _de)
// لغة غير معروفة : قالب لاتيني إنجليزي / unknown language: English-like Latin preset
#let _preset(lang) = if lang in _presets { _presets.at(lang) } else { _en }

// ---------------------------------------------------------------------
// إعدادات داخلية يضبطها examen ويقرؤها exercise و part و title-style
// Internal settings, written by `examen`, read by exercise / part / title-style
// ---------------------------------------------------------------------
#let _cfg = state("na-examen-cfg", (
  title-font: _sans,
  title-size: 16pt,
  part-size: 15pt,
  ex-name: _ar.ex-name,
  part-name: _ar.part-name,
  pt-one: _ar.pt-one,
  pt-many: _ar.pt-many,
  pad-points: true,
))

#let _ex-counter = counter("na-examen-exercise")
#let _part-counter = counter("na-examen-part")

// النقاط : 8 -> (08 نقاط) / (08 points) ، 1 -> (01 نقطة) / (01 point) ، نص -> كما كُتب بين قوسين
// Points: 8 -> (08 points) ; 1 -> (01 point) ; a string/content is used as written, in parentheses
#let _points-text(p, c) = {
  if p == none {
    none
  } else if type(p) == str or type(p) == content {
    [(#p)]
  } else {
    let s = str(p)
    if c.pad-points and p >= 1 and p < 10 { s = "0" + s }
    [(#s #if p == 1 [#c.pt-one] else [#c.pt-many])]
  }
}

// ---------------------------------------------------------------------
// عنوان بخط عريض ومسطّر (مثل «التمرين الأول» أو «Exercice 1»)
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
// تمرين : عنوانه «التمرين <الترتيبي> (<النقاط> نقاط)» أو «Exercice <n> (<n> points)»
//   points : عدد (8) أو نص ("08 نقاط") أو none
//   title  : auto = ترقيم تلقائي ، أو محتوى تكتبه بنفسك
//   gap    : المسافة قبل التمرين (لا تُضاف قبل الأول)
// ---------------------------------------------------------------------
#let exercise(points: none, title: auto, gap: 1cm, body) = {
  _ex-counter.step()
  _part-counter.update(0)
  context {
    let c = _cfg.get()
    let n = _ex-counter.get().first()
    if n > 1 { v(gap, weak: true) }
    let name = if title == auto { (c.ex-name)(n) } else { title }
    let pts = _points-text(points, c)
    block(sticky: true, title-style({
      name
      if pts != none { [ ]; pts }
    }))
  }
  body
}

// ---------------------------------------------------------------------
// جزء داخل تمرين : «الجزء الأول (02 نقاط)» أو «Partie A (02 points)» ؛ يُعاد ترقيمه مع كل تمرين
// ---------------------------------------------------------------------
#let part(points: none, title: auto, gap: 0.6cm, body) = {
  _part-counter.step()
  context {
    let c = _cfg.get()
    let n = _part-counter.get().first()
    if n > 1 { v(gap) }
    let name = if title == auto { (c.part-name)(n) } else { title }
    let pts = _points-text(points, c)
    block(sticky: true, text(font: c.title-font, weight: "bold", size: c.part-size, {
      name
      if pts != none { [ ]; pts }
    }))
  }
  body
}

// ---------------------------------------------------------------------
// القالب : #show: examen.with(...)
//   lang: "ar" (افتراضي، RTL) أو "fr" / "en" / "es" / "de" (LTR)
//   كل الخيارات التي قيمتها auto تُؤخذ من قالب اللغة
//   Every option set to auto is taken from the language preset
// ---------------------------------------------------------------------
#let examen(
  // ---- النصوص التي يغيّرها المستخدم ----
  school: auto,                           // المؤسسة / school
  year: auto,                             // السنة الدراسية / school year
  level: auto,                            // المستوى / level
  term: auto,                             // الفصل / term
  kind: auto,                             // «فروض» + الفصل ؛ none لحذفها
  term-label: auto,                       // نص السطر كاملًا بدل kind + term
  exam: auto,                             // نوع الاختبار / type of exam
  subject: auto,                          // المادة / subject
  title: auto,                            // نص السطر كاملًا بدل exam + subject
  duration: auto,                         // المدة ؛ none لحذفها
  code: "na-examen",                      // النص تحت الباركود ؛ none لحذفه
  // ---- كلمات ثابتة (غيّرها لتعريب أو ترجمة أخرى) ----
  year-label: auto,
  level-label: auto,
  duration-label: auto,
  page-label: auto,
  of-label: auto,
  // ---- الباركود ----
  barcode: true,
  barcode-type: "Code128",                // نوع الباركود (من tiaoma)
  barcode-data: auto,                     // القيمة المرمّزة ؛ auto = نص code
  barcode-height: 0.64cm,
  barcode-width: 5cm,
  barcode-cut: 0.25,                      // جزء يُقصّ من أسفل الباركود (0 = لا قصّ)
  // ---- اللغة والخطوط والصفحة ----
  lang: "ar",                             // "ar" ، "fr" ، "en" ، "es" ، "de"
  dir: auto,                              // rtl أو ltr ؛ auto = حسب اللغة
  font: auto,
  title-font: auto,
  size: auto,
  pad-points: true,                       // 8 -> 08
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

  _cfg.update((
    title-font: title-font,
    title-size: size,
    part-size: size - 1pt,
    ex-name: P.ex-name,
    part-name: P.part-name,
    pt-one: P.pt-one,
    pt-many: P.pt-many,
    pad-points: pad-points,
  ))

  // ---- الباركود : Code128 حقيقي (tiaoma) ----
  let bc-value = if barcode-data != auto { barcode-data } else if type(code) == str { code } else { "na-examen" }
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
  // المسافات السالبة مضبوطة على حجم 16pt (العربية) وتتناسب مع الحجم
  let k = size / 16pt
  let bs(b) = text(font: title-font, weight: "bold", size: size, b)
  let term-line = if term-label != auto { term-label } else if kind == none { term } else { [#kind #term] }
  let title-line = if title != auto { title } else { (P.title-fn)(exam, subject) }

  // في RTL تظهر المؤسسة يمينًا والسنة يسارًا ؛ وفي LTR العكس (المؤسسة يسارًا)
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

  body
}

// ---------------------------------------------------------------------
// اختصارات للقالب اللاتيني / Shortcuts for Latin templates
//   #show: examen-latin.with(...)        // فرنسية / French (lang: "fr")
//   #show: examen-latin.with(lang: "en", ...)
// ---------------------------------------------------------------------
#let examen-latin = examen.with(lang: "fr")
#let examen-fr = examen.with(lang: "fr")
#let examen-en = examen.with(lang: "en")
