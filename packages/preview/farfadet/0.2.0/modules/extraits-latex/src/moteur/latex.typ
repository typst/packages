// moteur/latex.typ — extraits de code LaTeX compilés à part et insérés comme images PDF.
//
// Typst ne peut lancer aucun programme : chaque extrait est donc marqué par une métadonnée
// <rendu-tex> que le script `outils/rendus_tex/rendus_tex.py` interroge, compile avec LaTeX
// (seulement si l'extrait a changé), puis range dans `rendus-tex/<empreinte>.pdf` en inscrivant
// le résultat dans `rendus-tex/index.json`. Ce fichier d'index est relu par le document : à son
// changement, l'aperçu se recompile et le rendu apparaît.
//
// TROIS façons de fournir les rendus au paquet (Typst interdit à un paquet de lire un fichier du
// projet de l'utilisateur, mais pas d'appeler une fonction définie dans le document) :
//
// 1. « Tout en un » (PDF du Ctrl+Maj+B) : le paquet exporte lui-même `latex`. bfwatch (extension VS Code)
//    compile les extraits, puis passe l'index et les PDF par `sys.inputs["bfcours-latex"]` (une
//    chaîne JSON) : le document n'écrit AUCUNE ligne de mise en place, l'import suffit.
// 2. « Lecture » (aperçu Tinymist) : le document donne au paquet une fonction de lecture, une fois,
//    par `#setbflatex(lire: p => read(p, encoding: none))`. Sans `sys.inputs["bfcours-latex"]`, `latex`
//    lit alors `rendus-tex/index.json` puis `rendus-tex/<empreinte>.pdf` par cette fonction : les
//    extraits déjà rendus s'affichent dans l'aperçu, et l'aperçu se recharge quand ces fichiers
//    changent. L'index est lu UNE fois par compilation (au moment du `setbflatex`). Typst ne sait pas
//    tester l'existence d'un fichier : `rendus-tex/index.json` doit exister (bfwatch le crée) ; un extrait
//    absent de l'index affiche l'encadré d'attente.
//    Sans `lire` ni `sys.inputs`, `latex` affiche un encadré « extrait non rendu ».
// 3. Historique (reste valable) : le document construit sa fonction avec `latex-avec`, en lui
//    donnant la lecture de `rendus-tex/index.json` (démon `rendus_tex.py`) :
//
//      #import "../../lib.typ": latex-avec
//      #let latex = latex-avec(json("rendus-tex/index.json"), p => read(p, encoding: none))
//
//    Tout nom de fichier est alors lu depuis le document, jamais depuis le paquet.
//
// Personnalisation : toutes les options de `latex` sont des clés du registre `latex-reglages`
// (mécanisme générique de farfadet-socle) : réglage global `setbflatex`, clés locales, styles nommés,
// réinitialisation. Priorité : clé locale > style nommé > réglage global > défaut.
//
// Tout ce qui n'est pas un nom public de lib.typ commence par « _ ».

#import "../../../socle/lib.typ": interne as _socle
#import _socle: (
  bf-lire,
  bf-etat,
  reglages-paquet, reglages-controles, reglages-choix, reglages-ou, reglages-resoudre,
)

// ---------------------------------------------------------------------------------------------
// Registre des réglages (clés = options de `latex` ; valeurs codées en dur d'avant = clés réglables)
// ---------------------------------------------------------------------------------------------

#let _moteurs = ("lualatex", "pdflatex", "xelatex")
#let _est-longueur-absolue(v) = type(v) == length and v.em == 0

