# auto-bidi

Write Hebrew, Arabic, and Farsi in Typst — without fighting the typesetter.

---

## The problem

When you write a Hebrew or Arabic paragraph in Typst, nothing happens automatically. The text is placed left-to-right, punctuation ends up on the wrong side, and you have to manually wrap every paragraph in a `set text(lang: "he")` rule. In a mixed-language document this becomes exhausting.

Every app you're used to — Word, Google Docs, Apple Notes, Obsidian, WhatsApp — detects the paragraph direction for you. Typst doesn't. **auto-bidi** fixes that.

### Why language, not just direction?

`auto-bidi` detects the **language**, not just RTL vs LTR. This matters because Typst uses `lang` for more than direction:

- **Hyphenation** — Hebrew, Arabic, and Farsi each have different hyphenation rules
- **Shaping** — Arabic script connects differently depending on language
- **Fonts** — language-specific font features and fallbacks

---

## Quickstart

```typst
#import "@preview/auto-bidi:0.1.0": *
#show: auto-dir
```

Now write freely:

```typst
אני כותב עברית וזה עובד.

I switch to English and it works too.

يمكنني الكتابة بالعربية أيضاً.

فارسی هم کار می‌کند.
```

Each paragraph is detected independently and gets the correct language tag.
Typst then applies direction, hyphenation, and language-specific shaping from `lang`. Just write.

See full examples: [auto-detection.typ](examples/auto-detection.typ) | [detection-modes.typ](examples/detection-modes.typ)

---

## How detection works

By default, `auto-bidi` uses **first-character detection** — just like Apple Notes, WhatsApp, and Obsidian. The first recognised script character in a paragraph sets its direction.

```typst
// starts with Hebrew → RTL
הרבה עברית כתובה פה with some English

// starts with English → LTR
A הרבה עברית כתובה פה
```

### "auto" mode

Prefer auto-based detection, where the **dominant script** decides direction:

```typst
#show: auto-dir.with(detect-by: "auto")
```

Now a paragraph with more Hebrew characters than Latin ones → Hebrew → RTL, regardless of which comes first.

Switch algorithms mid-document at any point with another `#show: auto-dir.with(...)`.

For Arabic-script documents that are primarily Persian, you can set:

```typst
#show: auto-dir.with(arabic-script-lang: "fa")
```

---

## What it ignores

Math equations, raw text, and code blocks are never touched — they stay LTR regardless of surrounding language:

```typst
// The equation is always LTR, the surrounding paragraph is RTL
הפונקציה $f(x) = x^2 + 1$ היא פרבולה.
```

---

## Lists stay unified

The direction of a list or enum is determined by the list as a whole, not item by item:

```typst
// Hebrew list — stays RTL even with some English
- פריט ראשון
- פריט שני עם English
- פריט שלישי

// Arabic list
- العنصر الأول
- العنصر الثاني
- العنصر الثالث

// Farsi list
- مورد اول
- مورد دوم
- مورد سوم
```

---

## Forcing language

Sometimes auto-detection isn't enough. `auto-bidi` lets you force language explicitly.

### Block scope

```typst
// Force Hebrew language on a specific block, regardless of content
#rl[
  This sentence is tagged as Hebrew even though it's written in English.
]

// Force English language on a block
#lr[
  גם עברית כאן תהיה מתויגת כאנגלית.
]

// Any language, including Farsi
#force-lang("fa")[این متن فارسی است.]
```

### Section scope

Place these anywhere in the document — no brackets needed:

```typst
#sethebrew
כל מה שאחרי השורה הזאת הוא עברית, כולל כותרות ורשימות.

= גם כותרות הן RTL

#setauto
Back to automatic detection from here.
```

| Command | Effect |
|---------|--------|
| `#sethebrew` | Force Hebrew from this point |
| `#setarabic` | Force Arabic from this point |
| `#setfarsi` | Force Farsi (Persian) from this point |
| `#setenglish` | Force English from this point |
| `#setauto` | Return to auto-detection |

---

## Direction hint characters

Sometimes a heading or paragraph is genuinely ambiguous — equal amounts of Hebrew and English, or the "wrong" script comes first. Drop an invisible hint character to nudge detection:

```typst
// Heading starts with English letter but you want RTL
= #r A הרבה עברית

// Heading is mostly Hebrew but you want LTR
= #l כותרת שצריכה להיות LTR
```

| Character | Hints toward |
|-----------|-------------|
| `#r` | RTL (Hebrew) |
| `#l` | LTR (English / Latin) |
| `#hechar` | Hebrew |
| `#archar` | Arabic |
| `#enchar` | English / Latin |

---

## Farsi / Persian

Farsi uses Arabic script, so it is RTL either way.  
For document direction, treating it like Arabic is enough.  
For language-specific shaping and hyphenation, prefer the `"fa"` language code:

```typst
#force-lang("fa")[
  این یک پاراگراف فارسی است که با فونت و قواعد زبان فارسی نمایش داده می‌شود.
]
```

For section-level control:

```typst
#setfarsi
این بخش فارسی است.
#setauto
```

If your whole document is Persian, set:

```typst
#show: auto-dir.with(arabic-script-lang: "fa")
```

---

## Font configuration

`auto-bidi` uses the `covers` font parameter so each font is applied only to its own script — Hebrew fonts never bleed into Arabic text and vice versa.

```typst
#show: auto-dir.with(
  hebrew-font: ("David CLM", "Libertinus Math"),
  english-font: ("New Computer Modern", "Libertinus Serif"),
  arab-font:   "Libertinus Serif",
)
```

Pass a single string or an array of fallback fonts for any script.

---

## Full API

| Export | Description |
|--------|-------------|
| `auto-dir` | Main show-rule wrapper — apply once to the whole document |
| `detect-lang(body)` | Detect the language of content, returns `"he"`, `"ar"`, `"fa"`, or `"en"` |
| `detect-dir(body)` | Detect the direction of content, returns `"rtl"` or `"ltr"` |
| `force-lang(lang, body)` | Force a BCP 47 language code on a block |
| `rl(body, lang: "he")` | Convenience wrapper for `force-lang`, defaulting to Hebrew |
| `lr(body, lang: "en")` | Convenience wrapper for `force-lang`, defaulting to English |
| `sethebrew` | Force Hebrew from this point onward |
| `setarabic` | Force Arabic from this point onward |
| `setfarsi` | Force Farsi (Persian) from this point onward |
| `setenglish` | Force English from this point onward |
| `setauto` | Return to auto-detection |
| `r` | Invisible RTL hint character (short for `hechar`) |
| `l` | Invisible LTR hint character (short for `enchar`) |
| `hechar` | Invisible Hebrew hint character |
| `archar` | Invisible Arabic hint character |
| `enchar` | Invisible Latin hint character |

---

## License

MIT
