# na-tabpos

English · [العربية](#العربية)

## English

`na-tabpos` is a Typst package (Typst ≥ 0.13) for math documents, Arabic ones in particular. It is built on [vartable](https://typst.app/universe/package/vartable) by Le_Foucheur and adds **one thing**: a *relative-position* row (curve vs line, or curve vs curve) with the two arcs at each intersection, like `\tkzTabPos`.

Everything else is vartable: sign rows, variation rows, hatched undefined areas, `"||"` bars, `"0"` bars, added values, styles… See the vartable documentation for the full syntax; it is unchanged.

The code in `lib.typ` is derived from vartable 0.2.5 (MIT). The `LICENSE` file carries both copyrights.

**Documentation:** [English (PDF)](https://github.com/naam11/na-tabpos/blob/main/documentationEN.pdf) · [العربية (PDF)](https://github.com/naam11/na-tabpos/blob/main/documentationAR.pdf)

### Main features

- The **difference row** `f(x) - g(x)` (a sign row placed right before a `"p"` row) is **1 cm high by default**. Change it with `diff-height`, or write `diff-height: none` for automatic height.
- The words of the `"p"` row **follow the language of the document** (`#set text(lang: ...)`): ar, fr, en, es, de, it, pt, nl, tr, ru. Any other language uses English. You can give your own words.
- The whole package is **one file**: `lib.typ`.

### Row types in `label`

| Type | Meaning |
|------|---------|
| `"s"` | sign row. The **difference row** `f(x) - g(x)` is just a sign row. |
| `"v"` | variation row |
| `"p"` | **relative-position row** (new) |

### Usage

```typst
#import "@preview/na-tabpos:1.0.0": *

#tabpos(
  variable: $x$,
  label: (
    ([$f(x) - y$], "s"),        // difference row: 1 cm
    ([الوضع النسبي], "p"),
  ),
  domain: ($-oo$, $-1$, $1$, $+oo$),
  contents: (
    ($+$, ("0", $-$), ("0", $+$)),
    ("+", ($A(-1 ; 0)$, "-"), ($B(1 ; 0)$, "+")),
  ),
)
```

![line and curve](https://raw.githubusercontent.com/naam11/na-tabpos/main/examples/line-and-curve.png)

### The `"p"` row

It is written exactly like a sign row, with these differences:

| Entry | Result |
|-------|--------|
| `"+"` | *above*: the text `(C_f) / above / (C_g)` |
| `"-"` | *below*: the text `(C_f) / below / (C_g)` |
| `("0", "+")` | the two arcs at the left end of the interval, then *above* |
| `(content, "-")` | the two arcs with the content (e.g. the point `$A(-1 ; 0)$`) under the text, then *below* |
| `"|h|"`, `"h"`, `"h\|"`, `"\|h"`, `("\|\|", "+")`, ... | same as vartable: hatched areas, bars |

Use the strings `"+"` and `"-"` (not `$+$`) in a `"p"` row.

### Options of `tabpos`

| Option | Default | Meaning |
|--------|---------|---------|
| `diff-height` | `1cm` | height of the difference row (a `"s"` row right before a `"p"` row); `none` = automatic |
| `pos-height` | `3cm` | default height of a `"p"` row; or give it per row: `([title], 3cm, "p")` |
| `first` | `auto` = `$(C_f)$` | name of the first curve |
| `second` | `auto` = `$(C_g)$` | name of the second curve or of the line, e.g. `$(Delta)$` |
| `above`, `below` | `auto` | words for the two positions; `auto` = language of the document |
| `cross` | `auto` | word between the two curves at an intersection |
| `at-point` | `auto` | word before the point note |
| `arc-width` | `0.94` | half-distance between the two arcs (CeTZ units, 1 = 1 cm) |

All the options of vartable (`hatching-style`, `values`, `table-style`, ...) still work.

### Naming the curves and the line

`first` renames `$(C_f)$` and `second` renames `$(C_g)$` (or names the line, e.g. `$(Delta)$`). Change the names **once for the whole document** with `tabpos-names`; every table after it uses them:

```typst
#tabpos-names(first: $(C_f)$, second: $(Delta)$)   // curve vs line
```

A single table can override them with `first` and `second`:

```typst
#tabpos(first: $(C_1)$, second: $(C_2)$, ...)
```

Call `tabpos-names` again at any point to change the names for the tables that follow. Use `auto` to keep one of them unchanged.

### Files

```
lib.typ  typst.toml  LICENSE  README.md
documentationEN.typ/.pdf  documentationAR.typ/.pdf
examples/          ready-to-compile examples (.typ, .pdf, .png)
fichier_de_test/   test files: heights, "p" options, hatching
```

---

<div dir="rtl">

## العربية

[English](#english) · العربية

`na-tabpos` حزمة Typst (الإصدار ≥ 0.13) للوثائق الرياضية، وخاصة العربية. مبنية على [vartable](https://typst.app/universe/package/vartable) للمؤلف Le_Foucheur وتضيف **شيئًا واحدًا**: سطر *الوضع النسبي* (منحنى مقابل مستقيم، أو منحنى مقابل منحنى) مع رسم القوسين عند كل نقطة تقاطع، مثل `\tkzTabPos`.

كل ما عدا ذلك هو vartable: أسطر الإشارة، أسطر التغيّرات، المناطق المهشّرة، الأشرطة `"||"` و`"0"`، القيم المضافة، الأنماط… راجع توثيق vartable للصياغة الكاملة؛ فهي لم تتغيّر.

شيفرة `lib.typ` مشتقة من vartable 0.2.5 (MIT)، ويحمل ملف `LICENSE` حقوق الطرفين.

**التوثيق:** [العربية (PDF)](https://github.com/naam11/na-tabpos/blob/main/documentationAR.pdf) · [English (PDF)](https://github.com/naam11/na-tabpos/blob/main/documentationEN.pdf)

### أهم الميزات

- **سطر الفرق** `f(x) - g(x)` (سطر إشارة يأتي مباشرة قبل سطر `"p"`) ارتفاعه **1 سم افتراضيًا**. غيّره بالخيار `diff-height`، أو اكتب `diff-height: none` للارتفاع التلقائي.
- كلمات سطر `"p"` **تتبع لغة المستند** (`#set text(lang: ...)`): ar, fr, en, es, de, it, pt, nl, tr, ru. وأي لغة أخرى تعطي الإنجليزية. ويمكنك كتابة كلماتك.
- الحزمة كلها **في ملف واحد**: `lib.typ`.

### أنواع الأسطر في `label`

| النوع | المعنى |
|------|---------|
| `"s"` | سطر إشارة. و**سطر الفرق** `f(x) - g(x)` هو سطر إشارة عادي |
| `"v"` | سطر تغيّرات |
| `"p"` | **سطر الوضع النسبي** (جديد) |

### الاستعمال

الشيفرة نفسها المذكورة في قسم Usage أعلاه:

```typst
#import "@preview/na-tabpos:1.0.0": *
```

![منحنى ومستقيم](https://raw.githubusercontent.com/naam11/na-tabpos/main/examples/line-and-curve.png)

### سطر `"p"`

يُكتب تمامًا مثل سطر الإشارة، مع هذه الفروق:

| المُدخَل | النتيجة |
|-------|--------|
| `"+"` | *فوق*: النص `(C_f) / فوق / (C_g)` |
| `"-"` | *تحت*: النص `(C_f) / تحت / (C_g)` |
| `("0", "+")` | القوسان عند الطرف الأيسر للمجال، ثم *فوق* |
| `(content, "-")` | القوسان مع المحتوى (مثل النقطة `$A(-1 ; 0)$`) تحت النص، ثم *تحت* |
| `"|h|"`, `"h"`, `"h\|"`, `"\|h"`, `("\|\|", "+")`, ... | مثل vartable: مناطق مهشّرة وأشرطة |

استعمل النصّين `"+"` و`"-"` (وليس `$+$`) في سطر `"p"`.

### خيارات `tabpos`

| الخيار | الافتراضي | المعنى |
|--------|---------|---------|
| `diff-height` | `1cm` | ارتفاع سطر الفرق (سطر `"s"` قبل سطر `"p"` مباشرة)؛ `none` = تلقائي |
| `pos-height` | `3cm` | الارتفاع الافتراضي لسطر `"p"`، أو لكل سطر: `([عنوان], 3cm, "p")` |
| `first` | `auto` = `$(C_f)$` | اسم المنحنى الأول |
| `second` | `auto` = `$(C_g)$` | اسم المنحنى الثاني أو المستقيم، مثل `$(Delta)$` |
| `above`, `below` | `auto` | كلمتا الوضعين؛ `auto` = بلغة المستند |
| `cross` | `auto` | الكلمة بين المنحنيين عند التقاطع |
| `at-point` | `auto` | الكلمة قبل اسم النقطة |
| `arc-width` | `0.94` | نصف المسافة بين القوسين (وحدات CeTZ، الوحدة = 1 سم) |

وتبقى كل خيارات vartable تعمل (`hatching-style`, `values`, `table-style`, ...).

### تسمية المنحنيين والمستقيم

الخيار `first` يغيّر اسم `$(C_f)$`، والخيار `second` يغيّر اسم `$(C_g)$` (أو يسمّي المستقيم، مثل `$(Delta)$`). غيّر الأسماء **مرة واحدة لكل المستند** بالدالة `tabpos-names`، وكل جدول بعدها يستعملها:

```typst
#tabpos-names(first: $(C_f)$, second: $(Delta)$)   // منحنى ومستقيم
```

ولجدول واحد فقط استعمل الخيارين `first` و`second`:

```typst
#tabpos(first: $(C_1)$, second: $(C_2)$, ...)
```

يمكنك استدعاء `tabpos-names` في أي موضع لتغيير الأسماء للجداول التي بعده. واكتب `auto` للإبقاء على أحد الاسمين دون تغيير.

</div>