/// Registre des réglages de farfadet-latex (état « bfr-latex »). Les clés et leurs défauts sont décrits
/// dans la documentation de `setbflatex`.
#let latex-reglages = reglages-paquet(
  "latex",
  (
    // --- contenu LaTeX de l'extrait
    paquets: (),
    preambule: none,
    moteur: auto,
    largeur-texte: auto,
    bordure: 2pt,
    // --- insertion du rendu
    largeur: auto,
    echelle: 100%,
    align: center,
    montrer-code: false,
    espace-avant: 1em,
    espace-apres: 1em,
    separable: false,
    // --- bloc du code montré
    code-fond: luma(246),
    code-taille: 0.8em,
    code-marge: 6pt,
    code-rayon: 2pt,
    code-langue: "latex",
    // --- messages « en attente » et « erreur »
    couleur-attente: rgb("#c77a0a"),
    couleur-erreur: rgb("#c0392b"),
    message-taille: 0.85em,
    message-marge: 8pt,
    message-rayon: 2pt,
    message-filet: 2.5pt,
    message-espace: 0.9em,
    texte-attente: auto,
    texte-erreur: auto,
    // --- lecture des rendus par le document (aperçu Tinymist)
    lire: none,
  ),
  controles: (
    lire: reglages-ou(reglages-choix(none), reglages-controles.fonction),
    paquets: (
      v => type(v) == str or (type(v) == array and v.all(p => type(p) == str or (
        type(p) == array and p.len() >= 1 and p.all(x => type(x) == str)
      ))),
      "un nom de paquet, ou un tableau de paquets où un paquet à options s'écrit (\"nom\", \"options\") : (\"tikz\", (\"babel\", \"french\"))",
    ),
    preambule: reglages-controles.contenu-ou-none,
    moteur: reglages-choix(auto, .._moteurs),
    largeur-texte: reglages-ou(reglages-choix(auto), (_est-longueur-absolue, "une longueur absolue (16cm, 160mm…)")),
    bordure: (_est-longueur-absolue, "une longueur absolue (2pt, 1mm…)"),
    largeur: reglages-ou(reglages-choix(auto), reglages-controles.longueur),
    echelle: (v => type(v) == ratio and v > 0%, "un pourcentage strictement positif (80%)"),
    align: (v => type(v) == alignment, "un alignement (center, left, right)"),
    montrer-code: reglages-controles.booleen,
    espace-avant: reglages-controles.longueur,
    espace-apres: reglages-controles.longueur,
    separable: reglages-controles.booleen,
    code-fond: reglages-controles.couleur-ou-none,
    code-taille: reglages-controles.longueur,
    code-marge: reglages-controles.longueur,
    code-rayon: reglages-controles.longueur,
    code-langue: reglages-controles.texte,
    couleur-attente: (v => type(v) == color, "une couleur Typst"),
    couleur-erreur: (v => type(v) == color, "une couleur Typst"),
    message-taille: reglages-controles.longueur,
    message-marge: reglages-controles.longueur,
    message-rayon: reglages-controles.longueur,
    message-filet: reglages-controles.longueur,
    message-espace: reglages-controles.longueur,
    texte-attente: reglages-ou(reglages-choix(auto), reglages-controles.fonction),
    texte-erreur: reglages-ou(reglages-choix(auto), reglages-controles.contenu),
  ),
  commande: "setbflatex",
)

// ---------------------------------------------------------------------------------------------
// Empreinte et lecture du code
// ---------------------------------------------------------------------------------------------

// Empreinte FNV-1a 32 bits, deux fois (deux graines) : 64 bits au total, assez pour qu'une
// collision soit hors de portée d'un document.
#let _fnv(s, graine) = {
  let h = graine
  for c in s.codepoints() { h = calc.rem(h.bit-xor(str.to-unicode(c)) * 16777619, 4294967296) }
  h
}
#let _empreinte(s) = {
  let un = str(_fnv(s, 2166136261), base: 16)
  let deux = str(_fnv(s, 40503), base: 16)
  "x" + un + "-" + deux
}

// Texte d'un bloc brut, d'une chaîne ou d'un contenu qui enveloppe un bloc brut.
#let _source(code) = {
  if type(code) == str { return code }
  if code.func() == raw { return code.text }
  let brut = if code.has("children") { code.children.find(c => c.func() == raw) } else { none }
  assert(brut != none, message: "latex : le corps doit contenir un bloc brut, par exemple [```latex … ```]")
  brut.text
}

// Un paquet s'écrit "tikz" ou ("babel", "french") ou ("geometry", "a4paper,margin=1cm").
#let _paquets-normalises(paquets) = {
  if type(paquets) == str { paquets = (paquets,) }
  paquets.map(p => {
    if type(p) == str { (nom: p, options: "") } else {
      let (nom, ..options) = p
      (nom: nom, options: options.pos().join(","))
    }
  })
}

// Longueur absolue écrite pour LaTeX : « 453.543bp ». Le « pt » de Typst vaut 1/72 de pouce, soit le
// « bp » de LaTeX (le « pt » de LaTeX vaut 1/72,27 de pouce) : écrire « pt » fausserait la longueur de 0,4 %.
#let _pt(v) = str(calc.round(v.pt(), digits: 3)) + "bp"

#let _boite-message(r, couleur, corps) = block(
  width: 100%,
  breakable: false,
  above: r.message-espace,
  below: r.message-espace,
  fill: couleur.lighten(90%),
  stroke: (left: r.message-filet + couleur, rest: 0.5pt + couleur.lighten(55%)),
  radius: r.message-rayon,
  inset: r.message-marge,
  text(size: r.message-taille, fill: couleur.darken(25%), weight: "regular", corps),
)

