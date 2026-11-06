// rdmcq.typ (farfadet-qcm, façade) — noms publics du portage de rdmcq.sty (Régis Deleuze) et du format
// BFCours (rdmcq.bfcours.format.sty) : `mcq`, `mcq-quest` et le setter unique `setrdmcq`. Clés = options
// /rdmcq/, /rdmcqcb/, /rdmcqrb/ (espaces → tirets). Le moteur est dans moteur/ (exporté par interne.typ).
//
// Les formats se choisissent par la clé `style:` (ou `format:`) de `mcq` et de `setrdmcq`.

#import "../../socle/lib.typ": interne as _socle
#import _socle: reglages-regler, reglages-reinitialiser, reglages-definir-style, reglages-verifier, environnements
#import "moteur/boite.typ": mcq-verifier-style, mcq-tcb-controles
#import "moteur/cases.typ": registre-rdmcqcb, registre-rdmcqrb
#import "moteur/mcq.typ": registre-mcq, mcq-raccourcis, mcq-environnement, mcq-question
#import "vrai-faux.typ": registre-vrai-faux

// =====================================================================
// Réglage : un seul setter
// =====================================================================

#let _registres = (Mcq: registre-mcq, rdmcqcb: registre-rdmcqcb, rdmcqrb: registre-rdmcqrb, "vrai-faux": registre-vrai-faux)

/// Setter unique du paquet (`\setrdmcq{…}`, `\setrdmcqcb{…}`, `\setrdmcqrb{…}` de rdmcq, plus le réglage de
/// `vrai-faux`). `pour:` choisit ce qu'on règle : `"Mcq"` (défaut : les clés /rdmcq/ de `mcq`), `"rdmcqcb"`
/// (cases à cocher des formats), `"rdmcqrb"` (boutons radio des formats) ou `"vrai-faux"`. Les appels
/// s'ajoutent clé par clé. Un format se choisit par `style: "Boston"` (ou `format: "Boston"`, qui pose les deux
/// formats partiels d'un coup) : formats `"default"`, `"Troyes"`, `"Tokyo"`, `"Boston"`, `"Miami"`, `"Reims"`,
/// `"Millau"`, `"Melun"`, `"Paris"` et `"BFCours"`.
///
/// ```example
/// #setrdmcq(orientation: "vertical", question-width: 6cm)                // réglage global de Mcq
/// #setrdmcq(pour: "rdmcqcb", color: blue)                                // cases à cocher des formats
/// #setrdmcq(pour: "vrai-faux", cases: "rond")                            // vrai-faux
/// #setrdmcq(definir: "serre", row-sep: 2pt, column-sep: 2pt, style: "Reims") // style nommé
/// #setrdmcq(reinitialiser: true)                                         // retour aux défauts
/// ```
///
/// - pour (str, none): `"Mcq"`, `"rdmcqcb"`, `"rdmcqrb"` ou `"vrai-faux"` ; `none` : `"Mcq"` (et, pour `reinitialiser`, les quatre). Défaut `none`.
/// - reinitialiser (bool, str): `true` : repart des défauts de rdmcq avant d'appliquer les clés (styles nommés gardés) ; `"tout"` : ramène aussi les styles nommés aux formats prédéfinis. Défaut `false`.
/// - definir (str, none): nom d'un style à définir avec les clés données (`pour: "Mcq"` ou `"vrai-faux"`) ; on l'appelle ensuite par `style: "nom"` (dans `mcq`, `setrdmcq`, `vrai-faux`). Défaut `none`.
/// - cles (any): pour `"Mcq"` : clés /rdmcq/ (`orientation`, `question-width`, `row-sep`, `format`, `style`…, voir `mcq`) ; pour `"rdmcqcb"` et `"rdmcqrb"` : `size`, `color`, `raise`, `check-symbol`, `check-color`, `checked`, `background-color` (défauts `0.9em`/`1.3em`, `black`, `red`) ; pour `"vrai-faux"` : voir `vrai-faux`.
/// -> content
#let setrdmcq(pour: none, reinitialiser: false, definir: none, ..cles) = {
  if cles.pos().len() > 0 { panic("setrdmcq : seuls des arguments nommés sont acceptés ; reçu : " + repr(cles.pos().first()) + ".") }
  if reinitialiser not in (true, false, "tout") {
    panic("setrdmcq : la clé « reinitialiser » attend true, false ou \"tout\" ; reçu : " + repr(reinitialiser) + ".")
  }
  let cible = if pour == none { "Mcq" } else { pour }
  if cible not in _registres {
    panic("setrdmcq : valeur invalide pour la clé « pour » : " + repr(pour) + ". Valeurs possibles : « Mcq », « rdmcqcb », « rdmcqrb » ou « vrai-faux ».")
  }
  let registre = _registres.at(cible)
  let d = cles.named()
  if cible == "Mcq" {
    d = mcq-raccourcis(d)
    for (k, v) in d {
      if type(v) == dictionary and (k.starts-with("every-") or k == "boxstyle") { mcq-verifier-style("setrdmcq (" + k + ")", v) }
    }
  }
  if definir != none {
    if cible not in ("Mcq", "vrai-faux") {
      panic("setrdmcq : « definir » s'emploie avec pour: \"Mcq\" (défaut) ou pour: \"vrai-faux\" ; les cases « " + cible + " » n'ont pas de style nommé (réglez-les par clés).")
    }
    return reglages-definir-style(registre, definir, commande: "setrdmcq", ..d)
  }
  if reinitialiser != false {
    for r in (if pour == none { _registres.values() } else { (registre,) }) {
      reglages-reinitialiser(r, styles: reinitialiser == "tout")
    }
  }
  reglages-regler(registre, ..d)
}

