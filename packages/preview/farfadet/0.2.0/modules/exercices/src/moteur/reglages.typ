// reglages.typ (farfadet-exo) — registres de réglages du paquet, par le mécanisme générique du socle.
//
// Cinq registres, tous réglés par l'unique setter `setrdexo` (voir exo.typ) :
// - « exo »          : clés des exercices, types `exo`, `exo-eval` ;
// - « exo-skins »    : couleurs (et cotes) de chaque thème, un type par thème ;
// - « rdexostars »   : clés des étoiles ;
// - « exo-divers »   : boîtes de points, tableaux de compétences, cartouches d'évaluation, chronomètre,
//                      sujets d'examen ;
// - « exolombards »  : options de l'habillage exolombards.
//
// Les couleurs par défaut sont des couleurs nommées de bfcours (marqueur `bf-nommee`), sauf celles des
// thèmes default, pooja, rikid, griba et objiva.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: *

/// Police sans empattement de rdexo (\sffamily de bfcours : Latin Modern Sans).
#let bf-exo-sans = ("Latin Modern Sans", "TeX Gyre Heros")

/// Couleurs propres à rdexo.sty (l. 73-74), connues de toutes les expressions xcolor du paquet.
#let bf-exo-couleurs = (
  starcolor: rgb("#FFDD00"),
  rdexored: rgb("#940B20"),
)

/// Couleur : valeur Typst, ou expression xcolor (« gray!20 », « rdexored!70 », « starcolor »).
/// Connaît les couleurs de bfcours, de rdexo et celles de \definecolor. À appeler dans un `context`.
#let bf-exo-couleur(v) = {
  if v == none or v == auto { return v }
  if type(v) != str { return v }
  xcolor(v, perso: bf-exo-couleurs + bf-lire(bf-couleurs-perso-p))
}

/// Taille LaTeX nommée pour la police sans (Latin Modern n'est pas réduite comme Utopia).
#let bf-exo-taille-sans(nom) = tailles-latex.at(bf-lire(bf-police-p).schema).at(nom)

#let _noms-tailles = ("tiny", "scriptsize", "footnotesize", "small", "normalsize", "large", "Large", "LARGE", "huge", "Huge")

/// Police LaTeX (« \sffamily\bfseries\footnotesize ») ou dictionnaire (font:, weight:, style:, size:)
/// → réglages de `text`. `size` : nom de taille LaTeX ou longueur. À appeler dans un `context`.
#let bf-exo-police(spec) = {
  if spec == none or spec == auto { return (:) }
  let d = (:)
  if type(spec) == str {
    let sans = spec.contains("\\sffamily") or spec.contains("\\textsf")
    if sans { d.insert("font", bf-exo-sans) }
    if spec.contains("\\bfseries") or spec.contains("\\textbf") { d.insert("weight", "bold") }
    if spec.contains("\\mdseries") or spec.contains("\\normalfont") { d.insert("weight", "regular") }
    if spec.contains("\\itshape") or spec.contains("\\slshape") { d.insert("style", "italic") }
    if spec.contains("\\upshape") { d.insert("style", "normal") }
    for nom in _noms-tailles {
      if spec.contains(regex("\\\\" + nom + "(?:[^a-zA-Z]|$)")) {
        d.insert("size", if sans { bf-exo-taille-sans(nom) } else { taille-latex(nom) })
      }
    }
    return d
  }
  let sans = spec.at("font", default: none) in ("sans", "sf")
  for (k, v) in spec {
    if k == "font" { d.insert("font", if v in ("sans", "sf") { bf-exo-sans } else { v }) }
    else if k == "size" {
      d.insert("size", if type(v) == str { if sans { bf-exo-taille-sans(v) } else { taille-latex(v) } } else { v })
    } else { d.insert(k, v) }
  }
  d
}

// =====================================================================
// Contrôles communs
// =====================================================================

