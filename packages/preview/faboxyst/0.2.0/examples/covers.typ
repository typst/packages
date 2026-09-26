// ===========================================================================
//  examples/covers.typ — the three full-page book covers of faboxyst.
//
//    typst compile examples/covers.typ --root .
//
//  Each cover paints the whole page: it reads the paper size and the
//  margins from the context and bleeds to the edge. Anchored elements
//  (series line, title block, seal, footer, spine band) follow the text
//  direction, so the Arabic covers below mirror on their own.
// ===========================================================================

#import "@preview/faboxyst:0.2.0": *

#set page(paper: "a4", margin: 1.5cm)

// 1. the royal guilloche: spiralling lace, diagonal grid, rosette seal
#book-cover(
  style: "guilloche",
  series: [COLLECTION D'EXCELLENCE ACADÉMIQUE],
  title: [THÉORIE DES NOMBRES],
  subtitle: [Théorie et Recherche Avancée],
  author: [Pr. Nom de l'Auteur],
  year: [2026],
  publisher: [ÉDITIONS ACADÉMIQUES],
  place-line: [tissemsilt • ALGER • lalou],
)

// 2. the Boussaada wedges: checker ground, paper wedges, white cards
#pagebreak()
#set text(dir: rtl, lang: "ar")
#book-cover(
  style: "wedges",
  title: [العنوان الرئيسي للكتاب],
  subtitle: [سلسلة التميز في الرياضيات],
  author: [المؤلف: بوسعادة حفيظ],
  level: [المستوى: السنة الرابعة متوسط],
  year: [السنة الدراسية: 2026 - 2027],
)

// 3. the spine band: rings and rungs beside a double-ruled title panel
#pagebreak()
#book-cover(
  style: "spine",
  series: [الجمهورية الجزائرية الديمقراطية الشعبية],
  level: [مستوى التعليم الثانوي - رياضيات],
  title: [سلسلة التميز],
  subtitle: [في الأعداد المركبة],
  author: [إعداد الأستاذ: نسيم],
  year: [تمارين شاملة، وحلول نموذجية],
  colour: rgb("#05192D"),
  accent: rgb("#4CC9F0"),
)

// 4. the medallion: a cream disc ringed in orange on brown, carrying an
//    atelier of school instruments on a gold pedestal
#pagebreak()
#book-cover(
  style: "medallion",
  series: [ملخّص دروس وتمارين],
  title: [الأعداد],
  subtitle: [المركّبة],
  level: [الشعب العلمية],
  year: [باك 2027],
  author: [نسيم],
  badge: [C],
  badge-label: [الرياضيات],
  place-line: [ملخّص دروس  /  تمارين نموذجية  /  حلول مفصّلة],
  note: [e^(iθ) = cos θ + i sin θ],
)

// 5. the compass: indigo streaks, magenta header card, year badge, an inset
//    graph and a great compass standing on its ellipse
#pagebreak()
#book-cover(
  style: "compass",
  series: [سلسلة التفوّق],
  note: [نفهم المفاهيم ونبني الحلول],
  badge-label: [السنة],
  badge: [3],
  badge-note: [ثانوي],
  lead-in: [كتابي في],
  title: [الرياضيات],
  subtitle: [دراسة الدوال],
  level: [السنة الثالثة ثانوي \_ الشعبة العلمية],
  formula: [$g(x) = x + 1 + 1/(x-1)$],
  author: [نسيم],
  author-label: [إعداد الأستاذ],
  place-line: [دروس مركّزة وتمارين محلولة],
  publisher: [بكالوريا 2027],
  topics: [النهايات . الاشتقاقية . السلوك التقاربي],
)

// 6. the open book: a dark band over a cream ground, two graphed pages,
//    a bookmark, a formula panel — here in its teal palette
#pagebreak()
#book-cover(
  style: "openbook",
  colour: rgb("#14424B"), accent: rgb("#E8871E"),
  series: [سلسلة الفهم والتميّز],
  title: [الرياضيات],
  subtitle: [النهايات والاشتقاقية],
  lead-in: [من الاقتراب إلى المماس],
  note: [اقرأ المحتوى، نفهم التقنية، ونبني المماس],
  page-a: [النهايات والاقتراب],
  page-b: [الاشتقاقية والمماس],
  formula: [$f'(a) = lim_(h -> 0) (f(a + h) - f(a))/h$],
  author: [إعداد الأستاذ نسيم],
  place-line: [التعليم الثانوي . التحليل الرياضي],
)

// 7. the sunburst: radial rays on green, a gold motto, yellow bands,
//    a bulleted topic list and an open book ringed by instruments
#pagebreak()
#book-cover(
  style: "sunburst",
  series: [سلسلة التميّز . بكالوريا 2027],
  note: [نرتقي إلى التميّز],
  level: [السنة الثالثة ثانوي],
  lead-in: [الشعب العلمية],
  topics: ([ملخصات مركّزة في النهايات والاستمرارية],
           [قواعد الاشتقاق ودراسة تغيّرات الدوال],
           [تمارين تطبيقية متدرّجة مع حلول مشروحة],
           [رسوم بيانية لفهم المماس والمستقيمات المقاربة]),
  title: [الرياضيات],
  subtitle: [دراسة الدوال],
  page-a: [من الاشتقاق إلى المماس],
  page-b: [قراءة السلوك التقاربي],
  formula: [$g(x) = x + 1 + 1/(x-1)$],
  author: [إعداد الأستاذ ناعم محمد],
  place-line: [نفهم المفاهيم . نعقل الحلول . نرتقي إلى التميّز],
)

// 8. the dice plate: navy frame with gem motifs, a rosette, a white card
//    whose corner is cut by a swoosh of 3D dice — an LTR French page
#pagebreak()
#set text(dir: ltr, lang: "fr")
#book-cover(
  style: "dice",
  series: [COLLECTION D'EXCELLENCE],
  note: [Première Édition],
  title: [PROBABILITÉS],
  subtitle: [Comprendre le hasard \ Explorer les possibles],
  author: [Nom de l'Auteur],
  topics: [$P(A)$],
  page-a: [LE LANGAGE DU HASARD],
  formula: [$Omega = { 1, 2, 3, 4, 5, 6 }$ \ $P(A) = frac(|A|, |Omega|)$],
  lead-in: [Un dé équilibré : six issues équiprobables.],
  page-b: [UNE LOI UNIFORME],
  badge-label: [OBTENIR UN NOMBRE PAIR],
  badge: [$A = { 2, 4, 6 }$ \ $P(A) = 3/6 = 1/2$ \ $P(bar(A)) = 1 - P(A)$],
  publisher: [ÉDITIONS ACADÉMIQUES],
)

// 9. the scatter plate: a cloud of 3D dice over night teal, faint
//    rosettes, a gold rule with corner ticks — an RTL Arabic page
#pagebreak()
#set text(dir: rtl, lang: "ar")
#book-cover(
  style: "scatter",
  series: [باك 2027],
  title: [الاحتمالات],
  subtitle: [سلسلة التميّز في الاحتمالات],
  author: [مع الأستاذ: نسيم],
  formula: [$P(A) = abs(A)/abs(Omega)$],
  note: [لتجزئة فضاء النتائج],
  publisher: [مفاهيم أساسية   /   أمثلة محلولة   /   تمارين وتطبيقات],
)