// mode : « fourni » (index reçu de bfwatch : un extrait absent est « en attente »),
// « lecture » (le document a donné `lire` : rendus lus dans rendus-tex/, aperçu Tinymist),
// « absent » (aucun rendu fourni : compilation hors bfwatch), « fichier » (latex-avec : démon à part).
#let _texte-attente-defaut(lignes, mode: "fichier") = if mode == "absent" [
  *Extrait LaTeX non rendu : Ctrl+Maj+B pour rendre les extraits et produire les PDF prof et élève.* Cet extrait de #lignes ligne#if lignes > 1 [s] n'est compilé que par
  l'extension VS Code « bfcours-typst ». Pour le voir aussi dans l'aperçu, écrire une fois en tête du document
  `#setbflatex(lire: p => read(p, encoding: none))`.
] else if mode == "fourni" [
  *Extrait LaTeX non rendu : Ctrl+Maj+B pour rendre les extraits et produire les PDF prof et élève.* L'extrait de #lignes ligne#if lignes > 1 [s] n'a pas été trouvé parmi les rendus.
] else if mode == "lecture" [
  *Extrait LaTeX pas encore rendu : Ctrl+Maj+B pour rendre les extraits et produire les PDF prof et élève.* L'extrait de #lignes ligne#if lignes > 1 [s] est nouveau ou modifié ;
  le rendu apparaît dans l'aperçu quelques secondes après.
] else [
  *Rendu LaTeX en attente : enregistrez (Ctrl+S).* L'extrait de #lignes ligne#if lignes > 1 [s] n'est pas encore compilé.
  Si rien ne vient, le démon de rendu n'est pas lancé : voir le guide de farfadet-latex.
]

// Rendus fournis par bfwatch : `sys.inputs["bfcours-latex"]` est une chaîne JSON
// { "index": <contenu de index.json>, "pdf": { "<clé>": [octets…] } }. Un tableau d'entiers est la
// seule forme que Typst convertit en octets sans boucle (`bytes(tableau)`) : décodage instantané.
#let _fourni = {
  let brut = sys.inputs.at("bfcours-latex", default: none)
  if brut == none { none } else { json(bytes(brut)) }
}

// Lecture par le document (clé `lire` de `setbflatex`) : dossier des rendus, vu depuis le fichier qui
// écrit `lire`, et index lu UNE fois par `setbflatex(lire: …)` (état), sinon lu à chaque extrait.
#let _dossier-rendus = "rendus-tex"
#let _index-lu-p = bf-etat("bfr-latex-index-lu", none)
#let _index-lu = _index-lu-p.etat
#let _lire-index(lire) = json(lire(_dossier-rendus + "/index.json"))

// Rendus à employer pour un extrait : ceux de bfwatch (`sys.inputs`) l'emportent ; sinon, si le document
// a donné `lire`, ceux de rendus-tex/ ; sinon ceux de la fabrique. À appeler dans un `context`.
#let _rendus-effectifs(r, index, lire-rendu, mode, dynamique) = {
  if not dynamique or r.lire == none { return (index, lire-rendu, mode) }
  let lire = r.lire
  let lu = bf-lire(_index-lu-p)
  (
    if lu == none { _lire-index(lire) } else { lu },
    cle => lire(_dossier-rendus + "/" + cle + ".pdf"),
    "lecture",
  )
}

