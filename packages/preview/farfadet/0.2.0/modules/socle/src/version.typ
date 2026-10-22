// version.typ (farfadet-socle) — version professeur / version élève du document.
//
// Auparavant, la version vivait dans l'état des zones de réponse (`bf-crep.correction`) et
// `sys.inputs.correction` était lu à trois endroits. Ici :
// - un état DÉDIÉ `bf-version` (booléen : true = version professeur) ;
// - `sys.inputs.correction` lu UNE SEULE FOIS (`correction-imposee`) ;
// - quand la version est imposée à la compilation (`--input correction=true|false`), tout réglage
//   écrit dans le document (modèle, `setrdcrep(correction: …)`, `regler-reponses(version: …)`)
//   est ignoré : une seule source, deux PDF.

/// Version imposée à la compilation : true, false, ou none si `--input correction=…` est absent.
#import "precoce.typ": bf-etat, bf-maj, bf-lire
#let correction-imposee = if "correction" in sys.inputs { sys.inputs.correction == "true" } else { none }

/// Version du document : true = professeur (avec corrections), false = élève, `auto` = celle du service
/// de compilation (`version.txt`), sinon professeur. L'état reste la seule source : farfadet-docs l'écrit
/// directement pour composer chaque volet d'un exemple, même quand la version est imposée.
#let bf-version-p = bf-etat("bf-version", if correction-imposee != none { correction-imposee } else { auto })
#let bf-version = bf-version-p.etat

/// Version imposée par le service de compilation (bfwatch) : `version.txt` à la racine du paquet, que
/// le service réécrit (« prof » ou « eleve ») entre deux compilations d'un même compilateur ; « auto »
/// dans le paquet installé. Lu à l'APPEL, jamais au niveau du module : changer le fichier ne refait que
/// les fermetures qui l'ont lu, pas l'évaluation des modules (la `Library`, donc `sys.inputs`, ne change pas).
#let version-service() = {
  let v = read("../version.txt").trim()
  if v == "prof" { true } else if v == "eleve" { false } else { none }
}

/// Version professeur ? À appeler dans un `context`.
/// L'état d'abord (valeur imposée, ou écrite par `set-correction` ou par un volet de farfadet-docs) ;
/// `version.txt` n'est lu que s'il vaut `auto` : le résultat ne dépend du fichier que dans ce cas.
#let est-correction() = {
  let v = bf-lire(bf-version-p)
  if v != auto { return v }
  let s = version-service()
  if s != none { s } else { true }
}

/// Bascule version élève / professeur à partir de cet endroit du document.
/// Sans effet quand la version est imposée par `--input correction=…` ou par le service.
#let set-correction(valeur) = if correction-imposee == none and version-service() == none { bf-maj(bf-version-p, valeur) }

/// \TFCorrection{si prof}{si élève} ; aussi \ifcorrection … \else … \fi.
#let tf-correction(vrai, faux) = context if est-correction() { vrai } else { faux }

// =====================================================================
// Ajouts : style des corrections (\SiCorrection*) et conditionnelle \ifcorrection
// =====================================================================
#import "reglages.typ": reglages-paquet, reglages-controles, reglages-resoudre
#import "couleurs.typ": couleurs, bf-xcolor, bf-nommee
#import "etat.typ": taille-latex, tailles-latex
#import "environnements.typ": environnements

#let _cles-police = ("size", "weight", "style", "font")

/// Réglages du socle (mécanisme générique, état « bfr-socle ») : couleur et police des corrections,
/// lues par \SiCorrection*. En LaTeX, `\setrdcrep{correction color=…, correction font=…}` (rdcrep) ;
/// bfcours pose `correction color=monrose, correction font=\large\bfseries` (URC:277).
/// farfadet-crep doit écrire ici (reglages-regler(bf-reglages-socle, …)) quand `setrdcrep` les change.
#let bf-reglages-socle = reglages-paquet(
  "socle",
  // défaut = couleur NOMMÉE monrose, lue au rendu : `setbfcolors(monrose: …)` la change (convention 2)
  (correction-color: bf-nommee("monrose"), correction-font: (size: "large", weight: "bold")),
  controles: (
    correction-color: reglages-controles.couleur-ou-nom,
    correction-font: (
      v => type(v) == function or (type(v) == dictionary and v.keys().all(k => k in _cles-police)),
      "une fonction (c => strong(c)) ou un dictionnaire de clés " + _cles-police.map(k => "« " + k + " »").join(", ")
        + " (size : nom LaTeX comme \"large\" ou longueur)",
    ),
  ),
  commande: "setbfsocle",
)

/// Écrit `corps` dans la police (et, si `couleur`, la couleur) des corrections ; `r` : réglages résolus
/// (clés `correction-color`, `correction-font`). Équivaut à \color{crepcorrectioncol}\crep@correction@font.
/// À appeler dans un `context`.
#let bf-police-correction(r, corps, couleur: true, commande: "SiCorrection") = {
  let f = r.correction-font
  let fill = if couleur { bf-xcolor(r.correction-color, commande: commande) } else { none }
  if type(f) == function { return if couleur { text(fill: fill, f(corps)) } else { f(corps) } }
  let args = (:)
  if couleur { args.fill = fill }
  if f.at("size", default: none) != none {
    let s = f.size
    if type(s) == str and s not in tailles-latex.at("12pt") {
      panic(commande + " : taille LaTeX inconnue « " + s + " ». Tailles possibles : " + tailles-latex.at("12pt").keys().map(k => "« " + k + " »").join(", ") + ".")
    }
    args.size = taille-latex(s)
  }
  if f.at("weight", default: none) != none { args.weight = f.weight }
  if f.at("style", default: none) != none { args.style = f.style }
  if f.at("font", default: none) != none { args.font = f.font }
  text(..args, corps)
}

/// \SiCorrection{x} / \SiCorrection*{x} : `corps` en version professeur seulement ; `etoile` l'écrit
/// dans la couleur et la police des corrections. `local` : clés locales (correction-color, correction-font, style).
#let bf-si-correction(etoile: false, local: (:), commande: "SiCorrection", corps) = context {
  if type(etoile) != bool { panic(commande + " : la clé « etoile » attend true ou false ; reçu : " + repr(etoile) + ".") }
  let local = local.pairs().filter(((k, v)) => v != auto).to-dict()
  let r = reglages-resoudre(bf-reglages-socle, local: local, commande: commande)
  if est-correction() { if etoile { bf-police-correction(r, corps, commande: commande) } else { corps } }
}

/// \ifcorrection … \else … \fi, en trois formes : (prof, eleve), (prof) seul, ou sans argument
/// (renvoie le booléen : à appeler dans un `context`).
#let bf-ifcorrection(commande: "ifcorrection", ..branches) = {
  if branches.named().len() > 0 {
    panic(commande + " : clé inconnue « " + branches.named().keys().first() + " ». Formes possibles : ifcorrection() (booléen), ifcorrection[prof], ifcorrection[prof][élève].")
  }
  // Chaque branche passe par la passe des environnements : un `#begin … #end` y est permis.
  let b = branches.pos().map(environnements)
  if b.len() == 0 { return est-correction() }
  if b.len() == 1 { return context if est-correction() { b.at(0) } }
  if b.len() == 2 { return tf-correction(b.at(0), b.at(1)) }
  panic(commande + " : au plus deux contenus (version professeur, version élève) ; reçu : " + str(b.len()) + ".")
}
