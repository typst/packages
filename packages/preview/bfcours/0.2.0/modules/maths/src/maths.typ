// maths.typ — façade des maths : ensemble DD, vecteurs, coordonnées, intervalles, crochets, repère.
//
//   $ vect(A B) = coordonnees(3, -1) $
//   $ x in intervalle(-2, +oo, forme: "of") $
//
// Habille `moteur/maths.typ`. Source LaTeX : bfcours-mathsCommands.sty. Les noms exposés s'emploient aussi
// bien dans une formule que dans le texte (`#vect($A B$)`). Aucun nom d'une seule lettre n'est exporté :
// les anciens `R`, `N`, `Z`, `Q`, `C`, `D` du moteur auraient masqué les variables d'une formule ; Typst
// fournit `NN`, `ZZ`, `QQ`, `RR`, `CC`, et `dd` est ajouté ici.
// Tout ce qui n'est pas un nom public de lib.typ commence par « _ ».
//
// `vect`, `coordonnees` → `coordonnees`, `repere` → `rep`) et rendu réglable par `setbfmaths`.

#import "moteur/maths.typ" as m
#import "../../socle/lib.typ": interne as _socle
#import _socle: reglages-resoudre, bf-xcolor, taille-latex
#import "reglages.typ": _M

// =====================================================================
// Ensembles de nombres
// =====================================================================

/// L'ensemble des nombres décimaux, noté 𝔻 comme `RR` note ℝ : à employer dans une formule (le `\D` de LaTeX,
/// repli de nom : une lettre seule est lue comme une lettre en mode maths).
/// Typst fournit déjà `NN`, `ZZ`, `QQ`, `RR` et `CC` ; seul `dd` est ajouté.
///
/// ```typ
/// $ NN subset ZZ subset dd subset QQ subset RR $
/// ```
///
/// -> content
#let dd = $bb(D)$

// =====================================================================
// Vecteurs, coordonnées, repère
// =====================================================================

/// Vecteur : le nom (ou les deux points) surmonté d'une flèche qui s'étire avec lui (`\overrightarrow`).
///
/// ```typ
/// $ vect(A B) + vect(B C) = vect(A C) $
/// ```
///
/// - nom (content): ce qu'on surmonte de la flèche : `A B`, `u`…
/// - accent (symbol): l'accent (`math.arrow` par défaut ; `math.harpoon`, `math.tilde`…).
/// -> content
#let vect(nom, accent: math.arrow) = math.accent(nom, accent)

/// Valeurs résolues d'une pastille : boîte grise des coordonnées.
#let _pastille(contenu, r) = m.pastille-avec(
  contenu,
  colback: bf-xcolor(r.colback),
  colframe: if r.colframe == auto { none } else { bf-xcolor(r.colframe) },
  arc: r.arc, boxsep: r.boxsep, gauche: r.left, droite: r.right, haut: r.top, bas: r.bottom, boxrule: r.boxrule,
)

/// Coordonnées d'un point ou d'un vecteur : chaque valeur sur son fond gris, séparées par un point-virgule
/// espacé à la française (`\Coordonnees[A]{x}{y}`). Deux valeurs dans le plan, trois dans l'espace.
///
/// ```typ
/// $ coordonnees(3, -1, nom: A) $
/// $ coordonnees(1, 2, 3, colback: "yellow!30", arc: #4pt) $
/// ```
///
/// - ..args (content): les coordonnées, dans l'ordre : `x`, `y` (et `z`) ; les clés nommées de la boîte : `colback`, `colframe`, `arc`, `boxsep`, `boxrule`, `left`, `right`, `top`, `bottom`, `separateur`.
/// - nom (content, none): nom du point, écrit devant la parenthèse : `A(3 ; -1)`.
/// - style (auto, str, array): nom d'un style de `setbfmaths(definir: …)`.
/// -> content
#let coordonnees(..args, nom: none, style: auto) = {
  assert(args.pos().len() >= 2, message: "coordonnees : donner au moins deux coordonnées, par exemple coordonnees(3, -1).")
  context {
    let r = reglages-resoudre(
      _M, pour: "Coordonnees", commande: "Coordonnees", local: args.named() + (style: style),
    )
    let dedans = args.pos().map(v => _pastille(v, r)).join(r.separateur)
    // Une seule boîte : les coordonnées ne se coupent jamais entre deux valeurs, comme une formule.
    box($#nom lr(\(#dedans\))$)
  }
}

/// Le repère orthonormé (O ; I ; J) (le `\Rep` de LaTeX).
///
/// ```typ
/// $ "Dans le repère" rep $
/// ```
///
/// -> content
#let rep = m.rep

// =====================================================================
// Intervalles et crochets
// =====================================================================