#let _c = reglages-controles
#let _couleur = _c.couleur-ou-nom
#let _police = (v => type(v) in (str, dictionary), "une police LaTeX (\"\\sffamily\\bfseries\\small\") ou un dictionnaire (font: \"sans\", weight: \"bold\", size: \"small\")")
#let _contenu = (v => type(v) in (str, content), "un contenu ou une chaîne")
#let _contenu-ou-none = (v => v == none or type(v) in (str, content), "none ou un contenu")
#let _longueur = _c.longueur
#let _nombre-ou-auto = (v => v == auto or type(v) in (int, float), "auto ou un nombre")
#let _nombre-auto-none = (v => v == auto or v == none or type(v) in (int, float), "auto, none (absent) ou un nombre")
#let _cadre = (v => v == auto or v == none or type(v) == function, "auto (cadre du thème), none (aucun cadre) ou une fonction (info, contenu) => contenu")
#let _dico = (v => type(v) == dictionary, "un dictionnaire de clés, par exemple (position: \"right\")")

// =====================================================================
// Couleurs par défaut : marqueurs `bf-nommee` (convention 2 de l'épurage)
// =====================================================================

/// Couleur par défaut → marqueur `bf-nommee(…)`, résolu AU RENDU par `reglages-resoudre` :
/// une expression xcolor (« gray!20 », « starcolor ») ou une constante Typst `black` / `white`.
/// Les couleurs `starcolor` et `rdexored` sont des couleurs nommées du socle : `setbfcolors`
/// les change partout. Les autres valeurs gardent la teinte d'origine de rdexo.
#let _nom(v) = {
  if type(v) == str { bf-nommee(v) } else if v == black { bf-nommee("black") } else if v == white { bf-nommee("white") } else { v }
}

/// Applique `_nom` aux clés de couleur d'un dictionnaire de défauts (clés en `-color`, `colback`,
/// `colframe`, `coltext`, `color`, `colback-…`, `couleur-code`, `star-color`…).
#let _nommer(d) = d.pairs().map(((k, v)) => (
  k,
  if k.ends-with("-color") or k.starts-with("colback") or k in ("colframe", "coltext", "color", "couleur-code", "star-background") { _nom(v) } else { v },
)).to-dict()

// =====================================================================
// 1. Registre « exo » : \setrdexo
// =====================================================================

/// Sous-clés de `lower` (/tcb/rdexo/lower/…, rdexo.sty l. 769-801).
#let bf-lower-defauts = (
  position: "bottom",
  width: 40%,
  skip: 3mm,
  box: "crep",
  style: (:),
  raster: (:),
  mirror: false,
)
#let bf-lower-cles = bf-lower-defauts.keys() + ("left", "right", "seyes-left", "seyes-right")

/// Sous-clés de `correction` (/tcb/rdexo/correction/…, rdexo.sty l. 263-277).
#let bf-correction-defauts = (
  columns: 1,
  raster: (:),
  mirror: false,
  mirror-style: (:),
  reset-num-start: true,
)

/// Clés locales des boîtes de correction (\setcorrectionstyle, raster, mirror style, style de la boîte basse).
#let bf-cles-boite = (
  "colback", "colframe", "coltext", "boxrule", "arc", "boxsep", "left", "right", "top", "bottom",
  "fontupper", "halign", "width", "height", "opacityback", "seyes", "extra-lines",
  "raster-column-skip", "raster-row-skip", "raster-equal-height", "raster-before-skip", "raster-after-skip",
)

#let _controle-sous-cles(nom, permises) = (
  v => type(v) == dictionary and v.keys().all(k => k in permises),
  "un dictionnaire dont les clés sont " + reglages-liste(permises),
)

/// Défauts de \setrdexo tels que les règle bfcours (bfcours-use_rdexo_rdcrep.sty, l. 260-276).
#let bf-exo-defauts = (
  skin: "bouyachakka",
  exo-header: "tcolorbox",
  header-skip: ptl(6),
  label: "Exercice",
  display-numexo: true,
  numexo: auto,
  display-score: true,
  score: auto,
  // ajout : un score calculé nul (aucun point dans l'énoncé) s'affiche-t-il (« / 0 », « 0 point ») ?
  // bfcours l'affiche ; false (défaut) le traite comme absent, sans cartouche vide
  display-zero-score: false,
  score-label: ("point", "points"),
  display-level: true,
  level: auto,
  display-exotitle: true,
  exotitle: none,
  exotitle-color: bf-nommee("black"),
  exotitle-font: "\\sffamily\\bfseries\\footnotesize",
  display-lower: auto,
  lower: (:),
  save-lower: false,
  tags: (),
  // étiquettes en marge : "correction" = version professeur seulement (overlay={\ifcorrection …}
  // des documents réels), true = toujours, false = jamais
  display-tags: "correction",
  // ajout : étiquettes sous le bandeau — si elles tiennent dans cette part de la ligne, l'énoncé commence sur
  // leur ligne, à leur gauche (le texte s'enroule autour) ; au-delà, elles gardent leur ligne ; none = toujours
  // sur leur ligne (comportement de bfcours)
  tags-wrap: 50%,
  correction-as-lower: false,
  // ajout : cadre autour de l'exercice entier / de sa correction. auto = celui du thème (aucun par défaut),
  // none = aucun cadre (même si le thème en a un), (info, contenu) => contenu = ce cadre
  cadre: auto,
  cadre-correction: auto,
  breakable: true,
  after-skip: ptl(10),
  sommaire: true,
  exo: (:),
  correction: (:),
  // niveaux de maîtrise (\mi, \mf, \ms, \tbm) en émojis (true, "images") ou en texte gras (false)
  emoji: true,
)

