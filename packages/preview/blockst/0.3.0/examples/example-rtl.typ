// Right-to-left rendering: Arabic, Hebrew and Persian.
//
// Nothing special is asked for here — the language is enough. Each locale
// declares `dir = "rtl"` in its own TOML, and the renderer mirrors the block
// layout: the notch, the hat dome, the C-block mouth, the loop arrow and the
// order of the labels all move to the reading edge.
//
// The Arabic and Hebrew scripts need fonts that cover them; see README-rtl.md.

#import "@preview/blockst:0.3.0": scratch

#set page(width: auto, height: auto, margin: 4mm, fill: none)
#set text(font: ("Noto Sans Arabic", "Noto Sans Hebrew", "DejaVu Sans"))

#table(
  columns: 3,
  stroke: none,
  column-gutter: 7mm,
  align: top + center,
  inset: (bottom: 2mm),

  text(size: 9pt)[العربية], text(size: 9pt)[עברית], text(size: 9pt)[فارسی],

  scratch("
عند نقر @greenFlag
تحرك (10) خطوة
كرر (4) مرة
استدر @turnRight (90) درجة
نهاية
قل [مرحبا] لمدة (2) ثانية
", language: "ar"),

  scratch("
כאשר לוחצים על @greenFlag
זוז (10) צעדים
חזור  (4) פעמים
הסתובב @turnRight (90) מעלות
סוף
", language: "he"),

  scratch("
وقتی‌ @greenFlag کلیک شد
حرکت کن  (10) گام
تکرار کن (4)
حرکت کن  (70) گام
آخر
", language: "fa"),
)
