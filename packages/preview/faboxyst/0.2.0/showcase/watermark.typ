#import "_helpers.typ": *

#set page(paper: "a4", margin: (x: 1.15cm, y: 1.2cm),
  header: text(size: 8pt, fill: luma(120))[faboxyst · watermark],
  footer: context align(center, text(size: 8pt, fill: luma(120), counter(page).display())))
#set text(font: "DejaVu Sans", size: 9.5pt)

#cmd-title[watermark · inclinaison]
#sig[
```typ
#fabox(..., watermark: [DRAFT],
  watermark-angle: -18deg,   // 0deg = droit, 90deg = vertical
  watermark-size: 2.1em,
  watermark-colour: auto)    // auto = colour.lighten(62%)

#with-watermark(any-box, [CONFIDENTIEL],
  watermark-angle: 12deg,
  watermark-size: 1.6em,
  watermark-colour: rgb("#C62828").transparentize(60%))
```
]

#note-line[Avant : l’angle était *codé en dur* à −18° et le filigrane n’existait que dans `fabox`. Maintenant : `watermark-angle` / `watermark-size` / `watermark-colour` sur fabox, sketch-box, ornatebox (+ presets), flagbox, calloutbox, notebook-box. Pour *toute* autre box : `#with-watermark`.]

#v(8pt)
#param-row([fabox  −18° vs 0°],
  fabox(title: [Draft], watermark: [DRAFT], watermark-angle: -18deg)[#en-sample #v(0.4cm) more lines so the mark shows.],
  { set text(dir: rtl, lang: "ar")
    fabox(title: [مسودة], watermark: [مسودة], watermark-angle: 0deg)[#ar-sample #v(0.4cm) سطر إضافي.] })

#param-row([fabox  +25° vs −55°  ·  size],
  fabox(title: [Big], watermark: [COPY], watermark-angle: 25deg, watermark-size: 2.8em,
    watermark-colour: rgb("#1565C0").transparentize(40%))[#en-sample #v(8pt) Body.],
  { set text(dir: rtl, lang: "ar")
    fabox(title: [نسخة], watermark: [نسخة], watermark-angle: -55deg, watermark-size: 1.4em)[#ar-sample #v(8pt) نص.] })

#cmd-title[watermark · autres boxes]
#param-row([ornatebox / khatambox],
  ornatebox(title: [Ornate], watermark: [SAMPLE], watermark-angle: -12deg)[#en-sample #v(10pt) .],
  { set text(dir: rtl, lang: "ar")
    khatambox(title: [خاتم], badge: [١], watermark: [تمرين], watermark-angle: 20deg)[#ar-sample #v(10pt) .] })

#param-row([flagbox / calloutbox],
  flagbox(title: [Flag], watermark: [OLD], watermark-angle: -30deg)[#en-sample #v(8pt) .],
  { set text(dir: rtl, lang: "ar")
    calloutbox(title: [تنبيه], tail: "se", watermark: [!], watermark-angle: 15deg, watermark-size: 3em)[#ar-sample] })

#param-row([notebook-box / sketch-box],
  notebook-box(title: [Ex], badge: [07], watermark: [MATH], watermark-angle: -8deg)[$a^2+b^2=c^2$],
  { set text(dir: rtl, lang: "ar")
    sketch-box(watermark: [ملاحظة], watermark-angle: 40deg)[#ar-sample] })

#param-row([with-watermark autour d’une box sans paramètre],
  with-watermark(
    ribbonbox(title: [Ribbon])[#en-sample #v(10pt) wrapped.],
    [WRAP], watermark-angle: 12deg, watermark-size: 2.4em),
  { set text(dir: rtl, lang: "ar")
    with-watermark(
      helixbox(title: [حلزون])[#ar-sample #v(10pt) .],
      [سري], watermark-angle: -22deg) })
