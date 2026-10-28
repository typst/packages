#import "@local/stacked:0.2.0":*
#set page(width:14.5cm, height: auto, margin:10pt)

// = Cube simple

// #canvas(z:(-.5,-.5),{
//   import draw:*
//   cube((),c:(teal,blue,gray),border-stroke: white)
// })

= pile

// #pile(5214,5111,2101,2,2, iso: false,side: true,grids: true,solution: true,back-separation: 6.5,left-separation: 2.5)

#pile((54321, 3112, 2112, 11111,purple),border-stroke: true,side: true,light:(15%,0%,40%))#h(1fr)
// side: true, grids:true,below-separation: 3,back-separation: 4.8,left-separation: 2.5
#pile(54321, 3112, 2112, 11111,z-spread: 0,iso:true,below-separation: 5)#h(1fr)
//side: true,grids:true,below-separation: 4.2,back-separation: 3,left-separation: 3.2, plan: true,

// #building((31670104,23312300,20111200),(11100000,2100000),30200000,color-list: (aqua.mix(blue),red, green,yellow,blue,eastern, purple),border-stroke: true,)

== Disposition des vues "3d" ou ""

#h(1fr)#pile(54321,3212,3212,11111,none,grids:true,solution: true,back-separation: 4,left-separation: 4,plan: true,iso:1,)#h(1fr)
#pile(54321,3212,3212,11111,eastern.mix(teal),border-stroke: true,iso:false, shadow: false,disposition: "",grids: true,solution: true,plan: true)
// grids:true,solution: true,back-separation: 4,axes: true
// opacity: 70%,side: true

= Aléatoire
// Mode aléatoire par défaut (3 x 4 x 5)
// Mode aléatoire personnalisé avec graine fixée pour changer de tirage
// #pile(random: true, width: 4, depth: 3, height: 6, seed: 42,side: true,random-mode: 1) //2

#pile(random-mode: 4, plan: true,)
#pile(random: true, width: 4, depth: 3, height: 6, seed: 2,side: true,random-mode: 2,plan: true,) //2
// 2. Mode aléatoire avec Plan de niveau
// #pile(random: true, plan: true, seed: 22,hauteur: 5,random-mode: 1)
// 2. Mode aléatoire avec Plan de niveau
#pile(aleatoire: true, plan: true, seed: 5,hauteur: 5,random-mode: 2,)
// 2. Mode aléatoire avec Plan de niveau
#pile(aleatoire: true, plan: true, seed: 3,random-mode: 3,hauteur: 5)

= Empilement et vues


#let construct-param = (color-list: (aqua.mix(blue),red, green,yellow,blue,eastern, purple),border-stroke: true,)
#let construct = ((31670104,23312300,20111200),(11100000,2100000),30200000,)

#building((("21111","xooox","10001","10001","11111"),
  ("30001",0,0,0,"10001"),
  ("40001",0,0,0,"1000g"),
  ("50001",0,0,0,"1000f"),
  ("61111","70001",80001,"90001","abcde")),)#h(1fr)
#building(..construct,..construct-param,box-args: (baseline:-30%,))#h(1fr)
#above-view(..construct,..construct-param)#h(1fr)
#below-view(..construct,..construct-param)

#right-view(..construct,..construct-param)#h(1fr)
#left-view(..construct,..construct-param)#h(1fr)
#front-view(..construct,..construct-param)#h(1fr)
#back-view(..construct,..construct-param)#h(1fr)




// Mode aléatoire personnalisé avec graine fixée pour changer de tirage
// #pile(random: true, seed: 42)
// #pile(random: true, width: 4, depth: 3, height: 6, seed: 42,random-mode: 1)

// // 1. Vue 3D + Plan de niveau 2D
// #pile("321", "210", plan: true)

// // 2. Mode aléatoire avec Plan de niveau
// #pile(random: true, plan: true, seed: 12)

// // 3. Avec grilles de projection et plan de niveau inscrit dans la vue de dessus
// #pile("43", "21", grids: true, solution: true, plan: true)



