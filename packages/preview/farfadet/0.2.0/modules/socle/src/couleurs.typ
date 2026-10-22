// couleurs.typ (farfadet-socle) — palette de bfcours-colors.sty, mélanges « à la xcolor »
// et couleurs courantes (accent, badges, tableaux). Palette reprise de la version LaTeX
// de bfcours (tableaux, listes : couleur des badges).
//
// xcolor écrit `c!p!d` pour « p % de c et (100 − p) % de d », mélange linéaire
// des composantes RVB ; `c!p` sous-entend `d = white`. `xmix` reproduit ce calcul.
//
// Phase 2 (06/10/2026) : ajouts SEULEMENT (les noms existants sont stables, interne.typ) :
// svgnames, couleurs nommées des autres modules, macros d'état complètes (`bf-couleurs-courantes`,
// `bf-couleur-courante`, `bf-regler-couleur-courante`), analyse STRICTE (`bf-xcolor`, `bf-definecolor`).
// Les noms publics LaTeX (`couleurs-tabular`…) sont dans publique.typ.

#import "precoce.typ": bf-etat, bf-maj, bf-lire
#import "svgnames.typ": svgnames

/// c!p!autre (xcolor) : p pour cent de c, le reste de `autre` (blanc par défaut).
#let xmix(c, p, autre: white) = {
  let a = rgb(c).components(alpha: false).map(v => v / 100%)
  let b = rgb(autre).components(alpha: false).map(v => v / 100%)
  let t = p / 100
  rgb(..a.zip(b).map(((x, y)) => (t * x + (1 - t) * y) * 100%))
}

// Couleurs de base de xcolor (modèle RVB, valeurs exactes du paquet).
#let xc = (
  red: rgb(255, 0, 0),
  green: rgb(0, 255, 0),
  blue: rgb(0, 0, 255),
  cyan: rgb(0, 255, 255),
  magenta: rgb(255, 0, 255),
  yellow: rgb(255, 255, 0),
  black: rgb(0, 0, 0),
  white: rgb(255, 255, 255),
  gray: rgb(128, 128, 128),
  darkgray: rgb(64, 64, 64),
  lightgray: rgb(191, 191, 191),
  brown: rgb(191, 128, 64),
  lime: rgb(191, 255, 0),
  olive: rgb(128, 128, 0),
  orange: rgb(255, 128, 0),
  pink: rgb(255, 191, 191),
  purple: rgb(191, 0, 64),
  teal: rgb(0, 128, 128),
  violet: rgb(128, 0, 128),
  // svgnames utilisés par bfcours
  Salmon: rgb(250, 128, 114),
)

// Environnements didactiques (bfcours-colors.sty).
#let couleurs = (
  defi: rgb(56, 128, 77),
  ex: rgb(39, 61, 112),
  nota: rgb(144, 55, 222),
  rem: rgb(128, 128, 128),
  thm: rgb(207, 8, 77),
  prop: rgb(0, 0, 200),
  demo: rgb(255, 128, 0),
  act: rgb(255, 128, 0),
  meth: rgb(151, 74, 0),
  // correction officielle et liens externes
  monrose: rgb("#FF1493"),
  // thèmes (définis en CMJN dans le .sty)
  nombres: cmyk(0%, 80%, 95%, 0%),
  gestion: cmyk(75%, 100%, 11%, 12%),
  grandeurs: cmyk(2%, 44%, 100%, 0%),
  geo: cmyk(62%, 10%, 0%, 0%),
  algo: cmyk(69%, 2%, 36%, 0%),
  correction: cmyk(63%, 23%, 93%, 6%),
  customBackground: rgb(0, 43, 54),
  // bluegreen, lightyellow, lightred : modèle rgb du .sty, valeurs exactes (0,87 → 87 %)
  bluegreen: rgb(0%, 87%, 87%),
  lightyellow: rgb(100%, 100%, 60%),
  lightred: rgb(100%, 60%, 60%),
  // doublon de gestion dans le .sty, et couleur des filets de tableaux (\arrayrulecolor{couleur_theme})
  gestionbis: cmyk(75%, 100%, 11%, 12%),
  couleur_theme: rgb("#000000"),
  // rdcrep : lignes Seyès
  seyescol: rgb("#C8C8DE"),
  // liens internes : red!50!yellow
  lien-interne: xmix(xc.red, 50, autre: xc.yellow),
  // énumérations : gray!80!black
  item-base: xmix(xc.gray, 80, autre: xc.black),
  // compatibilité avec les anciens noms
  base: rgb(51, 51, 51),
  // ---- Couleurs nommées des autres modules bfcours et rd* ----
  // rdexo.sty:73-74
  starcolor: rgb("#FFDD00"),
  rdexored: rgb("#940B20"),
  // new-bfcours-environments.sty:2536
  histoire: rgb(120, 72, 48),
  // bfcours-sectionning.sty:85 (rgb 0,2 0,2 0,2)
  BaseColor: rgb(20%, 20%, 20%),
  // rdarithm.sty:142-144
  arithmcol1: rgb("#FF6633"),
  arithmcol2: rgb("#00A580"),
  arithmcol3: rgb("#FFC518"),
  // rdmcq.bfcours.format.sty:6-9
  bfcours1: rgb("#f5f5f5"),
  bfcours2: rgb("#fca311"),
  bfcours3: rgb("#f9f6f0"),
  bfcours4: rgb("#5a5245"),
  // bfcours-commands.sty:271
  myblue: rgb(79, 129, 189),
  // bfcours-vocabulary.sty:105-108 (RoyalBlue redéfinit celle de svgnames)
  RoyalRed: rgb(200, 20, 20),
  RoyalGreen: rgb(20, 110, 20),
  RoyalBlue: rgb(65, 105, 250),
  color2: rgb(0, 82, 155),
  // bfcours-lightLST.sty:3-7
  CouleurVertForet: rgb(34, 139, 34),
  pythonkeyword: rgb(34, 139, 34),
  pythonstring: rgb(191, 56, 56),
  pythoncomment: rgb(128, 128, 128),
  pythonnumber: rgb(64, 64, 64),
)

