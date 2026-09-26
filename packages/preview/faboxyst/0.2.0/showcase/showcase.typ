#import "_helpers.typ": *
#set page(paper: "a4", margin: (x: 1.15cm, y: 1.2cm),
  header: text(size: 8pt, fill: luma(120))[faboxyst showcase · paramètres],
  footer: context align(center, text(size: 8pt, fill: luma(120), counter(page).display())))
#set text(font: "DejaVu Sans", size: 9.5pt)
#set par(leading: 0.55em)

#cmd-title[fabox]
#sig[
```typ
#fabox(
  body, title: none, subtitles: (), colour: rgb("#B03A2E"),
  frame: auto, back: auto, title-fill: auto, title-colour: auto,
  gradient-to: none, radius: 0.16, sharp: (), weight: 1.0pt,
  title-weight: auto, inset: 0.34cm, title-inset: 0.24cm,
  rule-between: true, frame-hidden: false, side-bar: none,
  side-bar-colour: auto, top-rule: none, bottom-rule: none,
  corner-tick: none, badge: none, badge-colour: auto,
  chevrons: 0, chevron-colour: auto, title-rule-inset: 0.0,
  title-rule-weight: auto, shadow: none, shadow-colour: auto,
  shadow-spread: auto, shadow-opacity: auto, shadow-offset: auto,
  shadow-blur: 14, tab: none, tab-width: 45%, tab-offset: 0.5,
  fold-colour: auto, fold-out: auto, label-number: none,
  label-number-fill: auto, label-caption: none, label-caption-fill: auto,
  label-out: auto, label-round: false, label-square: false,
  spine-out: auto, spine-align: start, spine-len: auto,
  spine-side: start, spine-fill: auto, spine-colour: auto,
  spine-inset: 0.16, spine-up: auto, spine-round: 0.0, spine-rule: false,
  ears: auto, earsrise: auto, earsshade: true, dots: auto,
  dotsfill: auto, dotscolour: auto, sweep: none, sweep-gap: auto,
  sweep-diamond: true, sweep-ticks: 3, sweep-wash: true,
  swoosh: 0.2, swoosh-deep: 0.48, swoosh-side: "top",
  swoosh-align: start, swoosh-both: auto, swoosh-pad: 0.34,
  plaque-rule: false, plaque-sharp: ("all",), fold: false,
  fold-size: 0.42, watermark: none, watermark-colour: auto,
  halo: none, border: none, tape-width: 0.16, tape-period: 0.10,
  tape-colours: (rgb("#FFDD00"), black), vignette: none,
  rough: false, roughness: 1.0, bowing: 0.6, seed: 11,
  width: 100%, icon: none, inline: false, baseline: 30%,
)
```
]
#v(6pt)

