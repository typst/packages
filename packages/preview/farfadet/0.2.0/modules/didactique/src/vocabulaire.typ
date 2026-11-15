// vocabulaire.typ (farfadet-didactique) — façade de bfcours-vocabulary.sty (\voc, \printvocindex),
// de \vocref (bfcours-commands) et du tableau de vocabulaire de bfcours-exoplus.

#import "moteur/vocabulaire.typ" as m
#import "../../socle/lib.typ": interne as _socle
#import _socle: bf-couleur-nommee

/// Mot de vocabulaire (`\voc{mot}`) : en gras, à la couleur d'accent courante, et noté pour l'index
/// du vocabulaire (`printvocindex`). Seule la première occurrence d'un même mot compte.
///
/// ```example
/// On appelle #voc[hypoténuse] le côté opposé à l'angle droit.
/// ```
///
/// - mot (content, str): le mot défini.
/// -> content
#let voc(mot) = m.voc(mot)

/// Boîte « Vocabulaire utilisé » (`\printvocindex`) : tous les mots passés à `voc`, en gras, avec
/// leur page (lien cliquable). À placer en fin de chapitre.
///
/// ```example
/// #printvocindex(colonnes: 2)
/// ```
///
/// - colonnes (int): nombre de colonnes (ajout ; LaTeX : `\badprintvocindex[colonnes=3]`). Défaut : `3`.
/// - titre (content): titre de la boîte. Défaut : `[Vocabulaire utilisé]`.
/// - colframe (color, str, auto): cadre et bandeau de titre. `auto` : blue!50!black.
/// - colback (color, str, auto): fond. `auto` : gray!10 (gray!5 si la liste est vide).
/// - coltitle (color, str): texte du titre. Défaut : `white`.
/// -> content
#let printvocindex(colonnes: 3, titre: [Vocabulaire utilisé], colframe: auto, colback: auto, coltitle: white) = m.printvocindex(
  colonnes: colonnes,
  titre: titre,
  colframe: colframe,
  colback: colback,
  coltitle: coltitle,
)

/// Mot en gras rose (la couleur nommée `monrose`, lue au rendu : `setbfcolors(monrose: …)`), lien vers
/// une adresse (`\vocref{url}{mot}`). En LaTeX le mot va aussi à l'index de makeidx, que bfcours
/// n'imprime pas : ce dépôt n'est pas porté. (`\vocnoindexref`, identique en Typst, n'existe plus.)
///
/// ```example
/// #vocref("https://fr.wikipedia.org/wiki/Hypoténuse")[hypoténuse]
/// ```
///
/// - cible (str, label, location): adresse ou étiquette du lien.
/// - mot (content): le mot.
/// -> content
#let vocref(cible, mot) = context link(cible, text(weight: "bold", fill: bf-couleur-nommee("monrose"), mot))

#let _crayon = box(height: 0.8em, baseline: 0.1em, image("moteur/icones/bccrayon.svg"))

/// Tableau de révision du vocabulaire (`\tableauVocabulaireSommaire`) : une ligne par mot (le mot est
/// précédé d'un crayon), colonnes « Vu en classe le », « Définition apprise le », « Prêt ». (Les lignes
/// `\vocabulaireSommaire{mot}` de LaTeX deviennent simplement les mots.)
///
/// ```example
/// #tableau-vocabulaire-sommaire[hypoténuse][cathète]
/// ```
///
/// - mots (content): un contenu par mot de vocabulaire.
/// -> content
#let tableau-vocabulaire-sommaire(..mots) = {
  parbreak()
  [Dans le tableau suivant, remplir les cases pour t'aider dans tes révisions.]
  parbreak()
  // En-têtes sans justification (pas d'espaces étirés) et coupés en fin de ligne : dans une colonne
  // étroite, « l'évaluation » sortait de sa case.
  show table.cell.where(y: 0): set par(justify: false)
  show table.cell.where(y: 0): set text(hyphenate: true)
  table(
    columns: (30%, 20%, 20%, 20%),
    align: (left + horizon, center + horizon, center + horizon, center + horizon),
    table.header(
      align(center, strong[Vocabulaire à connaître]),
      strong[Vu en classe le :],
      strong[Définition apprise le :],
      // `-?` : césure facultative, que la coupure automatique ne trouve pas après l'apostrophe
      strong[Coche si tu es prêt pour l'éva-?luation],
    ),
    ..mots.pos().map(mot => ([#_crayon #mot], [], [], [])).flatten(),
  )
}
