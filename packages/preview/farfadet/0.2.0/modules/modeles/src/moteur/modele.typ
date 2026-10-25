// modele.typ — le modèle de document bfcours : page, polices, équations, références.
//   #show: farfadet.with(correction: false)
//
// Préambule LaTeX reproduit (documents de production, ex. sources/cours-6e) :
//   \documentclass[a4paper,11pt,fleqn]{article}
//   \usepackage[left=1cm,right=0.5cm,top=0.5cm,bottom=2cm]{geometry}
//   \usepackage{bfcours}  \usepackage{bfcours-fonts}   (fourier + scrextend fontsize=12)
// Polices : Utopia (fourier) → Erewhon (clone OpenType d'Utopia, M. Sharpe) ;
//           Fourier-GUTenberg (maths) → Erewhon Math (D. Flipo, conçue pour Erewhon).
// Variante dys de bfcours-fonts : Fira Sans / Latin Modern Sans / TeX Gyre Heros, 14 pt, interligne × 1,2.
// Fichiers : polices/ du dépôt, à passer à Typst avec --font-path.
// Cotes relevées sur le rendu LaTeX de référence.
//
// Titres de section et sommaire : farfadet-didactique (moteur/sectionnement.typ).
//
// Trois étages :
//   bfcours-valeurs(r)   réglages résolus (clés LaTeX, `auto` selon dys) → arguments de bfcours-texte ;
//   bfcours-page(…)      format de page et pied de page (`set page` ne peut pas être dans un `context`) ;
//   bfcours-texte(…)     style du texte, des équations, des références (peut être posé dans un `context`).
// `farfadet(…)` les enchaîne avec des arguments directs (interface historique, stable).

#import "../../../socle/lib.typ": interne as _socle
#import _socle: *
#import "../../../enumerations/lib.typ": interne as _enum
#import _enum: regles-listes
#import "../../../didactique/lib.typ": interne as _didactique
#import _didactique: bf-regles-titres as _regles-titres
#import "entetes.typ": pied-de-page
#import "paginer.typ": paginer-auto
#import "reglages.typ": polices-dys as _polices-dys


// =====================================================================
// Réglages résolus → arguments du style de texte
// =====================================================================

/// Valeurs concrètes du style de texte à partir des réglages résolus `r` (type « bfcours ») :
/// remplace les `auto` par les valeurs de bfcours (ou de la variante dys), applique \setstretch.
/// Renvoie un dictionnaire de clés de `bfcours-texte`.
#let bfcours-valeurs(r) = {
  let dys = r.dys
  let pd = if type(r.police-dys) == str { _polices-dys.at(r.police-dys) } else { r.police-dys }
  let choisir(v, normal, adapte) = if v != auto { v } else if dys { adapte } else { normal }
  let taille = choisir(r.fontsize, 12pt, 14pt)
  // \baselineskip de KOMA : 14,5 pt pour 12 pt, proportionnel au-delà
  let interligne = if r.baselineskip != auto { r.baselineskip } else { ptl(14.5) * (taille / 12pt) }
  let etirement = choisir(r.etirement-interligne, 1, 1.2)
  (
    correction: r.correction,
    taille: taille,
    fleqn: r.fleqn,
    retrait-equations: choisir(r.mathindent, ptl(27.37), ptl(27.37)),
    police: choisir(r.police, ("Erewhon", "Libertinus Serif"), pd.texte),
    police-maths: choisir(r.police-maths, ("Erewhon Math", "New Computer Modern Math"), pd.maths),
    echelle-fourier: choisir(r.echelle-fourier, 11 / 12, 1),
    echelle-police: choisir(r.echelle-police, 1.065, 1),
    echelle-maths: choisir(r.echelle-maths, 1, 1),
    tracking-gras: choisir(r.tracking-gras, -0.009em, 0em),
    interligne: interligne * etirement,
    justifier: choisir(r.justifier, true, false),
    espace-mot: choisir(r.espace-mot, none, 0.8em),
    espace-mot-min: r.espace-mot-min,
    espace-mot-max: r.espace-mot-max,
    saut-avant-equation: r.abovedisplayskip,
    saut-apres-equation: r.belowdisplayskip,
    fraction-haut: r.correction-fraction-haut,
    fraction-bas: r.correction-fraction-bas,
    ecart-colonnes-matrice: r.ecart-colonnes-matrice,
  )
}