#let bf-exo-controles = (
  skin: (v => type(v) == str, "le nom d'un thème : \"bouyachakka\", \"default\", \"pooja\", \"rikid\", \"griba\", \"objiva\", \"exobac\", \"exobrevet\", \"exolombards\" ou un thème déclaré par rdexoSkin"),
  emoji: reglages-choix(true, false, "images"),
  exo-header: reglages-choix("none", "tcbox", "tcolorbox"),
  header-skip: _longueur,
  label: _contenu,
  display-numexo: _c.booleen,
  numexo: (v => v == auto or type(v) == int, "auto ou un entier"),
  display-score: _c.booleen,
  score: _nombre-auto-none,
  display-zero-score: _c.booleen,
  score-label: (v => type(v) == array and v.len() == 2, "un tableau de deux libellés (singulier, pluriel), par exemple (\"point\", \"points\")"),
  display-level: _c.booleen,
  level: _nombre-auto-none,
  display-exotitle: _c.booleen,
  exotitle: _contenu-ou-none,
  exotitle-color: _couleur,
  exotitle-font: _police,
  display-lower: reglages-choix(auto, true, false),
  lower: _controle-sous-cles("lower", bf-lower-cles),
  save-lower: _c.booleen,
  tags: (v => type(v) in (str, array, content), "une chaîne « a, b », un tableau de chaînes ou un contenu"),
  display-tags: reglages-choix(true, false, "correction"),
  tags-wrap: (v => v == none or type(v) == ratio, "none ou une proportion de la ligne, par exemple 50%"),
  correction-as-lower: _c.booleen,
  cadre: _cadre,
  cadre-correction: _cadre,
  breakable: _c.booleen,
  after-skip: _longueur,
  sommaire: _c.booleen,
  exo: (v => type(v) == dictionary and v.values().all(x => type(x) == dictionary), "un dictionnaire numéro → clés, par exemple (\"3\": (display-score: false))"),
  correction: _controle-sous-cles("correction", bf-correction-defauts.keys()),
)

#let bf-exo-registre = reglages-paquet(
  "exo",
  bf-exo-defauts,
  controles: bf-exo-controles,
  types: (EXO: (:), EXOEVAL: (:)),
  commande: "setrdexo",
)

/// Types que `setrdexo(pour: …)` adresse au registre des exercices.
#let bf-types-exercice = ("EXO", "EXOEVAL")

/// Fusion des clés à valeur dictionnaire (`lower`, `correction`, `exo`) d'un niveau à l'autre :
/// en LaTeX, `lower={box=crep}` puis `lower={position=right}` cumulent les deux sous-clés.
/// À appeler dans un `context`.
#let bf-exo-fusion(cle, pour: none, local: (:)) = {
  let e = bf-lire(bf-exo-registre)
  let res = bf-exo-defauts.at(cle)
  let ajouter(res, d) = {
    let v = d.at(cle, default: auto)
    if type(v) == dictionary { res + v } else { res }
  }
  // styles nommés du réglage global, puis clés globales, puis le type, puis les clés locales
  for nom in (e.global.at("style", default: ()),).flatten() {
    if nom != none and nom in e.styles { res = ajouter(res, e.styles.at(nom)) }
  }
  res = ajouter(res, e.global)
  if pour != none { res = ajouter(res, e.types.at(pour, default: (:))) }
  for nom in (local.at("style", default: ()),).flatten() {
    if nom != none and nom in e.styles { res = ajouter(res, e.styles.at(nom)) }
  }
  ajouter(res, local)
}

