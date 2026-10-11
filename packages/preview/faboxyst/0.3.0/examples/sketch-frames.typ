#import "@preview/faboxyst:0.3.0": *
#set page(width: 20cm, height: auto, margin: 1cm)
#show: faboxyst.with(theme: themes.notebook)
#let L = [Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh.]
#let AR = [نص عربي تجريبي لاختبار اتجاه الكتابة من اليمين إلى اليسار.]
#let S3 = ((title: [Analysis], body: L, icon: [★]), (title: [Plan], body: L, icon: [✦]), (title: [Build], body: L, icon: [●]))
#let A3 = ((title: [التحليل], body: AR, icon: [★]), (title: [التخطيط], body: AR, icon: [✦]), (title: [البناء], body: AR, icon: [●]))
#vintage-frame(window: "oval", height: 5cm)[Invitation]
#v(2mm)
#vintage-frame(window: "twin-oval", height: 6cm, ([Left], [Right]))
#v(2mm)
#vintage-frame(window: "twin-rect", height: 5cm, ([Left], [Right]))
#v(2mm)
#vintage-frame(inner: "bevel", height: 5cm, text(28pt, weight: "bold")[THE END])
#v(2mm)
#charcoal-frame(height: 5cm)[Charcoal]
#v(2mm)
#charcoal-frame(shape: "ellipse", height: 6cm)[Round]
#v(2mm)
#crayon-frame(height: 5cm)[Crayon]
#v(2mm)
#pencil-sketch-frame(height: 5cm)[Pencil]
#v(2mm)
#pencil-sketch-frame(panels: 2, doodles: false, height: 5cm, ([A], [B]))
#v(2mm)
#crayon-frame(height: 4cm)[#AR]
