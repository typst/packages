# na-corexamen

English · [العربية](#العربية)

## English

`na-corexamen` is a Typst package (Typst ≥ 0.13) for **marking schemes / corrections** of exams and assignments, in Arabic (RTL) and in Latin-script languages (LTR). It has the same header as `na-examen`. All exercises are drawn in **one continuous, page-breakable table (solution | marks)**: each exercise is a title row, its solution rows and a **Total** row, and the next exercise follows directly in the same table. You write the solution **freely** (plain text and equations, no brackets or cell syntax) and put `#mk(...)` at the end of each step: the package cuts your text at every `#mk`, puts each piece in a row with its mark in front of it, and **adds everything up automatically**. An optional summary table adds up all the exercises.

```typst
#import "@preview/na-corexamen:0.1.0": *

#show: correction.with(
  school: "ثانوية فلان الفلاني", level: "أولى ثانوي", subject: "الرياضيات",
  duration: "2 ســا",
)

#exercise[
  #section[I.]                           // sub-title row (optional)

  #q[1] Write the solution freely, with equations $x = 3$ #mk(0.5)

  #q[2] Another step
  $ f(x) = x^2 + 1 $ #mk(1)

  A step in two parts #mk(1, 1)          // marks given together are added up
]

#exercise(points: 5)[ #q[1] ... #mk(2) #q[2] ... #mk(3) ]   // declared points are checked
#summary(total: 20)                       // recap table + grand total /20
```

* The heading « التمرين الأول (08 نقاط) » takes its points from the sum of the `#mk`.
* `part[...]` groups rows under a sub-title; its points are summed too. `section[...]` is a plain sub-title row.
* `points:` is optional; if you give it and it differs from the computed total, a red ⚠ appears (same for `summary(total: ...)`).
* Rules: write `#exercise` at the top level of the document; write `#mk`, `#section`, `#part` directly in the body of the exercise; no `#set`/`#show` inside it or after `#show: correction`. Consecutive exercises form one table; other content between them (text, `#summary`) closes it.
* `lang: "fr" | "en" | "es" | "de"` switches to the Latin (LTR) template. `decimal: ","` changes the decimal separator.

Full documentation: `documentationEN.typ` (English) and `documentationAR.typ` (Arabic) — compile them with `typst compile`.

### Files

```
lib.typ  typst.toml  LICENSE  README.md
documentationEN.typ  documentationAR.typ
examples/   basic.typ  latin-fr.typ  latin-en.typ
```

---

<div dir="rtl">

## العربية

حزمة Typst (الإصدار ≥ 0.13) لـ**تصحيح الفروض والاختبارات** بالعربية (وباللغات اللاتينية أيضًا). لها نفس ترويسة `na-examen`. وترسم لكل التمارين **جدولًا واحدًا متصلًا يقبل الانقسام بين الصفحات (عناصر الإجابة | العلامة)** : لكل تمرين سطر عنوان وأسطر الحل وسطر **المجموع**، ثم يتبعه التمرين التالي مباشرةً في نفس الجدول. تكتب الحل **بحرية تامة** (نص ومعادلات، بلا أقواس ولا صيغة خلايا) وتضع `#mk(...)` في آخر كل خطوة : فتقطع الحزمة نصك عند كل `#mk` وتضع كل قطعة في سطر وعلامتها أمامها، و**تجمع كل شيء تلقائيًا**. وهناك جدول إجمالي اختياري يجمع كل التمارين.

```typst
#import "@preview/na-corexamen:0.1.0": *

#show: correction.with(school: "ثانوية فلان الفلاني", level: "أولى ثانوي", subject: "الرياضيات")

#exercise[
  #section[I.]                           // سطر عنوان فرعي (اختياري)

  #q[1] اكتب الحل بحرية مع المعادلات $x = 3$ #mk(0.5)

  #q[2] خطوة أخرى
  $ f(x) = x^2 + 1 $ #mk(1)

  خطوة على جزأين #mk(1, 1)               // العلامات المكتوبة معًا تُجمع
]

#exercise(points: 5)[ #q[1] ... #mk(2) #q[2] ... #mk(3) ]   // النقاط المعلنة تُراجَع
#summary(total: 20)                       // جدول إجمالي + المجموع الكلي من 20
```

* عنوان التمرين «التمرين الأول (08 نقاط)» يأخذ نقاطه من مجموع `#mk`.
* `part[...]` يجمع الأسطر تحت عنوان فرعي وتُجمع نقاطه أيضًا ؛ و`section[...]` سطر عنوان فرعي عادي.
* `points:` اختياري ؛ إن كتبته وخالف المجموع المحسوب يظهر ⚠ أحمر (وكذلك في `summary(total: ...)`).
* قواعد : اكتب `#exercise` في المستوى الأعلى من الوثيقة ؛ واكتب `#mk` و`#section` و`#part` مباشرةً في جسم التمرين ؛ ولا تضع `#set` أو `#show` داخله ولا بعد `#show: correction`. التمارين المتتالية تُدمج في جدول واحد، وأي محتوى آخر بينها (نص أو `#summary`) يغلق الجدول.
* `lang: "fr"` أو `"en"` أو `"es"` أو `"de"` للقالب اللاتيني. و`decimal: ","` لتغيير الفاصلة العشرية.

التوثيق الكامل : `documentationAR.typ` (بالعربية) و`documentationEN.typ` (بالإنجليزية) — قم بتصريفهما بـ `typst compile`.

</div>
