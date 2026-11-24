// ===========================================================================
//  sashbox — folded ribbon banners
//
//    typst compile pages/sashbox.typ pages/sashbox.pdf --root .
// ===========================================================================

#import "/lib.typ": *
#import "/pages/_preview.typ": titre

#set page(width: 17.5cm, height: auto, margin: 10mm)
#set text(font: "DejaVu Sans", size: 11pt)

= sashbox — folded ribbon

The three sashes of the reference plate: a flat band, an arch, and a hang.
Lettering follows the bow. `ruban` is an alias.

#titre[1. LTR — `flat` / `arch` / `hang`]

#sashbox(kind: "flat", fill: rgb("#FFE566"))[SUMMER SALE]
#v(1.15em)
#sashbox(kind: "arch", fill: rgb("#FF9EC8"))[Welcome]
#v(1.15em)
#sashbox(kind: "hang", fill: rgb("#7ED4C8"))[Thank you]

#titre[2. colours]

#sashbox(kind: "arch", fill: rgb("#5B8DEF"), text-colour: white)[NEW]
#v(0.7em)
#sashbox(kind: "hang", fill: rgb("#E85D4C"), text-colour: white)[SOLD OUT]

#titre[3. RTL — the clusters run the other way along the same arc]

#[
  #set text(lang: "ar", dir: rtl, font: ("DejaVu Sans",))
  #sashbox(kind: "flat", fill: rgb("#FFE566"))[تخفيضات الصيف]
  #v(0.85em)
  #sashbox(kind: "arch", fill: rgb("#FF9EC8"))[أهلاً وسهلاً]
  #v(0.85em)
  #sashbox(kind: "hang", fill: rgb("#7ED4C8"))[شكراً لكم]
]

#titre[4. `incline` — 1 is the kind's default; 0 is flat; a length is absolute]

#sashbox(kind: "arch", incline: 0.45, fill: rgb("#FF9EC8"))[soft]
#v(0.7em)
#sashbox(kind: "arch", incline: 1, fill: rgb("#FF9EC8"))[default]
#v(0.7em)
#sashbox(kind: "arch", incline: 1.45, fill: rgb("#FF9EC8"))[steep]
#v(0.7em)
#sashbox(kind: "hang", incline: 0.55, fill: rgb("#7ED4C8"))[soft hang]
#v(0.7em)
#sashbox(kind: "flat", incline: 0.8, fill: rgb("#5B8DEF"), text-colour: white)[flat + incline]

#titre[5. crisp vs `rough: true` (sloppy ink)]

#grid(columns: (1fr, 1fr), gutter: 0.45cm,
  {
    titre[crisp]
    sashbox(kind: "flat", fill: rgb("#FFE566"))[SALE]
    v(0.7em)
    sashbox(kind: "arch", fill: rgb("#FF9EC8"))[Welcome]
    v(0.7em)
    sashbox(kind: "hang", fill: rgb("#7ED4C8"))[Thanks]
  },
  {
    titre[sloppy]
    sashbox(kind: "flat", rough: true, fill: rgb("#FFE566"))[SALE]
    v(0.7em)
    sashbox(kind: "arch", rough: true, fill: rgb("#FF9EC8"))[Welcome]
    v(0.7em)
    sashbox(kind: "hang", rough: true, fill: rgb("#7ED4C8"))[Thanks]
  },
)

#titre[6. `hand: "roughjs"`]

#sashbox(kind: "arch", rough: true, hand: "roughjs",
  ink: rgb("#1A237E"),
  fill: rgb("#5B8DEF"), text-colour: white)[Rough.js]