// Noms de couleurs définis par l'utilisateur (\definecolor, \colorlet) : complétés par definecolor().
// C'est AUSSI là que `setbfcolors` range la nouvelle valeur d'une couleur nommée de bfcours (`thm`…) :
// un nom présent ici l'emporte sur la palette `couleurs` dans toutes les expressions xcolor.
#let bf-couleurs-perso-p = bf-etat("bf-couleurs-perso", (:))
#let bf-couleurs-perso = bf-couleurs-perso-p.etat

// ---------- Marqueur de couleur nommée (épurage, 07/10/2026) ----------

/// Marqueur de COULEUR NOMMÉE, à mettre dans les défauts d'un registre (`reglages-paquet`) ou dans une
/// clé réglée : `reglages-resoudre` / `reglages-courants` le remplacent, dans leur `context`, par la
/// valeur COURANTE de la couleur (celle que `setbfcolors` a pu changer). `expr` : nom d'une couleur
/// nommée (`"thm"`, `"monrose"`…), d'une macro d'état (`"currentAccentColor"`…) ou expression xcolor
/// qui en contient (`"thm!20"`, `"defi!80!black"`, `"currentTableColbackColor!50"`). Le nom est vérifié
/// à la résolution (erreur listant les noms possibles).
#let bf-nommee(expr) = {
  if type(expr) != str or expr.trim() == "" {
    panic("bf-nommee : nom de couleur attendu (\"thm\", \"currentAccentColor\", \"thm!20\"…) ; reçu : " + repr(expr) + ".")
  }
  (bf-nommee: expr.trim())
}

/// `v` est-il un marqueur de couleur nommée (`bf-nommee(…)`) ?
#let bf-est-nommee(v) = type(v) == dictionary and v.len() == 1 and "bf-nommee" in v

/// Résout un nom de couleur bfcours/xcolor (« prop », « monrose », « red »…) ou renvoie la couleur telle quelle.
/// `perso` : dictionnaire de couleurs supplémentaires (voir definecolor).
/// Un nom inconnu ne fait jamais échouer la compilation : il devient noir (ou blanc s'il désigne
/// un titre ou un fond, où le noir serait illisible). Le convertisseur, lui, donne leur valeur aux
/// couleurs que bfcours redéfinit en cours de route (\currentTableColTitleColor…) et signale dans
/// son rapport celles qu'il a dû supposer.
#let couleur(c, perso: (:)) = {
  if type(c) != str { return c }
  let nom = c.trim()
  if nom in perso { perso.at(nom) } else if nom in couleurs { couleurs.at(nom) } else if nom in xc {
    xc.at(nom)
  } else if nom in svgnames { svgnames.at(nom) } else if nom.match(regex("^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{4}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$")) != none {
    rgb(nom)
  } else if nom.contains(regex("(?i)col(title|back)")) { white } else { black }
}

/// Expression xcolor → couleur : « red!50!black », « gray!10 », « blue!50!black!80 », « -red ».
/// Les mélanges s'enchaînent de gauche à droite, comme dans xcolor.
#let xcolor(expr, perso: (:)) = {
  if type(expr) != str { return expr }
  let e = expr.trim()
  let complement = e.starts-with("-")
  if complement { e = e.slice(1) }
  let morceaux = e.split("!").map(m => m.trim())
  let c = couleur(morceaux.at(0), perso: perso)
  let i = 1
  while i < morceaux.len() {
    let p = float(morceaux.at(i))
    let autre = if i + 1 < morceaux.len() { couleur(morceaux.at(i + 1), perso: perso) } else { white }
    c = xmix(c, p, autre: autre)
    i += 2
  }
  if complement {
    let (r, g, b) = rgb(c).components(alpha: false)
    c = rgb(100% - r, 100% - g, 100% - b)
  }
  c
}

/// \definecolor{nom}{modèle}{valeurs} ou \colorlet{nom}{expression} : à placer dans le document.
#let definecolor(nom, valeur) = bf-maj(bf-couleurs-perso-p, d => d + ((nom): xcolor(valeur, perso: d)))

