#import "@preview/verseatile:0.1.1": *

#show <poemtitle>: it => text(
  size: 14pt,
  weight: "medium",
  number-type: "old-style")[#smallcaps(it)]

#show-verse-numbers.update(true)
#show <verse-number>: set text(
  size: 8pt)
#verse-number-modulo.update(4)

#poem[Hor. carm. I, 26][

Musis amicus tristitiam et metus \
tradam protervis in mare Creticum \
portare ventis, quis sub Arcto \
rex gelidae metuatur orae,

quid Tiridaten terreat, unice \
securus. O quae fontibus integris \
gaudes, apricos necte flores, \
necte meo Lamiae coronam,

Piplea dulcis. Nil sine te mei \
prosunt honores; hunc fidibus novis, \
hunc Lesbio sacrare plectro \
teque tuasque decet sorores.

][0012]
