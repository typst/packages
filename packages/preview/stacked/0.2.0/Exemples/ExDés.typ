#import "@local/stacked:0.2.0":*
#set page(width:14cm, height: auto, margin:10pt)
// #import "../Non/cetz-geo.typ": *

// set-transform((
//     (      calc.cos(ph)  * x-scale,      calc.sin(ph) * x-scale,  0,0),
//     (-calc.cos(th) * calc.sin(ph) , calc.cos(th) * calc.cos(ph),  calc.sin(th),0),
//     (0,0,1,0),
//     (0,0,0,1)
//   ))

// set-transform((
//     (-calc.sin(ph) * x-scale,         calc.cos(ph)  * x-scale,         0,0),
//     (-calc.cos(th) * calc.cos(ph), -calc.cos(th) * calc.sin(ph) ,calc.sin(th),0),
//     (0,0,1,0),
//     (0,0,0,1)
//   ))

#canvas({//x:35.264deg,y:45deg
  import draw:*  
  dice(standalone: false, origin: (0,2),front: 2,top:3,s:.8,vue: "D")
  repere
})

#dice(front: 2, top: 3, theta: 60,phi: 110, s: 1,opacity:60%,color: eastern,) 

= Dé seul
A simple die (front=1, top=2) and a red one with white dots viewed from the left:

#h(1fr) #dice(front: 2, top: 3, theta: 75,phi: 105, s: 1.5, vue: "D") 
#h(1fr)
// Un dé rouge tourné, avec une vue inversée (gauche)
#dice(front: 6, top: 5, color: red, s: 1.5, vue: "G", dot-color: white)#h(1fr) 

// Un dé standard (Face avant 3, dessus 1)
// #dice(front: 3, top: 1)

// Dé rouge plus petit, vu de Gauche
// #dice(front: 5, top: 3, color: red, s: .7, vue: "G")

= Lancers de dés
// Lancer de 5 dés aléatoires en mode classique
// #throws(5, seed: 567,)

// Lancer classique (aligné horizontalement) de 5 dés aléatoires :
Classic throw of 5 random dices :
#throws(5, seed: 42,colors:luma(25%),dot-color: white)

// Lancer mode Yams (accolés) avec liste de couleurs :
Yams mode throw of 4 dices with a list of colors :
#throws(
  4, 
  yams: true,
  yams-h: 0,
  // espace-h: 1mm,
  colors: (red, blue, green, yellow),
  seed: 987,
  s: 1.2,
  vue: "D"
)

Throw with chosen faces et view from the left:
// Lancer avec faces explicitement définies (pour du contrôle précis) et vue de gauche :
#throws(
  3,
  s: 1,
  list: ((1, 2), (6, 5), (4, 1)),
  espace-h: -1mm,
  colors: orange,
  vue: "D"
)

// Lancer classique (aligné horizontalement) de 5 dés aléatoires
// #throws(5, seed: 42,colors:luma(25%),dot-color: white)

// Lancer style Yams (alignement en diagonale 3D partagée) avec couleurs mélangées
Yams mode throw of 5 dices with a list of colors :
#throws(
  5, 
  yams: true, 
  colors: (rgb("ef476f"), rgb("ffd166"), rgb("06d6a0"), rgb("118ab2"), rgb("073b4c")), 
  seed: 999, 
  s: 1.2,
  yams-h: -.15,
  opacity: 70%,
)

= Dés en 2d from eric1102
// // #set text(font: "Noto Color Emoji")

// \u{2680} \u{2681} \u{2682} \u{2683} \u{2684} \u{2685}

#for n in range(1, 7) { dice-face(n) + h(2pt) } #h(1fr)
#for n in range(1, 7) { dice-face(n, fill: black) + h(2pt) } #h(1fr)
#for n in range(1, 7) { dice-face(n, fill: yellow) + h(2pt) } #h(1fr)
#for n in range(1, 7) { dice-face(n, spot-fill: red) + h(2pt) }

#set text(fill: blue)
The die #dice-face(1) shows the number 1.#h(1fr) 
$#dice-face(3) + #dice-face(2) = #dice-face(5)$ #h(1fr)