// vrai-faux.typ (farfadet-qcm, façade) — exercice « vrai ou faux » : `vrai-faux` et `affirmation`
// (ajouts sans équivalent LaTeX : noms gardés).
//
// Principe : dans la version professeur, la bonne colonne est cochée (case dans la couleur des corrections) ;
// dans la version élève, les cases restent vides. Rien n'est aléatoire par défaut ; le mélange, s'il est
// demandé, est reproductible (même graine = même ordre dans les deux versions).
//
// Réglages : `setrdmcq(pour: "vrai-faux", …)` (registre « vrai-faux »). Épurage du 07/10/2026 : le QCM
// maison (`qcm`, `question`, `juste`) est supprimé ; couleurs par défaut = couleurs nommées de bfcours.

#import "../../socle/lib.typ": interne as _socle
#import _socle: (
  bf-afficher-points-p,
  bf-interligne-p,
  bf-lire,
  bf-interligne, est-correction, bf-afficher-points, bf-boite-points-en-ligne, bf-points, bf-resoudre-couleur,
  bf-xcolor, bf-nommee, reglages-paquet, reglages-resoudre, reglages-controles, reglages-choix, reglages-ou,
  environnements,
)

// =====================================================================
// Réglages (registre « vrai-faux », sélectionné par setrdmcq(pour: "vrai-faux"))
// =====================================================================

#let _c = reglages-controles
#let _cases = reglages-choix("carre", "rond")

/// Registre des réglages de `vrai-faux` et `affirmation` (setter : `setrdmcq(pour: "vrai-faux", …)`).
/// Les couleurs par défaut sont des couleurs nommées de bfcours, lues au rendu.
#let registre-vrai-faux = reglages-paquet(
  "vrai-faux",
  (
    numerotation: "1.",
    num-start: 1,
    cases: "carre",
    melanger: false,
    graine: 1,
    correction: auto,
    correction-color: bf-nommee("monrose"),
    row-sep: 0.9em,
    taille-case: 0.85em,
    filet-case: 0.7pt,
    couleur-case: bf-nommee("black"),
    epaisseur-coche: 1.2pt,
    colonnes: 1,
    libelles: ([Vrai], [Faux]),
    lignes-justification: 0,
    column-sep: 1em,
    largeur-colonne: 1.7cm,
    filet: 0.5pt,
    filet-color: bf-nommee("rem"),
    fond-entete: bf-nommee("rem!15"),
    marge-cellule: (x: 0.5em, y: 0.45em),
    taille-justification: 0.9em,
  ),
  controles: (
    numerotation: reglages-ou(_c.texte, (v => v == none, "none")),
    cases: _cases,
    graine: _c.entier,
    num-start: _c.entier,
    correction: reglages-ou(_c.booleen, (v => v == auto, "auto (version prof/élève)")),
    correction-color: reglages-ou(_c.couleur, _c.texte),
    couleur-case: reglages-ou(_c.couleur, _c.texte),
    colonnes: (v => type(v) == int and v >= 1, "un entier au moins égal à 1"),
    libelles: (v => type(v) == array and v.len() == 2, "un tableau de deux contenus, par exemple ([Vrai], [Faux])"),
    lignes-justification: (v => type(v) == int and v >= 0, "un entier positif ou nul"),
    fond-entete: reglages-ou(_c.couleur, _c.texte, (v => v == none, "none")),
    filet: (v => v == none or type(v) in (length, color, stroke, dictionary), "none, une épaisseur, une couleur ou un trait (0.5pt + gray)"),
    filet-color: reglages-ou(_c.couleur, _c.texte),
    marge-cellule: (v => type(v) in (length, dictionary), "une longueur ou un dictionnaire (x: …, y: …)"),
    taille-justification: _c.longueur,
  ),
  commande: "setrdmcq",
)

/// Ajoute des points au barème.
#let _ajouter-points(n) = bf-points.update(p => p + (total: p.total + n, exo: p.exo + n))

/// Points d'une affirmation : ajoutés au barème et, si la boîte est demandée (`boite: true`, ou `auto` avec
/// `displayitempoints(true)`), boîte « n pts » collée à droite de la ligne.
#let _points-ligne(n, boite) = {
  if n != none {
    _ajouter-points(n)
    context {
      if if boite == auto { bf-lire(bf-afficher-points-p) } else { boite } {
        h(1fr)
        bf-boite-points-en-ligne(n)
      }
    }
  }
}

// =====================================================================
// Outils
// =====================================================================

/// Mélange reproductible (Fisher-Yates, générateur congruentiel) : même graine, même ordre.
#let _melanger(tableau, graine) = {
  let t = tableau
  let x = calc.rem(graine * 7919 + 104729, 2147483647)
  for i in range(t.len() - 1, 0, step: -1) {
    x = calc.rem(x * 48271, 2147483647)
    let j = calc.rem(x, i + 1)
    let a = t.at(i)
    t.at(i) = t.at(j)
    t.at(j) = a
  }
  t
}

