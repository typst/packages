#import "../utils/fonts.typ": 字体, 字号

#page(paper: "a4", margin: (top: 2cm+0.5cm, bottom: 2cm+0.5cm, left: 2cm + 0.5cm, right: 2cm))[
  #v(80pt-0.5cm)
  #set text(font: 字体.宋体, size: 字号.小四)
  #align(right, image("../assets/statement-bachelor.svg", width: 468pt)) 
  // 小四字号 39em -> 468pt
]