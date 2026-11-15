// Four folded banners, composed from the exported single-row component.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 19cm, height: auto, margin: 1.1cm, fill: rgb("#F4F3F3"))
#set text(font: "DejaVu Sans", size: 10pt)
#show: faboxyst.with(theme: themes.notebook)

= Folded banners

#folded-banner(
  title: [Lorem Ipsum],
  body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, crastel im.],
  number: [01],
  icon: image("assets/folded-people.svg", width: 1.2cm),
  colour: rgb("#0B4055"),
)
#v(0.16cm)
#folded-banner(
  title: [Lorem Ipsum],
  body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, crastel im.],
  number: [02],
  icon: image("assets/folded-chat.svg", width: 1.2cm),
  colour: rgb("#F3921B"),
)
#v(0.16cm)
#folded-banner(
  title: [Lorem Ipsum],
  body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, crastel im.],
  number: [03],
  icon: image("assets/folded-gear.svg", width: 1.1cm),
  colour: rgb("#47BDE5"),
)
#v(0.16cm)
#folded-banner(
  title: [Lorem Ipsum],
  body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, crastel im.],
  number: [04],
  icon: image("assets/folded-flame.svg", width: 1.1cm),
  colour: rgb("#A2BA69"),
)

#v(0.35cm)
#text(size: 8pt, fill: rgb("#777777"))[The number, fold, panel colour, icon and direction are individually configurable.]
