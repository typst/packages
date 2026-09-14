#import "@preview/qualitree:0.1.0": qfd
#import "milk-data.typ": automatic-diff, automatic-component-diff
#set page(width: auto, height: auto, margin: 8mm)
#set text(font: ("IBM Plex Sans", "New Computer Modern"), size: 9pt, lang: "fr")
#text(size: 16pt, weight: "bold")[Option B · lait réfrigéré et préparation automatique]
#v(2mm)
#block(width: 200mm)[Comparaison avec la même machine à café initiale. Disposer de lait entre les utilisations ajoute le stockage froid et le dosage automatique. Nettoyage et encombrement doivent être réévalués.]
#v(3mm)
#qfd(..automatic-diff, width: auto, what-width: 58mm)
#pagebreak()
#text(size: 16pt, weight: "bold")[Option B · conséquences sur les composants]
#v(2mm)
#block(width: 200mm)[Le réservoir réfrigéré, le circuit lait et le mélangeur demandent des commandes coordonnées, un accès pour le nettoyage et une protection adaptée. Les deux options sont des concepts à étudier, pas un classement de performances mesurées.]
#v(3mm)
#qfd(..automatic-component-diff, width: auto, what-width: 58mm)
