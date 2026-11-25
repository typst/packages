#import "@preview/na-courbe:0.1.0": courbe, integrale, papier-milli
#set text(dir: ltr)

// 1) دالة كسرية: فروع، مقارب مسمّى، مماس، نقطة بإسقاطات
#align(center, courbe(
  x => (x * x - 1) / (x - 2),
  branches: ((-4, 1.9), (2.1, 12)),
  x: (-4, 12), y: (-5, 12),yunite:0.7cm,xunite:0.7,
  nom: $C_f$, nom-pos: (3.2, 4.6),
  va: ((v: 2, nom: $x = 2$, nom-pos: (2.4, 7)),),
  tangente: (a: 0, nom: $T$),
  droites: ((a: 1, b: 2, couleur: red,
nom: $y = x + 2$,nom-pos: (7, 7.6)),),
  points: ((v: 0, nom: $A$, proj: true),),
  xlabel: $x$, ylabel: $y$, origine: $O$,
))

// 2) شبكة رئيسية وثانوية منقطة + تدريجات بأطوال مختلفة
#align(center, courbe(
  x => x * x / 2, domain: (-3, 3), x: (-3, 3), y: (-1, 5), size: (8, 5),
  grille: "toutes", xminor: 0.5, yminor: 0.5, grille-trait: "pointille",
  xtick: 0.3, ytick: 0.12, nom: $C_f$, nom-t: 0.9, nom-dy: 0.3,
))

// 3) ترقيم مثلثي
#align(center, courbe(
  x => calc.sin(x), domain: (-2 * calc.pi, 2 * calc.pi),
  x: (-2 * calc.pi, 2 * calc.pi), y: (-1.5, 1.5), echelle: (0.9, 2.2),
  xnum: "pi", xpi: 2, nom: $sin x$, nom-t: 0.62, nom-dy: 0.3, origine: $O$,
))

// 4) ورقة مليمترية: خطوط كل 1 مم و5 مم و1 سم بالطول الفعلي للمحورين
#align(center, courbe(
  x => x * x / 4 - 1, domain: (-4, 4), x: (-4, 4), y: (-2, 4),
  grille: "millimetre", nom: $C_f$, nom-t: 0.9, nom-dy: 0.3,
  xlabel: $x$, ylabel: $y$, origine: $O$,
))

// 5) ورقة مليمترية زرقاء بوحدات مختلفة على المحورين
#align(center, courbe(
  x => calc.sqrt(x), domain: (0, 8), x: (-1, 8), y: (-1, 4),
  grille: "millimetre", grille-couleur: blue, xunite: 1, yunite: 1.5,
  cadre: true, titre: [$y = sqrt(x)$], nom: $C_f$, origine: $O$,
))

// 6) ورقة فارغة
#align(center, papier-milli(x: (0, 10), y: (0, 6), grille-couleur: green))