// =====================================================================
// 2. Registre « exo-skins » : `setrdexo(pour: "<thème>", …)`
// =====================================================================

/// Couleurs de chaque thème (rdexo.sty l. 1196-1866 ; bfcours-use_rdexo_rdcrep.sty l. 69-83 ;
/// bfcours-exobac.sty l. 142-155 et 270-282). `auto` : sans objet pour ce thème.
#let bf-skins-defauts = (
  default: (
    bg-color: "gray!10", fg-color: black, frame-color: black,
    star-fg-color: "starcolor", star-bg-color: "gray!20", star-line-color: black,
    score-fg-color: white, score-bg-color: black, lower-bg-color: "gray",
    tags-bg-color: "black!70", tags-fg-color: white,
    arc: ptl(6), righthand-width: auto,
  ),
  pooja: (
    bg-color: "gray!20", fg-color: black, frame-color: black,
    star-fg-color: "starcolor", star-bg-color: "gray!20", star-line-color: black,
    score-fg-color: white, score-bg-color: black, lower-bg-color: "gray",
    tags-bg-color: "black!70", tags-fg-color: white,
    arc: ptl(6), righthand-width: 1.8cm,
  ),
  rikid: (
    bg-color: "rdexored", fg-color: white, frame-color: black,
    star-fg-color: "starcolor", star-bg-color: "gray!20", star-line-color: black,
    score-fg-color: "rdexored", score-bg-color: white, lower-bg-color: "orange",
    tags-bg-color: "rdexored!70", tags-fg-color: white,
    arc: ptl(2), righthand-width: auto,
  ),
  griba: (
    bg-color: black, fg-color: white, frame-color: black,
    star-fg-color: "starcolor", star-bg-color: "gray!20", star-line-color: black,
    score-fg-color: white, score-bg-color: "purple", lower-bg-color: "gray",
    tags-bg-color: "teal!70", tags-fg-color: white,
    arc: ptl(2), righthand-width: auto,
  ),
  // objiva (rdexo.sty, version de septembre 2026) : bandeau gris, deux parallélogrammes sombres
  // (étiquette à gauche, score et niveau à droite)
  objiva: (
    bg-color: "gray!30", fg-color: "black!75", label-color: white, frame-color: black,
    star-fg-color: "starcolor", star-bg-color: "gray!30", star-line-color: "black!75",
    score-fg-color: white, score-bg-color: black, lower-bg-color: "gray",
    tags-bg-color: "black!75", tags-fg-color: white,
    title-color: "black!75",
    arc: ptl(6), righthand-width: auto,
  ),
  // thèmes de bfcours : leurs couleurs par défaut sont des marqueurs de couleur nommée (convention 2)
  bouyachakka: _nommer((
    bg-color: "gray!20", fg-color: black, frame-color: black,
    star-fg-color: "orange", star-bg-color: white, star-line-color: black,
    score-fg-color: black, score-bg-color: "gray!20", lower-bg-color: "gray",
    tags-bg-color: "black!70", tags-fg-color: white,
    // 6 pt Typst
    arc: 6pt, righthand-width: 2.8cm,
  )),
  exobac: _nommer((
    fg-color: black, rule-color: black, score-fg-color: black,
    tags-bg-color: "black!8", tags-fg-color: "black!65",
    star-fg-color: "black!45", star-bg-color: white, star-line-color: "black!55",
    correction-fg-color: black,
  )),
  exobrevet: _nommer((
    fg-color: black, rule-color: black, score-fg-color: black,
    tags-bg-color: "black!8", tags-fg-color: "black!65",
    star-fg-color: "black!45", star-bg-color: white, star-line-color: "black!55",
    correction-fg-color: black,
  )),
  exolombards: (:),
)

