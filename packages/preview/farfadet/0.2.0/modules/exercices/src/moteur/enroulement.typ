// enroulement.typ (farfadet-exo) — un élément flottant à droite (étiquettes d'un exercice, badge de points d'un item)
// sur la première ligne d'un texte : le texte coule à sa gauche puis reprend toute la largeur dessous.
//
// Même effet que wrap-it, mais le texte est découpé ENTRE les éléments d'une suite, ENTRE les mots d'un texte et
// dans le corps d'un `strong`, d'un `emph` ou d'un contenu stylé : jamais au milieu d'une formule, d'une boîte,
// ni juste après une apostrophe (wrap-it coupe mot à mot et abîme les formules et les apostrophes).

#import "../../../socle/lib.typ": interne as _socle
#import _socle: bf-sans-espace-initial

/// Fonctions dont l'élément tient dans une ligne de texte.
#let _fonctions-texte = (text, strong, emph, smartquote, box, h, link, highlight, underline)

#let _seq = [*a* *b*].func()
#let _styled = text(red)[a].func()

/// Plus long début de `c` qui tient en une ligne (`tient(contenu) -> bool`) : (avant, apres), `avant` valant
/// none si rien ne tient. On coupe entre les éléments d'une suite, entre les mots d'un texte et dans le corps
/// d'un `strong`, d'un `emph` ou d'un contenu stylé ; le reste (formule, boîte, liste…) ne se coupe pas.
#let _decouper(c, tient) = {
  if tient(c) { return (c, none) }
  let f = c.func()
  if f == _seq {
    let e = c.children
    for i in range(e.len()) {
      let base = e.slice(0, i)
      if not tient((base + (e.at(i),)).join()) {
        let (a, b) = _decouper(e.at(i), x => tient((base + (x,)).join()))
        let avant = (base + if a != none { (a,) } else { () }).join()
        let apres = ((if b != none { (b,) } else { () }) + e.slice(i + 1)).join()
        return (avant, apres)
      }
    }
    return (c, none)
  }
  if f == text and c.has("text") {
    let mots = c.text.split(" ")
    let j = 0
    for k in range(1, mots.len() + 1) {
      if tient([#mots.slice(0, k).join(" ")]) { j = k } else { break }
    }
    if j == 0 { return (none, c) }
    return ([#mots.slice(0, j).join(" ")], if j < mots.len() { [#mots.slice(j).join(" ")] })
  }
  if f in (strong, emph) {
    let (a, b) = _decouper(c.body, x => tient(f(x)))
    return (if a != none { f(a) }, if b != none { f(b) })
  }
  if f == _styled {
    let refaire(x) = _styled(x, c.styles)
    let (a, b) = _decouper(c.child, x => tient(refaire(x)))
    return (if a != none { refaire(a) }, if b != none { refaire(b) })
  }
  (none, c)
}

/// Élément « en ligne » (texte, espace, formule en ligne, boîte…) : seuls ceux-là peuvent ouvrir un texte
/// sur la ligne d'un élément flottant.
#let _en-ligne(c) = {
  if type(c) != content { return true }
  let f = c.func()
  if f == _seq { return c.children.all(_en-ligne) }
  if f == _styled { return _en-ligne(c.child) }
  if f in (strong, emph) { return _en-ligne(c.body) }
  if f == math.equation { return not c.block }
  f in _fonctions-texte or f == [ ].func()
}

/// Premier élément significatif de `c` (on descend dans les suites et les contenus stylés, on saute les espaces).
#let _premier(c) = {
  if type(c) != content { return c }
  if c.func() == _seq {
    let e = c.children.filter(x => x != [ ] and x.func() != parbreak)
    if e.len() == 0 { return c }
    return _premier(e.first())
  }
  if c.func() == _styled { return _premier(c.child) }
  c
}

/// Pose `contenu` en ligne SANS agrandir la ligne : boîte de hauteur nulle posée sur la ligne de base, le contenu
/// centré sur la hauteur des minuscules. À appeler dans un `context`.
#let bf-flottant-en-ligne(contenu) = {
  let m = measure(contenu)
  box(width: m.width, height: 0pt, place(top + left, dy: -(m.height / 2 + 0.25em.to-absolute()), contenu))
}

/// `corps` commence sur la première ligne, à gauche de `flottant` (rangé au bord droit, décalé de `decalage`
/// vers la gauche), et se poursuit dessous sur toute la largeur. Retombe sur `repli` quand c'est impossible :
/// `flottant` plus large que `seuil` fois la ligne (`seuil` : proportion, none = pas de limite), texte qui ne
/// commence pas par du texte en ligne (liste, figure, formule en affichage, paragraphes), ou première ligne
/// trop vide pour être justifiée. `habiller` enveloppe le résultat réussi.
///
/// `largeur: auto` : le résultat est un bloc (`layout`), de la largeur du conteneur (étiquettes sous un bandeau).
/// `largeur` donnée (distance du début du texte au bord droit du conteneur) : le résultat reste EN LIGNE, dans le
/// paragraphe (point d'un item, dont le numéro doit rester sur la première ligne). Contenu à placer dans un `context`.
#let bf-enrouler-ligne(flottant, corps, repli, decalage: 0pt, seuil: none, habiller: c => c, largeur: auto, pose: bf-flottant-en-ligne, repli-bloc: none) = {
  let corps-enroule(total) = {
    let l-flottant = measure(flottant).width + decalage
    let ecart = 1em.to-absolute()
    let dispo = total - l-flottant - ecart
    let tient(x) = {
      let h = measure(block(width: dispo, x)).height
      h <= measure(block(width: 20000pt, x)).height + 0.1pt
    }
    if (seuil != none and l-flottant > seuil * total) or dispo < 3cm { return repli }
    let corps = bf-sans-espace-initial(corps)
    let (avant, apres) = _decouper(corps, tient)
    // jamais de coupure juste après une apostrophe (« l’ / intervalle ») : le mot élidé passe avec la suite
    if apres != none and avant != none and avant.func() == _seq {
      let e = avant.children
      if e.len() >= 2 and e.last().func() == smartquote and e.at(-2).func() == text {
        let mots = e.at(-2).text.split(" ")
        let reste = mots.slice(0, -1).join(" ")
        apres = ([#mots.last()], e.last(), apres).join()
        avant = (e.slice(0, -2) + if reste != "" { ([#reste],) } else { () }).join()
      }
    }
    // le texte commence par un bloc (liste, figure, formule en affichage) : `repli-bloc` si fourni
    if repli-bloc != none and not _en-ligne(_premier(corps)) { return repli-bloc }
    if avant == none or avant == [] or not _en-ligne(avant) { return repli }
    // première ligne trop vide (mot ou formule insécable qui n'entre pas) : l'espacement des mots serait
    // démesuré, on retombe sur le repli
    if apres != none and measure(box(avant)).width < 0.85 * dispo { return repli }
    let apres = if apres != none { bf-sans-espace-initial(apres) }
    let ligne = if apres != none { [#avant#linebreak(justify: true)] } else { avant }
    habiller({
      [#box(width: dispo, ligne)#h(1fr)#pose(flottant)#if apres != none [#linebreak()#apres]]
    })
  }
  if largeur == auto { layout(taille => corps-enroule(taille.width)) } else { corps-enroule(largeur) }
}