/// xcolor() qui connaît les couleurs définies par definecolor — à appeler dans un `context`.
#let xcouleur(expr) = xcolor(expr, perso: bf-lire(bf-couleurs-perso-p))

// =====================================================================
// Couleurs COURANTES (bfcours-colors.sty) : états partagés par tous les paquets
// =====================================================================
// Placées ici (didactique ⇄ tableaux) :
// les environnements didactiques les posent, les tableaux, listes, textes et colonnes les lisent.

// ---------- Couleur d'accent courante ----------
// \currentAccentColor de bfcours : modifiée par les environnements didactiques,
// lue par \acc, \encadrer, les puces… (noir hors environnement).
#let bf-couleur-p = bf-etat("bf-couleur", black)
#let bf-couleur = bf-couleur-p.etat

// ---------- Couleur des badges : \itemBaseColor ----------
/// Couleur des badges de tcbenumerate et d'enumerate (\itemBaseColor, gray!80!black hors environnement).
#let bf-couleur-item-p = bf-etat("bf-couleur-item", couleurs.item-base)
#let bf-couleur-item = bf-couleur-item-p.etat

/// \couleurItem{c}
#let couleuritem(c) = context bf-maj(bf-couleur-item-p, xcouleur(c))

/// \resetItemBaseColor
#let resetitembasecolor() = bf-maj(bf-couleur-item-p, couleurs.item-base)

// ---------- Couleurs des tableaux ----------
#let tableaux-defauts = (
  // \CouleursTabular : cadre, fond du titre, texte du titre, fond, texte ; filets = \arrayrulecolor
  primaire: (cadre: "blue!50!black", fond-titre: "blue!50!black", texte-titre: "white", fond: "white", texte: "red!50!black", filets: "black"),
  // \CouleursSecondaryTabular
  secondaire: (cadre: "red!50!black", fond-titre: "Salmon!30!white", texte-titre: "black", fond: "yellow!10!white", texte: "red!50!black"),
)

/// Couleurs des tableaux primaires (tcbtab) et secondaires (tcbtabx), modifiées par les environnements.
#let bf-couleurs-tableaux-p = bf-etat("bf-couleurs-tableaux", tableaux-defauts)
#let bf-couleurs-tableaux = bf-couleurs-tableaux-p.etat

/// Couleur `c` suivie d'un suffixe xcolor (« !80!black ») ; `c` : nom, expression ou couleur Typst.
/// À appeler dans un `context`.
#let bf-teinte(c, suffixe: "") = {
  if type(c) == str { return xcouleur(c + suffixe) }
  if suffixe == "" { return c }
  xcolor("bfc" + suffixe, perso: bf-lire(bf-couleurs-perso-p) + (bfc: c))
}

/// Résout une couleur stockée (chaîne xcolor ou couleur). À appeler dans un `context`.
#let bf-resoudre-couleur(c) = if type(c) == str { xcouleur(c) } else { c }

/// \CouleursTabular{cadre}{fond titre}{texte titre}{fond}{texte} (filets = cadre)
#let couleurstabular(cadre, fond-titre, texte-titre, fond, texte) = bf-maj(bf-couleurs-tableaux-p, t => t + (
  primaire: (cadre: cadre, fond-titre: fond-titre, texte-titre: texte-titre, fond: fond, texte: texte, filets: cadre),
))

/// \CouleursSecondaryTabular{cadre}{fond titre}{texte titre}{fond}{texte}
#let couleurssecondarytabular(cadre, fond-titre, texte-titre, fond, texte) = bf-maj(bf-couleurs-tableaux-p, t => t + (
  secondaire: (cadre: cadre, fond-titre: fond-titre, texte-titre: texte-titre, fond: fond, texte: texte),
))

/// \ResetCouleursTabular, \ResetCouleursSecondaryTabular
#let resetcouleurstabular() = bf-maj(bf-couleurs-tableaux-p, t => t + (primaire: tableaux-defauts.primaire))
#let resetcouleurssecondarytabular() = bf-maj(bf-couleurs-tableaux-p, t => t + (secondaire: tableaux-defauts.secondaire))

// ---------- Autres macros d'état de bfcours-colors.sty ----------

/// Valeurs par défaut des 18 macros d'état de bfcours-colors.sty (`COL:34-60`, `:114`) et de
/// `\boitecouleur` (bfcours-boiteReponseInsertbox, piloté par `\CouleurTexteAccent`), en expressions xcolor.
#let couleurs-courantes-defauts = (
  lienInterneColor: "red!50!yellow",
  currentBackgroundColor: "white",
  currentFrameColor: "white",
  currentTitleColor: "black",
  currentColContainerBackgroundColor: "white",
  currentColContainerFrameColor: "white",
  currentAccentColor: "black",
  currentTableFrameColor: "blue!50!black",
  currentTableColbackTitleColor: "blue!50!black",
  currentTableColTitleColor: "white",
  currentTableColbackColor: "white",
  currentTableColupperColor: "red!50!black",
  currentSecondaryTableFrameColor: "red!50!black",
  currentSecondaryTableColbackTitleColor: "Salmon!30!white",
  currentSecondaryTableColTitleColor: "black",
  currentSecondaryTableColbackColor: "yellow!10!white",
  currentSecondaryTableColupperColor: "red!50!black",
  itemBaseColor: "gray!80!black",
  boitecouleur: "gray!75!black",
)

