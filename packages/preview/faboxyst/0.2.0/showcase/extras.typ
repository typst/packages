#import "_helpers.typ": *
#set page(paper: "a4", margin: (x: 1.15cm, y: 1.2cm),
  header: text(size: 8pt, fill: luma(120))[faboxyst showcase · extras],
  footer: context align(center, text(size: 8pt, fill: luma(120), counter(page).display())))
#set text(font: "DejaVu Sans", size: 9.5pt)
#set par(leading: 0.55em)

#cmd-title[speech-bubble · joined-bubbles · five-w]
#sig[
```typ
#speech-bubble(body, fill: rgb("#FF8A1F"), ink: black, stroke: 2.4pt,
  width: 100%, height: auto, tail: "sw",
  tail-width: 0.85cm, tail-length: 0.55cm, tail-at: 0.22,
  gloss: true, size: 1.35em, direction: auto)
#joined-bubbles(a, b, fill-a, fill-b)
#five-w(colours, labels)
```
]

#param-row([one contour  ·  Qui ? / لماذا ؟],
  speech-bubble([Qui ?], fill: rgb("#FF8A1F")),
  speech-bubble([لماذا ؟], fill: rgb("#B56BFF"), tail: "se"),
  code: `#speech-bubble([Qui ?], fill: rgb("#FF8A1F"))`)
#param-row([tail-width 0.4cm vs 1.3cm],
  speech-bubble([thin], fill: rgb("#66BB6A"), tail-width: 0.4cm),
  speech-bubble([عريض], fill: rgb("#66BB6A"), tail-width: 1.3cm, tail: "se"),
  code: `#speech-bubble([thin], tail-width: 0.4cm)`)
#param-row([tail-length 0.28cm vs 1.0cm],
  speech-bubble([short], fill: rgb("#42A5F5"), tail-length: 0.28cm),
  speech-bubble([طويل], fill: rgb("#42A5F5"), tail-length: 1.0cm, tail: "se"),
  code: `#speech-bubble([short], tail-length: 0.28cm)`)
#param-row([tail sw vs se],
  speech-bubble([SW], fill: rgb("#FFA726"), tail: "sw"),
  speech-bubble([SE], fill: rgb("#FFA726"), tail: "se"),
  code: `#speech-bubble([SW], tail: "sw")`)
#param-row([gloss on vs off],
  speech-bubble([Gloss], fill: rgb("#EC407A"), gloss: true),
  speech-bubble([بدون], fill: rgb("#EC407A"), gloss: false, tail: "se"),
  code: `#speech-bubble([Gloss], gloss: true)`)
#v(8pt)
#snippet(`#joined-bubbles(a: [Qui ?], b: [Pourquoi ?])`)
#joined-bubbles(a: [Qui ?], b: [Pourquoi ?])
#v(8pt)
#snippet(`#five-w()`)
#five-w()
#v(8pt)
#snippet(`#five-w(labels: ([من؟], [ماذا؟], [أين؟], [متى؟], [لماذا؟]))`)
#rtl-box[#five-w(labels: ([من؟], [ماذا؟], [أين؟], [متى؟], [لماذا؟]))]

#cmd-title[ruled-sheet · punch holes]
#sig[
```typ
#ruled-sheet(body, width: 8.4, height: auto, holes: auto, hole-side: auto,
  rule: "lines", ruling: 0.62, …)
// holes: false | 0 | true | auto | int
// hole-side: auto → leading edge (right in RTL)
```
]
#param-row([holes: auto  (leading edge)],
  ruled-sheet(width: 7.2, holes: auto)[#en-sample],
  ruled-sheet(width: 7.2, holes: auto, direction: rtl)[#ar-sample],
  code: `#ruled-sheet(width: 7.2, holes: auto)`)
#param-row([holes: 3 vs 8],
  ruled-sheet(width: 7.2, holes: 3)[#en-sample],
  ruled-sheet(width: 7.2, holes: 8, direction: rtl)[#ar-sample],
  code: `#ruled-sheet(holes: 3)  vs  holes: 8`)
#param-row([holes: 0  (no punches)],
  ruled-sheet(width: 7.2, holes: 0)[#en-sample],
  ruled-sheet(width: 7.2, holes: 0, direction: rtl)[#ar-sample],
  code: `#ruled-sheet(holes: 0)`)
#param-row([hole-side left vs right],
  ruled-sheet(width: 7.2, holes: 5, hole-side: left)[#en-sample],
  ruled-sheet(width: 7.2, holes: 5, hole-side: right, direction: rtl)[#ar-sample],
  code: `#ruled-sheet(holes: 5, hole-side: left)`)

#cmd-title[grid-note · index-card  clip (RTL)]
#sig[
```typ
#grid-note(body, clip: false, clip-at: 0.80, …)
#index-card(body, clip: false, clip-at: 0.80, …)
```
]
#param-row([grid-note clip true  (mirrored in RTL)],
  grid-note(width: 7.0, clip: true)[#en-sample],
  grid-note(width: 7.0, clip: true, direction: rtl)[#ar-sample],
  code: `#grid-note(width: 7.0, clip: true)`)
#param-row([grid-note clip-at 0.2 vs 0.85],
  grid-note(width: 7.0, clip: true, clip-at: 0.2)[#en-sample],
  grid-note(width: 7.0, clip: true, clip-at: 0.85, direction: rtl)[#ar-sample],
  code: `#grid-note(clip: true, clip-at: 0.2)`)
#param-row([index-card clip true],
  index-card(width: 7.2, heading: [Card], clip: true)[#en-sample],
  index-card(width: 7.2, heading: [بطاقة], clip: true, direction: rtl)[#ar-sample],
  code: `#index-card(heading: [Card], clip: true)`)
