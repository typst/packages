// Visual review: one folder-shaped box per page, without the source grid.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 5.4cm, margin: 0.45cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #tabbed-folder-box(
    title: [KEY PRIORITY],
    body: [Keep related ideas together. Use this folder-style box for a concise summary, a priority, or a project update.],
    icon: image("assets/tabbed-folder-check-white.svg", width: 0.58cm),
    print-icon: image("assets/tabbed-folder-check-black.svg", width: 0.58cm),
    width: 8.2cm,
    body-height: 2.2cm,
    direction: ltr,
    colour: rgb("#E95548"),
  )
]

#pagebreak()
#set page(fill: rgb("#20252B"))
#align(center + horizon)[
  #tabbed-folder-box(
    title: [ملخّص التنفيذ],
    body: [اجمع الأفكار المترابطة في موضع واحد، واستخدم هذا الصندوق لعرض أولوية أو تحديث موجز عن المشروع.],
    icon: image("assets/tabbed-folder-check-white.svg", width: 0.58cm),
    print-icon: image("assets/tabbed-folder-check-black.svg", width: 0.58cm),
    width: 8.2cm,
    body-height: 2.2cm,
    direction: rtl,
    dark: true,
    colour: rgb("#24B7C8"),
  )
]

#pagebreak()
#set page(fill: white)
#print-group[
  #align(center + horizon)[
    #tabbed-folder-box(
      title: [KEY PRIORITY],
      body: [Keep related ideas together. Use this folder-style box for a concise summary, a priority, or a project update.],
      icon: image("assets/tabbed-folder-check-white.svg", width: 0.58cm),
      print-icon: image("assets/tabbed-folder-check-black.svg", width: 0.58cm),
      width: 8.2cm,
      body-height: 2.2cm,
      direction: ltr,
      colour: rgb("#E95548"),
    )
  ]
]

#pagebreak()
#print-group[
  #align(center + horizon)[
    #tabbed-folder-box(
      title: [ملخّص التنفيذ],
      body: [اجمع الأفكار المترابطة في موضع واحد، واستخدم هذا الصندوق لعرض أولوية أو تحديث موجز عن المشروع.],
      icon: image("assets/tabbed-folder-check-white.svg", width: 0.58cm),
      print-icon: image("assets/tabbed-folder-check-black.svg", width: 0.58cm),
      width: 8.2cm,
      body-height: 2.2cm,
      direction: rtl,
      colour: rgb("#E95548"),
    )
  ]
]
