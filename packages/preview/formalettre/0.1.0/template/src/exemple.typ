#import "@preview/formalettre:0.1.0": *

#set text(lang: "fr")

#show: lettre.with(
expediteur: (
  nom: "de La Boétie",
  prenom: "Étienne",
  voie: "145 avenue de Germignan",
  complement_adresse: "",
  code_postal: "33320",
  commune: "Le Taillan-Médoc",
  telephone: "01 23 45 67 89",
  email: "etienne@laboetie.org",
  signature: "",
),
destinataire: (
  titre: "Michel de Montaigne",
  voie: "17 butte Farémont",
  complement_adresse: "",
  code_postal: "55000",
  commune: "Bar-le-Duc",
  sc: "",
),
lieu: "Camp Germignan",
objet: [Ceci est un objet de courrier.],
date: [le 7 juin 1559],
pj: "",


)

#lorem(200)