// typst.app/universe/package/glossarium
/*
Gestion des groupes dans le glossaire
Acronymes : Se prononce comme un mot, ex : OTAN
Sigles : NE se prononce PAS comme un mot : SNCF
Définitions : Mots définis dans le contexte du rapport
*/

/*
    key: "",
    short: "",
    artshort: none,
    long: "",
    artlong: none,
    plural: none,
    longplural: none,
    description: "",
    group: (""),
*/

#let v-liste-glossaire = (
  // Entrée exemple — à remplacer par vos propres définitions
  (
    key: "ex",
    short: "Ex.",
    artshort: "l'",
    long: "Exemple",
    artlong: none,
    plural: none,
    longplural: none,
    description: "Entrée exemple du glossaire — à remplacer par vos propres définitions.",
    group: ("Définitions"),
  ),
)