#let bf-skins-communs = _nommer((
  bg-color: "gray!10", fg-color: black, frame-color: black,
  star-fg-color: "starcolor", star-bg-color: "gray!20", star-line-color: black,
  score-fg-color: white, score-bg-color: black, lower-bg-color: "gray",
  tags-bg-color: "black!70", tags-fg-color: white,
  // `title color` est relayée vers `exotitle color` (/.forward to) : auto = ne rien changer
  title-color: auto,
  rule-color: black,
  correction-fg-color: black,
  // objiva : couleur du texte de l'étiquette (sur le parallélogramme sombre)
  label-color: white,
  // carré ■ (ou ❑) devant « Exercice n » : auto = couleur du texte du bandeau (fg-color), comme le
  // \ding{110} de rdexo, qui prend la couleur du titre (coltitle)
  square-color: auto,
  arc: ptl(6),
  righthand-width: auto,
))

#let bf-skins-registre = reglages-paquet(
  "exo-skins",
  bf-skins-communs,
  controles: (
    bg-color: _couleur, fg-color: _couleur, frame-color: _couleur,
    star-fg-color: _couleur, star-bg-color: _couleur, star-line-color: _couleur,
    score-fg-color: _couleur, score-bg-color: _couleur, lower-bg-color: _couleur,
    tags-bg-color: _couleur, tags-fg-color: _couleur, title-color: _c.couleur-ou-nom,
    rule-color: _couleur, correction-fg-color: _couleur, label-color: _couleur,
    square-color: reglages-ou(_couleur, (v => v == auto, "auto")),
    arc: _longueur, righthand-width: _c.longueur-ou-auto,
  ),
  types: bf-skins-defauts,
  commande: "setrdexo",
)

/// Noms des clés de couleur et de cote d'un thème (adressées par `setrdexo(pour: "<thème>", …)` ou, pour
/// un seul exercice, par les clés locales d'`exo`).
#let bf-cles-skin = bf-skins-communs.keys()

/// Thèmes déclarés par l'utilisateur (\rdexoSkin) : nom → (tcbox: fonction, tcolorbox: fonction, couleurs: dict).
#let bf-skins-perso-p = bf-etat("bf-exo-skins-perso", (:))
#let bf-skins-perso = bf-skins-perso-p.etat

/// Couleurs effectives d'un thème, résolues en couleurs Typst. À appeler dans un `context`.
/// `local` : clés de couleur propres à UN exercice (`exo(skin: "pooja", score-bg-color: red)`) ; elles
/// l'emportent sur les réglages de `setrdexo(pour: "<thème>", …)`.
#let bf-skin-couleurs(nom, local: (:)) = {
  let brutes = if nom in bf-skins-defauts { reglages-resoudre(bf-skins-registre, pour: nom, local: local, commande: "EXO") } else {
    reglages-courants(bf-skins-registre) + bf-lire(bf-skins-perso-p).at(nom, default: (couleurs: (:))).couleurs + local
  }
  let res = (:)
  for (k, v) in brutes {
    res.insert(k, if k.ends-with("-color") { bf-exo-couleur(v) } else { v })
  }
  res
}

// =====================================================================
// 3. Registre « rdexostars » : `setrdexo(pour: "rdexostars", …)`
// =====================================================================

/// Style `default` de /tikz/rdexostars (rdexo.sty l. 2117-2130).
#let bf-etoiles-defauts = _nommer((
  star-color: "yellow",
  star-background: "gray",
  line-color: black,
  line-width: ptl(0.6),
  raise: 0pt,
  scale: 1,
  show-bg: false,
  display-mode: "horizontal",
  background: (:),
  background-app: (:),
))

#let bf-etoiles-registre = reglages-paquet(
  "rdexostars",
  bf-etoiles-defauts,
  controles: (
    star-color: _couleur,
    star-background: _couleur,
    line-color: _couleur,
    line-width: _longueur,
    raise: _longueur,
    scale: _c.nombre,
    show-bg: _c.booleen,
    display-mode: reglages-choix("horizontal", "vertical"),
    background: _controle-sous-cles("background", ("colback", "colframe", "boxrule", "arc", "boxsep", "opacityback")),
    background-app: _controle-sous-cles("background-app", ("colback", "colframe", "boxrule", "arc", "boxsep", "opacityback")),
  ),
  commande: "setrdexo",
)

// =====================================================================
// 4. Registre « exo-divers » : `setrdexo(pour: "itempoint" | "competences" | …)`
// =====================================================================

