#import "../lib.typ": risk, risk-matrix, example-policy
#set page(paper: "a4", margin: 18mm)
#set text(lang: "fr", font: "Libertinus Serif")

#let risks = (
  risk("R1", "Interruption du service", 3, 3),
  risk("R2", "Divulgation d'informations", 4, 2),
)

= Matrice de risques
#risk-matrix(risks, policy: example-policy)
Politique de démonstration : à adapter au contexte de l'étude.
