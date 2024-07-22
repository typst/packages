od#set text(lang: "fr")
// le complément est optionnel
#let adresse(rue, codepostal, ville, complement: "") = (
  rue: rue,
  complement: complement,
  codepostal: codepostal,
  ville: ville
)
// Formatte bien l'adresse
#let affiche-adresse(adresse) = {
  [
  #adresse.rue \
  ]
  if adresse.complement != "" {
    [
      #adresse.complement \
    ]
  }
  adresse.codepostal + " " + adresse.ville
}
#let date-en-francais(date) = {
  // Liste d'associations mois anglais -> français
  let mois = (
    "1": "janvier",
    "2": "février",
    "3": "mars",
    "4": "avril",
    "5": "mai",
    "6": "juin",
    "7": "juillet",
    "8": "août",
    "9": "septembre",
    "10": "octobre",
    "11": "novembre",
    "12": "décembre"
  )

  let day = str(date.day())
  let month = date.month()
  let year = str(date.year())

  day + " " + mois.at(str(month)) + " " + year
}
#let locataire(nom, prenom, adresse) = (
  nom: nom,
  prenom: prenom,
  adresse: adresse
)

#let proprietaire(nom, prenom, adresse, genre) = (
  nom: nom,
  prenom: prenom,
  adresse: adresse,
  genre: genre
)


#let lettre-preavis(
  locataire: locataire,
  proprietaire: proprietaire,
  date-etat-des-lieux: datetime
) = {
  // En-tête locataire
  align(left)[
    #locataire.prenom #locataire.nom \
    #affiche-adresse(locataire.adresse)
  ]

  v(2cm)

  // En-tête propriétaire
  align(right,box()[
      #align(left)[
      #proprietaire.prenom #proprietaire.nom \
      // Gère le complément d'adresse qui est optionnel
      #affiche-adresse(proprietaire.adresse)
  ]])

  v(1cm)

  align(left)[
    Objet : demande de congé de logement \
    Lettre recommandée avec avis de réception
  ]
  v(0.5cm)
  // Apostrophe
  align(left)[
    #proprietaire.genre,
  ]
    v(0.2cm)
// Annonce de départ
par[Nous allons prochainement quitter notre logement. Celui-ci se trouve en zone tendue. // TODO(derniere phrase devrait etre fonction de l'adresse)
]

// Rapel de la loi
par[Conformément à la loi n° 89-462 du 6 juillet 1989 (article 15) et au décret n° 2013-392 relatif au
champ d'application de la taxe annuelle sur les logements vacants instituée par l'article 232 du
code général des impôts (premier tableau en annexe du décret), le préavis dans cette situation
est d'un mois.]

// TODO : fonction de zone tendue
par[Le congé prendra effet 1 mois après la date d'accusé de réception du courrier recommandé.]

par[Afin de convenir ensemble d'une date pour vous remettre les clés du logement et réaliser
ensemble l'état des lieux, nous vous informons que le déménagement est prévu le #date-en-francais(date-etat-des-lieux)
] // Salutations TODO : fix date
par[Veuillez agréer, #proprietaire.genre, l'expression de nos salutations distinguées.]

v(1cm)
// Lieu et date d'écriture
align(right)[
  //#let ville = #locataire.adresse.ville
  #locataire.adresse.ville
  le #date-en-francais(datetime.today())
]

// Signature
v(2cm)
align(right)[
  #locataire.prenom #locataire.nom
]
}