// Macros rangées dans `bf-couleurs-tableaux` : nom LaTeX → (tableau, champ).
#let _macros-tableaux = (
  currentTableFrameColor: ("primaire", "cadre"),
  currentTableColbackTitleColor: ("primaire", "fond-titre"),
  currentTableColTitleColor: ("primaire", "texte-titre"),
  currentTableColbackColor: ("primaire", "fond"),
  currentTableColupperColor: ("primaire", "texte"),
  currentSecondaryTableFrameColor: ("secondaire", "cadre"),
  currentSecondaryTableColbackTitleColor: ("secondaire", "fond-titre"),
  currentSecondaryTableColTitleColor: ("secondaire", "texte-titre"),
  currentSecondaryTableColbackColor: ("secondaire", "fond"),
  currentSecondaryTableColupperColor: ("secondaire", "texte"),
)

// Macros sans état ancien (les autres vivent dans bf-couleur, bf-couleur-item, bf-couleurs-tableaux).
#let _macros-propres = (
  "lienInterneColor", "currentBackgroundColor", "currentFrameColor", "currentTitleColor",
  "currentColContainerBackgroundColor", "currentColContainerFrameColor", "boitecouleur",
)

/// État des macros de couleur qui n'avaient pas d'état : `\lienInterneColor`, `\currentBackgroundColor`,
/// `\currentFrameColor`, `\currentTitleColor`, `\currentColContainer…Color` ×2, `\boitecouleur`.
/// Valeurs : expressions xcolor (chaînes) ou couleurs Typst.
#let bf-couleurs-courantes-p = bf-etat(
  "bf-couleurs-courantes",
  _macros-propres.map(n => (n, couleurs-courantes-defauts.at(n))).to-dict(),
)
#let bf-couleurs-courantes = bf-couleurs-courantes-p.etat

/// `\boitecouleur` FIXÉE par l'utilisateur (`setbfcolors(boitecouleur: …)`) ; `none` : la boîte suit la
/// couleur d'accent (comportement de `\CouleurTexteAccent`). Ramené de farfadet-didactique lors de
/// l'épurage (07/10/2026) : même clé d'état « bf-boitecouleur-fixe », donc le même état que celui que lit
/// `bf-boitecouleur` de didactique.
#let bf-boitecouleur-fixe-p = bf-etat("bf-boitecouleur-fixe", none)
#let bf-boitecouleur-fixe = bf-boitecouleur-fixe-p.etat

/// Couleur EFFECTIVE d'une macro d'état, par son nom LaTeX (« currentAccentColor »…). À appeler dans un `context`.
#let bf-couleur-courante(nom) = {
  if nom == "currentAccentColor" { return bf-lire(bf-couleur-p) }
  if nom == "itemBaseColor" { return bf-lire(bf-couleur-item-p) }
  if nom in _macros-tableaux {
    let (t, k) = _macros-tableaux.at(nom)
    return bf-resoudre-couleur(bf-lire(bf-couleurs-tableaux-p).at(t).at(k))
  }
  if nom in _macros-propres { return bf-resoudre-couleur(bf-lire(bf-couleurs-courantes-p).at(nom)) }
  panic("macro de couleur inconnue « " + str(nom) + " ». Macros possibles : " + couleurs-courantes-defauts.keys().map(k => "« " + k + " »").join(", ") + ".")
}

/// \renewcommand{\<macro>}{valeur} pour une macro d'état de couleur (nom LaTeX). `valeur` : couleur Typst
/// ou expression xcolor. Contrairement à `couleurstabular`, ne touche pas aux filets (\arrayrulecolor).
#let bf-regler-couleur-courante(nom, valeur) = {
  if nom == "currentAccentColor" { return context bf-maj(bf-couleur-p, bf-resoudre-couleur(valeur)) }
  if nom == "itemBaseColor" { return context bf-maj(bf-couleur-item-p, bf-resoudre-couleur(valeur)) }
  if nom in _macros-tableaux {
    let (t, k) = _macros-tableaux.at(nom)
    return bf-maj(bf-couleurs-tableaux-p, d => {
      let sous = d.at(t)
      sous.insert(k, valeur)
      d.insert(t, sous)
      d
    })
  }
  if nom in _macros-propres { return bf-maj(bf-couleurs-courantes-p, d => d + ((nom): valeur)) }
  panic("macro de couleur inconnue « " + str(nom) + " ». Macros possibles : " + couleurs-courantes-defauts.keys().map(k => "« " + k + " »").join(", ") + ".")
}

