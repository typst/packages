#import "@preview/theorion:0.4.0": *
#import cosmos.fancy: *
// #import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion

#set page(height: auto)
#set heading(numbering: "1.1")
#set text(lang: "ar")

/// 1. تغيير العدادات والترقيم:
// #set-inherited-levels(1)
// #set-zero-fill(true)
// #set-leading-zero(true)
// #set-theorion-numbering("1.1")

/// 2. خيارات أخرى:
// #set-result("noanswer")
// #set-qed-symbol[#math.qed]

/// 3. بيئة مبرهنة مخصصة
// #let (theorem-counter, theorem-box, theorem, show-theorem) = make-frame(
//   "theorem",
//   "مبرهنة",
//   counter: theorem-counter,
//   inherited-levels: 2,
//   inherited-from: heading,
//   render: (prefix: none, title: "", full-title: auto, body) => [#strong[#full-title.]#sym.space#emph(body)],
// )
// #show: show-theorem

/// 4. استخدمها فقط
// #theorem(title: "مبرهنة إقليدس")[
//   هناك عدد لا نهائي من الأعداد الأولية.
// ] <thm:euclid>
// #theorem-box(title: "مبرهنة بدون ترقيم")[
//   هذه المبرهنة ليست مرقمة.
// ]

/// 5. مثال على الملحق
// #counter(heading).update(0)
// #set heading(numbering: "A.1")
// #set-theorion-numbering("A.1")

/// 6. جدول المحتويات
// #outline(title: none, target: figure.where(kind: "theorem"))

= بيئات ثيوريون

== بداية سريعة

```typst
#import "@preview/theorion:0.4.0": *
#import cosmos.fancy: *
// #import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion

#theorem(title: "مبرهنة إقليدس")[
  هناك عدد لا نهائي من الأعداد الأولية.
] <thm:euclid>

#theorem-box(title: "مبرهنة بدون ترقيم", outlined: false)[
  هذه المبرهنة ليست مرقمة.
]
```

== تخصيص

```typst
// 1. تغيير العدادات والترقيم:
#set-inherited-levels(1)
#set-zero-fill(true)
#set-leading-zero(true)
#set-theorion-numbering("1.1")

// 2. خيارات أخرى:
#set-result("noanswer")
#set-qed-symbol[#math.qed]

// 3. بيئة مبرهنة مخصصة
#let (theorem-counter, theorem-box, theorem, show-theorem) = make-frame(
  "theorem",
  "مبرهنة",
  counter: theorem-counter,
  inherited-levels: 2,
  inherited-from: heading,
  render: (prefix: none, title: "", full-title: auto, body) => [#strong[#full-title.]#sym.space#emph(body)],
)
#show: show-theorem

// 4. استخدمها فقط
#theorem(title: "مبرهنة إقليدس")[
  هناك عدد لا نهائي من الأعداد الأولية.
] <thm:euclid>
#theorem-box(title: "مبرهنة بدون ترقيم", outlined: false)[
  هذه المبرهنة ليست مرقمة.
]

// 5. مثال على الملحق
#counter(heading).update(0)
#set heading(numbering: "A.1")
#set-theorion-numbering("A.1")

// 6. جدول المحتويات
#outline(title: none, target: figure.where(kind: "theorem"))
```

== جدول المبرهنات

#outline(title: none, target: figure.where(kind: "theorem"))

== بيئات مبرهنة أساسية

دعونا نبدأ ببيئة التعريف.

#definition[
  يُسمى عدد طبيعي بـ #highlight[_عدد أولي_] إذا كان أكبر من 1
  ولا يمكن كتابته كناتج عددين طبيعيين أصغر.
] <def:prime>

#example[
  الأعداد $2$ و $3$ و $17$ أولية. كما هو مثبت في @cor:infinite-prime،
  هذه القائمة بعيدة عن الكمال! انظر @thm:euclid للبرهان الكامل.
]

#assumption[
  لكل $n in NN$، إذا وُجد $k in NN$ بحيث $n = 2k$، فنقول أن $n$ عدد زوجي.
]

#property[
  مجموع عددين زوجيين هو دائمًا عدد زوجي.
]

#conjecture(title: "حدسية الأعداد الأولية التوأم")[
  يوجد عدد لا نهائي من الأعداد الأولية $p$ بحيث $p+2$ أيضًا أولي.
]

#theorem(title: "مبرهنة إقليدس")[
  هناك عدد لا نهائي من الأعداد الأولية.
] <thm:euclid>

#proof[
  بالتناقض: افترض أن $p_1, p_2, dots, p_n$ هو تعداد متناهي للأعداد الأولية.
  ليكن $P = p_1 p_2 dots p_n$. لأن $P + 1$ ليس في قائمتنا،
  لا يمكن أن يكون أوليًا. وبالتالي، بعض الأعداد الأولية $p_j$ يقسم $P + 1$.
  لأن $p_j$ يقسم أيضًا $P$ ,يجب أن يقسم الفرق $(P + 1) - P = 1$،
  وهذا تناقص.
]

#corollary[
  لا يوجد أكبر عدد أولي.
] <cor:infinite-prime>

#lemma[
  هناك عدد لا نهائي من الأعداد المركبة.
]

== دوال و استمرارية

#theorem(title: "مبرهنة الاستمرارية")[
  إذا كانت دالة $f$ قابلة للتفاضل في كل نقطة, فإن $f$ مستمرة.
] <thm:continuous>

