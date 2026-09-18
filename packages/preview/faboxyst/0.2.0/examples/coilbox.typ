// faboxyst — coilbox / cahier: a spiral-notebook page with a pink frame
// and 3D coils, after the clip-art reference.
#import "@preview/faboxyst:0.2.0": *

#set page(paper: "a4", margin: (x: 1.4cm, y: 1.2cm), fill: white)
#set text(size: 10.5pt)
#show: faboxyst.with(theme: (lang: "fr", dir: ltr))

// The notebook box, like the clip-art: frame + spine + coils.
#coilbox(title: [Lundi 15 septembre], height: 9cm)[
  Chère journal,

  Aujourd'hui la classe a fabriqué des pancartes en bois pour la fête de
  fin d'année, puis nous avons relié nos feuilles au cahier à spirale.
  Le ressort rose et violet passe dans les œillets noirs, et le cadre
  arrondi borde toute la page.
]

#v(0.6cm)

// RTL: spine and coils mirror to the right.
#cahier(title: [دفتر اليوميات], width: 80%, direction: rtl)[
  الصفحة تُقلب من اليمين إلى اليسار، والسلك الوردي والبنفسجي على اليمين.
]
