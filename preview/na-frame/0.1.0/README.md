# na-frame 0.1.0 (الإصدار الأول / first release)

إطارات احترافية قابلة للتقسيم بين الصفحات، تعمل بالعربية (RTL) وباللاتينية (LTR).
Professional breakable frames for Arabic (RTL) and Latin (LTR) documents.

**كل تعريفات الإطارات موجودة في ملف واحد: `lib.typ`.**
All frame definitions live in a single file: `lib.typ`.
## Documentation and Files

- Arabic Documentation: [doc.pdf](doc.pdf)
- English Documentation: [doc-en.pdf](doc-en.pdf)
- Example: [demo-ar.typ](demo-ar.typ)
- Example: [demo-en.typ](demo-en.typ)
## التثبيت / Install

**تثبيت يدوي / Manual install:** copy the package contents into
`<typst-data>/typst/packages/na/na-frame/0.1.0/` (folder name = `version` in `typst.toml`):

| OS | Path |
|---|---|
| Linux | `~/.local/share/typst/packages/na/na-frame/0.1.0/` |
| macOS | `~/Library/Application Support/typst/packages/na/na-frame/0.1.0/` |
| Windows | `%APPDATA%\typst\packages\na\na-frame\0.1.0\` |

ثم استدعها بالاسم / then import it by name:

    #import "@na/na-frame:0.1.0": *

**من مستودع حزم Typst (في حال القبول) / From the Typst package repository (once accepted):** no install needed, Typst downloads it automatically:

    #import "@preview/na-frame:0.1.0": *

## الواجهة الموحدة / Unified interface

المحتوى أولًا ثم المعاملات المسماة: `#theorem-frame(title: [مبرهنة], color: palette.red)[ ... ]`

| المعامل | المعنى |
|---|---|
| `title` | العنوان (`auto` = عنوان افتراضي حسب لغة المستند) |
| `color` | لون الإطار |
| `title-color` | لون خانة العنوان (`auto` = لون الإطار) |
| `title-text-color` | لون نص العنوان |
| `breakable` | قابل للتقسيم بين الصفحات (الافتراضي `true`) |

استدعاء عام: `#frame("blue", title: [تعريف])[ ... ]` — الأسماء في السجل `frames`.

## إطارات عربية ولاتينية في نفس الملف / Mixed directions in one file

كل إطار يقبل `dir:` (‏`auto` = اتجاه المستند، أو `rtl`، أو `ltr`) و`lang:` (الافتراضي `ar` مع rtl و`en` مع ltr):

    #theorem-frame(dir: rtl)[مبرهنة فيثاغورس ...]
    #theorem-frame(dir: ltr, title: [Theorem])[Pythagoras ...]
    #frame("blue", dir: ltr)[A definition ...]

Every frame takes `dir:` and `lang:`, so Arabic and Latin frames can live in the same document.

## الإطارات / Frames (64 في السجل)

**الدفعتان 1–2:** board, blue, theorem, flag, proof, gradient, chapter, ribbon, green, shadow, paper, sticky, notebook, corner-rule, properties, folded, centered, double-tab, torn, spiral, notebook-page, numbered-exercise

**الدفعة 3:**

- تمارين: numbered, exercise-card, exam, framed-exercise, sheet, subtitle-frame
- تعريفات وملاحظات: property, tab, curved-tab, speech, rounded-tab, right-rule, folded-corner, outlined-tab, inset-tab, warning-note
- دفاتر: side-notebook, binder-notebook, practical-notebook, homework-sheet, homework-sheet-modern
- بنمط السلك الجانبي (كانت مزخرفة): lace, illuminated, geometric, math-cover, vintage, jewel, star-chain, lantern, botanical, emerald, right-scroll, bevel-frame
- شرائط وعناوين (بلا محتوى): ribbon-banner, arched-ribbon
- ملاحظات هامة: ribbon-notes
- دفاتر ومكتسبات إضافية: grid-notebook, prerequisites
- الدفعة 4: folded-ribbon, hanging-tab, winged-tab, badge-notebook

بعض الإطارات لها معاملات خاصة (`subtitle`, `points`, `number`, `source`, `width`...) — راجع توقيع كل دالة في `lib.typ`.

## التوثيق / Documentation

- `doc.typ` — دليل الاستخدام بالعربية (`typst compile doc.typ`)
- `doc-en.typ` — user guide in English (`typst compile doc-en.typ`)

## ملاحظات / Notes

- في النسخة اللاتينية (`dir: ltr`) تظهر خانة العنوان على اليسار في كل الإطارات ذات الخانة، وتبقى على اليمين في العربية (`dir: rtl`). / In Latin (LTR) documents the title tab of every tabbed frame sits on the left; in Arabic (RTL) it stays on the right.
- `sheet-frame`, `bevel-frame`, `warning-note` بعرض ثابت (`width: 170mm`) وبعضها بارتفاع ثابت وغير قابلة للتقسيم.
- `notebook-frame` و`ribbon-frame` الأصليان محفوظان؛ نسختا ملف boxnaam1 صارتا `binder-notebook-frame` و`ribbon-banner`.
- جُرِّبت الحزمة (العرضان والدليلان) على مترجم Typst؛ أبلغ عن أي خطأ ترجمة لتصحيحه.

## أمثلة / Demos

`examples/demo-ar.typ` (نسخة عربية) و`examples/demo-en.typ` (نسخة لاتينية): كل الإطارات في كل ملف

## تحديث / Update: homework-sheet-modern, practical-notebook, warning-note

