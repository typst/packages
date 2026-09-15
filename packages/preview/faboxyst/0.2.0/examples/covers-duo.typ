// ===========================================================================
//  examples/covers-duo.typ — every book-cover style, twice.
//
//    typst compile examples/covers-duo.typ --root .
//
//  Sixteen covers: each of the eight styles set once in Arabic (rtl) and
//  once in French (ltr), with fresh subjects and wordings — literature,
//  history, sciences, analysis, geometry, statistics — to show the same
//  plates carrying two voices.
// ===========================================================================

#import "@preview/faboxyst:0.2.0": *

#set page(paper: "a4", margin: 1.5cm)

// ---- 1. guilloche ----
#set text(dir: rtl, lang: "ar")
#book-cover(
  style: "guilloche",
  series: [سلسلة الروائع الأدبية],
  title: [فنّ المقال],
  subtitle: [من الوصف إلى الحجاج],
  author: [د. سميرة حدّاد],
  year: [2026],
  publisher: [دار الياسمين],
  place-line: [الجزائر • وهران • قسنطينة],
)

#pagebreak()
#set text(dir: ltr, lang: "fr")
#book-cover(
  style: "guilloche",
  series: [BIBLIOTHÈQUE DES LETTRES],
  title: [L'ATELIER DU RÉCIT],
  subtitle: [Nouvelle, portrait, chronique],
  author: [Prof. A. Meunier],
  year: [2026],
  publisher: [ÉDITIONS DU CÈDRE],
  place-line: [Alger • Oran • Constantine],
)

// ---- 2. wedges ----
#pagebreak()
#set text(dir: rtl, lang: "ar")
#book-cover(
  style: "wedges",
  title: [تاريخ الجزائر],
  subtitle: [المقاومات الوطنية 1830 - 1954],
  author: [الأستاذ: ك. بومدين],
  level: [السنة الرابعة متوسط],
  year: [الموسم الدراسي: 2026 - 2027],
)

#pagebreak()
#set text(dir: ltr, lang: "fr")
#book-cover(
  style: "wedges",
  title: [GÉOGRAPHIE],
  subtitle: [Territoires en mutation],
  author: [Mme L. Cherif],
  level: [Classe de Première],
  year: [Édition 2026 - 2027],
)

// ---- 3. spine ----
#pagebreak()
#set text(dir: rtl, lang: "ar")
#book-cover(
  style: "spine",
  series: [وزارة التربية الوطنية],
  level: [التعليم المتوسط - السنة الثالثة],
  title: [الفيزياء],
  subtitle: [الضوء والعدسات],
  author: [إعداد الأستاذ: ر. عمارة],
  year: [تجارب موثّقة وتطبيقات محلولة],
  colour: rgb("#1B3A2F"),
  accent: rgb("#D9A441"),
)

#pagebreak()
#set text(dir: ltr, lang: "fr")
#book-cover(
  style: "spine",
  series: [Manuels de l'École Républicaine],
  level: [Collège — Classe de Troisième],
  title: [SCIENCES DE LA VIE],
  subtitle: [Le vivant en cellules],
  author: [Préparé par M. K. Saadi],
  year: [Fiches d'observation & TP guidés],
  colour: rgb("#2A1B3A"),
  accent: rgb("#B48EE0"),
)

// ---- 4. medallion ----
#pagebreak()
#set text(dir: rtl, lang: "ar")
#book-cover(
  style: "medallion",
  series: [ملخّص دروس وتمارين],
  title: [الكرة],
  subtitle: [الأرضية],
  level: [الجذع المشترك علوم],
  year: [باك 2029],
  author: [ياسمين],
  badge: [1],
  badge-label: [ثانوي],
  place-line: [دروس موجزة / رسوم تعليمية / تمارين متدرّجة],
  note: [الفصل 1: ديناميكية الكرة الأرضية],
)

#pagebreak()
#set text(dir: ltr, lang: "fr")
#book-cover(
  style: "medallion",
  series: [Résumés & exercices],
  title: [LA TERRE],
  subtitle: [ACTIVE],
  level: [Seconde scientifique],
  year: [Bac 2029],
  author: [Y. Belkacem],
  badge: [1],
  badge-label: [Tronc commun],
  place-line: [Cours synthétiques / Schémas / Exercices progressifs],
  note: [Chapitre 1 : séismes et volcans],
)

// ---- 5. compass ----
#pagebreak()
#set text(dir: rtl, lang: "ar")
#book-cover(
  style: "compass",
  series: [سلسلة البصيرة],
  note: [نبني الحدس قبل البرهان],
  badge-label: [السنة],
  badge: [2],
  badge-note: [ثانوي],
  lead-in: [كتابي في],
  title: [الرياضيات],
  subtitle: [الدوال اللوغاريتمية],
  level: [السنة الثانية ثانوي \_ الشعب العلمية],
  formula: [$ln(a b) = ln a + ln b$],
  author: [عمارة],
  author-label: [إعداد الأستاذ],
  place-line: [خصائص، نهايات، واشتقاق],
  publisher: [آفاق 2028],
  topics: [النهايات . الاشتقاق . النمو المتباطئ],
)

#pagebreak()
#set text(dir: ltr, lang: "fr")
#book-cover(
  style: "compass",
  series: [Collection Perspicacité],
  note: [L'intuition avant la preuve],
  badge-label: [Classe],
  badge: [Tle],
  badge-note: [spécialité],
  lead-in: [Mon cahier de],
  title: [MATHÉMATIQUES],
  subtitle: [Fonctions logarithmes],
  level: [Terminale — spécialité maths],
  formula: [$lim_(x -> +oo) ln(x)/x = 0$],
  author: [K. Saadi],
  author-label: [par],
  place-line: [propriétés, limites, dérivées],
  publisher: [Horizons 2028],
  topics: [limites . dérivées . croissances comparées],
)

