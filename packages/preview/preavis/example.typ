#import "lib.typ": lettre_preavis, locataire, adresse, proprietaire
#lettre_preavis(
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
  date_etat_des_lieux: datetime(year:2024, month:9, day:21)
)