في النسخة اللاتينية (`dir: ltr`) أصبح العنوان/الشريط على **اليسار** (الرسوم معكوسة، النص غير معكوس)، وتبقى النسخة العربية كما هي.
In Latin (LTR) documents the title tab / spine / pen and the rings are now on the **left**; Arabic output is unchanged.
`homework-sheet-modern` now has no fixed fields (name/class/date removed): it accepts `title` and an optional `header` that you write yourself.

## تحديث / Update: عنوان ومحتوى من اختيارك / your own titles and content

كل إطار (60) يقبل `title:` بالمحتوى الذي تكتبه أنت، والعنوان الافتراضي لا يظهر إلا إذا لم تكتب عنوانًا. `homework-sheet` صار يقبل `title:` أيضًا.
Every frame takes your own `title:` and content; the built-in default title appears only when you give none. `homework-sheet` now accepts `title:` too.

**عنوان بنسختين عربية ولاتينية / one title in two languages** — أي معامل نصي (`title`, `subtitle`, `third-title`, `points`, `source`, `badge-top`, `badge-bottom`, `header`) يقبل قاموسًا يُختار منه النص حسب لغة الإطار:

    #theorem-frame(title: (ar: [مبرهنة فيثاغورس], en: [Pythagorean theorem]))[ ... ]
    #theorem-frame(dir: ltr, title: (ar: [مبرهنة], en: [Theorem]))[ ... ]

`title: none` يعطي عنوانًا فارغًا. الأمثلة في `examples/` كتبت من جديد بعناوين ومحتوى من اختياري.

## تحديث / Update: ribbon-notes-frame

إطار جديد `ribbon-notes-frame` («ملاحظات هامة»): شريط علوي متدرج مع عنوان فرعي (`subtitle`، افتراضيًا «أضف إلى») وشارة ملوّنة (`tag-title`، افتراضيًا «معلوماتك»). في النسخة اللاتينية (`dir: ltr`) ينعكس الشريط كله والنص لا ينعكس. اسمه في السجل: `ribbon-notes`.
New frame `ribbon-notes-frame` ("Important notes"): gradient header ribbon with a caption (`subtitle`, default "Add to") and a colored tag (`tag-title`, default "your notes"). In Latin documents (`dir: ltr`) the whole ribbon is mirrored, the text is not. Registry name: `ribbon-notes`.

    #ribbon-notes-frame(title: [ملاحظات هامة])[ ... ]
    #ribbon-notes-frame(dir: ltr, title: [Important notes])[ ... ]

## تحديث / Update: grid-notebook-frame, prerequisites-frame

إطاران جديدان بأسماء مختلفة عن الموجود: `grid-notebook-frame` (دفتر أزرق بشبكة ملليمترية وشارة منحنية، يختلف عن `practical-notebook`) و`prerequisites-frame` (بطاقة المكتسبات القبلية: بنود حمراء التسميات بزاوية مطوية وحلقات). كلاهما ينعكس في `dir: ltr` (الرسم فقط). في السجل: `grid-notebook` و`prerequisites`.
Two new frames with new names: `grid-notebook-frame` (blue grid notebook with a curved badge; differs from `practical-notebook`) and `prerequisites-frame` (prerequisites card: red-labeled items, folded corner, rings). Both mirror in `dir: ltr` (drawing only). Registry names: `grid-notebook`, `prerequisites`.

    #grid-notebook-frame(title: [تمرين تطبيقي])[ ... ]
    #prerequisites-frame(items: (([المكتسبات], [...]), ([الكفاءات], [...])))

## تحديث / Update: الدفعة 4 (4 إطارات) وعرض الدفتر الأزرق / batch 4 and grid-notebook width

أربعة إطارات جديدة بأسماء مستقلة، كل منها بنسخة عربية ولاتينية (`dir: ltr`) وشرح مفصّل في `doc.typ` و`doc-en.typ`:
Four new frames with their own names, each with an Arabic and a Latin (`dir: ltr`) layout and a detailed section in `doc.typ` / `doc-en.typ`:

| الإطار / Frame | السجل / Registry | الوصف / Description |
|---|---|---|
| `folded-ribbon-frame` | `folded-ribbon` | ورقة بشريط عريض مطوي / sheet with a wide folded ribbon |
| `hanging-tab-frame` | `hanging-tab` | ورقة بلسان عنوان منحنٍ معلّق / curved hanging title tab |
| `winged-tab-frame` | `winged-tab` | عنوان وسطي بجناحين وحدّ منقّط / centered winged label |
| `badge-notebook-frame` | `badge-notebook` | بطاقة بطبقتين وشارة مائلة / two-layer card with a slanted badge |

`grid-notebook-frame` و`badge-notebook-frame`: العرض الافتراضي صار `auto` أي عرض المساحة المتاحة مثل بقية الإطارات (كان `195mm`، وفي الأمثلة `150mm`). مرّر `width:` لعرض ثابت.
`grid-notebook-frame` and `badge-notebook-frame`: default width is now `auto` (the full available width, like the other frames) instead of a fixed `195mm`; pass `width:` for a fixed size.

`practical-notebook`: العرض الافتراضي صار `auto` أيضًا (عرض المساحة المتاحة، والحلقات تبرز 4 مم في الهامش). / `practical-notebook` now defaults to `width: auto` too (full available width, rings stick out 4 mm into the margin).

`ribbon-notes-frame`: إطار العنوان صار ارتفاعه = ارتفاع العنوان + 6 مم (3 مم فوقه و3 مم تحته) والعنوان في وسطه، وكلمة الشارة الصفراء في وسطها تمامًا. / the title frame is now title height + 6 mm (3 mm above, 3 mm below) with the title centered, and the yellow tag text is centered.
