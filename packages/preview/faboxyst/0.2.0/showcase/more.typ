#import "_helpers.typ": *
#set page(paper: "a4", margin: (x: 1.15cm, y: 1.2cm),
  header: text(size: 8pt, fill: luma(120))[faboxyst showcase · more],
  footer: context align(center, text(size: 8pt, fill: luma(120), counter(page).display())))
#set text(font: "DejaVu Sans", size: 9.5pt)
#set par(leading: 0.55em)

#cmd-title[mark · hl · mark-emph]
#sig[
```typ
#mark(body, kind: "highlight", colour: auto, weight: auto, seed: 3,
  rough: true, expand: 0.16em, opacity: auto)
#hl(body, colour: auto)     // kind: "highlight"
#mark-emph(colour: auto, kind: "highlight")
// kinds: highlight underline double wave circle box strike scribble bracket jagged fan
```
]
#param-row([kind: highlight],
  [A #mark[key] word.],
  rtl-box[كلمة #mark[مفتاح].],
  code: `#mark[key]`)
#param-row([kind: underline / wave],
  [An #mark(kind: "underline")[underlined] and #mark(kind: "wave", colour: rgb("#1565C0"))[wavy] run.],
  rtl-box[#mark(kind: "underline")[تسطير] و #mark(kind: "wave", colour: rgb("#1565C0"))[موج].],
  code: `#mark(kind: "wave", colour: blue)[wavy]`)
#param-row([kind: circle / box],
  [See #mark(kind: "circle")[this] and #mark(kind: "box")[that].],
  rtl-box[#mark(kind: "circle")[هذا] و #mark(kind: "box")[ذاك].],
  code: `#mark(kind: "circle")[this]`)
#param-row([kind: strike / scribble],
  [A #mark(kind: "strike")[mistake] then #mark(kind: "scribble", colour: rgb("#C62828"))[noise].],
  rtl-box[#mark(kind: "strike")[خطأ] ثم #mark(kind: "scribble", colour: rgb("#C62828"))[شطب].],
  code: `#mark(kind: "strike")[mistake]`)
#param-row([kind: bracket / jagged / fan],
  [#mark(kind: "bracket")[bracket] · #mark(kind: "jagged", colour: rgb("#EF6C00"))[jagged] · #mark(kind: "fan")[fan]],
  rtl-box[#mark(kind: "bracket")[قوس] · #mark(kind: "jagged")[خشن]],
  code: `#mark(kind: "bracket")[bracket]`)
#param-row([hl / mark-emph],
  [Use #hl[yellow] or #mark-emph()[emph].],
  rtl-box[#hl[أصفر] و #mark-emph()[تأكيد].],
  code: `#hl[yellow]`)

#cmd-title[spread-box · sticky · highlight (felt)]
#sig[
```typ
#spread-box(body, spread: auto, colour: rgb("#2A6FB0"), title: none, …)
#sticky(body, width: 4cm, angle: -3deg, colour: auto)
#highlight(body, ink: "yellow", alpha: 45%)   // alias felt
```
]
#param-row([spread-box],
  spread-box(title: [Spread], colour: rgb("#2A6FB0"))[#en-sample],
  spread-box(title: [انتشار], colour: rgb("#C2185B"), direction: rtl)[#ar-sample],
  code: `#spread-box(title: [Spread])[…]`)
#param-row([spread inwards vs outwards],
  spread-box(title: [In], inwards: 0.35cm)[#en-sample],
  spread-box(title: [خارج], outwards: 0.45cm, direction: rtl)[#ar-sample],
  code: `#spread-box(inwards: 0.35cm)`)
#param-row([sticky angle],
  sticky(angle: -8deg)[stick],
  sticky(angle: 12deg, colour: rgb("#81D4FA"), direction: rtl)[لاصق],
  code: `#sticky(angle: -8deg)[stick]`)
#param-row([felt highlight inks],
  [A #felt(ink: "yellow")[yellow] and #felt(ink: "green")[green] swipe.],
  rtl-box[#felt(ink: "pink")[وردي] و #felt(ink: "blue")[أزرق].],
  code: `#felt(ink: "yellow")[yellow]`)

#cmd-title[sb-tape · sb-pin · sb-clip · sb-heart]
#sig[
```typ
#sb-tape(w: 2.6, h: 0.78, angle: -8deg, kind: "dots")  // dots|gingham|stripe|plain
#sb-pin(size: 0.42, colour: auto)
#sb-clip(w: 0.62).whole
#sb-heart(size: 0.32, colour: auto)
```
]
#param-row([sb-tape kind dots vs gingham],
  box(height: 1.4cm, sb-tape(kind: "dots", angle: -6deg)),
  box(height: 1.4cm, sb-tape(kind: "gingham", angle: 8deg, colour: rgb("#E8A0A0"))),
  code: `#sb-tape(kind: "dots")`)
#param-row([sb-tape stripe vs plain],
  box(height: 1.4cm, sb-tape(kind: "stripe", angle: -4deg)),
  box(height: 1.4cm, sb-tape(kind: "plain", angle: 10deg, colour: rgb("#90CAF9"))),
  code: `#sb-tape(kind: "stripe")`)
#param-row([sb-pin size / colour],
  align(center, sb-pin(size: 0.55)),
  align(center, sb-pin(size: 0.85, colour: rgb("#EF5350"))),
  code: `#sb-pin(size: 0.85, colour: red)`)
#param-row([sb-clip],
  align(center, sb-clip(w: 0.50).whole),
  align(center, sb-clip(w: 0.72, angle: 18deg, colour: rgb("#546E7A")).whole),
  code: `#sb-clip(w: 0.50).whole`)
#param-row([sb-heart],
  align(center, sb-heart(size: 0.55)),
  align(center, sb-heart(size: 0.90, colour: rgb("#C2185B"))),
  code: `#sb-heart(size: 0.55)`)

#cmd-title[sb-underline · sb-divider · lesson-table · notepad]
#sig[
```typ
#sb-underline(body, colour: auto, span: 0.56)
#sb-divider(colour: auto)
#lesson-table(..cells, columns: auto, header: true)
#notepad(body, crumpled: false, rings: auto, side: auto)
```
]
#param-row([sb-underline span],
  sb-underline(span: 0.4)[Heading],
  sb-underline(span: 0.9, colour: rgb("#1565C0"))[عنوان],
  code: `#sb-underline(span: 0.4)[Heading]`)