// Fabrique de `latex`. `lire-rendu` : clé -> octets du PDF ; `mode` : voir `_texte-attente-defaut`.
// `dynamique` : la clé `lire` du réglage peut fournir les rendus (fonction `latex` du paquet seulement).
#let _fabrique(index, lire-rendu, mode, dynamique: false) = {
  /// Insère un extrait de code LaTeX, compilé à l'enregistrement et inséré comme image PDF.
  ///
  /// ```typ
  /// #latex(paquets: ("ProfCollege",))[```latex
  /// \Developper{(2x+3)(x-5)}
  /// ```]
  /// ```
  ///
  /// Tant que l'extrait n'est pas compilé, un message l'annonce à sa place ; une erreur LaTeX
  /// s'affiche, résumée, à la place du rendu. Les paquets nommés doivent être installés sur la
  /// machine, et le compilateur LaTeX doit être déclaré dans VS Code (voir le guide).
  ///
  /// Toutes les clés valent `auto` par défaut : « selon les réglages » (`setbflatex`, puis style
  /// nommé, puis valeur par défaut). Une clé inconnue ou une valeur invalide arrête la compilation
  /// avec la liste des possibilités. Les clés de `setbflatex` autres que celles ci-dessous
  /// (`code-fond`, `couleur-erreur`, `bordure`…) s'écrivent aussi ici.
  ///
  /// - code (str, raw, content): le code LaTeX, en bloc brut.
  /// - paquets (auto, str, array): paquets à charger : `"tikz"`, ou `("tikz", "tkz-tab")`, ou une liste
  ///   où un paquet à options s'écrit `("babel", "french")` (défaut `()`). Remplace la liste réglée.
  /// - preambule (auto, none, str, raw): lignes de préambule propres à cet extrait, par exemple
  ///   `\usetikzlibrary{arrows.meta}` ou une macro (défaut `none`). Un préambule commun à tous les
  ///   extraits se met dans `rendus-tex/preambule.tex`, ou dans `setbflatex(preambule: …)`.
  /// - moteur (auto, str): `auto` (réglage du projet, `lualatex` par défaut), `"lualatex"`,
  ///   `"pdflatex"` ou `"xelatex"`.
  /// - largeur (auto, length, ratio): largeur du rendu ; `auto` garde la taille naturelle LaTeX.
  /// - echelle (auto, ratio): facteur appliqué à la taille naturelle (ignoré si `largeur` est fixée) (défaut `100%`).
  /// - align (auto, alignment): position horizontale du rendu (défaut `center`).
  /// - montrer-code (auto, bool): affiche aussi le code LaTeX, sous le rendu (défaut `false`).
  /// - style (auto, str, array): nom d'un style défini par `setbflatex(definir: …)` (ou `definir-style`),
  ///   ou tableau de noms.
  /// - ..options (any): toute autre clé de `setbflatex` (voir ce réglage).
  /// -> content
  let latex(
    code,
    paquets: auto,
    preambule: auto,
    moteur: auto,
    largeur: auto,
    echelle: auto,
    align: auto,
    montrer-code: auto,
    style: auto,
    ..options,
  ) = {
    if options.pos().len() > 0 {
      panic("latex : un seul argument positionnel (le code) est attendu ; reçu en plus : " + repr(options.pos().first()))
    }
    let locales = (
      paquets: paquets,
      preambule: preambule,
      moteur: moteur,
      largeur: largeur,
      echelle: echelle,
      align: align,
      montrer-code: montrer-code,
      style: style,
    ) + options.named()
    // Une clé locale `auto` (« non précisée ») ne masque ni un style nommé ni le réglage global :
    // `reglages-resoudre` du socle l'ignore (demande farfadet-latex satisfaite).
    context {
      let r = reglages-resoudre(latex-reglages, local: locales, commande: "latex")
      let (index, lire-rendu, mode) = _rendus-effectifs(r, index, lire-rendu, mode, dynamique)
      let source = _source(code)
      let liste = _paquets-normalises(r.paquets)
      let pre = if r.preambule == none { "" } else { _source(r.preambule) }
      let mot = if r.moteur == auto { "" } else { r.moteur }
      let largeur-texte = if r.largeur-texte == auto { "" } else { _pt(r.largeur-texte) }
      // Défaut : « 2pt » au sens de LaTeX, valeur historique transmise telle quelle (cache inchangé).
      let bordure = if r.bordure == 2pt { "2pt" } else { _pt(r.bordure) }
      let signature = (
        source,
        liste.map(p => p.nom + "[" + p.options + "]").join(";"),
        pre,
        mot,
      )
      // Les clés ajoutées au calcul de l'empreinte seulement quand elles s'écartent du défaut :
      // les rendus déjà en cache restent valables.
      if largeur-texte != "" { signature.push("largeur-texte=" + largeur-texte) }
      if bordure != "2pt" { signature.push("bordure=" + bordure) }
      let cle = _empreinte(signature.join("\u{1f}"))
      // Lu par le script : tout ce qu'il faut pour compiler l'extrait.
      [#metadata((
        cle: cle,
        code: source,
        paquets: liste,
        preambule: pre,
        moteur: mot,
        largeur-texte: largeur-texte,
        bordure: bordure,
      )) <rendu-tex>]

      let lignes = source.split("\n").len()
      let entree = if index == none { none } else { index.at("extraits", default: (:)).at(cle, default: none) }

      let rendu = if entree == none {
        _boite-message(r, r.couleur-attente, if r.texte-attente == auto { _texte-attente-defaut(lignes, mode: mode) } else { (r.texte-attente)(lignes) })
      } else if entree.at("erreur", default: none) != none {
        _boite-message(r, r.couleur-erreur)[
          #if r.texte-erreur == auto [*Erreur LaTeX dans cet extrait.*] else [#r.texte-erreur] #linebreak()
          #set par(justify: false)
          #raw(entree.erreur, block: true)
        ]
      } else {
        let octets = lire-rendu(cle)
        let image-pdf(..options) = image(octets, format: "pdf", ..options)
        if r.largeur != auto {
          image-pdf(width: r.largeur)
        } else {
          // Taille naturelle (× échelle), sauf si elle dépasse la place disponible (colonne, cadre étroit) :
          // un rendu composé à la largeur du texte (`align*`, `center`…) débordait alors du cadre, qui le
          // rognait. Il est ramené à la largeur disponible ; un rendu qui tient ne change pas.
          layout(place => {
            let naturelle = measure(image-pdf()).width * r.echelle
            if naturelle > place.width and place.width > 0pt { image-pdf(width: place.width) }
            else if r.echelle == 100% { image-pdf() }
            else { image-pdf(width: naturelle) }
          })
        }
      }

      block(width: 100%, above: r.espace-avant, below: r.espace-apres, breakable: r.separable, {
        if entree != none and entree.at("erreur", default: none) == none { std.align(r.align, rendu) } else { rendu }
        if r.montrer-code {
          block(
            width: 100%,
            fill: r.code-fond,
            inset: r.code-marge,
            radius: r.code-rayon,
            text(size: r.code-taille, raw(source, lang: r.code-langue, block: true)),
          )
        }
      })
    }
  }
  latex
}

