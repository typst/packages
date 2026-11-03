// Print-only proof for abstract-textbox, with matching LTR and RTL sets.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 20cm, height: auto, margin: 1cm, fill: white)
#set text(font: "DejaVu Sans", size: 8pt)
#set par(leading: 0.42em)
#show: faboxyst.with(theme: "print")

= Abstract Textboxes — print

#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  column-gutter: 0.30cm,
  abstract-textbox(
    title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
    number: [01], icon: image("assets/abstract-gears.svg", width: 0.78cm),
    colour: rgb("#F3921B"), width: 100%,
    backing-offset: (x: 0.48cm, y: 0.20cm),
  ),
  abstract-textbox(
    title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
    number: [02], icon: image("assets/abstract-database.svg", width: 0.78cm),
    colour: rgb("#4ABCE6"), width: 100%,
  ),
  abstract-textbox(
    title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
    number: [03], icon: image("assets/abstract-search.svg", width: 0.78cm),
    colour: rgb("#A5BF6A"), width: 100%,
  ),
  abstract-textbox(
    title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
    number: [04], icon: image("assets/abstract-idea-print.svg", width: 0.78cm),
    colour: rgb("#FFD04A"), width: 100%,
  ),
)

#v(0.5cm)
#text(lang: "en", dir: ltr, size: 12pt, weight: "bold")[Same cards — RTL print]
#set text(lang: "ar", dir: rtl)
#v(0.2cm)
#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  column-gutter: 0.30cm,
  abstract-textbox(
    title: [معلومات عامة],
    body: [نصّ موجز لشرح الفكرة، مع توضيح النقاط الأساسية وإضافة أمثلة تساعد على الفهم.],
    number: [01], icon: image("assets/abstract-gears.svg", width: 0.78cm),
    colour: rgb("#F3921B"), width: 100%, direction: rtl,
    backing-offset: (x: 0.48cm, y: 0.20cm),
  ),
  abstract-textbox(
    title: [قاعدة البيانات],
    body: [تُنظّم البيانات وتُحفظ بطريقة تسهّل الوصول إليها واستعمالها عند الحاجة.],
    number: [02], icon: image("assets/abstract-database.svg", width: 0.78cm),
    colour: rgb("#4ABCE6"), width: 100%, direction: rtl,
  ),
  abstract-textbox(
    title: [البحث],
    body: [ابحث عن المعلومات المناسبة، ثم قارن النتائج واختر ما يدعم الموضوع.],
    number: [03], icon: image("assets/abstract-search.svg", width: 0.78cm),
    colour: rgb("#A5BF6A"), width: 100%, direction: rtl,
  ),
  abstract-textbox(
    title: [فكرة جديدة],
    body: [اجمع بين الملاحظة والتجربة للوصول إلى استنتاج واضح ومفيد.],
    number: [04], icon: image("assets/abstract-idea-print.svg", width: 0.78cm),
    colour: rgb("#FFD04A"), width: 100%, direction: rtl,
  ),
)