#param-row([colour  ·  rouge vs bleu],
  fabox(title: en-title, colour: rgb("#B03A2E"))[#en-sample],
  fabox(title: ar-title, colour: rgb("#B03A2E"))[#ar-sample])
#param-row([colour  ·  bleu],
  fabox(title: en-title, colour: rgb("#1A4FA0"))[#en-sample],
  fabox(title: ar-title, colour: rgb("#1A4FA0"))[#ar-sample])
#param-row([radius  0 vs 0.4],
  fabox(title: en-title, radius: 0)[#en-sample],
  fabox(title: ar-title, radius: 0.4)[#ar-sample])
#param-row([weight  0.6pt vs 2.4pt],
  fabox(title: en-title, weight: 0.6pt)[#en-sample],
  fabox(title: ar-title, weight: 2.4pt)[#ar-sample])
#param-row([back / title-fill / title-colour],
  fabox(title: [Note], back: rgb("#FFF3D6"), title-fill: rgb("#E67E22"), title-colour: black)[#en-sample],
  fabox(title: ar-title, back: rgb("#E8F5E9"), title-fill: rgb("#2E7D32"))[#ar-sample])
#param-row([gradient-to],
  fabox(title: en-title, colour: rgb("#1A4FA0"), gradient-to: rgb("#E3F2FD"))[#en-sample],
  fabox(title: ar-title, colour: rgb("#6A1B9A"), gradient-to: rgb("#F3E5F5"))[#ar-sample])
#param-row([rule-between  true vs false],
  fabox(title: en-title, rule-between: true)[#en-sample],
  fabox(title: ar-title, rule-between: false)[#ar-sample])
#param-row([frame-hidden],
  fabox(title: en-title, frame-hidden: false)[#en-sample],
  fabox(title: ar-title, frame-hidden: true)[#ar-sample])
#param-row([side-bar  none vs 0.16],
  fabox(title: en-title, side-bar: none)[#en-sample],
  fabox(title: ar-title, side-bar: 0.16)[#ar-sample])
#param-row([top-rule / bottom-rule],
  fabox(title: en-title, top-rule: 0.10)[#en-sample],
  fabox(title: ar-title, bottom-rule: 0.10)[#ar-sample])
#param-row([badge + chevrons],
  fabox(title: [Exercise], badge: [12], chevrons: 4)[#en-sample],
  fabox(title: [تمرين], badge: [١٢], chevrons: 4)[#ar-sample])
#param-row([shadow],
  fabox(title: en-title, shadow: true)[#en-sample],
  fabox(title: ar-title, shadow: true, shadow-offset: (0.12, 0.12))[#ar-sample])
#param-row([tab: "plaque"],
  fabox(title: [Plaque], tab: "plaque")[#en-sample],
  fabox(title: [لوحة], tab: "plaque")[#ar-sample])
#param-row([tab: "fold"],
  fabox(title: [Fold], tab: "fold")[#en-sample],
  fabox(title: [طية], tab: "fold")[#ar-sample])
#param-row([tab: "label" + label-number],
  fabox(title: [Def], tab: "label", label-number: [01])[#en-sample],
  fabox(title: [تعريف], tab: "label", label-number: [٠١])[#ar-sample])
#param-row([tab: "spine"],
  fabox(title: [Spine], tab: "spine")[#en-sample],
  fabox(title: [عمود], tab: "spine")[#ar-sample])
#param-row([tab: "ears"],
  fabox(title: [Ears], tab: "ears")[#en-sample],
  fabox(title: [أذنان], tab: "ears")[#ar-sample])
#param-row([tab: "dots"],
  fabox(title: [Dots], tab: "dots")[#en-sample],
  fabox(title: [نقاط], tab: "dots")[#ar-sample])
#param-row([tab: "swoosh"],
  fabox(title: [Swoosh], tab: "swoosh")[#en-sample],
  fabox(title: [منحنى], tab: "swoosh")[#ar-sample])
#param-row([sweep],
  fabox(title: [Sweep], sweep: 1.4)[#en-sample],
  fabox(title: [كنس], sweep: 1.4)[#ar-sample])
#param-row([fold dog-ear],
  fabox(title: en-title, fold: true, fold-size: 0.5)[#en-sample],
  fabox(title: ar-title, fold: true, fold-size: 0.5)[#ar-sample])
#param-row([watermark],
  fabox(title: en-title, watermark: [DRAFT])[#en-sample],
  fabox(title: ar-title, watermark: [مسودة])[#ar-sample])
#param-row([halo],
  fabox(title: en-title, halo: (0.12, rgb("#F4C430")))[#en-sample],
  fabox(title: ar-title, halo: (0.12, rgb("#81C784")))[#ar-sample])
#param-row([border: "caution"  tape],
  fabox(title: [Caution], border: "caution")[#en-sample],
  fabox(title: [تحذير], border: "caution")[#ar-sample])
#param-row([vignette],
  fabox(title: en-title, vignette: 0.10)[#en-sample],
  fabox(title: ar-title, vignette: 0.10)[#ar-sample])
#param-row([rough],
  fabox(title: en-title, rough: true, roughness: 1.6)[#en-sample],
  fabox(title: ar-title, rough: true, roughness: 1.6)[#ar-sample])
#param-row([subtitles],
  fabox(title: [Chapter], subtitles: (([1.1], [Sets]),))[#en-sample],
  fabox(title: [فصل], subtitles: (([١٫١], [مجموعات]),))[#ar-sample])



#cmd-title[fabox-sign / fabox-note / example-header]
#sig[
```typ
#fabox-sign(body, sides: 8, size: 2.6, colour: rgb("#D32F2F"),
  text-colour: white, weight: 2.6pt, ring: 0.16,
  rough: false, roughness: 1.0, bowing: 0.6, seed: 5, direction: auto)
#fabox-note(body, icon: [!], colour: rgb("#FBEC5D"),
  icon-fill: rgb("#6B6B47"), frame: rgb("#8A8A5C"),
  weight: 0.9pt, inset: 0.26cm, fold-size: 0.34, width: 100%, ...)
#example-header(word, number: none, tag: none, note: none,
  colour: rgb("#CE0F77"), tag-colour: rgb("#4FA7CD"), height: 0.72, ...)
```
]
#v(6pt)

#param-row([fabox-sign  sides  8 vs 6],
  align(center, fabox-sign(sides: 8)[STOP]),
  align(center, fabox-sign(sides: 6, colour: rgb("#1565C0"))[قف]))
#param-row([fabox-sign  ring / size],
  align(center, fabox-sign(size: 2.1, ring: 0.08)[A]),
  align(center, fabox-sign(size: 2.8, ring: 0.22, colour: rgb("#2E7D32"))[ب]))
#param-row([fabox-note],
  fabox-note[A sticky warning with a folded corner.],
  fabox-note(direction: rtl, icon: [!])[ملاحظة لاصقة مع زاوية مطوية.])
#param-row([fabox-note  colour],
  fabox-note(colour: rgb("#BBDEFB"), icon-fill: rgb("#1565C0"))[Blue note.],
  fabox-note(colour: rgb("#C8E6C9"), icon-fill: rgb("#2E7D32"))[ملاحظة خضراء.])
#param-row([example-header],
  example-header([Example], number: [3], tag: [easy]),
  { set text(dir: rtl, lang: "ar"); example-header([مثال], number: [٣], tag: [سهل]) })



#cmd-title[flagbox]
#sig[
```typ
#flagbox(body, title: none, colour: rgb("#1C5F9C"), fill: auto,
  ribbon: auto, ribbon-mid: auto, title-colour: white,
  title-weight: "bold", title-size: 1em,
  title-inset: (x: 0.30cm, y: 0.16cm), flag-align: start,
  shift: 1.0cm, spread: 0.20cm, overhang: 0.05cm,
  tail: "drape", notch: 0.22cm, rod: 0.10cm, rod-colour: auto,
  finials: true, badge: none, badge-colour: auto,
  end-motif: none, end-motif-size: 0.5cm, gloss: true,
  stitch: false, shadow: true, radius: 0.10cm, flag-radius: 0.10cm,
  stroke: 0.4mm, inset: (top: 0.30cm, ...), width: 100%,
  breakable: true, direction: auto)
```
]
#v(6pt)

#param-row([defaults],
  flagbox(title: [Note])[#en-sample],
  flagbox(title: ar-title)[#ar-sample])
#param-row([colour / ribbon],
  flagbox(title: [Info], colour: rgb("#C2185B"), ribbon: rgb("#F48FB1"))[#en-sample],
  flagbox(title: [معلومة], colour: rgb("#2E7D32"))[#ar-sample])
#param-row([tail  drape vs fork],
  flagbox(title: [Drape], tail: "drape")[#en-sample],
  flagbox(title: [شوكة], tail: "fork")[#ar-sample])
#param-row([finials / stitch / gloss],
  flagbox(title: [Stitch], stitch: true, gloss: false, finials: false)[#en-sample],
  flagbox(title: [خياطة], stitch: true, finials: true)[#ar-sample])
#param-row([flag-align  start vs center],
  flagbox(title: [Start], flag-align: start)[#en-sample],
  flagbox(title: [وسط], flag-align: center)[#ar-sample])
#param-row([shift / spread],
  flagbox(title: [Shift 0.4], shift: 0.4cm, spread: 0.08cm)[#en-sample],
  flagbox(title: [إزاحة], shift: 1.6cm, spread: 0.32cm)[#ar-sample])
#param-row([badge],
  flagbox(title: [Ex], badge: [7])[#en-sample],
  flagbox(title: [تمرين], badge: [٧])[#ar-sample])



#cmd-title[ornatebox]
#sig[
```typ
#ornatebox(body, title: none, colour: rgb("#1F3A68"), gold: rgb("#C9A24E"),
  paper: rgb("#FCF9F2"), palette: (:), fill: auto,
  rules: ((0.9pt, "ink"), (0.4pt, "gold")), rule-gap: 0.09cm,
  radius: 0cm, outset: 0cm,
  edge: "rosette", edge-sides: ("start", "end"), edge-size: 0.42cm,
  edge-gap: 0.9cm, edge-count: auto, edge-shift: 0cm, edge-mask: auto,
  edge-band: none, edge-band-fill: auto, edge-band-stroke: none,
  edge-alternate: false, edge-pack: false, edge-fit: false,
  edge-clear: auto, edge-turn: true,
  corner: "wedge", corner-size: 0.7cm, corner-shift: (0cm, 0cm),
  centre: (bottom: "rosette"), centre-size: auto, centre-mask: auto,
  title-style: "sash", title-colour: auto, title-size: 1.1em,
  title-weight: "bold", title-align: auto,
  title-inset: (x: 0.45cm, y: 0.16cm), title-gap: 0.28cm,
  title-rule: auto, sash-fill: auto, sash-stroke: none, sash-line: none,
  sash-gap: 0.14cm, sash-inset: (0.55cm, 0.9cm),
  caps: ("ogee", "ogee"), cap-len: auto, tile: "tile",
  pennant-caps: ("point", "point"), pennant-width: auto, pennant-stroke: auto,
  badge: none, badge-label: none, badge-size: auto, badge-star: true,
  badge-shift: auto, end-motif: none, end-motif-size: auto,
  flank: none, flank-size: auto,
  inset: (x: 0.55cm, y: 0.42cm), width: 100%, height: auto,
  shadow: false, direction: auto)
```
]
#v(6pt)

#param-row([defaults  sash],
  ornatebox(title: [Ornate])[#en-sample],
  ornatebox(title: [مزخرف])[#ar-sample])
#param-row([title-style: tiles],
  ornatebox(title: [Tiles], title-style: "tiles")[#en-sample],
  ornatebox(title: [بلاط], title-style: "tiles")[#ar-sample])
#param-row([title-style: pennant],
  ornatebox(title: [Pennant], title-style: "pennant")[#en-sample],
  ornatebox(title: [راية], title-style: "pennant")[#ar-sample])
#param-row([colour / gold],
  ornatebox(title: [Teal], colour: rgb("#0E6655"), gold: rgb("#D4AF37"))[#en-sample],
  ornatebox(title: [أخضر], colour: rgb("#0E6655"), gold: rgb("#D4AF37"))[#ar-sample])
#param-row([radius  0 vs 0.28cm],
  ornatebox(title: [Square], radius: 0cm)[#en-sample],
  ornatebox(title: [مدور], radius: 0.28cm)[#ar-sample])
#param-row([edge  rosette vs palmette],
  ornatebox(title: [Rosette], edge: "rosette")[#en-sample],
  ornatebox(title: [سعفة], edge: "palmette")[#ar-sample])
#param-row([corner  wedge vs scroll],
  ornatebox(title: [Wedge], corner: "wedge")[#en-sample],
  ornatebox(title: [حلزون], corner: "scroll")[#ar-sample])
#param-row([badge],
  ornatebox(title: [Exercise], badge: [4])[#en-sample],
  ornatebox(title: [تمرين], badge: [٤])[#ar-sample])
#param-row([shadow],
  ornatebox(title: [Shadow], shadow: true)[#en-sample],
  ornatebox(title: [ظل], shadow: true)[#ar-sample])
#param-row([caps  ogee vs point],
  ornatebox(title: [Ogee], caps: ("ogee", "ogee"))[#en-sample],
  ornatebox(title: [رأس], caps: ("point", "point"))[#ar-sample])



#cmd-title[khatambox · zellijbox · arabesquebox · mihrabbox · mosaicbox · fleuronbox]
#sig[
```typ
#khatambox(body, title: none, badge: none, badge-label: none,
  colour: rgb("#1F3A68"), sash-fill: rgb("#1E6B5A"), ..a)
#zellijbox(... tile-colour: rgb("#1B7F8C"))
#arabesquebox(...)  #mihrabbox(...)  #mosaicbox(...)
#fleuronbox(... edge-glyph: "❦", corner-glyph: "✤")
```
]
#v(6pt)

#param-row([khatambox],
  khatambox(title: [Khatam], badge: [1])[#en-sample],
  khatambox(title: [خاتم], badge: [١])[#ar-sample])
#param-row([zellijbox],
  zellijbox(title: [Zellij])[#en-sample],
  zellijbox(title: [زليج])[#ar-sample])
#param-row([arabesquebox],
  arabesquebox(title: [Arabesque])[#en-sample],
  arabesquebox(title: [أرابسك])[#ar-sample])
#param-row([mihrabbox],
  mihrabbox(title: [Mihrab])[#en-sample],
  mihrabbox(title: [محراب])[#ar-sample])
#param-row([mosaicbox],
  mosaicbox(title: [Mosaic])[#en-sample],
  mosaicbox(title: [فسيفساء])[#ar-sample])
#param-row([fleuronbox],
  fleuronbox(title: [Fleuron])[#en-sample],
  fleuronbox(title: [زهرة])[#ar-sample])



#cmd-title[calloutbox]
#sig[
```typ
#calloutbox(body, title: none, colour: rgb("#1A4FA0"), fill: rgb("#F4F8FF"),
  title-colour: white, tail: "sw", tail-size: 0.42cm, tail-at: 0.18,
  radius: 0.18cm, weight: 1.35pt, inset: 0.34cm, width: 100%, direction: auto)
```
]
#v(6pt)

#param-row([tail sw vs se],
  calloutbox(title: [Call], tail: "sw")[#en-sample],
  calloutbox(title: ar-title, tail: "se")[#ar-sample])
#param-row([tail ne vs nw],
  calloutbox(title: [NE], tail: "ne")[#en-sample],
  calloutbox(title: [شمال], tail: "nw")[#ar-sample])
#param-row([colour / fill],
  calloutbox(title: [Warm], colour: rgb("#E67E22"), fill: rgb("#FFF3E0"))[#en-sample],
  calloutbox(title: [دافئ], colour: rgb("#E67E22"), fill: rgb("#FFF3E0"))[#ar-sample])
#param-row([tail-size / radius],
  calloutbox(title: [Big tail], tail-size: 0.7cm, radius: 0.08cm)[#en-sample],
  calloutbox(title: [صغير], tail-size: 0.22cm, radius: 0.32cm)[#ar-sample])



#cmd-title[ribbonbox]
#sig[
```typ
#ribbonbox(body, title: none, colour: rgb("#1A3580"), fill: rgb("#F6D56A"),
  tab-fill: rgb("#F3C2D4"), title-colour: rgb("#5A2A6A"), radius: 0.10cm,
  band: 0.20cm, weight: 1.05pt, pair: 0.07cm, chevron: true,
  chevron-colour: rgb("#F4F0E4"), chevron-size: 0.22cm, shadow: true,
  flourish: true, tab-offset: 0.85cm, inset: 0.38cm, width: 100%, direction: auto)
```
]
#v(6pt)

#param-row([defaults],
  ribbonbox(title: [Ribbon])[#en-sample],
  ribbonbox(title: [شريط])[#ar-sample])
#param-row([chevron false / flourish false],
  ribbonbox(title: [Plain], chevron: false, flourish: false)[#en-sample],
  ribbonbox(title: [بسيط], chevron: false, flourish: false)[#ar-sample])
#param-row([band / colours],
  ribbonbox(title: [Wide], band: 0.34cm, fill: rgb("#B3E5FC"))[#en-sample],
  ribbonbox(title: [عريض], band: 0.34cm, fill: rgb("#C8E6C9"))[#ar-sample])



#cmd-title[crestbox / plate]
#sig[
```typ
#crestbox(body, title: none, colour: rgb("#1E5C4A"), outer: rgb("#141414"),
  fill: rgb("#D4B896"), title-colour: rgb("#1B3A8C"), cut: 0.30cm,
  weight: 0.95pt, outer-weight: 1.65pt, gap: 0.11cm, pair: 0.13cm,
  ear: 0.18cm, shadow: true, shadow-offset: (0.00cm, 0.11cm),
  flourish: true, inset: 0.40cm, width: 100%, direction: auto)
#plate(body, title: [Example], ..a)
```
]
#v(6pt)

#param-row([crestbox],
  crestbox(title: [Crest])[#en-sample],
  crestbox(title: [شعار])[#ar-sample])
#param-row([cut / flourish],
  crestbox(title: [Cut], cut: 0.18cm, flourish: false)[#en-sample],
  crestbox(title: [قطع], cut: 0.42cm, flourish: true)[#ar-sample])
#param-row([plate alias],
  plate(title: [Plate])[#en-sample],
  plate(title: [لوحة])[#ar-sample])



#cmd-title[helixbox]
#sig[
```typ
#helixbox(body, title: none, colour: rgb("#178A78"), fill: rgb("#F7FBFC"),
  title-colour: rgb("#D4E86A"), helix-a: rgb("#C6E04A"), helix-b: rgb("#F3F6E8"),
  helix-period: 0.58cm, bar: 0.52cm, stripe: (rgb("#F0D44A"), rgb("#3D6BC4")),
  stripe-width: 0.09cm, shadow: true, ...)
```
]
#v(6pt)

#param-row([defaults],
  helixbox(title: [Helix])[#en-sample],
  helixbox(title: [حلزون])[#ar-sample])
#param-row([period / bar],
  helixbox(title: [Tight], helix-period: 0.32cm, bar: 0.38cm)[#en-sample],
  helixbox(title: [واسع], helix-period: 0.85cm, bar: 0.7cm)[#ar-sample])
#param-row([stripe colours],
  helixbox(title: [Candy], stripe: (rgb("#E91E63"), rgb("#FFC107")))[#en-sample],
  helixbox(title: [حلوى], stripe: (rgb("#E91E63"), rgb("#FFC107")))[#ar-sample])



#cmd-title[swooshbox]
#sig[
```typ
#swooshbox(body, title: none, colour: rgb("#1E54D6"), fill: white,
  tab-fill: none, title-colour: white, radius: 0.20cm, skew: 10pt,
  tr: auto, br: auto, flourish: true, tab-offset: 1.35cm,
  stroke: 0.65pt + rgb("#C4C8CE"), shadow: true, inset: 0.38cm, width: 100%)
```
]
#v(6pt)

#param-row([defaults],
  swooshbox(title: [Swoosh])[#en-sample],
  swooshbox(title: [انحناء])[#ar-sample])
#param-row([skew  4pt vs 18pt],
  swooshbox(title: [Low], skew: 4pt)[#en-sample],
  swooshbox(title: [حاد], skew: 18pt)[#ar-sample])
#param-row([flourish false],
  swooshbox(title: [No flourish], flourish: false)[#en-sample],
  swooshbox(title: [بدون], flourish: false)[#ar-sample])



#cmd-title[circuitbox]
#sig[
```typ
#circuitbox(body, title: none, colour: rgb("#1B4F9C"), fill: white,
  title-colour: auto, radius: 0.28cm, step: 0.26cm, rail: 1.35cm,
  weight: 1.05pt, pair: 1.55pt, gap: auto, flourish: true, inset: 0.38cm)
```
]
#v(6pt)

#param-row([defaults],
  circuitbox(title: [Circuit])[#en-sample],
  circuitbox(title: [دارة])[#ar-sample])
#param-row([step / rail],
  circuitbox(title: [Fine], step: 0.16cm, rail: 0.9cm)[#en-sample],
  circuitbox(title: [خشن], step: 0.4cm, rail: 1.8cm)[#ar-sample])



#cmd-title[keybox]
#sig[
```typ
#keybox(body, colour: rgb(0,0,128), frame: black, fill: white,
  sz: 10pt, band: auto, band-inset: 5pt, weight: 1pt, inset: auto, width: 100%)
```
]
#v(6pt)

#param-row([defaults],
  keybox[A key-bordered definition.],
  keybox(direction: rtl)[تعريف بإطار مفاتيح.])
#param-row([colour / sz],
  keybox(colour: rgb("#B71C1C"), sz: 8pt)[Small keys.],
  keybox(colour: rgb("#1B5E20"), sz: 14pt)[مفاتيح كبيرة.])



#cmd-title[lacebox]
#sig[
```typ
#lacebox(body, title: none, lace: "spiral", model: "band",
  colour: rgb("#1B2A41"), fill: white, band: 1.15cm, weight: 1pt,
  inset: 0.4cm, width: 100%, direction: auto, rough: 0,
  ornament: none, ornament-family: "vectorian")
```
]
#v(6pt)

#param-row([lace spiral],
  lacebox(title: [Lace], lace: "spiral")[#en-sample],
  lacebox(title: [دانتيل], lace: "spiral")[#ar-sample])
#param-row([model band vs frame],
  lacebox(title: [Band], model: "band")[#en-sample],
  lacebox(title: [إطار], model: "frame")[#ar-sample])
#param-row([ornament],
  lacebox(title: [Orn.], ornament: 11)[#en-sample],
  lacebox(title: [زخرفة], ornament: 11)[#ar-sample])



#cmd-title[ringbox]
#sig[
```typ
#ringbox(body, colour: black, fill: luma(252), rings: auto,
  ring-width: 0.8em, ring-radius: 3pt, ring-thickness: 3pt,
  ring-spacing: 3pt, radius: 2pt, frame: false, frame-colour: auto,
  frame-weight: 0.85pt, inset: 1em, width: 100%)
```
]
#v(6pt)

#param-row([defaults],
  ringbox[#en-sample],
  ringbox(direction: rtl)[#ar-sample])
#param-row([frame + rings 3 vs 8],
  ringbox(frame: true, rings: 3)[#en-sample],
  ringbox(frame: true, rings: 8)[#ar-sample])
#param-row([ring-width],
  ringbox(ring-width: 0.45em, ring-thickness: 1.6pt)[#en-sample],
  ringbox(ring-width: 1.2em, ring-thickness: 4pt)[#ar-sample])



#cmd-title[punchbox]
#sig[
```typ
#punchbox(body, title: none, number: none, colour: rgb("#1A4FA0"),
  badge-fill: rgb("#E53935"), bar: black, hole: white, side: rgb("#7CB342"),
  fill: white, title-colour: white, bar-height: 0.54cm, hole-radius: 0.135cm,
  holes: auto, side-weight: 1.6pt, shadow: true, inset: 0.38cm)
```
]
#v(6pt)

#param-row([defaults],
  punchbox(title: [Punch], number: [03])[#en-sample],
  punchbox(title: [ثقب], number: [٠٣])[#ar-sample])
#param-row([holes / bar-height],
  punchbox(title: [Few], holes: 4, bar-height: 0.36cm)[#en-sample],
  punchbox(title: [كثير], holes: 10, bar-height: 0.7cm)[#ar-sample])



#cmd-title[plannerbox]
#sig[
```typ
#plannerbox(body, title: none, number: none, colour: rgb("#1A4FA0"),
  badge-fill: rgb("#E53935"), bar: black, hole: white, ring-colour: black,
  fill: white, title-colour: white, bar-height: 0.50cm, hole-radius: 0.12cm,
  holes: auto, rings: auto, ring-width: 0.55cm, ring-radius: 2.6pt,
  ring-thickness: 2.6pt, frame: true, frame-weight: 0.7pt, shadow: true, ...)
```
]
#v(6pt)

#param-row([defaults],
  plannerbox(title: [Week], number: [12])[#en-sample],
  plannerbox(title: [أسبوع], number: [١٢])[#ar-sample])
#param-row([rings false],
  plannerbox(title: [No rings], rings: 0)[#en-sample],
  plannerbox(title: [بدون], rings: 0)[#ar-sample])



#cmd-title[filebox]
#sig[
```typ
#filebox(body, tabs: ([Notes],), active: 0, colour: rgb("#C4A35A"),
  active-fill: rgb("#F4E4B8"), idle-fill: rgb("#E0D0A0"),
  title-colour: rgb("#4A3A18"), fill: rgb("#FFF8E8"),
  frame-weight: 1.15pt, tab-height: 0.46cm, radius: 0.10cm, inset: 0.36cm)
```
]
#v(6pt)

#param-row([tabs / active 0],
  filebox(tabs: ([Notes], [Ex], [Def]), active: 0)[#en-sample],
  filebox(tabs: ([ملاحظات], [تمرين], [تعريف]), active: 0)[#ar-sample])
#param-row([active 2 / taller tabs],
  filebox(tabs: ([A], [B], [C]), active: 2, tab-height: 0.62cm)[#en-sample],
  filebox(tabs: ([أ], [ب], [ج]), active: 2, tab-height: 0.62cm)[#ar-sample])



#cmd-title[stubbox]
#sig[
```typ
#stubbox(body, stub: none, colour: rgb("#1A4FA0"), stub-colour: white,
  fill: white, radius: 0.10cm, stub-width: 1.35cm, dots: 11, dot: 1.1pt,
  frame-weight: 0.9pt, shadow: true, inset: 0.34cm)
```
]
#v(6pt)

#param-row([defaults],
  stubbox(stub: [A])[#en-sample],
  stubbox(stub: [أ])[#ar-sample])
#param-row([stub-width / dots],
  stubbox(stub: [ID], stub-width: 2.0cm, dots: 6)[#en-sample],
  stubbox(stub: [رقم], stub-width: 0.9cm, dots: 16)[#ar-sample])



#cmd-title[stackbox]
#sig[
```typ
#stackbox(body, title: none, colour: rgb("#1A4FA0"), fill: white,
  title-colour: white, back: (rgb("#D6DCE4"), rgb("#B8C0CC")),
  layers: 3, offset: 0.16cm, radius: 0.10cm, frame-weight: 0.85pt, inset: 0.36cm)
```
]
#v(6pt)

#param-row([layers 2 vs 5],
  stackbox(title: [Stack], layers: 2)[#en-sample],
  stackbox(title: [كومة], layers: 5)[#ar-sample])
#param-row([offset],
  stackbox(title: [Tight], offset: 0.06cm)[#en-sample],
  stackbox(title: [بعيد], offset: 0.28cm)[#ar-sample])



#cmd-title[tapebox]
#sig[
```typ
#tapebox(body, title: none, colour: rgb("#E07A5F"), tape-b: rgb("#F2CC8F"),
  fill: rgb("#FFFEF8"), title-colour: rgb("#4A2C1A"), pattern: "solid",
  tape-height: 0.46cm, tape-overhang: 0.18cm, tilt: -1.2deg,
  radius: 0.08cm, frame-weight: 0.7pt, inset: 0.36cm)
```
]
#v(6pt)

#param-row([pattern solid vs stripes],
  tapebox(title: [Solid], pattern: "solid")[#en-sample],
  tapebox(title: [خطوط], pattern: "stripes")[#ar-sample])
#param-row([tilt / tape-height],
  tapebox(title: [Tilt], tilt: -6deg, tape-height: 0.62cm)[#en-sample],
  tapebox(title: [مائل], tilt: 6deg, tape-height: 0.32cm)[#ar-sample])



#cmd-title[boardbox / chalkbox / markerbox]
#sig[
```typ
#boardbox(body, title: none, kind: "chalk", colour: auto, fill: auto,
  title-colour: auto, text-fill: auto, grid: true, grid-step: 0.32cm,
  grid-stroke: auto, tray: true, border: 0.16cm, inset: 0.32cm, width: 100%)
#chalkbox / #markerbox
```
]
#v(6pt)

#param-row([chalk vs marker],
  chalkbox(title: [Chalk])[#en-sample],
  markerbox(title: [سبورة])[#ar-sample])
#param-row([grid / tray],
  boardbox(title: [No tray], grid: false, tray: false)[#en-sample],
  boardbox(title: [شبكة], grid: true, tray: true, kind: "marker")[#ar-sample])



#cmd-title[screwbox]
#sig[
```typ
#screwbox(body, tl: true, tr: true, bl: true, br: true,
  colour: rgb("#5C6670"), fill: rgb("#F4F6F8"), screw: rgb("#C5CCD3"),
  slot: rgb("#3A4046"), screw-size: 0.34cm, angle: 0deg, weight: 1.35pt,
  radius: 0.10cm, inset: 0.42cm)
```
]
#v(6pt)

#param-row([all screws vs two],
  screwbox[#en-sample],
  screwbox(tl: true, tr: false, bl: false, br: true)[#ar-sample])
#param-row([screw-size / angle],
  screwbox(screw-size: 0.22cm, angle: 25deg)[#en-sample],
  screwbox(screw-size: 0.48cm, angle: -35deg)[#ar-sample])



#cmd-title[sashbox / ruban]
#sig[
```typ
#sashbox(body, kind: "flat", fill: rgb("#FFE566"), shade: auto,
  text-colour: auto, height: 1.22cm, width: 100%, tail: auto, fold: auto,
  bow: auto, incline: auto, weight: "bold", size: 1.15em, inset: 0.28cm,
  direction: auto, rough: false, hand: auto, seed: 31, ink: auto,
  pen: 3.1pt, ghost: true)
#ruban = sashbox
```
]
#v(6pt)

#param-row([kind flat vs fold],
  sashbox(kind: "flat")[FLAT SASH],
  sashbox(kind: "fold")[طية])
#param-row([kind bow / incline],
  sashbox(kind: "bow")[BOW],
  sashbox(kind: "incline")[مائل])
#param-row([fill / height],
  sashbox(fill: rgb("#FF8A80"), height: 0.9cm)[SHORT],
  sashbox(fill: rgb("#80D8FF"), height: 1.5cm)[طويل])
#param-row([rough],
  sashbox(rough: true)[HAND],
  sashbox(rough: true)[يدوي])



#cmd-title[notebook-box]
#sig[
```typ
#notebook-box(body, title: none, badge: none, colour: rgb("#22C55E"),
  ink: auto, inner-ink: auto, inner-lighten: 25%, fill: white,
  title-fill: auto, paper: auto, grid: true, grid-step: 0.42,
  rings: 4, ring-side: auto, ring-at: auto, ring-colour: auto,
  ring-size: 0.30, ring-aspect: 0.62, bead: 0.10, gap: 0.14,
  ring-gap: 0.10, spine: auto, radius: 0.42, weight: 2.4pt,
  inner-weight: 2.0pt, double-frame: true, roughness: 1.0, bowing: 0.5,
  seed: 7, inset: 0.62cm, width: 100%, title-size: 1.15em)
#notebook-box-clean = roughness: 0
```
]
#v(6pt)

#param-row([defaults vs clean],
  notebook-box(title: [Exercice], badge: [03])[$a+b=3$],
  notebook-box-clean(title: [تمرين], badge: [٠٣])[$a+b=3$])
#param-row([rings 2 vs 6 / colour],
  notebook-box(title: [Few], rings: 2, colour: rgb("#3B82F6"))[#en-sample],
  notebook-box(title: [كثير], rings: 6, colour: rgb("#F59E0B"))[#ar-sample])
#param-row([grid false / roughness 0 vs 2],
  notebook-box(title: [No grid], grid: false, roughness: 0)[#en-sample],
  notebook-box(title: [خشن], grid: true, roughness: 2.2)[#ar-sample])



#cmd-title[iconbox / tip-card / concept-card]
#sig[
```typ
#iconbox(body, title: none, icon: none, mark: none, banner: false,
  colour: rgb("#C2185B"), frame: auto, fill: white, title-colour: auto,
  title-size: 1.15em, italic: true, radius: 0.28cm, weight: 1.5pt,
  stroke: auto, dash: none, frame-char: none, frame-char-size: 0.28cm,
  inset: 0.38cm, width: 100%, icon-size: 1.55em, icon-dx: 0.10cm,
  icon-dy: -0.42cm, mark-size: 1.15em)
#tip-card  #concept-card  #ico-star  #ico-bulb  #ico-pencil
```
]
#v(6pt)

#param-row([iconbox + ico-bulb],
  iconbox(title: [Tip], icon: ico-bulb(), banner: true)[#en-sample],
  iconbox(title: [نصيحة], icon: ico-bulb(), banner: true)[#ar-sample])
#param-row([dash / concept],
  concept-card[#en-sample],
  concept-card(direction: rtl)[#ar-sample])
#param-row([tip-card],
  tip-card[#en-sample],
  tip-card(direction: rtl)[#ar-sample])



#cmd-title[numbox]
#sig[
```typ
#numbox(...)  #numbox-reset(n: 1)  #numbox-counter
```
]
#v(6pt)

#numbox-reset(n: 1)
#param-row([auto numbering],
  numbox(title: [Item])[#en-sample],
  numbox(title: [عنصر])[#ar-sample])
#param-row([next numbers],
  numbox(title: [Next])[#en-sample],
  numbox(title: [التالي])[#ar-sample])#cmd-title[fancy: sloppy-box · post-it · ticket · folder · terminal · neon · polaroid]
#sig[
```typ
#sloppy-box  #post-it  #ticket / ticketbox  #folder  #terminal
#neon  #polaroid  #vignette  #spread-box  #banner-3d
#flag-ribbon  #speed-bar  #spiral-binding  #bound-page
#mark  #hl  #mark-emph
```
]
#v(6pt)

#param-row([sloppy-box],
  sloppy-box[#en-sample],
  sloppy-box(direction: rtl)[#ar-sample])
#param-row([post-it],
  post-it[#en-sample],
  post-it(direction: rtl)[#ar-sample])
#param-row([ticket stub],
  ticket(stub: [N°12])[#en-sample],
  ticket(stub: [١٢])[#ar-sample])
#param-row([folder],
  folder(title: [Docs])[#en-sample],
  folder(title: [ملفات])[#ar-sample])
#param-row([terminal],
  terminal(title: [bash])[ls -la],
  terminal(title: [طرفية])[echo hi])
#param-row([neon],
  neon[NEON],
  neon(colour: rgb("#FF4081"))[نيون])
#param-row([polaroid],
  polaroid(caption: [Summer])[#align(center)[☀]],
  polaroid(caption: [صيف])[#align(center)[☀]])
#param-row([vignette],
  vignette([Term], [definition]),
  { set text(dir: rtl, lang: "ar"); vignette([حد], [تعريف]) })
#param-row([banner-3d],
  banner-3d[BANNER],
  banner-3d(colour: rgb("#C62828"))[شريط])
#param-row([speed-bar],
  speed-bar[FAST],
  speed-bar(direction: rtl)[سريع])
#param-row([flag-ribbon],
  flag-ribbon[SALE],
  flag-ribbon(direction: rtl)[عرض])#cmd-title[sketch-box · semantic (note tip warning example burst ...)]
#sig[
```typ
#sketch-box(body, shape: "round", fill: none, stroke-colour: auto,
  stroke-weight: auto, radius: auto, pad: auto, width: auto, seed: auto,
  roughness: auto, hatch: none, shadow: none, depth: 0, inset-top: 0pt,
  passes: 1, pass-offset: 0.06, curl: 0.42, text-fill: auto,
  breakable: false, direction: auto)
#note  #tip  #warning  #example  #definition  #burst  #block3d
#hatched  #shadowed  #plaque  #double-frame  #pill-box  #sticky
```
]
#v(6pt)

#param-row([shape round vs burst],
  sketch-box(shape: "round")[#en-sample],
  sketch-box(shape: "burst")[#ar-sample])
#param-row([shape plaque vs stadium],
  sketch-box(shape: "plaque")[#en-sample],
  sketch-box(shape: "stadium")[#ar-sample])
#param-row([depth 3D],
  block3d(depth: 0.18)[#en-sample],
  block3d(depth: 0.42)[#ar-sample])
#param-row([hatched angle],
  hatched(angle: 30)[#en-sample],
  hatched(angle: 75)[#ar-sample])
#param-row([passes],
  double-frame[#en-sample],
  double-frame(direction: rtl)[#ar-sample])
#param-row([note / tip / warning],
  stack(spacing: 6pt, note[Note.], tip[Tip.], warning[Warn.]),
  { set text(dir: rtl, lang: "ar"); stack(spacing: 6pt, note[ملاحظة.], tip[نصيحة.], warning[تحذير.]) })
#param-row([plaque / pill],
  plaque(title: [Plaque])[#en-sample],
  pill-box(direction: rtl)[#ar-sample])
#param-row([sticky angle],
  sticky(angle: -8deg)[stick],
  sticky(angle: 10deg)[لاصق])
#param-row([definition],
  definition([INTEGER])[Whole numbers.],
  definition([عدد صحيح])[الأعداد الكاملة.])#cmd-title[ornament · pgfornament · lace · motifs]
#sig[
```typ
#ornament(m, size: 0.5cm, palette: (:), baseline: 20%)
#pgfornament(n, family: "vectorian", width: 1.2cm, paint: black, thickness: 0.5pt)
#lace(pattern, w, h, paint, thickness: 0.1pt)
#glyph-motif  #content-motif  #image-motif  #tint  #turned
#khatam-badge(number, label: none, size: 1.4cm, ...)
```
]
#v(6pt)

#let show-motifs = {
  set text(size: 8pt)
  for (k, m) in motifs {
    box(inset: 4pt, width: 2.4cm, height: 2.2cm,
      stroke: 0.3pt + luma(210), radius: 3pt,
      align(center, {
        ornament(m, size: 0.9cm)
        v(2pt)
        k
      }))
    h(4pt)
  }
}
#show-motifs
#v(10pt)
#param-row([pgfornament n=1 vs n=11],
  align(center, pgfornament(1, width: 2.4cm)),
  align(center, pgfornament(11, width: 2.4cm, paint: rgb("#8B1E3F"))))
#param-row([khatam-badge],
  align(center, khatam-badge([3], label: [Ex])),
  align(center, khatam-badge([7], label: [تمرين])))



#cmd-title[book-cover  (page entière)]
#sig[
```typ
#book-cover(title: none, subtitle: none, author: none, series: none,
  level: none, year: none, publisher: none, place-line: none,
  badge: none, badge-label: none, badge-note: none, lead-in: none,
  page-a: none, page-b: none, topics: none, formula: none, note: none,
  author-label: auto, style: "guilloche", lace: "spiral",
  colour: auto, accent: auto, direction: auto)
```
]
#v(6pt)

#note-line[Miniatures — le vrai cadre pleine page est dans `pages-full.typ`.]
#block(height: 11cm, clip: true,
  scale(42%, origin: top + left,
    book-cover(
      title: [Showcase],
      subtitle: [Faboxyst],
      author: [Arena],
      year: [2026],
      style: "guilloche",
    )))



#cmd-title[ornate-pages · bound-page · spiral-binding]
#sig[
```typ
#ornate-pages(doc, preset: ornatebox, margin: 1.2cm, inner: auto, ..args)
#bound-page(body, side: auto, colour: rgb("#88AAAA"), margin: 2.6cm, rest: 1.8cm, ..args)
#spiral-binding(side: auto, colour: rgb("#88AAAA"), gap: 1.5cm, gutter: true, ...)
```
]
#v(6pt)

#note-line[Ces commandes *prennent la page*. Voir les fichiers `page-ornate.typ`, `page-bound.typ`.]
#param-row([spiral-binding left vs right],
  box(height: 4.2cm, width: 100%, stroke: 0.4pt + luma(200), {
    spiral-binding(side: "left", gap: 1.1cm)
    place(horizon + center)[left binding]
  }),
  box(height: 4.2cm, width: 100%, stroke: 0.4pt + luma(200), {
    spiral-binding(side: "right", gap: 1.1cm)
    place(horizon + center)[ربط يمين]
  }))