// ---- 6. openbook ----
#pagebreak()
#set text(dir: rtl, lang: "ar")
#book-cover(
  style: "openbook",
  series: [سلسلة الفهم والتميّز],
  title: [الرياضيات],
  subtitle: [المتتاليات العددية],
  lead-in: [من الحدس إلى البرهان],
  note: [نتتبّع نموّ المتتالية حتى بلوغ نهايتها],
  page-a: [الرتبة والتقارب],
  page-b: [المتتاليات الهندسية],
  formula: [$u_(n+1) = q u_n$ ثمّ $u_n = u_0 q^n$],
  author: [إعداد الأستاذة ياسمين],
  place-line: [التعليم الثانوي . التحليل],
)

#pagebreak()
#set text(dir: ltr, lang: "fr")
#book-cover(
  style: "openbook",
  colour: rgb("#14424B"),
  accent: rgb("#E8871E"),
  series: [Collection Compréhension],
  title: [ANALYSE],
  subtitle: [Suites & limites],
  lead-in: [De l'intuition à la preuve],
  note: [Suivre une suite jusqu'au seuil qu'elle franchit],
  page-a: [Rang & convergence],
  page-b: [Suites géométriques],
  formula: [$u_n = u_0 q^n$ pour tout $n$],
  author: [Préparé par Y. Belkacem],
  place-line: [Lycée . Analyse],
)

// ---- 7. sunburst ----
#pagebreak()
#set text(dir: rtl, lang: "ar")
#book-cover(
  style: "sunburst",
  series: [سلسلة النجاح . بكالوريا 2027],
  note: [معًا نحو القمة],
  level: [السنة الثانية ثانوي],
  lead-in: [الشعب العلمية],
  topics: ([مجسّمات الفضاء: المكعب والمنشور],
           [التوازي والتقاطع في الفضاء],
           [الإسقاط العمودي وقواعده],
           [تمارين محلولة خطوة بخطوة]),
  title: [الرياضيات],
  subtitle: [الهندسة الفضائية],
  page-a: [من المستوى إلى الفضاء],
  page-b: [قراءة المجسّمات],
  formula: [$V = B times h$],
  author: [إعداد الأستاذ عمارة],
  place-line: [نفهم الفضاء . نبني البراهين],
)

#pagebreak()
#set text(dir: ltr, lang: "fr")
#book-cover(
  style: "sunburst",
  series: [Objectif Bac . session 2027],
  note: [Cap sur la mention],
  level: [Terminale — spé maths],
  lead-in: [Filières scientifiques],
  topics: ([Fiches mémo : limites & dérivées],
           [Méthodes de résolution guidées],
           [QCM d'auto-évaluation corrigés],
           [Schémas pour tout retenir]),
  title: [MATHÉMATIQUES],
  subtitle: [Révisions intensives],
  page-a: [Du plan à l'espace],
  page-b: [Lire les solides],
  formula: [$V = B times h$],
  author: [Préparé par R. Amara],
  place-line: [Comprendre . S'entraîner . Réussir],
)

// ---- 8. dice ----
#pagebreak()
#set text(dir: rtl, lang: "ar")
#book-cover(
  style: "dice",
  series: [سلسلة الامتياز],
  note: [الطبعة الثانية],
  title: [الاحتمالات],
  subtitle: [عدّ الأحداث \ توزيع الاحتمالات],
  author: [د. كريم بومدين],
  topics: [$P(A union B)$],
  page-a: [لغة الأحداث],
  formula: [$"Card"(A union B) = "Card"(A) + "Card"(B) - "Card"(A inter B)$ \
            $P(bar(A)) = 1 - P(A)$],
  lead-in: [نردان متوازنان: اثنتا عشرة نتيجة ممكنة.],
  page-b: [قانون ثنائي الحد],
  badge-label: [رمي نردين],
  badge: [$P(X = 7) = 6/36 = 1/6$ \ $E(X) = n p$],
  publisher: [ديوان العلوم للنشر],
)

#pagebreak()
#set text(dir: ltr, lang: "fr")
#book-cover(
  style: "dice",
  series: [COLLECTION EXCELLENCE],
  note: [Deuxième tirage],
  title: [STATISTIQUES],
  subtitle: [Sonder, estimer, prévoir \ Décider en incertitude],
  author: [Dr L. Cherif],
  topics: [$I_(95%)$],
  page-a: [L'ART DE L'ÉCHANTILLON],
  formula: [$bar(x) = 1/n sum_(i=1)^n x_i$ \
            $s^2 = 1/n sum_(i=1)^n (x_i - bar(x))^2$],
  lead-in: [Un sondage fiable commence par un bon échantillon.],
  page-b: [INTERVALLE DE CONFIANCE],
  badge-label: [SONDAGE À 95 %],
  badge: [$I = [bar(x) - 1/sqrt(n), bar(x) + 1/sqrt(n)]$ \
          $"amplitude" = 2/sqrt(n)$],
  publisher: [MAISON DES NOMBRES],
)

// ---- 9. scatter ----
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

#pagebreak()
#set text(dir: ltr, lang: "fr")
#book-cover(
  style: "scatter",
  series: [BAC 2027],
  title: [PROBABILITÉS],
  subtitle: [Série d'excellence en probabilités],
  author: [Avec le professeur : Nassim],
  formula: [$P(A) = "card"(A)/"card"(Omega)$],
  note: [pour une partition de l'univers],
  publisher: [Notions fondamentales   /   Exemples résolus   /   Exercices],
)