/// Case à cocher, carrée ou ronde ; cochée d'une croix (carré) ou d'un point (rond) dans la couleur donnée.
/// Proportions de la case d'origine (côté 0,85 em, croix de 0,15 à 0,7 em, point de rayon 0,28 em).
#let _case(coche, r, couleur) = {
  let cote = r.taille-case
  let k = cote / 0.85em
  box(
    width: cote,
    height: cote,
    stroke: r.filet-case + bf-resoudre-couleur(r.couleur-case),
    radius: if r.cases == "rond" { 50% } else { 0pt },
    {
      if coche and r.cases == "rond" {
        place(center + horizon, circle(radius: 0.28em * k, fill: couleur, stroke: none))
      } else if coche {
        place(top + left, line(start: (0.15em * k, 0.15em * k), end: (0.7em * k, 0.7em * k), stroke: r.epaisseur-coche + couleur))
        place(top + left, line(start: (0.7em * k, 0.15em * k), end: (0.15em * k, 0.7em * k), stroke: r.epaisseur-coche + couleur))
      }
    },
  )
}

/// Couleur des corrections et version effectives.
#let _correction(r) = (
  couleur: bf-xcolor(r.correction-color, commande: "vrai-faux"),
  prof: if r.correction == auto { est-correction() } else { r.correction },
)

// =====================================================================
// Vrai / faux
// =====================================================================

/// Une affirmation d'un exercice « vrai ou faux ». Le booléen `vrai` donne la bonne réponse.
///
/// ```example
/// #vrai-faux(affirmation(vrai: true)[Un carré est un rectangle.])
/// ```
///
/// - enonce (content): l'affirmation.
/// - vrai (bool): `true` si l'affirmation est vraie, `false` si elle est fausse. Défaut `true`.
/// - justification (content, none): justification attendue, affichée en version professeur seulement. Défaut `none`.
/// - points (int, float, none): barème de l'affirmation. Défaut `none`.
/// - boite (bool, auto): boîte « n pts » à droite de l'affirmation. Défaut `auto`.
/// -> content (marqueur : ne s'affiche que dans un `vrai-faux`)
#let affirmation(enonce, vrai: true, justification: none, points: none, boite: auto) = {
  if type(vrai) != bool {
    panic("affirmation : valeur invalide pour la clé « vrai » : " + repr(vrai) + ". Valeurs possibles : true ou false.")
  }
  // marqueur de contenu (`metadata`) : `affirmation` s'écrit dans un corps (`#begin(vrai-faux) … #end(vrai-faux)`)
  // comme en argument de `vrai-faux(…)` ; `vrai-faux` relit la valeur du marqueur.
  metadata((bf-affirmation: true, enonce: enonce, vrai: vrai, justification: justification, points: points, boite: boite))
}

#let _sequence = [a#h(1pt)b].func()
#let _espace = [#h(1pt) #h(1pt)].children.at(1).func()

/// Affirmations contenues dans un corps (un marqueur `affirmation`, une séquence, ou un dictionnaire de
/// l'ancienne écriture). Le blanc est ignoré ; tout autre contenu est une erreur.
#let _collecter-affirmations(c) = {
  let faute(x) = panic(
    "vrai-faux : chaque affirmation doit être créée par affirmation(…), par exemple affirmation(vrai: true)[Énoncé] ; reçu : " + repr(x) + ".",
  )
  let res = ()
  let pile = (c,)
  while pile.len() > 0 {
    let x = pile.pop()
    if type(x) == dictionary {
      if x.at("bf-affirmation", default: false) { res.push(x) } else { faute(x) }
    } else if type(x) != content {
      faute(x)
    } else {
      let f = x.func()
      if f == _sequence { for y in x.children.rev() { pile.push(y) } }
      else if f == metadata and type(x.value) == dictionary and x.value.at("bf-affirmation", default: false) {
        res.push(x.value)
      } else if f == parbreak or f == _espace or (f == text and x.text.trim() == "") {
        continue
      } else if x.at("label", default: none) == <bf-garde> {
        continue
      } else { faute(x) }
    }
  }
  res
}