#snippet(`#sb-divider()`)
#sb-divider()
#v(6pt)
#snippet(`#lesson-table([A], [B], [C], [1], [2], [3])`)
#lesson-table([A], [B], [C], [can], [may], [must], [1], [2], [3])
#v(8pt)
#param-row([notepad rings / crumpled],
  notepad(width: 7.0, rings: 4)[#en-sample],
  notepad(width: 7.0, crumpled: true, rings: 3, direction: rtl)[#ar-sample],
  code: `#notepad(width: 7.0, rings: 4)`)

#cmd-title[torn-note · stamp-card · deckle-tag · lesson-card]
#sig[
```typ
#torn-note(body, amp: 0.13, tape: auto, tilt: 0deg)
#stamp-card(body, pin: true, scallop: 0.20)
#deckle-tag(body, amp: 0.020, tape: auto)
#lesson-card(body, title: none, clip: true)
```
]
#param-row([torn-note amp / tape],
  torn-note(width: 7.0, amp: 0.08)[#en-sample],
  torn-note(width: 7.0, amp: 0.22, direction: rtl)[#ar-sample],
  code: `#torn-note(width: 7.0, amp: 0.08)`)
#param-row([stamp-card pin],
  stamp-card(width: 6.8, pin: true)[#en-sample],
  stamp-card(width: 6.8, pin: false, direction: rtl)[#ar-sample],
  code: `#stamp-card(pin: true)`)
#param-row([deckle-tag],
  deckle-tag(width: 5.0)[TAG],
  deckle-tag(width: 5.0, direction: rtl)[وسم],
  code: `#deckle-tag(width: 5.0)[TAG]`)
#param-row([lesson-card clip],
  lesson-card(width: 7.0, title: [Lesson], clip: true)[#en-sample],
  lesson-card(width: 7.0, title: [درس], clip: true, direction: rtl)[#ar-sample],
  code: `#lesson-card(title: [Lesson], clip: true)`)

#cmd-title[plankbox · pancarte]
#sig[
```typ
#plankbox(body, title: none, wood: auto, edge: auto, streak: auto,
  text-fill: auto, title-size: 1.1em, tilt: 2deg, gap: 0.06cm,
  weight: 1.6pt, jitter: 0.8pt, mottle: 6%, inset: (x: 0.55cm, y: 0.30cm),
  width: 96%, seed: auto, direction: auto)
#pancarte(..a)   // French alias of plankbox
```
]
#param-row([title plank + body plank],
  ltr-box(plankbox(title: [Ma lettre], width: 92%)[de fin d'année]),
  rtl-box(plankbox(title: [رسالتنا], width: 92%)[نهاية السنة]),
  code: `#plankbox(title: [Ma lettre])[de fin d'année]`)
#param-row([tilt 2deg vs 8deg],
  ltr-box(plankbox(title: [Note], tilt: 2deg, width: 92%)[#en-sample]),
  rtl-box(plankbox(title: ar-title, tilt: 8deg, width: 92%)[#ar-sample]),
  code: `#plankbox(tilt: 8deg)[…]`)
#param-row([single plank (no title)],
  ltr-box(plankbox([Salle 12 — menuiserie], width: 70%)),
  rtl-box(plankbox([قاعة ١], width: 70%)),
  code: `#plankbox[Salle 12]`)
#param-row([recoloured walnut],
  ltr-box(plankbox(title: [Atelier], wood: rgb("#C89058"),
    streak: rgb("#8A5A2B"), width: 92%)[#en-sample]),
  rtl-box(plankbox(title: [ورشة], wood: rgb("#C89058"),
    streak: rgb("#8A5A2B"), width: 92%)[#ar-sample]),
  code: `#plankbox(wood: rgb("#C89058"))[…]`)
#param-row([jitter 0.2pt vs 1.6pt],
  ltr-box(plankbox(title: [Calm], jitter: 0.2pt, width: 92%)[#en-sample]),
  rtl-box(plankbox(title: [خشن], jitter: 1.6pt, width: 92%)[#ar-sample]),
  code: `#plankbox(jitter: 1.6pt)[…]`)

#cmd-title[tornpage · page-dechiree]
#sig[
```typ
#tornpage(body, title: none, fill: auto, ink: auto, rule: auto,
  title-size: 1.4em, amp: 0.2, seg: 0.7cm, rag: 2pt, depth: 4,
  inset: (x: 5pt, y: 5pt), bottom: 1em, width: 100%, seed: auto,
  shadow: true, mottle: 4%, direction: auto)
#page-dechiree(..a)   // French alias
```
]
#param-row([title + fractal-torn bottom],
  ltr-box(tornpage(title: [Note Title])[#en-sample]),
  rtl-box(tornpage(title: [عنوان], width: 90%)[#ar-sample]),
  code: `#tornpage(title: [Note Title])[…]`)
#param-row([amp 0.1 vs 0.35],
  ltr-box(tornpage(amp: 0.1, width: 90%)[#en-sample]),
  rtl-box(tornpage(amp: 0.35, width: 90%)[#ar-sample]),
  code: `#tornpage(amp: 0.35)[…]`)
#param-row([depth 2 vs 5],
  ltr-box(tornpage(depth: 2, width: 90%)[#en-sample]),
  rtl-box(tornpage(depth: 5, width: 90%)[#ar-sample]),
  code: `#tornpage(depth: 5)[…]`)
#param-row([shadow false / mottle 0],
  ltr-box(tornpage(shadow: false, width: 90%)[#en-sample]),
  rtl-box(tornpage(mottle: 0%, width: 90%)[#ar-sample]),
  code: `#tornpage(shadow: false)[…]`)

#cmd-title[coilbox · cahier]
#sig[
```typ
#coilbox(body, title: none, frame: auto, coil-a: auto, coil-b: auto,
  title-size: 1.2em, coil-gap: 1.05cm, radius: 0.55cm,
  inset: (x: 0.6cm, y: 0.6cm), width: 100%, height: auto, direction: auto)
#cahier(..a)   // French alias
```
]
#param-row([notebook frame + 3D coils],
  ltr-box(coilbox(title: [Monday], height: 4.6cm)[#en-sample]),
  rtl-box(coilbox(title: [الاثنين], height: 4.6cm)[#ar-sample]),
  code: `#coilbox(title: [Monday])[…]`)
#param-row([recoloured frame / coils],
  ltr-box(coilbox(coil-a: rgb("#26A69A"), coil-b: rgb("#5C6BC0"),
    height: 4.2cm)[#en-sample]),
  rtl-box(coilbox(frame: rgb("#7986CB"), height: 4.2cm)[#ar-sample]),
  code: `#coilbox(coil-a: rgb("#26A69A"))[…]`)