// =====================================================================
// Page
// =====================================================================

/// Format de page et pied de page du modèle (geometry : marges ; \headheight porté à 14,5 pt après geometry).
///   papier, marges : ceux de geometry ; `decalage` reproduit le décalage vertical de 2,5 pt TeX
///                    des documents bfcours.
///   avec-page      : false : ne règle ni le format ni le pied (aperçus dans une autre mise en page).
///   pied           : false : pas de pied de page.
#let bfcours-page(
  papier: "a4",
  marges: (left: 1cm, right: 0.5cm, top: 0.5cm, bottom: 2cm),
  decalage: 2.5pt * 72 / 72.27,
  avec-page: true,
  pied: true,
  doc,
) = {
  let m = (left: 1cm, right: 0.5cm, top: 0.5cm, bottom: 2cm) + marges
  set page(
    paper: papier,
    margin: (left: m.left, right: m.right, top: m.top + decalage, bottom: m.bottom - decalage),
    // le pied peut être remplacé en cours de document (sujets d'examen) sans `set page`, qui ouvrirait une page :
    // `bf-pied-surcharge` (farfadet-socle) porte alors le pied de remplacement
    footer: if pied {
      context {
        let s = bf-pied-surcharge.get()
        if s == none { pied-de-page() } else { s }
      }
    } else { none },
    footer-descent: 0pt,
  ) if avec-page
  if avec-page and pied { bf-pied-modele.update(true) }
  doc
}


// =====================================================================
// Texte
// =====================================================================