#tip-box[
  @thm:continuous تخبرنا أن القابلية للتفاضل تؤدي إلى الاستمرارية،
  ولكن ليس العكس. على سبيل المثال، $f(x) = |x|$ مستمرة ولكن ليس قابلة للتفاضل عند $x = 0$.
  لمزيد من الفهم العميق للدوال المستمرة، انظر @thm:max-value في الملحق.
]

== مبرهنات هندسية

#theorem(title: "مبرهنة فيثاغورس")[
  في مثلث قائم، مربع الوتر يساوي مجموع مربعي الضلعين الآخرين:
  $x^2 + y^2 = z^2$
] <thm:pythagoras>

#important-box[
  @thm:pythagoras هي واحدة من أهم المبرهنات وأكثرها تأثيرًا في هندسة المستوى،
  تجمع بين الهندسة والجبر.
]

#corollary[
  لا يوجد مثلث قائم بإضلاع ذات قياسات 3 سم و 4 سم و 6 سم.
  هذا يتبع مباشرة من @thm:pythagoras.
] <cor:pythagoras>

#lemma[
  مُعطى قطعتين من الخط ذوات أطول $a$ و $b$ ،هناك عدد حقيقي $r$
  يحقق $b = r a$.
] <lem:proportion>

== هياكل جبرية

#definition(title: "حلقة")[
  ليكن $R$ مجموعة غير فارغة مع عمليتين ثنائيتين $+$ و $dot$ ،تحقق:
  1. $(R, +)$ هي زمرة تبديلية (أبيلية)
  2. $(R, dot)$ هي شبه زمرة
  3. قوانين التوزيع محققة
  فإن $(R, +, dot)$ تُسمى حلقة.
] <def:ring>

#proposition[
  كل حقل هو حلقة، ولكن ليس كل حلقة هي حقل. هذا المفهوم يعتمد على @def:ring.
] <prop:ring-field>

#example[
  انظر @def:ring. حلقة الأعداد الصحيحة $ZZ$ ليست حقلًا، لأنه لا يوجد عناصر باستثناء $plus.minus 1$
  لها معكوسات ضربية.
]

/// ملحق
#counter(heading).update(0)
#set heading(numbering: "A.1")
#set-theorion-numbering("A.1")

= ملحقات ثيوريون

== تحليل متقدم

#theorem(title: "مبرهنة القيمة القصوى")[
  أية دالة مستمرة على مجال مغلق يجب أن تحقق قيمة قصوى ودنيا.
] <thm:max-value>

#warning-box[
  كلا الشرطين لهذه المبرهنة ضروريان:
  - يجب أن تكون الدالة مستمرة
  - يجب أن يكون المجال فترة مغلقة
]

== ملحقات جبر متقدم

#axiom(title: "مسلمات الزمرة")[
  يجب أن تحقق أي مجموعة $(G, dot)$ الشروط التالية:
  1. الإغلاق
  2. التجميع
  3. وجود عنصر الوحدة
  4. وجود العناصر معكوسة
] <axiom:group>

#postulate(title: "المبرهنة الأساسية في الجبر")[
  كل متعدد حدود غير منعدم مع معاملات مركبة (عُقدية) له جذور مركبة.
] <post:fta>

#remark[
  تُعرف هذه المبرهنة أيضًا باسم مبرهنة جاوس، لأنها أُثبتت لأول مرة بواسطة جاوس.
]

== مشاكل شائعة وحلولها

#problem[
  أثبت أنه لأي عدد صحيح $n > 1$، يوجد تسلسل من $n$ أعداد مركبة متتالية.
]

#solution[
  انظر التسلسل: $n! + 2, n! + 3, ..., n! + n$

  من أجل أي $2 <= k <= n$، فإن $n! + k$ قابل للقسم على $k$ لأن:
  $n! + k = k(n! / k + 1)$

  وبالتالي, نحصل على تسلسل من $n-1$ أعداد مركبة متتالية.
]

#exercise[
  1. أثبت أن حدسية الأعداد الأولية التوأم ماتزال غير مثبتة.
  2. حاول شرح لماذا تُعتبر هذه الحدسية صعبة.
]

#conclusion[
  تحتوي نظرية الأعداد على العديد من المسائل غير المحلولة التي تبدو بسيطة
  ولكنها معقدة بشكل عميق.
]

== ملاحظات مهمة

#note-box[
  تذكر أن البراهين الرياضية يجب أن تكون دقيقة وواضحة.
  الوضوح بدون دقة غير كافٍ، والدقة بدون وضوح غير فعالة.
]

#caution-box[
  عند التعامل مع السلاسل اللانهائية، قم دائمًا بالتحقق من التقارب قبل مناقشة الخواص الأخرى.
]

#quote-box[
  الرياضيات هي ملكة العلوم، ونظرية الأعداد هي ملكة الرياضيات.
  — جاوس
]

#emph-box[
  ملخص الفصل:
  - قدمنا مفاهيم نظرية الأعداد الأساسية
  - أثبتنا العديد من المبرهنات المهمة
  - أظهرنا أنواعًا مختلفة من البيئات الرياضية
]

== إعادة كتابة المبرهنات

// 1. إعادة كتابة جميع المبرهنات
#theorion-restate(filter: it => it.outlined and it.identifier == "theorem", render: it => it.render)
// 2. إعادة كتابة جميع المبرهنات مع دالة عرض مخصصة
// #theorion-restate(
//   filter: it => it.outlined and it.identifier == "theorem",
//   render: it => (prefix: none, title: "", full-title: auto, body) => block[#strong[#full-title.]#sym.space#emph(body)],
// )
// 3. إعادة كتابة مبرهنة محددة
// #theorion-restate(filter: it => it.label == <thm:euclid>)

