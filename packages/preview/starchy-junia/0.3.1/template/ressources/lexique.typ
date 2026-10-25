// =============================================================================
// LEXIQUE — entrées du lexique du rapport
// =============================================================================
// Le lexique n'est affiché que si au moins une entrée est citée dans le texte
// avec `@cle` (ex : `@api`). Documentation complète du paquet utilisé :
// https://typst.app/universe/package/glossarium
//
// Champs d'une entrée :
//   key         : clé utilisée pour citer l'entrée avec `@cle` — obligatoire, sans espace
//   short       : forme courte affichée dans le texte, ex : "API" — obligatoire
//   long        : forme longue, affichée à la première citation, ex : "Application Programming Interface"
//   description : définition affichée dans le lexique
//   group       : groupe dans lequel ranger l'entrée, ex : "Sigles"
//   plural, longplural, artshort, artlong : pluriels et articles, facultatifs
//                 Le pluriel ajoute « s » par défaut : pour un sigle invariable, écrire plural: "API"
//
// Citations (syntaxe de glossarium) :
//   @api         forme longue et courte à la première citation, puis forme courte
//   @api:long    forme longue seule          @api:short   forme courte seule
//   @Api         majuscule initiale          @api:pl      pluriel
//
// Groupes conseillés :
//   Acronymes   : se prononcent comme un mot, ex : OTAN
//   Sigles      : ne se prononcent pas comme un mot, ex : SNCF
//   Définitions : mots définis dans le contexte du rapport
// =============================================================================

// Liste des entrées, transmise au modèle dans `squelette.typ` (`glossaire: v-liste-glossaire`)
#let v-liste-glossaire = (
  // Exemple — décommenter et adapter, puis citer avec `@api` dans une fiche :
  // (
  //   key:         "api",
  //   short:       "API",
  //   long:        "Application Programming Interface",
  //   description: [Interface permettant à deux logiciels de communiquer.],
  //   group:       "Sigles",
  // ),
)