/// Style du texte, des équations et des références du modèle bfcours.
///   correction : version professeur (true) ou élève (false) ; `--input correction=…` l'emporte.
///   taille     : \normalsize NOMINAL du document ; bfcours-fonts impose 12 pt (scrextend),
///                quelle que soit l'option de classe. Tailles nommées : barème KOMA de cette taille.
///   echelle-fourier : fourier compose Utopia à 11/12 du nominal (glyphes à 11 pt pour 12 pt).
///   echelle-police : rapport Utopia / police Typst à corps égal (Erewhon : 692/650 = 1,065) ;
///                la police Typst est donc composée à taille × echelle-fourier × echelle-police
///                (11,715 pt).
///   police, police-maths : listes de repli. Erewhon et Erewhon Math si elles sont installées ;
///                sinon Libertinus Serif et New Computer Modern Math, intégrées à Typst : aucune
///                police à installer pour obtenir un rendu correct.
///   echelle-maths : facteur d'agrandissement de la police des formules (1 par défaut : les
///                formules ont la taille du texte). Une police dessinée plus grande dans son em
///                s'utilise avec un facteur égal (la formule est composée à 1/facteur) ; les
///                espaces calculés en em et les écarts des matrices suivent ce facteur.
///   tracking-gras : Erewhon Bold est 1,9 % plus large qu'Utopia Bold à l'échelle retenue (AFM),
///                d'où un léger resserrement de l'approche du gras.
///   fleqn      : équations centrées à gauche, en retrait de \mathindent (`retrait-equations`).
///   interligne : \baselineskip (déjà multiplié par \setstretch).
///   justifier, espace-mot : justification ; `espace-mot` = \spaceskip (none : espace de la police).
///   espace-mot-min, espace-mot-max : limites de l'espace intermot, en proportion de l'espace normal.
///   saut-avant-equation, saut-apres-equation : \abovedisplayskip, \belowdisplayskip.
///   fraction-haut, fraction-bas : les fractions de Fourier sont plus hautes et plus profondes que
///                celles d'Erewhon Math ; correction d'espacement autour des équations qui en contiennent.
///   ecart-colonnes-matrice : écart entre colonnes des matrices (2 \arraycolsep).
#let bfcours-texte(
  correction: true,
  taille: 12pt,
  fleqn: true,
  retrait-equations: 27.37pt * 72 / 72.27,
  police: ("Erewhon", "Libertinus Serif"),
  police-maths: ("Erewhon Math", "New Computer Modern Math"),
  echelle-fourier: 11 / 12,
  echelle-police: 1.065,
  echelle-maths: 1,
  tracking-gras: -0.009em,
  interligne: 14.5pt * 72 / 72.27,
  justifier: true,
  espace-mot: none,
  espace-mot-min: 100% * (0.207 - 0.05) / 0.207,
  espace-mot-max: 160%,
  saut-avant-equation: 12pt * 72 / 72.27,
  saut-apres-equation: 12pt * 72 / 72.27,
  fraction-haut: 1.9pt,
  fraction-bas: 2.3pt,
  ecart-colonnes-matrice: 10pt * 72 / 72.27,
  doc,
) = {
  // taille des glyphes LaTeX (11 pt) et taille Typst équivalente (11,715 pt)
  let glyphe = taille * echelle-fourier
  let corps = glyphe * echelle-police
  let schema = if taille <= 10.5pt { "10pt" } else if taille <= 11.5pt { "11pt" } else { "12pt" }
  let nominal = if taille <= 10.5pt { 10pt } else if taille <= 11.5pt { 11pt } else { 12pt }
  // \quad de TeX (\fontdimen6 d'Utopia : 0,88 × nominal) : en mode math aussi, il suit la police du texte
  let cadratin = 0.88 * taille * 72 / 72.27
  // Lignes de hauteur fixe : 0,75 et 0,25 × glyphe au-dessus et au-dessous de la ligne de base
  // (8,25 + 2,75 pt) ; l'écart entre lignes de base vaut \baselineskip pour du texte courant.
  set text(
    font: police,
    size: corps,
    lang: "fr",
    region: "FR",
    top-edge: 0.75em / echelle-police,
    bottom-edge: -0.25em / echelle-police,
    hyphenate: auto,
  )
  set text(spacing: espace-mot) if espace-mot != none
  // Justification : l'espace d'Utopia (fourier) vaut 0,207, s'étire de 0,124 et se resserre de 0,05 (TFM)
  set par(
    justify: justifier,
    first-line-indent: 0pt,
    leading: interligne - glyphe,
    spacing: interligne - glyphe,
    justification-limits: (spacing: (min: espace-mot-min, max: espace-mot-max)),
  )
  // Formules : police composée à 1/echelle-maths (1 par défaut) ; ce qui est en em
  // (quad, matrices, contenus en boîte) est ramené aux dimensions de TeX ou du texte.
  let regler-formule(it) = {
    // 1em et non `corps` : la formule suit la taille du contexte (bandeau, titre, note), pas celle du corps
    set text(font: police-maths, size: 1em / echelle-maths)
    set math.mat(column-gap: ecart-colonnes-matrice, row-gap: 0.2em * echelle-maths)
    set math.vec(gap: 0.2em * echelle-maths)
    set math.cases(gap: 0.2em * echelle-maths)
    show h.where(amount: 1em): h(cadratin)
    show h.where(amount: 2em): h(2 * cadratin)
    show box: set text(font: police, size: corps)
    // Texte en boîte dans une formule en ligne. Pas pour une équation affichée : le bloc qui porte ses lignes
    // alignées (`&`, `\`) recevrait aussi la police du texte, et ses formules passeraient en police de texte
    // (avertissement « current font is not designed for math »).
    show block: set text(font: police, size: corps) if not it.block
    it
  }
  show math.equation: regler-formule
  // Formule en ligne qui contient une fraction en grand (`display(a/b)`) : sa boîte garde sa vraie hauteur. Avec les
  // bords de ligne fixes ci-dessus, la fraction dépasserait de la ligne et toucherait celle du dessus ou du
  // dessous ; TeX, lui, écarte les lignes (\lineskip) quand une formule est plus haute que la ligne.
  show math.equation.where(block: false): it => {
    let corps = repr(it.body)
    if corps.contains("display(") and corps.contains("frac(") {
      set text(top-edge: "bounds", bottom-edge: "bounds")
      it
    } else { it }
  }
  show text.where(weight: "bold"): set text(tracking: tracking-gras)
  show strong: set text(tracking: tracking-gras)
  // Équations centrées (fleqn) : espacement de TeX, calculé sur la hauteur et la profondeur de la formule
  // (\abovedisplayskip, \belowdisplayskip, \baselineskip, \lineskip).
  show math.equation.where(block: true): it => context {
    let il = bf-lire(bf-interligne-p)
    let haut = 0.75 * glyphe
    let bas = 0.25 * glyphe
    let simple = it.numbering == none and not repr(it.body).contains("align-point") and not repr(it.body).contains("linebreak")
    let ligne = math.equation(block: false, math.display(it.body))
    let h = if simple { measure([#text(top-edge: "baseline", bottom-edge: -1000pt)[x]#ligne]).height - 1000pt } else { haut }
    let d = if simple { measure([#text(top-edge: 1000pt, bottom-edge: "baseline")[x]#ligne]).height - 1000pt } else { bas }
    // Les fractions de Fourier sont plus hautes et plus profondes que celles d'Erewhon Math
    // (relevé : +1,9 pt au-dessus, +2,3 pt au-dessous) : on espace comme TeX l'aurait fait.
    let fraction = repr(it.body).contains("frac(")
    let dh = if fraction and h > haut + 1pt { fraction-haut } else { 0pt }
    let dd = if fraction and d > bas + 1pt { fraction-bas } else { 0pt }
    block(
      width: 100%,
      above: saut-avant-equation + calc.max(il.lineskip, il.baselineskip - bas - h - dh) + dh,
      below: saut-apres-equation + calc.max(il.lineskip, il.baselineskip - d - dd - haut) + dd,
      inset: (left: if fleqn { retrait-equations } else { 0pt }),
      align(if fleqn { left } else { center }, if simple { par(justify: false, ligne) } else { it }),
    )
  }
  // Espaces fines de babel-french avant ; ! ? et insécable avant :
  show regex("\s([;!?])"): it => [#sym.space.nobreak.narrow#it.text.last()]
  show regex("\s:"): [#sym.space.nobreak:]
  // Double syntaxe `#begin(f) … #end(f)` : la passe consomme les marqueurs avant toutes les autres règles
  // (elle regroupe le contenu entre begin et end, puis appelle f).
  show: bf-precoce
  show: paginer-auto
  show: environnements
  show: francais
  show: regles-listes
  show: _regles-titres
  // Une référence vers une étiquette absente (posée par une macro rendue en image, par exemple)
  // arrêterait la compilation : on la signale en orange plutôt que d'interrompre le document.
  // Les environnements étiquetés de farfadet-didactique (figure de kind « bfn-… ») : `@lbl[texte]` affiche
  // « texte » ; sans numérotation, `@lbl` affiche le supplément (titre ou texte-reference) ; avec
  // numérotation, `@lbl` garde le rendu habituel « Propriété 2.3 ». Toujours cliquable.
  show ref: it => context {
    if query(it.target).len() == 0 {
      text(fill: rgb("#e07b00"))[??]
    } else {
      let el = it.element
      let natif = el != none and el.func() == figure and type(el.kind) == str and el.kind.starts-with("bfn-")
      if not natif {
        it
      } else if it.supplement not in (auto, none) {
        link(el.location(), it.supplement)
      } else if el.numbering == none {
        link(el.location(), el.supplement)
      } else {
        it
      }
    }
  }
  bf-maj(bf-taille-base-p, corps)
  // `echelle` : rapport à la taille nominale du barème (10, 11 ou 12 pt) ; `taille` : \normalsize réel
  bf-maj(bf-police-p, p => p + (schema: schema, echelle: corps / nominal, texte: police, taille: taille))
  bf-maj(bf-interligne-p, i => i + (baselineskip: interligne))
  bf-maj(bf-fleqn-p, (actif: fleqn, retrait: retrait-equations))
  set-correction(correction)
  doc
}


// =====================================================================
// Le modèle, en un appel (interface historique)
// =====================================================================

/// Modèle de document bfcours : page + texte, avec des arguments directs (sans réglages d'état).
/// Les arguments de page sont ceux de `bfcours-page` ; les autres, ceux de `bfcours-texte`
/// (`interligne`, `retrait-equations`, `echelle-*`, `tracking-gras`… ; `pied` : pied de page).
#let farfadet(
  correction: true,
  taille: 12pt,
  papier: "a4",
  marges: (left: 1cm, right: 0.5cm, top: 0.5cm, bottom: 2cm),
  decalage: 2.5pt * 72 / 72.27,
  fleqn: true,
  avec-page: true,
  pied: true,
  doc,
  ..texte,
) = {
  let corr = if "correction" in sys.inputs { sys.inputs.correction == "true" } else { correction }
  show: bfcours-page.with(papier: papier, marges: marges, decalage: decalage, avec-page: avec-page, pied: pied)
  bfcours-texte(correction: corr, taille: taille, fleqn: fleqn, ..texte.named(), doc)
}