// =====================================================================
// Environnement et commandes
// =====================================================================

/// Questionnaire à choix multiples (`\begin{Mcq}[…] … \end{Mcq}`) : contient des `mcq-quest`. Version
/// professeur : les bonnes réponses (`br`) sont mises en valeur selon le format. La teinte des bonnes
/// réponses du format `"BFCours"` est une couleur nommée de bfcours (`prop`) : `setbfcolors` la change.
///
/// ```example
/// #mcq(question-width: 6cm)[
///   #mcq-quest(br: 2)[Combien font $2 + 2$ ?][3][4][5]
/// ]
/// ```
///
/// - orientation (str): `"horizontal"` (réponses côte à côte) ou `"vertical"` (les unes sous les autres). Défaut `"horizontal"`.
/// - resume (bool): poursuit la numérotation du Mcq précédent. Défaut `false`.
/// - num-start (int): numéro de la première question. Défaut `1`.
/// - width (length, auto): largeur totale. Défaut `auto` (largeur de ligne).
/// - question-width (length): largeur de la zone des questions. Défaut `8.5cm`.
/// - same-width (bool): zone des réponses sous la question, sur toute la largeur. Défaut `false`.
/// - boxrule (length): épaisseur des cadres. Défaut `0.6pt`.
/// - column-sep (length): écart entre zone question et zone réponses (`0pt` : cadres chevauchés). Défaut `0pt`.
/// - row-sep (length): écart entre les rangées (`0pt` : cadres chevauchés). Défaut `0pt`.
/// - question-answer-sep (length, auto, function): écart question/réponses avec `same-width`. Défaut `auto` (= row sep).
/// - answer-column-sep (length, auto): écart entre réponses voisines (`≤ 0` : chevauchement). Défaut `auto` (= column sep).
/// - answer-row-sep (length): écart vertical entre réponses. Défaut `0pt`.
/// - answer-columns (int): colonnes de réponses en orientation verticale (`0` : automatique). Défaut `0`.
/// - format (str): pose les deux formats partiels (questions, réponses) d'un coup (nom de format). Défaut `none`.
/// - question-format (str): format des questions. Défaut `"default"`.
/// - answer-format (str): format des réponses. Défaut `"default"`.
/// - style (str, array): format(s) global(aux) ou style(s) nommé(s) : `"Troyes"`, `"Tokyo"`, `"Boston"`, `"Miami"`, `"Reims"`, `"Millau"`, `"Melun"`, `"Paris"`, `"BFCours"`, ou un style défini par `setrdmcq(definir: …)`.
/// - boxstyle (dictionary): style tcb de la boîte englobante (`before-skip`, `after-skip`, `colback`, `boxrule`, `breakable`…). Défaut `(:)`.
/// - correction (bool, auto): mode correction. Défaut `auto` (version professeur).
/// - colback (color, str): raccourci : fond des zones question et réponses.
/// - colframe (color, str): raccourci : cadre des deux zones.
/// - opacityback (float): raccourci : opacité du fond des deux zones.
/// - question-colback (color, str, none): fond de la zone des questions. Défaut `none` (selon le format).
/// - question-colframe (color, str, none): cadre de la zone des questions. Défaut `none`.
/// - question-opacityback (float, none): opacité du fond des questions. Défaut `none`.
/// - answer-colback (color, str, none): fond des réponses (zone et boîtes). Défaut `none`.
/// - answer-colframe (color, str, none): cadre des réponses. Défaut `none`.
/// - answer-opacityback (float, none): opacité du fond des réponses. Défaut `none`.
/// - every-question-zone (dictionary): style tcb ajouté à toutes les zones de question. Défaut `(:)`.
/// - every-question (dictionary): style tcb de la boîte interne de toutes les questions. Défaut `(:)`.
/// - every-answer-zone (dictionary): style tcb de toutes les zones de réponses. Défaut `(:)`.
/// - every-answer (dictionary): style tcb de toutes les réponses. Défaut `(:)`.
/// - every-odd-question-zone (dictionary): zones de question des rangées impaires. Défaut `(:)`.
/// - every-even-question-zone (dictionary): zones de question des rangées paires. Défaut `(:)`.
/// - every-odd-answer-zone (dictionary): zones de réponses des rangées impaires. Défaut `(:)`.
/// - every-even-answer-zone (dictionary): zones de réponses des rangées paires. Défaut `(:)`.
/// - every-odd-answer (dictionary): réponses des rangées impaires. Défaut `(:)`.
/// - every-even-answer (dictionary): réponses des rangées paires. Défaut `(:)`.
/// - every-odd-row (dictionary): raccourci : les trois clés `every-odd-…`.
/// - every-even-row (dictionary): raccourci : les trois clés `every-even-…`.
/// - answer (dictionary): style tcb par numéro de réponse, `("3": (colback: gray))`. Défaut `(:)`.
/// - counter-format (function): présentation du numéro de question (`\renewcommand{\rdmcqCounterFormat}`). Défaut : pastille noire.
/// - corps (content): les questions.
/// -> content
#let mcq(..args) = {
  let pos = args.pos()
  if pos.len() != 1 {
    panic("mcq : un seul contenu est attendu, par exemple #mcq(…)[#mcq-quest(br: 1)[Question][A][B]] ; reçu : " + str(pos.len()) + " contenus.")
  }
  // le corps passe par `environnements` : `#begin(mcq) … #end(mcq)` et les environnements imbriqués fonctionnent
  mcq-environnement(mcq-raccourcis(args.named()), environnements(pos.first()))
}

