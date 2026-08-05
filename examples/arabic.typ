// Right-to-left: the branches run anticlockwise and the text ranges right.
#import "../lib.typ": *
#set page(width: 18cm, height: auto, margin: 1cm)
#set text(font: ("Amiri", "DejaVu Sans"), size: 11pt, lang: "ar", dir: rtl)
#set par(justify: false)

#mindmap([*متوازي الأضلاع*], leaf-width: 4.0,
  branch(title: [تعريف])[رباعي أضلاعه المتقابلة متوازية.],
  branch(title: [خصائص])[الأضلاع المتقابلة متساوية.],
  branch(title: [المساحة])[$S = b times h$],
  branch(title: [القطران])[يتقاطعان في منتصفهما.],
  branch(title: [أخطاء])[الخلط بين القاعدة والارتفاع.],
)
