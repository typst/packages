// The same single folder-step box, monochrome print — LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11cm, height: 5.8cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.print)

#print-group[
  #align(center + horizon)[
    #folder-step-box(
      title: [Plan the Work],
      body: [Capture the key actions, owners, and timing in one easy-to-scan folder.],
      icon: image("assets/folder-step-clipboard-navy.svg", width: 0.62cm),
      print-icon: image("assets/folder-step-clipboard-black.svg", width: 0.62cm),
      number: [01],
      width: 5.9cm,
      front-height: 3.3cm,
      folder-height: 2.55cm,
      direction: ltr,
    )
  ]
]

#pagebreak()

#print-group[
  #align(center + horizon)[
    #folder-step-box(
      title: [تنظيم العمل],
      body: [اجمع المهام والمسؤوليات والمواعيد في صندوق واحد يسهل الرجوع إليه.],
      icon: image("assets/folder-step-clipboard-white.svg", width: 0.62cm),
      print-icon: image("assets/folder-step-clipboard-black.svg", width: 0.62cm),
      number: [01],
      width: 5.9cm,
      front-height: 3.3cm,
      folder-height: 2.55cm,
      direction: rtl,
    )
  ]
]