#let _cles-quest = ("br", "answer-zone", "answer", "points", "boite")

/// Une question et ses réponses (`\McqQuest[…]{question}{rép1, rép2, …}`). Le premier contenu est la
/// question, les suivants sont les réponses (ou un tableau de réponses). Les clés inconnues de rdmcq sont
/// des clés tcb de la zone externe de la question.
///
/// ```example
/// #mcq(same-width: true)[
///   #mcq-quest(br: (1, 3), answer: ("2": (colback: luma(220))))[Quels nombres sont pairs ?][2][3][4]
/// ]
/// ```
///
/// - br (int, array): numéro(s) des bonnes réponses (à partir de 1). Défaut `0` (aucune).
/// - answer-zone (dictionary): style tcb local de la zone des réponses. Défaut `(:)`.
/// - answer (dictionary): style tcb par réponse, `("2": (colback: gray))` (`answer 2/.style`). Défaut `(:)`.
/// - points (int, float, none): barème de la question (ajout bfcours). Défaut `none`.
/// - boite (bool, auto): boîte « n pts » à droite de l'énoncé (ajout). Défaut `auto` (suit `displayitempoints`).
/// - question (content): la question.
/// - reponses (content, array): les réponses possibles.
/// -> content
#let mcq-quest(..args) = {
  let pos = args.pos()
  if pos.len() < 1 { panic("mcq-quest : la question est attendue, par exemple #mcq-quest(br: 1)[Question][A][B].") }
  let question = pos.first()
  let reps = pos.slice(1)
  if reps.len() == 1 and type(reps.first()) == array { reps = reps.first() }
  let o = args.named()
  let br = o.remove("br", default: 0)
  let zone = o.remove("answer-zone", default: (:))
  let styles = o.remove("answer", default: none)
  let points = o.remove("points", default: none)
  let boite = o.remove("boite", default: auto)
  if not (type(br) == int or (type(br) == array and br.all(x => type(x) == int))) {
    panic("mcq-quest : valeur invalide pour la clé « br » : " + repr(br) + ". Valeurs possibles : un entier ou un tableau d'entiers (numéros des bonnes réponses).")
  }
  // clés restantes : clés tcb de la zone question (le message d'erreur liste aussi les clés propres)
  let controles = (:)
  for k in _cles-quest { controles.insert(k, (v => true, "")) }
  let _ = reglages-verifier("McqQuest", o, controles + mcq-tcb-controles)
  mcq-verifier-style("McqQuest (answer-zone)", zone)
  if styles != none {
    if type(styles) != dictionary { panic("mcq-quest : la clé « answer » attend un dictionnaire (\"n\": style tcb).") }
    for (n, s) in styles { mcq-verifier-style("McqQuest (answer \"" + n + "\")", s) }
  }
  let justes = if type(br) == int { if br > 0 { (br,) } else { () } } else { br }
  mcq-question(question, reps, justes: justes, local: o, zone: zone, styles: styles, points: points, boite: boite)
}
