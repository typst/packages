// sprig 0.2.0 — blossom : la carte-fleur, en LTR et en RTL.
#import "@preview/sprig:0.2.0": *

#set page(width: 29.7cm, height: 21cm, margin: 0.7cm)
#set text(size: 9pt)

#blossom(
  [*Résoudre une équation*],
  petal: "wedge",
  numbering: "01",
  palette: "poster",
  branch(title: [*Observer*])[Lire l'énoncé, repérer les données utiles.],
  branch(title: [*Traduire*])[Écrire l'équation qui modélise la situation.],
  branch(title: [*Résoudre*])[Isoler l'inconnue, pas à pas.],
  branch(title: [*Vérifier*])[Remplacer la valeur trouvée.],
  branch(title: [*Conclure*])[Rédiger la réponse avec son unité.],
)

#v(1cm)

#blossom(
  [*الحساب الحرفي*],
  dir: rtl,
  petal: "petal",
  tint: 30%,
  palette: "cool",
  branch(title: [*المفردات*])[تحليل، نشر، اختزال],
  branch(title: [*الخصائص*])[التوزيع، التبادلية، الأولويات],
  branch(title: [*الطرائق*])[ميزان، شريط، تعويض],
  branch(title: [*الأهداف*])[حلّ المعادلات والبراهين],
)
