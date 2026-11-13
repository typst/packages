# na-examen

حزمة Typst لإعداد الفروض والاختبارات المدرسية بشكل احترافي، مع دعم كامل للغة العربية واللاتينية.

## Documentation and Files

- Arabic Documentation: documentationAR.typ
- English Documentation: documentationEN.typ
## English

`na-examen` is a Typst package (Typst ≥ 0.13) for exams and assignments in Arabic (RTL) and in Latin-script languages (LTR: French, English, Spanish, German). The author only writes the exercises; the package draws the page: a header with a barcode, a line of text under it, the school, the school year, the level, the term, the subject and the duration, and a footer "page X of Y". Exercises, parts and question boxes are numbered automatically.

### Usage

```typst
#import "@preview/na-examen:0.1.0": *

#show: examen.with(
  school: "ثانوية فلان الفلاني",
  year: "2026-2027",
  level: "أولى جذع مشترك علوم وتكنولوجيا",
  term: "الفصل الأول",
  subject: "الرياضيات",
  duration: "2 ســا",
  code: "fard 1 fasl awal-1AS-typst",   // text under the barcode
)

#exercise(points: 8)[
  *I.* نص التمرين ...
  #q[1] السؤال الأول.
  #q[2] السؤال الثاني.
]

#exercise(points: 5)[ ... ]

#exercise(points: 7)[
  #part(points: 2)[ ... ]
  #part(points: 5)[ ... ]
]
```

### Latin template (French, English, ...)

The same template also exists in Latin script. Choose it with `lang`; the direction becomes left-to-right, the fonts, the fixed words and the exercise names follow the language:

```typst
#import "@preview/na-examen:1.1.0": *

#show: examen.with(
  lang: "fr",                       // "fr", "en", "es" or "de"  (default "ar")
  school: "Lycée Ibn Khaldoun",
  level: "1re année secondaire",
  term: "Premier trimestre",
  subject: "Mathématiques",
  duration: "2 h",
)

#exercise(points: 8)[ ... #q[1] ... ]     // « Exercice 1 (08 points) »
#exercise(points: 7)[
  #part(points: 3)[ ... ]                   // « Partie A (03 points) »
  #part(points: 4)[ ... ]
]
```

`examen-latin` is the same as `examen.with(lang: "fr")`, `examen-fr` and `examen-en` are shortcuts too. Every option left at `auto` (school, level, term, subject, labels, fonts, size, ...) is taken from the language; any value you write replaces it. For another language, use `lang: "it"` for example: the English words are used and you replace them with the options (`year-label`, `page-label`, `of-label`, ...) and `title` / `term-label`.

| Language | Exercise | Part | Points | Page footer |
|----------|----------|------|--------|-------------|
| `ar` | التمرين الأول | الجزء الأول | (08 نقاط) | صفحة 1 من 3 |
| `fr` | Exercice 1 | Partie A | (08 points) | Page 1 sur 3 |
| `en` | Exercise 1 | Part A | (08 points) | Page 1 of 3 |
| `es` | Ejercicio 1 | Parte A | (08 puntos) | Página 1 de 3 |
| `de` | Aufgabe 1 | Teil A | (08 Punkte) | Seite 1 von 3 |

The document language follows `lang`, so other packages that follow `#set text(lang: ...)` (for example `na-tabpos`) use French or English words automatically. `pad-points: false` writes `8 points` instead of `08 points`.

### Functions

| Function | Meaning |
|----------|---------|
| `examen` | the template (`#show: examen.with(...)`): page, header, footer and information block |
| `exercise(points:, title:, gap:)[...]` | an exercise: "التمرين الأول (08 نقاط)", numbered automatically |
| `part(points:, title:, gap:)[...]` | a part inside an exercise: "الجزء الأول (02 نقاط)", numbering restarts at each exercise |
| `q[1]` | boxed question number (`coB` is the same function) |
| `title-style[...]` | bold underlined title |

`points` is a number (`8` gives "(08 نقاط)", `1` gives "(01 نقطة)"), a string (used as written, in parentheses) or `none`. `title: auto` is the automatic title; give any content to replace it.

### Options of `examen`

