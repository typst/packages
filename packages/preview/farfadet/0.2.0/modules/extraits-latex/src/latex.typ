// latex.typ (façade) — personnalisation des extraits LaTeX : un setter (réglage global, styles nommés, remise à zéro).
// Le moteur (`latex-avec`, registre `latex-reglages`) est dans moteur/latex.typ.
// Tout ce qui n'est pas un nom public de lib.typ commence par « _ ».

#import "../../socle/lib.typ": interne as _socle
#import _socle: reglages-regler, reglages-definir-style, reglages-reinitialiser, bf-maj
#import "moteur/latex.typ": latex-reglages, _index-lu, _index-lu-p, _lire-index

/// Règle les extraits LaTeX de la suite du document : seul réglage du paquet (réglage global, style
/// nommé, remise à zéro). Les appels s'ajoutent clé par clé ; une clé locale de `latex(…)` l'emporte
/// toujours. Une clé inconnue ou une valeur invalide arrête la compilation avec la liste des possibilités.
///
/// ```typ
/// #setbflatex(paquets: ("tikz",), echelle: 80%, moteur: "pdflatex")
/// #setbflatex(couleur-erreur: purple, code-fond: luma(230))
/// #setbflatex(definir: "figure", paquets: ("tikz",), echelle: 85%)
/// #setbflatex(reinitialiser: true)
/// ```
///
/// Clés (aucune n'a d'équivalent LaTeX : les noms sont ceux de Typst) :
///
/// *Le contenu LaTeX*
/// - paquets (str, array): paquets chargés par `\usepackage` dans chaque extrait (défaut `()`).
/// - preambule (none, str, raw): lignes de préambule communes à tous les extraits (défaut `none`) ;
///   s'ajoute à `rendus-tex/preambule.tex`.
/// - moteur (auto, str): `auto`, `"lualatex"`, `"pdflatex"` ou `"xelatex"` (défaut `auto`).
/// - largeur-texte (auto, length): largeur maximale du texte d'un extrait, en longueur absolue (défaut
///   `auto` : réglage VS Code `bfcours-latex.largeur-texte`, `16cm` sinon).
/// - bordure (length): marge de recadrage autour du rendu, classe `standalone` (défaut `2pt`).
///
/// *L'insertion du rendu*
/// - largeur (auto, length, ratio): largeur du rendu (défaut `auto` : taille naturelle).
/// - echelle (ratio): facteur appliqué à la taille naturelle (défaut `100%`).
/// - align (alignment): position horizontale (défaut `center`).
/// - montrer-code (bool): affiche aussi le code LaTeX sous le rendu (défaut `false`).
/// - espace-avant (length): espace avant le bloc (défaut `1em`).
/// - espace-apres (length): espace après le bloc (défaut `1em`).
/// - separable (bool): autorise un saut de page dans le bloc (défaut `false`).
///
/// *Le code montré*
/// - code-fond (color, none): fond du bloc de code (défaut `luma(246)`).
/// - code-taille (length): taille du code (défaut `0.8em`).
/// - code-marge (length): marge intérieure (défaut `6pt`).
/// - code-rayon (length): arrondi des coins (défaut `2pt`).
/// - code-langue (str): langue de coloration (défaut `"latex"`).
///
/// *Les messages « en attente » et « erreur »*
/// - couleur-attente (color): couleur du message d'attente (défaut `#c77a0a`).
/// - couleur-erreur (color): couleur du message d'erreur (défaut `#c0392b`).
/// - message-taille (length): taille du texte (défaut `0.85em`).
/// - message-marge (length): marge intérieure (défaut `8pt`).
/// - message-rayon (length): arrondi des coins (défaut `2pt`).
/// - message-filet (length): épaisseur du filet de gauche (défaut `2.5pt`).
/// - message-espace (length): espace avant et après (défaut `0.9em`).
/// - texte-attente (auto, function): fonction `lignes => contenu` qui compose le message d'attente
///   (défaut `auto`).
/// - texte-erreur (auto, content): titre du message d'erreur (défaut `auto`).
///
/// *La lecture des rendus (aperçu Tinymist)*
/// - lire (none, function): fonction `chemin => octets` écrite DANS le document, à régler une fois en tête :
///   `#setbflatex(lire: p => read(p, encoding: none))`. Sans `sys.inputs` de bfwatch, `latex` lit alors
///   `rendus-tex/index.json` et `rendus-tex/<empreinte>.pdf` par cette fonction : l'aperçu montre les extraits
///   déjà rendus et se recharge quand ils changent. L'index est lu une fois par compilation. Typst ne sait pas
///   tester l'existence d'un fichier : `rendus-tex/index.json` doit exister (bfwatch le crée). Défaut `none`.
///
/// *Les autres arguments*
/// - pour (none): sans objet (le paquet n'a qu'un type d'objet) ; gardé pour la signature commune des setters.
/// - reinitialiser (bool, str): `true` repart des défauts avant d'appliquer les clés (styles gardés) ;
///   `"tout"` oublie aussi les styles nommés (défaut `false`).
/// - definir (none, str): définit le style nommé de ce nom avec les clés données, au lieu de régler ; on
///   l'appelle ensuite par `style: "nom"` sur `latex(…)` ou dans `setbflatex(…)`. Un style peut en appeler
///   un autre (`style:`) ; un style défini par `definir-style` (commun à tous les paquets bfcours) fonctionne
///   aussi, et en cas de même nom celui de ce paquet l'emporte.
/// - style (str, array): style(s) nommé(s) appliqué(s) au réglage global.
/// -> content
#let setbflatex(pour: none, reinitialiser: false, definir: none, ..cles) = {
  let commande = "setbflatex"
  if cles.pos().len() > 0 {
    panic(commande + " : seuls des arguments nommés sont acceptés ; reçu : " + repr(cles.pos().first()) + ".")
  }
  if pour != none {
    panic(commande + " : le paquet n'a qu'un type d'objet : la clé « pour » est sans objet ; reçu : " + repr(pour) + ".")
  }
  if reinitialiser not in (true, false, "tout") {
    panic(commande + " : la clé « reinitialiser » attend true, false ou \"tout\" ; reçu : " + repr(reinitialiser) + ".")
  }
  if definir != none {
    return reglages-definir-style(latex-reglages, definir, commande: commande, ..cles)
  }
  if reinitialiser == "tout" { reglages-reinitialiser(latex-reglages, styles: true) }
  let regle = reglages-regler(latex-reglages, reinitialiser: reinitialiser != false, commande: commande, ..cles)
  // `lire` : l'index des rendus est lu ici, une seule fois par compilation, pour tous les extraits.
  let lecture = cles.named().at("lire", default: auto)
  if type(lecture) == function {
    [#regle#bf-maj(_index-lu-p, _lire-index(lecture))]
  } else if lecture == none or (lecture == auto and reinitialiser != false) {
    [#regle#bf-maj(_index-lu-p, none)]
  } else {
    regle
  }
}
