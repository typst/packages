// One reusable peak-header box — dark RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 10cm, height: 6cm, margin: 0.45cm, fill: rgb("#20242A"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #peak-header-box(
    title: [تقدّم ملموس],
    body: [يمنح الإنجاز الواضح الفريق هدفاً مشتركاً ودافعاً لمواصلة التقدّم.],
    icon: image("assets/peak-header-bars-teal.svg", width: 0.62cm),
    print-icon: image("assets/peak-header-bars-black.svg", width: 0.62cm),
    number: [٠١],
    width: 5.0cm,
    height: 4.65cm,
    direction: rtl,
    dark: true,
    colour: rgb("#2E8EAA"),
  )
]
