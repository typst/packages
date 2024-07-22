#import "@preview/simple-preavis:0.1.0": lettre-preavis, locataire, adresse, proprietaire

#lettre-preavis(
  locataire: locataire(
     "Dupont locataire",
     "Jean",
     adresse(
       "123 rue de la Paix",
       "75000",
       "Paris",
       complement: "Appartement 2"
    )
  ),
  proprietaire: proprietaire(
     "Martin proprietaire",
    "Sophie",
     adresse(
       "456 avenue des Champs-Élysées",
       "75008",
       "Paris"
    ),
    "Madame"
  ),
  date-etat-des-lieux: datetime(year:2024, month:9, day:21)
)