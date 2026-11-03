// One reusable folder-tab box — dark RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 5.4cm, margin: 0.45cm, fill: rgb("#20252B"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

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