/// Boîte de points de \tcbitempoint (new-bfcours-environments.sty l. 156-189) : nœud TikZ
/// draw=black, fill=purple!10, rounded corners, inner sep=3pt, minimum width=1cm,
/// centré à \linewidth − 1,6 cm − dx de la position courante.
/// `dys` (ancien \dystcbitempoint) : variante DYS, décalée de 2 cm vers la gauche ; `dx: auto` (défaut)
/// vaut 0 cm, ou 2 cm si `dys` est vrai ; un `dx` explicite l'emporte.
#let _boite-points = (
  colback: "purple!10", colframe: black, boxrule: ptl(0.4), arc: ptl(4), boxsep: ptl(3),
  min-width: 1cm, xshift: 1.6cm, dx: auto, dy: 0pt, dys: false, position: "droite",
  singular: "pt", plural: "pts", icone: none,
)

/// Variante « gris » d'`itempoint` (ancien \itempoint de bfcours : fill=gray!10, inner sep=1pt, à
/// \linewidth − 0,7 cm). Elle ne remplace que les clés laissées à leur valeur par défaut.
#let bf-points-gris = _nommer((colback: "gray!10", boxsep: ptl(1), xshift: 0.7cm))

#let bf-divers-types = (
  // \tcbitempoint et \itempoint ne font qu'une seule fonction : `itempoint` (clé `variante` : "standard" ou "gris")
  itempoint: _nommer(_boite-points + (variante: "standard")),
  // \infotcbitempoint : fill=green!10, à \linewidth − 1,9 cm, icône \faLaptop
  infotcbitempoint: _nommer(_boite-points + (colback: "green!10", xshift: 1.9cm, icone: auto)),
  // \baremepoint : draw=red, fill=red!2!white, text=red, inner sep=3pt, 0,2 cm au-dessus du contenu
  baremepoint: _nommer((colback: "red!2!white", colframe: "red", coltext: "red", boxrule: ptl(0.4), arc: ptl(4), boxsep: ptl(3), raise: 0.2cm, singular: "pt", plural: "pts")),
  // tableaux de compétences (bfcours-commands.sty l. 238-252, 358-362)
  competences: _nommer((
    entete-travaillees: [Compétences travaillées],
    entete-evaluees: [Compétences évaluées],
    entete-sommaire: [Compétences travaillées],
    colback-mi: "red!10!white", colback-mf: "orange!10!white",
    colback-ms: "yellow!10!white", colback-tbm: "green!10!white",
    colback-competence: "gray!10",
    couleur-code: "prop",
    puce: [•],
    puce-sommaire: [✎],
  )),
  // \tableauEval, \tableauProjetEval (bfcours-commands.sty l. 375-430)
  tableauEval: _nommer((
    colback: white, colframe: black, boxrule: ptl(1), arc: ptl(2),
    nom: [Nom :], prenom: [Prénom :], duree: [Durée :],
    raster-columns: 4, raster-column-skip: ptl(5), raster-row-skip: ptl(1),
  )),
  tableauProjetEval: _nommer((
    colback: white, colframe: black, boxrule: ptl(0.4), arc: ptl(2),
    nom: [Nom :], prenom: [Prénom :], date: [Date de rendu :],
    raster-columns: 4, raster-column-skip: ptl(5), raster-row-skip: ptl(1),
  )),
  // \tableauPresenteEvalSixieme (bfcours-commands.sty l. 365-374)
  tableauPresenteEvalSixieme: _nommer((
    colback: white, colframe: black, boxrule: 2pt, arc: 2pt,
    nom: [Nom :], prenom: [Prénom :], bilan: [Bilan :], width: 70%,
  )),
  // \overlaychrono, \chrono (bfcours-commands.sty l. 540-580)
  overlaychrono: _nommer((
    radius: 0.4cm, color: "red", opacity: 0.7, line-width: ptl(0.8), circle-width: ptl(0.4),
    label-sep: 0.7cm,
  )),
  chrono: _nommer((title: [Durée :], width: 3cm, colframe: "gray!75!black")),
  // bfcours-exobac.sty : soulignement des titres (l. 58-59), cadres (l. 806-832)
  bfexobacUline: (depth: ptl(2.4), width: ptl(0.5)),
  // \chapitreBac : clés /bfexobac/ (l. 551-574) ; none = valeur par défaut du style (bac ou brevet).
  // La clé LaTeX `style` (bac | brevet) est lue par chapitreBac lui-même : dans le registre, `style:`
  // désigne toujours un style nommé.
  chapitreBac: (
    examen: none, epreuve: none, session: auto, matiere: [MATHÉMATIQUES],
    serie: none, duree: none, coefficient: none, code: none, pages: auto,
    calculatrice: none, annonce: none, composition: none, qualite: none, bareme: none, infos: none,
    famille: ("TeX Gyre Heros", "Nimbus Sans", "Arial"),
    garde: true, sans-serif: true, mise-en-page: true, skin: true,
  ),
)