/// \CouleurTexteAccent{c} (couleur d'accent ET \boitecouleur), \ResetCouleurTexteAccent
/// (accent noir, \boitecouleur = gray!75!black), comme `COL:102-110`.
#let couleurtexteaccent(c) = {
  context bf-maj(bf-couleur-p, bf-resoudre-couleur(c))
  bf-maj(bf-couleurs-courantes-p, d => d + (boitecouleur: c))
}
#let resetcouleurtexteaccent() = {
  bf-maj(bf-couleur-p, black)
  bf-maj(bf-couleurs-courantes-p, d => d + (boitecouleur: couleurs-courantes-defauts.boitecouleur))
}

// \bfdSetColors… : réglages de couleurs d'un environnement didactique. Chaque variante calcule les
// nouvelles valeurs des trois états de couleur (accent, tableaux, badges) ; `bf-couleurs-reglage`
// les applique dans une portée (environnement, via `bf-porter`), la commande publique les pose pour la
// suite du document (état).
#let _bfd-descr = (
  "bf-couleur": bf-couleur-p,
  "bf-couleurs-tableaux": bf-couleurs-tableaux-p,
  "bf-couleur-item": bf-couleur-item-p,
)

/// Valeurs posées par une variante de \bfdSetColors… (dictionnaire clé d'état → valeur). Dans un `context`.
#let _bfd-valeurs(variante, c) = {
  if variante in ("theoreme", "definition") {
    let k = xcouleur(if variante == "theoreme" { "thm" } else { "defi" }) // couleur nommée courante (setbfcolors)
    let secondaire = if variante == "theoreme" {
      (cadre: k, fond-titre: "Salmon!30!white", texte-titre: black, fond: "yellow!10!white", texte: k)
    } else {
      (cadre: k, fond-titre: xmix(k, 30), texte-titre: black, fond: xmix(k, 5), texte: k)
    }
    (
      "bf-couleur": k,
      "bf-couleurs-tableaux": (
        primaire: (cadre: k, fond-titre: k, texte-titre: white, fond: xmix(k, 5), texte: "blue!50!black", filets: k),
        secondaire: secondaire,
      ),
      "bf-couleur-item": k,
    )
  } else {
    let (k, k5, k30, k80) = (bf-teinte(c), bf-teinte(c, suffixe: "!5"), bf-teinte(c, suffixe: "!30!white"), bf-teinte(c, suffixe: "!80!black"))
    let res = (
      "bf-couleur": k80,
      "bf-couleurs-tableaux": (
        primaire: (cadre: k, fond-titre: k, texte-titre: white, fond: k5, texte: "blue!50!black", filets: k),
        secondaire: (cadre: k, fond-titre: k30, texte-titre: black, fond: k5, texte: k),
      ),
    )
    if variante == "setcolors" { res.insert("bf-couleur-item", k) }
    res
  }
}

// Commande publique : marqueur lisible par `bf-couleurs-reglage`, puis mises à jour d'état.
#let _bfd-reglage(variante, c) = [#metadata((bfr-couleurs: variante, arg: c))#context {
    for (cle, v) in _bfd-valeurs(variante, c) { bf-maj(_bfd-descr.at(cle), v) }
  }]

/// \bfdSetColors{c} : réglage de couleurs d'un environnement didactique (accent c!80!black,
/// tableaux primaires et secondaires, badges). À placer au début du corps de l'environnement.
#let bfdsetcolors(c) = _bfd-reglage("setcolors", c)

/// Variante Théorème (\bfdSetColorsTheoreme) : accent = thm, secondaire Salmon/jaune.
#let bfdsetcolorstheoreme() = _bfd-reglage("theoreme", none)

/// Variante Définition (\bfdSetColorsDefinition) : accent = defi.
#let bfdsetcolorsdefinition() = _bfd-reglage("definition", none)

/// Variante sans couleur de badges (\bfdSetColorsNoItem, Notation et Aide).
#let bfdsetcolorsnoitem(c) = _bfd-reglage("noitem", c)

/// Interprète un réglage de couleurs d'environnement sans le poser : `reglage` est un contenu fait de
/// \bfdSetColors… et de mises à jour (`bf-maj`) des états de couleur (`couleurstabular`, accroches de
/// palette…). Renvoie `valeurs` (dictionnaire clé d'état → valeur) modifié dans l'ordre du contenu.
/// Ce qui n'est pas un réglage de couleur est ignoré. Dans un `context`.
#let bf-couleurs-reglage(reglage, valeurs) = {
  if type(reglage) != content { return valeurs }
  let v = valeurs
  let pile = (reglage,)
  while pile.len() > 0 {
    let x = pile.pop()
    let f = x.func()
    if f == [].func() or f == [a#h(1pt)b].func() {
      if x.has("children") { pile += x.children.rev() }
    } else if f == metadata and type(x.value) == dictionary {
      let m = x.value
      if "bfr-couleurs" in m { v += _bfd-valeurs(m.bfr-couleurs, m.arg) }
      else if "bfr-maj" in m and m.bfr-maj in v { v.insert(m.bfr-maj, (m.f)(v.at(m.bfr-maj))) }
    } else if x.has("child") { pile.push(x.child) }
  }
  v
}

