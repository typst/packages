// evaluation.typ (farfadet-exo) — FAÇADE publique des compétences et de l'évaluation
// (bfcours-competencies.sty, bfcours-commands.sty, bfcours-exoplus.sty). Moteur : moteur/evaluation.typ.
// Tous les réglages passent par `setrdexo` (types `competences`, `tableau-eval`, `chrono`…, clé `emoji`).

#import "../../socle/lib.typ": interne as _socle
#import _socle: environnements, decouper-items, item-corps
#import "moteur/evaluation.typ" as _m
#import "moteur/exo.typ" as _x

/// Lignes d'un tableau de compétences. Syntaxe commande : les arguments positionnels, tels quels.
/// Syntaxe environnement : UN SEUL corps dont les lignes sont des items `-` (une compétence par item) ;
/// le code d'une compétence ne s'écrit alors qu'avec la syntaxe commande (`competence(code: …)`).
#let _lignes(items) = {
  let pos = items.pos()
  if pos.len() != 1 or type(pos.first()) != content { return pos }
  let c = environnements(pos.first())
  let a-items = c.func() == list.item or (c.has("children") and c.children.any(x => x.func() == list.item))
  if a-items { decouper-items(c, puce: "-").map(item-corps) } else { (c,) }
}

// =====================================================================
// Compétences
// =====================================================================

/// Ligne d'un tableau de compétences (\competence[code]{texte}) : puce, intitulé, code encadré à droite.
///
/// ```example
/// #tableaucompetence(competence[Reconnaître une fonction affine], competence(code: "C2")[Calculer une image])
/// ```
///
/// - code (str, content, none): code de la compétence, encadré à droite. Défaut : none.
/// - corps (content): intitulé.
/// -> dictionary
#let competence(code: none, corps) = _m.competence(code: code, environnements(corps))

/// Tableau « Compétences travaillées » (\tableaucompetence) : une ligne par compétence et quatre
/// colonnes d'auto-évaluation MI, MF, MS, TBM. Les titres et en-têtes se règlent par
/// `setrdexo(pour: "competences", …)`.
///
/// ```example
/// #tableaucompetence(competence[Résoudre une équation], competence(code: "C3")[Justifier])
/// ```
///
/// La syntaxe environnement donne un tableau sans codes : `#begin(tableaucompetence)` puis une compétence
/// par item `-`, puis `#end(tableaucompetence)`.
///
/// - ..items (dictionary, content): lignes : `competence(…)` ou simples contenus ; ou un seul corps d'items `-`.
/// -> content
#let tableaucompetence(..items) = _m.tableaucompetence(.._lignes(items))

/// Tableau « Compétences évaluées » (\tableaucompetenceEval).
///
/// ```example
/// #tableaucompetence-eval(competence[Calculer], competence(code: "C2")[Raisonner])
/// ```
/// -> content
#let tableaucompetence-eval(..items) = _m.tableaucompetenceeval(.._lignes(items))

/// Index des compétences du document (\printcompindex) : un tableau « Compétences évaluées » dont les
/// lignes sont les compétences inscrites par les exercices (titres des EXO, étiquettes des EXOEVAL),
/// sans doublon.
///
/// ```example
/// #printcompindex()
/// ```
/// -> content
#let printcompindex() = _x.printcompindex()

// =====================================================================
// Évaluation
// =====================================================================

/// Cartouche d'évaluation (\tableauEval{durée}) : « Nom / Prénom » sur 3/4, « Durée » et chronomètre sur 1/4.
///
/// ```example
/// #tableau-eval(55)
/// ```
///
/// - duree (int): durée en minutes.
/// - colback, colframe (color, str), boxrule, arc (length), nom, prenom, duree (content), raster-columns (int), raster-column-skip, raster-row-skip (length): réglables (`setrdexo(pour: "tableauEval", …)`).
/// -> content
#let tableau-eval(duree, ..cles) = _m.bf-tableauEval(duree, ..cles)

/// Cartouche de projet (\tableauProjetEval{date}) : case de droite « Date de rendu : ».
///
/// ```example
/// #tableau-projet-eval[12 octobre]
/// ```
/// -> content
#let tableau-projet-eval(date, ..cles) = _m.bf-tableauProjetEval(date, ..cles)

/// Cartouche de sixième (\tableauPresenteEvalSixieme{…}{note max}) : « Nom / Prénom » et « Bilan : ▢ / note ▢ ».
///
/// ```example
/// #tableau-presente-eval-sixieme([], 20)
/// ```
///
/// - inutilise (any): premier argument LaTeX (sans effet).
/// - note (int, content): note maximale.
/// -> content
#let tableau-presente-eval-sixieme(inutilise, note, ..cles) = _m.bf-tableauPresenteEvalSixieme(inutilise, note, ..cles)

/// Chronomètre encadré « Durée : » (\chrono{minutes}).
///
/// ```example
/// #chrono(30)
/// ```
/// -> content
#let chrono(minutes, ..cles) = _m.bf-chrono(minutes, ..cles)

/// Cadran en surimpression (\overlaychrono{minutes}) : secteur jusqu'aux minutes, puis « minutes’ ».
///
/// ```example
/// Durée : #h(1cm) #overlaychrono(45) #h(2cm)
/// ```
///
/// - radius (length), color (color, str), opacity (float), line-width, circle-width, label-sep (length): réglables (`setrdexo(pour: "overlaychrono", …)`).
/// -> content
#let overlaychrono(minutes, ..cles) = _m.bf-overlaychrono(minutes, ..cles)

/// Niveau de maîtrise « Maîtrise insuffisante » (\mi) : émoji, ou « MI » si `setrdexo(emoji: false)`.
///
/// ```example
/// #mi() #mf() #ms() #tbm()
/// ```
/// -> content
#let mi() = _m.mi()

/// « Maîtrise fragile » (\mf).
///
/// ```example
/// #mf()
/// ```
/// -> content
#let mf() = _m.mf()

/// « Maîtrise satisfaisante » (\ms).
///
/// ```example
/// #ms()
/// ```
/// -> content
#let ms() = _m.ms()

/// « Très bonne maîtrise » (\tbm).
///
/// ```example
/// #tbm()
/// ```
/// -> content
#let tbm() = _m.tbm()