#let _ou-none(c) = reglages-ou(c, (v => v == none, "none"))
#let bf-divers-registre = reglages-paquet(
  "exo-divers",
  (:),
  controles: (
    colback: _couleur, colframe: _couleur, coltext: _couleur, boxrule: _longueur, arc: _longueur,
    boxsep: _longueur, min-width: _longueur, xshift: _longueur, dy: _longueur, raise: _longueur,
    dys: _c.booleen, variante: reglages-choix("standard", "gris"), position: reglages-choix("droite", "gauche"),
    dx: (v => v == auto or type(v) in (length, relative), "auto ou une longueur"),
    singular: _contenu, plural: _contenu, icone: (v => v == none or v == auto or type(v) in (str, content), "none, auto ou un contenu"),
    entete-travaillees: _contenu, entete-evaluees: _contenu, entete-sommaire: _contenu,
    colback-mi: _couleur, colback-mf: _couleur, colback-ms: _couleur, colback-tbm: _couleur,
    colback-competence: _couleur, couleur-code: _couleur, puce: _contenu, puce-sommaire: _contenu,
    nom: _contenu, prenom: _contenu, date: _contenu, bilan: _contenu,
    raster-columns: _c.entier, raster-column-skip: _longueur, raster-row-skip: _longueur,
    width: _longueur, radius: _longueur, color: _couleur, opacity: _c.nombre, line-width: _longueur,
    circle-width: _longueur, label-sep: _longueur, title: _contenu, depth: _longueur,
    examen: _contenu-ou-none, epreuve: _contenu-ou-none,
    session: (v => v == auto or type(v) in (int, str, content), "auto (année en cours) ou une année"),
    matiere: _contenu-ou-none, serie: _contenu-ou-none, duree: _contenu-ou-none,
    coefficient: (v => v == none or type(v) in (int, float, str, content), "none ou un coefficient"),
    code: _contenu-ou-none, pages: (v => v == auto or type(v) == int, "auto ou un entier"),
    calculatrice: _contenu-ou-none, annonce: _contenu-ou-none, composition: _contenu-ou-none,
    qualite: _contenu-ou-none, bareme: (v => v == none or type(v) in (array, content, str), "none, un contenu ou un tableau de lignes ((intitulé, points), …)"),
    infos: _contenu-ou-none,
    famille: (v => v == none or type(v) in (str, array), "none (ne pas changer la police) ou une famille de police"),
    garde: _c.booleen, sans-serif: _c.booleen, mise-en-page: _c.booleen, skin: _c.booleen,
  ),
  types: bf-divers-types,
  commande: "setrdexo",
)

// =====================================================================
// 5. Registre « exolombards » : `setrdexo(pour: "exolombards", …)` (options de bfcours-exolombards-skin)
// =====================================================================

#let bf-exolombards-registre = reglages-paquet(
  "exolombards",
  (
    // « auto » est un mot-clé de Typst : clé écrite entre guillemets, lue par .at("auto")
    "auto": true,
    pied: false,
    auteur: [M. Dupont],
    etablissement: [Lycée du Parc],
    decalage: -0.25cm,
    correction: "auto",
    etiquette: auto,
    titre: auto,
    bareme: auto,
    mot-correction: [Correction :],
  ),
  controles: (
    auteur: _contenu,
    etablissement: _contenu,
    decalage: _longueur,
    correction: reglages-choix("auto", "suite", "separee"),
    etiquette: (v => v == auto or type(v) == function, "auto ou une fonction (texte => contenu)"),
    titre: (v => v == auto or type(v) == function, "auto ou une fonction (titre => contenu)"),
    bareme: (v => v == auto or type(v) == function, "auto ou une fonction (points => contenu)"),
    mot-correction: _contenu,
  ),
  commande: "setrdexo",
)