/// Exercice « vrai ou faux » (ajout) : un tableau où chaque affirmation se coche dans la colonne « Vrai » ou
/// « Faux ». La version professeur coche la bonne colonne ; la version élève laisse les cases vides.
/// Réglage global : `setrdmcq(pour: "vrai-faux", …)`, mêmes clés.
///
/// ```example
/// #vrai-faux[
///   #affirmation(vrai: true)[Un carré est un rectangle.]
///   #affirmation(vrai: false, justification: [Le nombre $2$ est pair et premier.])[Aucun nombre premier n'est pair.]
/// ]
/// ```
///
/// L'ancienne écriture (`vrai-faux(affirmation(…)[…], affirmation(…)[…])`) reste acceptée.
///
/// - colonnes (int): nombre de tableaux côte à côte (affirmations réparties dans l'ordre). Défaut `1`.
/// - numerotation (str, none): motif de numérotation ; `none` : sans numéro. Défaut `"1."`.
/// - num-start (int): numéro de la première affirmation. Défaut `1`.
/// - cases (str): `"carre"` ou `"rond"`. Défaut `"carre"`.
/// - libelles (array): intitulés des deux colonnes. Défaut `([Vrai], [Faux])`.
/// - lignes-justification (int): lignes vierges laissées à l'élève sous chaque affirmation. Défaut `0`.
/// - melanger (bool): mélange l'ordre des affirmations. Défaut `false`.
/// - graine (int): graine du mélange. Défaut `1`.
/// - correction (bool, auto): version professeur. Défaut `auto`.
/// - correction-color (color, str): couleur des corrections. Défaut : couleur nommée `monrose`.
/// - row-sep (length): espace avant et après le tableau. Défaut `0.9em`.
/// - column-sep (length): espace entre tableaux côte à côte. Défaut `1em`.
/// - largeur-colonne (length): largeur des colonnes « Vrai » et « Faux ». Défaut `1.7cm`.
/// - filet (length, color, stroke, none): épaisseur des filets du tableau (ou trait complet). Défaut `0.5pt`.
/// - filet-color (color, str): couleur des filets quand `filet` est une épaisseur. Défaut : couleur nommée `rem`.
/// - fond-entete (color, str, none): fond de la ligne d'en-tête. Défaut : `rem!15` (couleur nommée `rem` éclaircie).
/// - marge-cellule (length, dictionary): marges des cellules. Défaut `(x: 0.5em, y: 0.45em)`.
/// - taille-justification (length): taille du texte des justifications. Défaut `0.9em`.
/// - taille-case (length): côté des cases. Défaut `0.85em`.
/// - filet-case (length): épaisseur du bord des cases. Défaut `0.7pt`.
/// - couleur-case (color, str): couleur du bord des cases. Défaut : `black`.
/// - epaisseur-coche (length): épaisseur de la croix. Défaut `1.2pt`.
/// - style (str, array): style(s) nommé(s), définis par `setrdmcq(definir: "nom", pour: "vrai-faux", …)`.
/// - affirmations (content): les affirmations créées par `affirmation(…)`, passées une à une ou écrites dans un corps `[…]` ; en syntaxe environnement : `#begin(vrai-faux)` … `#end(vrai-faux)`.
/// -> content
#let vrai-faux(..args) = {
  // les positionnels sont des affirmations (ancienne écriture) ou un corps `[ #affirmation(…)[…] … ]`,
  // éventuellement avec `#begin … #end` imbriqués (passe `environnements`)
  let affirmations = args.pos().map(p => if type(p) == content { environnements(p) } else { p })
    .map(_collecter-affirmations).flatten()
  context {
    let r = reglages-resoudre(registre-vrai-faux, local: args.named(), commande: "vrai-faux")
    let liste = affirmations
    if r.melanger { liste = _melanger(liste, r.graine) }
    let (couleur, prof) = _correction(r)
    let ligne = bf-lire(bf-interligne-p).baselineskip
    let colonnes = r.colonnes
    let libelles = r.libelles
    let fond-entete = if r.fond-entete == none { none } else { bf-xcolor(r.fond-entete, commande: "vrai-faux") }
    let filet = if type(r.filet) == length { r.filet + bf-xcolor(r.filet-color, commande: "vrai-faux") } else { r.filet }
    let par-tableau = calc.max(1, calc.ceil(liste.len() / colonnes))
    let tableau(debut-local, morceau) = table(
      columns: (1fr, r.largeur-colonne, r.largeur-colonne),
      stroke: filet,
      inset: r.marge-cellule,
      align: (left + horizon, center + horizon, center + horizon),
      fill: (x, y) => if y == 0 { fond-entete },
      table.header([], strong(libelles.at(0)), strong(libelles.at(1))),
      ..morceau.enumerate().map(((k, a)) => {
        let numero = if r.numerotation == none { none } else { strong(numbering(r.numerotation, r.num-start + debut-local + k)) }
        let texte = [#if numero != none [#numero #h(0.3em)]#a.enonce#_points-ligne(a.points, a.boite)]
        let suite = if prof and a.justification != none {
          v(0.25em)
          text(fill: couleur, size: r.taille-justification, a.justification)
        } else if not prof and r.lignes-justification > 0 {
          v(r.lignes-justification * ligne)
        }
        (
          [#texte#suite],
          _case(prof and a.vrai, r, couleur),
          _case(prof and not a.vrai, r, couleur),
        )
      }).flatten(),
    )
    block(breakable: false, above: r.row-sep, below: r.row-sep, grid(
      columns: (1fr,) * colonnes,
      column-gutter: r.column-sep,
      ..range(colonnes).map(c => {
        let morceau = liste.slice(calc.min(c * par-tableau, liste.len()), calc.min((c + 1) * par-tableau, liste.len()))
        if morceau.len() > 0 { tableau(c * par-tableau, morceau) }
      }),
    ))
  }
}