/// \bfdResetColors (et \bfdResetColorsNoItem, qui garde la couleur des badges).
#let bfdresetcolors() = {
  bf-maj(bf-couleur-item-p, couleurs.item-base)
  bf-maj(bf-couleurs-tableaux-p, tableaux-defauts)
  bf-maj(bf-couleur-p, black)
}
#let bfdresetcolorsnoitem() = {
  bf-maj(bf-couleurs-tableaux-p, tableaux-defauts)
  bf-maj(bf-couleur-p, black)
}

// =====================================================================
// Analyse STRICTE des couleurs : pour les commandes publiques
// =====================================================================
// `couleur` et `xcolor` (plus haut) ne font jamais échouer la compilation (le convertisseur en dépend).
// Les commandes publiques, elles, doivent signaler une couleur inconnue : elles passent par `bf-xcolor`.

#let _hexa = regex("^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{4}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$")
#let _pourcentage = regex("^[0-9]+(\.[0-9]+)?$")
#let _types-couleur = (color, gradient, tiling)

/// Le nom `nom` désigne-t-il une couleur connue ? (`perso` : couleurs de definecolor/colorlet).
#let bf-couleur-connue(nom, perso: (:)) = (
  nom in perso or nom in couleurs or nom in xc or nom in svgnames or nom in couleurs-courantes-defauts
    or nom.match(_hexa) != none
)

/// Expression xcolor → couleur, en signalant toute erreur (nom inconnu, proportion invalide).
/// Connaît les 22 couleurs de bfcours-colors, les couleurs nommées des autres modules, xcolor, svgnames,
/// les couleurs de definecolor/colorlet et les 18 macros d'état (`currentAccentColor!50`…).
/// Une couleur Typst passe telle quelle. À appeler dans un `context`.
#let bf-xcolor(expr, commande: "xcolor") = {
  if type(expr) in _types-couleur { return expr }
  // marqueur de couleur nommée (bf-nommee) : on résout son expression
  if bf-est-nommee(expr) { expr = expr.bf-nommee }
  if type(expr) != str {
    panic(commande + " : couleur attendue (couleur Typst ou expression xcolor comme \"thm!80!black\") ; reçu : " + repr(expr) + ".")
  }
  let perso = bf-lire(bf-couleurs-perso-p)
  let e = expr.trim()
  let corps = if e.starts-with("-") { e.slice(1) } else { e }
  let morceaux = corps.split("!").map(m => m.trim())
  let macros = (:)
  for (i, m) in morceaux.enumerate() {
    if calc.even(i) {
      if not bf-couleur-connue(m, perso: perso) {
        panic(
          commande + " : couleur inconnue « " + m + " » dans " + repr(expr)
            + ". Noms possibles : les couleurs de bfcours (thm, defi, prop, demo, meth, act, rem, nota, ex, nombres, gestion, grandeurs, geo, algo, correction, monrose…), de xcolor (red, blue, gray…), de svgnames (Salmon, DarkBlue, ForestGreen…), celles de definecolor ou colorlet, les macros d'état (currentAccentColor, itemBaseColor…) ou \"#RRGGBB\".",
        )
      }
      if m in couleurs-courantes-defauts and m not in perso { macros.insert(m, bf-couleur-courante(m)) }
    } else if m.match(_pourcentage) == none or float(m) > 100 {
      panic(commande + " : proportion invalide « " + m + " » dans " + repr(expr) + ". Valeurs possibles : un nombre de 0 à 100 (\"red!30!white\").")
    }
  }
  xcolor(e, perso: perso + macros)
}

// Lecture d'une liste de composantes « 56,128,77 » ou (56, 128, 77).
#let _composantes(valeur, n, commande, modele) = {
  let vs = if type(valeur) == str { valeur.split(",").map(x => x.trim()) } else if type(valeur) == array { valeur } else { (valeur,) }
  if vs.len() != n {
    panic(commande + " : le modèle « " + modele + " » attend " + str(n) + " composante(s) ; reçu : " + repr(valeur) + ".")
  }
  vs.map(x => {
    if type(x) in (int, float) { x } else if type(x) == str and x.match(regex("^-?[0-9]*(\.[0-9]+)?$")) != none and x != "" {
      float(if x.starts-with(".") { "0" + x } else { x })
    } else { panic(commande + " : composante invalide " + repr(x) + " pour le modèle « " + modele + " ».") }
  })
}

#let _dans(x, a, b, commande, modele) = {
  if x < a or x > b { panic(commande + " : composante " + str(x) + " hors de [" + str(a) + ", " + str(b) + "] pour le modèle « " + modele + " ».") }
  x
}

/// Modèles de couleur reconnus par `bf-couleur-modele` (ceux de \definecolor de xcolor).
#let bf-modeles-couleur = ("RGB", "rgb", "HTML", "cmyk", "cmy", "gray", "Gray", "hsb", "HSB", "Hsb")