| Option | Default | Meaning |
|--------|---------|---------|
| `school` | `"اسم المؤسسة"` | school |
| `year` | `"2026-2027"` | school year, after `year-label` |
| `level` | `"المستوى"` | level, after `level-label` |
| `term` | `"الفصل الأول"` | term |
| `kind` | `"فروض"` | word before the term ("فروض الفصل الأول"); `none` removes it |
| `term-label` | `auto` | the whole term text, instead of `kind` + `term` |
| `exam` | `"الفرض المحروس"` | type of exam |
| `subject` | `"الرياضيات"` | subject: "الفرض المحروس في مادة الرياضيات" |
| `title` | `auto` | the whole title line, instead of `exam` + `subject` |
| `duration` | `"2 ســا"` | duration, after `duration-label`; `none` removes it |
| `code` | `"na-examen"` | text under the barcode; `none` removes it |
| `barcode` | `true` | draw the barcode |
| `barcode-height`, `barcode-width` | `0.64cm`, `5cm` | barcode size |
| `barcode-type`, `barcode-data`, `barcode-cut` | `"Code128"`, `auto`, `0.25` | real barcode (tiaoma): type, encoded value (`auto` = the `code` text), fraction cut from the bottom |
| `year-label`, `level-label`, `duration-label`, `page-label`, `of-label` | Arabic words | fixed words |
| `lang` | `"ar"` | language of the document |
| `font`, `title-font`, `size` | Amiri, Arial, `16pt` | fonts and size |
| `paper`, `margin` | `"a4"`, as in the original file | page |

The document language is `ar`, so other packages that follow `#set text(lang: ...)` (for example `na-tabpos`) use Arabic words automatically.

### Files

```
lib.typ  typst.toml  LICENSE  README.md
documentationEN.typ  documentationAR.typ     (compile them to get the PDFs)
examples/          basic.typ  custom-header.typ  no-barcode.typ  latin-fr.typ  latin-en.typ
fichier_de_test/   long-exam.typ
```

---

<div dir="rtl">

## العربية

[English](#english) · العربية

`na-examen` حزمة Typst (الإصدار ≥ 0.13) للفروض والاختبارات العربية، وكذلك اللاتينية (الفرنسية والإنجليزية والإسبانية والألمانية). لا على المستخدم إلا أن يكتب نص التمارين؛ والحزمة ترسم الصفحة: ترويسة فيها باركود ونص تحته، والمؤسسة، والسنة الدراسية، والمستوى، والفصل، والمادة، والمدة، وتذييل «صفحة X من Y». وتُرقَّم التمارين والأجزاء تلقائيًا.

### الاستعمال

```typst#import "@preview/na-examen:0.1.0": *

#show: examen.with(
  school: "ثانوية فلان الفلاني",
  year: "2026-2027",
  level: "أولى جذع مشترك علوم وتكنولوجيا",
  term: "الفصل الأول",
  subject: "الرياضيات",
  duration: "2 ســا",
  code: "fard 1 fasl awal-1AS-typst",   // النص تحت الباركود
)

#exercise(points: 8)[
  *I.* نص التمرين ...
  #q[1] السؤال الأول.
  #q[2] السؤال الثاني.
]
```

### القالب اللاتيني (الفرنسية، الإنجليزية، ...)

للقالب نسخة بالحروف اللاتينية أيضًا، تُختار بالخيار `lang`: يصير الاتجاه من اليسار إلى اليمين، وتتبع الخطوط والكلمات الثابتة وأسماء التمارين اللغةَ المختارة:

```typst
#show: examen.with(
  lang: "fr",                       // "fr" أو "en" أو "es" أو "de"  (الافتراضي "ar")
  school: "Lycée Ibn Khaldoun",
  level: "1re année secondaire",
  term: "Premier trimestre",
  subject: "Mathématiques",
  duration: "2 h",
)

#exercise(points: 8)[ ... ]     // « Exercice 1 (08 points) »
```

والاسم `examen-latin` يساوي `examen.with(lang: "fr")`، وكذلك `examen-fr` و`examen-en`. كل خيار تتركه `auto` يؤخذ من قالب اللغة، وأي قيمة تكتبها تحلّ محلّه. ولغة أخرى (مثل `lang: "it"`) تستعمل الكلمات الإنجليزية، فتغيّرها بالخيارات (`year-label` و`page-label` و`of-label` ...) و`title` و`term-label`.

الدوال والخيارات مذكورة في الجدولين أعلاه، وبالتفصيل في `documentationAR.typ`.

</div>