/// Cotes des crochets tirées des valeurs résolues.
#let _cotes(r) = (trait: r.trait, patte: r.patte, marge: r.marge, ecart: r.ecart, approche: r.approche)

/// Intervalle de nombres réels, entre crochets qui s'adaptent à la hauteur de ce qu'ils entourent
/// (un intervalle de fractions a de grands crochets). Le point-virgule est espacé à la française
/// (`\intervalle[forme]{a}{b}`).
///
/// La `forme` dit comment chaque crochet est tourné : `f` (fermé) regarde vers l'intérieur, `o` (ouvert)
/// vers l'extérieur. Première lettre : borne de gauche ; seconde : borne de droite.
///
/// ```typ
/// $ intervalle(0, 1) $
/// $ intervalle(-2, +oo, forme: "of") $
/// $ intervalle(1/2, 3/4, forme: "oo") $
/// ```
///
/// - a (content): borne de gauche.
/// - b (content): borne de droite.
/// - forme (auto, str): `"ff"` : [a ; b], `"oo"` : ]a ; b[, `"fo"` : [a ; b[, `"of"` : ]a ; b].
/// - style (auto, str, array): nom d'un style de `setbfmaths(definir: …)`.
/// - ..options (any): `separateur` (le point-virgule), et les cotes des crochets : `trait` (épaisseur), `patte` (retour horizontal), `marge` (dépassement), `ecart` (blanc intérieur), `approche` (blanc extérieur).
/// -> content
#let intervalle(a, b, forme: auto, style: auto, ..options) = context {
  let r = reglages-resoudre(
    _M, pour: "intervalle", commande: "intervalle",
    local: options.named() + (forme: forme, style: style),
  )
  m.crochets(forme: r.forme, cr: _cotes(r), $#a #r.separateur #b$)
}

/// Un crochet : trois cas selon ce qu'on lui donne.
/// - `corps` donné : crochet ADAPTATIF, de la hauteur de `corps` (comme `\left[ … \right]`), écrit à côté de lui.
/// - `taille` donnée (nom LaTeX ou longueur), sans `corps` : crochet seul à cette taille.
/// - ni l'un ni l'autre : crochet seul à la taille du texte courant, aux cotes de LaTeX.
#let _crochet(droit, nom, args) = context {
  assert(args.pos().len() <= 1, message: nom + " : au plus un contenu (celui dont le crochet prend la hauteur).")
  let corps = args.pos().at(0, default: none)
  let r = reglages-resoudre(_M, pour: "Crochet", commande: nom, local: args.named())
  if corps != none {
    return m.crochet-adapte(droit, corps, cr: _cotes(r))
  }
  let c = m.crochet-seul(droit, ex: r.ex, cr: _cotes(r))
  if r.taille == auto { c } else { text(size: taille-latex(r.taille), c) }
}

/// Crochet gauche « [ » (le `\CrochetG` de LaTeX), à taille adaptative selon le contenu : avec un
/// argument, sa hauteur suit celle de ce contenu, écrit juste après lui, comme `\left[ … \right]`.
/// Sans argument, c'est un crochet seul à la taille du texte courant ; `taille:` impose une autre taille
/// (elle remplace l'ancien `CrochetGSize`).
///
/// ```typ
/// $ crochetg(1/2) ; crochetd(3/4) $
/// $ crochetg() 0 ; 1 crochetd() $
/// #crochetg(taille: "Large") x ; y #crochetd(taille: "Large")
/// ```
///
/// - ..args (content): au plus un contenu (positionnel), dont le crochet prend la hauteur et qu'il précède ; sans contenu : crochet seul. Clés nommées : `taille` (crochet seul : nom LaTeX comme `"large"`, ou longueur ; `auto` : celle du contexte), `style` (style défini par `setbfmaths(definir: …)`), cotes du crochet (`trait`, `patte`, `marge`, `ecart`, `approche`, `ex` : longueur d'un « ex »).
/// -> content
#let crochetg(..args) = _crochet(false, "CrochetG", args)

/// Crochet droit « ] » (le `\CrochetD` de LaTeX), à taille adaptative selon le contenu : avec un argument,
/// il se place juste après ce contenu et en prend la hauteur. Sans argument : crochet seul (voir `crochetg`).
///
/// ```typ
/// $ crochetg(1/2) ; crochetd(3/4) $
/// $ crochetg() 0 ; 1 crochetd() $
/// ```
///
/// - ..args (content): au plus un contenu (positionnel), dont le crochet prend la hauteur et qu'il suit ; sans contenu : crochet seul. Mêmes clés nommées que `crochetg`.
/// -> content
#let crochetd(..args) = _crochet(true, "CrochetD", args)