/// \definecolor : (modèle, valeur) → couleur Typst. `valeur` : chaîne LaTeX (« 56,128,77 », « FF1493 »,
/// « 0,.8,.95,0 ») ou tableau de nombres.
#let bf-couleur-modele(modele, valeur, commande: "definecolor") = {
  if modele not in bf-modeles-couleur {
    panic(commande + " : modèle de couleur inconnu « " + str(modele) + " ». Modèles possibles : " + bf-modeles-couleur.map(m => "« " + m + " »").join(", ") + ".")
  }
  if modele == "HTML" {
    let h = if type(valeur) == str { valeur.trim().trim("#") } else { "" }
    if h.match(regex("^[0-9A-Fa-f]{6}$")) == none {
      panic(commande + " : le modèle « HTML » attend six chiffres hexadécimaux (\"FF1493\") ; reçu : " + repr(valeur) + ".")
    }
    return rgb("#" + h)
  }
  if modele == "RGB" {
    let (r, g, b) = _composantes(valeur, 3, commande, modele).map(x => _dans(x, 0, 255, commande, modele))
    return rgb(r / 255 * 100%, g / 255 * 100%, b / 255 * 100%)
  }
  if modele == "rgb" {
    let (r, g, b) = _composantes(valeur, 3, commande, modele).map(x => _dans(x, 0, 1, commande, modele))
    return rgb(r * 100%, g * 100%, b * 100%)
  }
  if modele == "cmyk" {
    let (c, m, y, k) = _composantes(valeur, 4, commande, modele).map(x => _dans(x, 0, 1, commande, modele))
    return cmyk(c * 100%, m * 100%, y * 100%, k * 100%)
  }
  if modele == "cmy" {
    let (c, m, y) = _composantes(valeur, 3, commande, modele).map(x => _dans(x, 0, 1, commande, modele))
    return rgb((1 - c) * 100%, (1 - m) * 100%, (1 - y) * 100%)
  }
  if modele == "gray" {
    let (g,) = _composantes(valeur, 1, commande, modele).map(x => _dans(x, 0, 1, commande, modele))
    return rgb(g * 100%, g * 100%, g * 100%)
  }
  if modele == "Gray" {
    let (g,) = _composantes(valeur, 1, commande, modele).map(x => _dans(x, 0, 15, commande, modele))
    return rgb(g / 15 * 100%, g / 15 * 100%, g / 15 * 100%)
  }
  // hsb (0-1), HSB (0-240), Hsb (teinte en degrés 0-360, s et b 0-1)
  let (h, s, b) = _composantes(valeur, 3, commande, modele)
  let (h, s, b) = if modele == "hsb" {
    (_dans(h, 0, 1, commande, modele) * 360, _dans(s, 0, 1, commande, modele), _dans(b, 0, 1, commande, modele))
  } else if modele == "HSB" {
    (_dans(h, 0, 240, commande, modele) / 240 * 360, _dans(s, 0, 240, commande, modele) / 240, _dans(b, 0, 240, commande, modele) / 240)
  } else {
    (_dans(h, 0, 360, commande, modele), _dans(s, 0, 1, commande, modele), _dans(b, 0, 1, commande, modele))
  }
  rgb(color.hsv(h * 1deg, s * 100%, b * 100%))
}

/// Nom de couleur valide pour \definecolor / \colorlet (chaîne non vide, sans « ! » ni espace).
#let bf-verifier-nom-couleur(nom, commande) = {
  if type(nom) != str or nom.trim() == "" or nom.contains("!") or nom.contains(" ") {
    panic(commande + " : nom de couleur invalide " + repr(nom) + ". Un nom est une chaîne sans espace ni « ! » (\"macouleur\").")
  }
  nom
}

/// \definecolor{nom}{modèle}{valeur} : enregistre `nom` pour toutes les expressions xcolor qui suivent.
#let bf-definecolor(nom, modele, valeur, commande: "definecolor") = {
  let _ = bf-verifier-nom-couleur(nom, commande)
  let c = bf-couleur-modele(modele, valeur, commande: commande)
  bf-maj(bf-couleurs-perso-p, d => d + ((nom): c))
}

/// \colorlet{nom}{expression} : l'expression est évaluée IMMÉDIATEMENT (comme xcolor), puis enregistrée.
#let bf-colorlet(nom, expr, commande: "colorlet") = {
  let _ = bf-verifier-nom-couleur(nom, commande)
  context {
    let c = bf-xcolor(expr, commande: commande)
    bf-maj(bf-couleurs-perso-p, d => d + ((nom): c))
  }
}

// =====================================================================
// Couleurs NOMMÉES : lecture directe et setbfcolors (épurage, 07/10/2026)
// =====================================================================
// Une couleur nommée de bfcours (`thm`, `defi`, `monrose`, `geo`…) a une valeur d'origine (`couleurs`)
// et une valeur COURANTE : celle de `bf-couleurs-perso` si `setbfcolors` (ou `colorlet`, `definecolor`)
// l'a changée. Les macros d'état (`current-accent-color`…) ont leur propre état (plus haut).
// Doc : ../REGLAGES.md, section « Couleurs nommées ».