/// Construit la fonction `latex` d'un document à partir de ses rendus. Forme « historique » : le
/// document lit lui-même `rendus-tex/index.json`, produit par le démon `rendus_tex`. Pour un cours
/// enregistré avec l'extension VS Code (bfwatch), inutile : `latex` est déjà exporté par le paquet.
///
/// Typst interdit à une fonction de paquet de lire un fichier du document : l'index et la lecture
/// des PDF sont donc fournis par le document lui-même.
///
/// ```typ
/// #import "../../lib.typ": latex-avec
/// #let latex = latex-avec(json("rendus-tex/index.json"), p => read(p, encoding: none))
/// ```
///
/// Dans un document découpé en chapitres, le script écrit aussi `rendus-tex/latex.typ`, qui
/// contient ces deux lignes : un chapitre n'a qu'à écrire
/// `#import "rendus-tex/latex.typ": latex`.
///
/// - index (dictionary): contenu de `rendus-tex/index.json`, lu avec `json(…)`.
/// - lire (function): fonction `chemin => read(chemin, encoding: none)` écrite dans le document.
/// - dossier (str): dossier des rendus, vu depuis le fichier qui écrit `lire`.
/// -> function
#let latex-avec(index, lire, dossier: "rendus-tex") = _fabrique(
  index, cle => lire(dossier + "/" + cle + ".pdf"), "fichier",
)

/// Insère un extrait de code LaTeX, compilé à l'enregistrement et inséré comme image PDF. C'est la
/// fonction à utiliser : l'import du paquet (ou du méta-paquet) suffit, sans aucune ligne de mise en
/// place. Les clés sont celles de `setbflatex` (`paquets`, `preambule`, `moteur`, `largeur`,
/// `echelle`, `align`, `montrer-code`, `style`…).
///
/// ```typ
/// #latex[```latex
/// $\dfrac{3}{4} + \dfrac{1}{4} = 1$
/// ```]
/// ```
///
/// Les rendus viennent de bfwatch (extension VS Code `bfcours-typst`, Ctrl+Maj+B) :
/// il repère les extraits, les compile avec LaTeX (seulement ceux qui ont changé) et les range dans
/// `rendus-tex/`. Les PDF du Ctrl+Maj+B les reçoivent directement ; l'aperçu Tinymist les lit si le
/// document a écrit une fois `#setbflatex(lire: p => read(p, encoding: none))`. Sans cela, l'extrait est
/// remplacé par un encadré « extrait LaTeX non rendu ».
///
/// - code (str, raw, content): le code LaTeX, en bloc brut.
/// -> content
#let latex = _fabrique(
  if _fourni == none { none } else { _fourni.index },
  cle => bytes(_fourni.pdf.at(cle)),
  if _fourni == none { "absent" } else { "fourni" },
  dynamique: _fourni == none,
)
