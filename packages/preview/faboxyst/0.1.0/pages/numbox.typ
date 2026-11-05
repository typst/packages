// ===========================================================================
//  numbox — dedicated preview page
//
//    typst compile pages/numbox.typ pages/numbox.pdf --root . --font-path fonts
// ===========================================================================

#import "/lib.typ": *

#set page(width: 17cm, height: auto, margin: 9mm)
#set text(font: "DejaVu Sans", size: 10.5pt)
#set par(leading: 0.62em)

#let titre(t) = block(above: 0.85em, below: 0.35em,
  text(size: 8pt, style: "italic", fill: rgb("#666"), t))

= numbox — numbered question

#titre[1. the textbook original: auto number + answer]

#numbox-reset()
#numbox[
  Find 3 examples where the product of two numbers remains
  unchanged when one of them is increased by 2 and the other is
  decreased by 4.
][
  Let numbers be $a$ and $b$. \
  Then $(a + 2)(b - 4) = a b$ \
  So, $b = 2a + 4$ \
  Hence 3 examples are $(a = 1, b = 6)$, $(a = 2, b = 8)$, $(a = 3, b = 10)$
]

#titre[2. `number: auto` — the counter increments by itself]

#numbox[The next one is automatic.]
#numbox[And the one after that.]

#titre[3. `number: 7` then auto — jump, then continue]

#numbox(number: 7)[Forced to 7. The next auto will be 8.]
#numbox[This should be 8.]

#titre[4. `number: none` and a custom plaque]

#numbox(number: none)[No plaque at all.]
#numbox(number: [A], colour: rgb("#7B1FA2"))[A custom plaque.]

#titre[5. `colour` and `answer-label`]

#numbox(colour: rgb("#C62828"), answer-label: [Sol.])[Another colour.][A short answer.]

#titre[6. the frame stroke — `frame`, `weight`, `dash`]

#numbox(dash: "dashed")[dashed]
#numbox(dash: "dotted", frame: rgb("#1E54A8"))[dotted]
#numbox(dash: "dash-dotted", weight: 1.8pt)[dash-dotted]
#numbox(weight: 3pt, frame: rgb("#0D47A1"))[thick solid]
#numbox(stroke: 1.6pt + rgb("#E65100"))[full `stroke:` override]

#titre[7. `frame-char` — a repeating character instead of a line]

#numbox(frame-char: "*")[stars]
#numbox(frame-char: "~", frame: rgb("#00695C"))[tildes]
#numbox(frame-char: "·", frame-char-size: 0.36cm)[dots as glyphs]

#titre[8. RTL — plaque on the top-right, period on the left of the digit]

#[
  #set text(lang: "ar", dir: rtl, font: ("Tajawal", "DejaVu Sans"))
  #numbox-reset()
  #numbox[
    جد ثلاثة أمثلة يبقى فيها جداء عددين ثابتاً إذا زيد أحدهما بـ 2 ونقص الآخر بـ 4.
  ][
    ليكن العددان $a$ و $b$. \
    إذن $(a + 2)(b - 4) = a b$
  ]
  #numbox[السؤال التالي يُرقّم تلقائياً.]
  #numbox(dash: "dashed")[إطار متقطع]
]

#titre[9. `direction: ltr` forced inside an RTL block]

#[
  #set text(lang: "ar", dir: rtl, font: ("Tajawal", "DejaVu Sans"))
  #numbox(direction: ltr)[Forced LTR plaque, even in an RTL block.]
]

#titre[10. a one-line box — the plaque shrinks to the frame]

#numbox-reset()
#numbox[A single short line.]
#numbox[Another one-liner, still flush.]
#numbox[
  A taller box keeps the requested `badge-size` (0.78 cm) because the
  frame is already deeper than the plaque.
]