/// Les couleurs nommées de bfcours que `setbfcolors` change (palette `couleurs` sans ses noms internes
/// `lien-interne`, `item-base`, `base` : les deux premiers se règlent par les macros `lienInterneColor`
/// et `item-base-color`).
#let bf-noms-couleurs-nommees = couleurs.keys().filter(k => k not in ("lien-interne", "item-base", "base"))

/// Valeur COURANTE d'une couleur nommée, d'une macro d'état ou d'une expression xcolor qui en contient
/// (`"defi"`, `"currentAccentColor"`, `"thm!20"`) ; accepte aussi un marqueur `bf-nommee(…)` ou une couleur
/// Typst (rendue telle quelle). Erreur explicite sur un nom inconnu. À appeler dans un `context`.
#let bf-couleur-nommee(expr, commande: "bf-couleur-nommee") = bf-xcolor(expr, commande: commande)

/// Moteur de `setbfcolors` : change la valeur de base des couleurs nommées de bfcours et des macros
/// d'état, pour la suite du document. Les valeurs sont évaluées tout de suite (comme `\colorlet`), dans
/// l'ordre d'écriture. `reinitialiser: true` ramène d'abord toutes les couleurs nommées (y compris celles
/// changées par `colorlet`/`definecolor` sous un nom de bfcours) et toutes les macros à leur valeur
/// d'origine. `boitecouleur: auto` rend à `\boitecouleur` la couleur d'accent.
#let bf-regler-couleurs(commande: "setbfcolors", reinitialiser: false, ..args) = {
  if args.pos().len() > 0 {
    panic(commande + " : seuls des arguments nommés sont acceptés (thm: …, defi: …) ; reçu : " + repr(args.pos().first()) + ".")
  }
  if type(reinitialiser) != bool {
    panic(commande + " : la clé « reinitialiser » attend true ou false ; reçu : " + repr(reinitialiser) + ".")
  }
  let possibles = bf-noms-couleurs-nommees + couleurs-courantes-defauts.keys()
  for (nom, v) in args.named() {
    if nom not in possibles {
      panic(
        commande + " : couleur inconnue « " + nom + " ». Noms possibles : "
          + possibles.map(k => "« " + k + " »").join(", ") + ".",
      )
    }
    let ok = type(v) in _types-couleur or type(v) == str or bf-est-nommee(v) or (nom == "boitecouleur" and v == auto)
    if not ok {
      panic(
        commande + " : valeur invalide pour « " + nom + " » : " + repr(v)
          + ". Valeurs possibles : une couleur Typst ou une expression xcolor (\"thm!80!black\")"
          + (if nom == "boitecouleur" { ", ou auto" } else { "" }) + ".",
      )
    }
  }
  if reinitialiser {
    bf-maj(bf-couleurs-perso-p, d => d.pairs().filter(((k, _)) => k not in bf-noms-couleurs-nommees and k != "lien-interne").to-dict())
    bf-maj(bf-couleur-p, black)
    bf-maj(bf-couleur-item-p, couleurs.item-base)
    bf-maj(bf-couleurs-tableaux-p, tableaux-defauts)
    bf-maj(bf-couleurs-courantes-p, _ => _macros-propres.map(n => (n, couleurs-courantes-defauts.at(n))).to-dict())
    bf-maj(bf-boitecouleur-fixe-p, none)
  }
  for (nom, v) in args.named() {
    if nom == "boitecouleur" and v == auto {
      bf-maj(bf-boitecouleur-fixe-p, none)
      bf-maj(bf-couleurs-courantes-p, d => d + (boitecouleur: couleurs-courantes-defauts.boitecouleur))
      continue
    }
    context {
      let c = bf-xcolor(v, commande: commande + " (" + nom + ")")
      if nom in bf-noms-couleurs-nommees {
        bf-maj(bf-couleurs-perso-p, d => d + ((nom): c))
      } else if nom == "currentAccentColor" {
        // comme \CouleurTexteAccent : l'accent ET \boitecouleur
        bf-maj(bf-couleur-p, c)
        bf-maj(bf-couleurs-courantes-p, d => d + (boitecouleur: c))
      } else if nom == "itemBaseColor" {
        bf-maj(bf-couleur-item-p, c)
      } else if nom == "lienInterneColor" {
        bf-maj(bf-couleurs-courantes-p, d => d + ((nom): c))
        bf-maj(bf-couleurs-perso-p, d => d + ("lien-interne": c))
      } else if nom == "boitecouleur" {
        bf-maj(bf-boitecouleur-fixe-p, c)
        bf-maj(bf-couleurs-courantes-p, d => d + (boitecouleur: c))
      } else if nom in _macros-tableaux {
        let (quel, champ) = _macros-tableaux.at(nom)
        bf-maj(bf-couleurs-tableaux-p, t => {
          let x = t.at(quel)
          x.insert(champ, c)
          // \CouleursTabular : les filets (\arrayrulecolor) suivent le cadre des tableaux primaires
          if quel == "primaire" and champ == "cadre" { x.insert("filets", c) }
          t.insert(quel, x)
          t
        })
      } else {
        bf-maj(bf-couleurs-courantes-p, d => d + ((nom): c))
      }
    }
  }
}

