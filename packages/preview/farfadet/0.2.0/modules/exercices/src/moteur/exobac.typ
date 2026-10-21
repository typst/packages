// exobac.typ (farfadet-exo) — sujets officiels : skins rdexo « exobac » et « exobrevet », \chapitreBac,
// \chapitreBrevet, parties, consignes, cadres et corrigé à pagination séparée (bfcours-exobac.sty).
//
// Les en-têtes d'exercice sont dans skins.typ (_exobac-tete, _exobrevet-tete) ; ce fichier porte les
// commandes. En Typst, \chapitreBac (commande de préambule qui installe le style de page) devient un
// modèle : `#show: chapitreBac.with(session: 2026, code: "26-MATJ1ME1")`.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: *
#import "reglages.typ": bf-divers-registre, bf-exo-couleur
#import "exo.typ": bf-setrdexo, bf-exo, bf-exobac-etat, bf-exobac-etat-p, bf-rdexocorrection

// =====================================================================
// Activation des skins (l. 428-487)
// =====================================================================

/// Réglages rdexo communs aux deux styles d'examen (\bfexobac@commonrdexo).
#let _commun = (
  exo-header: "tcolorbox",
  header-skip: ptl(2),
  display-numexo: true,
  display-score: true,
  display-level: false,
  display-tags: false,
  display-exotitle: true,
  exotitle-color: black,
  score-label: ("point", "points"),
  lower: (box: "crep"),
  breakable: true,
)

/// \styleExoBac[clés rdexo] : skin « exobac » (Exercice n souligné, points entre parenthèses).
#let bf-styleExoBac(..cles) = {
  bf-setrdexo(.._commun, skin: "exobac", label: "Exercice", exotitle-font: "\\normalsize\\bfseries", ..cles.named())
  bf-maj(bf-exobac-etat-p, e => e + (corrword: "Corrigé", corrof: "de l’exercice", actif: true))
}

/// \styleExoBrevet[clés rdexo] : skin « exobrevet » (Exercice n (X points), tout en gras).
#let bf-styleExoBrevet(..cles) = {
  bf-setrdexo(.._commun, skin: "exobrevet", label: "Exercice", exotitle-font: "\\normalsize\\bfseries", ..cles.named())
  bf-maj(bf-exobac-etat-p, e => e + (corrword: "Correction", corrof: "de l’exercice", actif: true))
}

/// \numeroterBac[n] : le prochain exercice portera le numéro n + 1 (la numérotation GLOBALE est
/// gardée : les corrections restent rangées sous leur numéro global).
#let bf-numeroterBac(n: 0) = context {
  let courant = bf-exo.get().first()
  bf-maj(bf-exobac-etat-p, e => e + (decalage: courant - n))
}

/// \styleQuestionsBac[*][clés] : items « Question n », sans barème ni titre ; repart à 1 sauf `etoile`.
#let bf-styleQuestionsBac(etoile: false, ..cles) = {
  bf-setrdexo(label: "Question", display-score: false, display-exotitle: false, ..cles.named())
  bf-maj(bf-exobac-etat-p, e => e + (corrof: "de la question"))
  if not etoile { bf-numeroterBac() }
}

/// \styleExercicesBac[*][clés] : items « Exercice n (X points) », titre affiché ; repart à 1 sauf `etoile`.
#let bf-styleExercicesBac(etoile: false, ..cles) = {
  bf-setrdexo(label: "Exercice", display-score: true, display-exotitle: true, ..cles.named())
  bf-maj(bf-exobac-etat-p, e => e + (corrof: "de l’exercice"))
  if not etoile { bf-numeroterBac() }
}

// =====================================================================
// Commandes d'appoint (l. 791-849)
// =====================================================================

/// \partieBac[*]{titre} : titre de partie centré et gras ; sans étoile, entrée de sommaire.
#let bf-partieBac(titre, etoile: false) = {
  block(width: 100%, above: 0.6em + 0.8em, below: 0.4em + 0.8em, breakable: false, align(center, strong(titre)))
  if not etoile [#metadata((nom: titre, titre: none, simple: true))<bf-toc>]
}

/// \consigneBac[*]{texte} : cadre de consignes en gras italique centré (DNB) ; `etoile` : en gras
/// au fil du texte (bac).
#let bf-consigneBac(texte, etoile: false) = {
  if etoile {
    block(width: 100%, above: 0.5em + 0.6em, below: 0.7em + 0.6em, strong(texte))
  } else {
    // \fbox{minipage} : \fboxrule 0,4 pt, \fboxsep de bfcours (3 mm)
    block(width: 100%, above: 0.5em + 0.6em, below: 0.7em + 0.6em, stroke: ptl(0.4) + black, inset: 3mm,
      align(center, text(weight: "bold", style: "italic", [#v(0.3em)#texte#v(0.3em)])))
  }
}

/// \encadreBac[titre]{contenu} : petit cadre pleine largeur (« Aide au calcul », « Rappel »).
#let bf-encadreBac(corps, titre: none) = block(width: 100%, stroke: ptl(0.4) + black, inset: 3mm, {
  if titre != none { block(above: 0pt, below: 0.65em, strong(titre)) }
  corps
})

/// \encadreBacEtroit[titre]{contenu} : même cadre, à la largeur du contenu (varwidth).
#let bf-encadreBacEtroit(corps, titre: none) = box(stroke: ptl(0.4) + black, inset: 3mm, {
  if titre != none { block(above: 0pt, below: 0.65em, strong(titre)) }
  corps
})

/// \corrigeBac[*][titre=CORRIGÉ] : clôt le sujet, ouvre le corrigé (pagination séparée) et rejoue
/// toutes les corrections ; `etoile` : sans les rejouer (plages choisies par \rdexocorrection).
#let bf-corrigeBac(titre: [CORRIGÉ], etoile: false) = {
  pagebreak(weak: true)
  [#metadata(none) <bf-exobac-corrige>]
  bf-partieBac(titre, etoile: true)
  if not etoile { bf-rdexocorrection(0) }
}

// =====================================================================
// \chapitreBac : pied de page, police, page de garde (l. 490-784)
// =====================================================================

/// Pages du sujet (sans le corrigé) : page du corrigé − 1, sinon dernière page ; clé `pages` prioritaire.
#let _pages-sujet(p) = {
  if p.pages != auto { return p.pages }
  let c = query(<bf-exobac-corrige>)
  if c.len() > 0 { c.first().location().page() - 1 } else { counter(page).final().first() }
}

/// Valeurs par défaut selon le style (\bfexobac@setdefaults).
#let _defauts-style(p, style) = {
  let nb = _pages-sujet(p)
  let d = p
  if style == "brevet" {
    if d.examen == none { d.examen = [DIPLÔME NATIONAL DU BREVET] }
    if d.serie == none { d.serie = [Série générale] }
    if d.duree == none { d.duree = [2 h 00] }
    if d.coefficient == none { d.coefficient = 2 }
    if d.calculatrice == none {
      d.calculatrice = [L'usage de la calculatrice avec mode examen actif ou sans mémoire « type collège » est *interdit pour la partie 1* et autorisé pour la partie 2.\ L'utilisation du dictionnaire est interdite.]
    }
    if d.annonce == none {
      d.annonce = [Dès que le sujet vous est remis, assurez-vous qu'il est complet.\ Ce sujet comporte #nb pages numérotées de la page 1/#nb à la page #nb/#nb]
    }
    if d.bareme == none {
      d.bareme = (
        ([Partie 1 – Automatismes\ 20 min (calculatrice interdite)], [6 points]),
        ([Partie 2 – Raisonnement et résolution de problèmes\ 1 h 40 (calculatrice autorisée)], [14 points]),
      )
    }
    if d.composition == none { d.composition = [*À l'issue de la partie 1, les copies sont ramassées.*] }
  } else {
    if d.examen == none { d.examen = [BACCALAURÉAT GÉNÉRAL] }
    if d.epreuve == none { d.epreuve = [ÉPREUVE D'ENSEIGNEMENT DE SPÉCIALITÉ] }
    if d.duree == none { d.duree = [4 heures] }
    if d.coefficient == none { d.coefficient = 16 }
    if d.calculatrice == none {
      d.calculatrice = [L'usage de la calculatrice avec mode examen actif est autorisé.\ L'usage de la calculatrice sans mémoire, « type collège », est autorisé.]
    }
    if d.annonce == none {
      d.annonce = [Dès que ce sujet vous est remis, assurez-vous qu'il est complet.\ Ce sujet comporte #nb pages numérotées de 1/#nb à #nb/#nb.]
    }
    if d.qualite == none {
      d.qualite = [La qualité de la rédaction, la clarté et la précision des raisonnements entreront pour une part importante dans l'appréciation des copies.\ Les candidates et les candidats sont invités à faire figurer sur leurs copies toute trace de recherche, même incomplète ou infructueuse.]
    }
  }
  if d.session == auto { d.session = datetime.today().year() }
  d
}

/// Pied de page : code du sujet à gauche (gras au bac), « Page : n/N » ou « Page n sur N » à droite ;
/// dans le corrigé, pagination propre et « – Corrigé » après le code.
#let _pied-bac(p, style) = context {
  let ici = here().page()
  let c = query(<bf-exobac-corrige>)
  let fin-sujet = if c.len() > 0 { c.first().location().page() - 1 } else { none }
  let dans-corrige = fin-sujet != none and ici > fin-sujet
  let n = if dans-corrige { ici - fin-sujet } else { counter(page).get().first() }
  let total = if dans-corrige { counter(page).final().first() - fin-sujet } else { _pages-sujet(p) }
  let mot = bf-lire(bf-exobac-etat-p).corrword
  let code = if p.code == none { [] } else if style == "brevet" { p.code } else { strong(p.code) }
  let gauche = [#code#if dans-corrige [#if p.code != none [~–~]#mot]]
  let droite = if style == "brevet" [Page *#n* sur #total] else [Page : #n/#total]
  set text(weight: "regular", style: "normal")
  grid(columns: (1fr, auto), gauche, droite)
}

/// Page de garde d'un sujet de baccalauréat.
#let _garde-bac(d) = {
  set par(justify: false)
  align(center, {
    let lp(nom) = taille-latex(nom)
    block(text(size: lp("LARGE"), weight: "bold", d.examen))
    if d.epreuve != none { v(0.9em); block(d.epreuve) }
    v(2.6em)
    block(text(size: lp("Large"), weight: "bold")[SESSION #d.session])
    v(2.6em)
    block(text(size: lp("LARGE"), weight: "bold", d.matiere))
    if d.serie != none { v(1.2em); block(text(size: lp("large"), d.serie)) }
    v(3.4em)
    if d.duree != none { block[Durée de l'épreuve : *#d.duree*] }
    if d.coefficient != none { block[Coefficient : #d.coefficient] }
    if d.calculatrice != none { v(2.6em); block(emph(d.calculatrice)) }
    if d.annonce != none { v(2.6em); block(d.annonce) }
    if d.composition != none { v(2.2em); block(d.composition) }
    if d.qualite != none { v(2.2em); block(d.qualite) }
    if d.infos != none { v(2.2em); block(d.infos) }
  })
  pagebreak()
}

/// Barème du DNB : tableau à deux colonnes centrées (0,62 et 0,22 \textwidth), filets pleins.
#let _bareme(b) = {
  if type(b) != array { return b }
  table(
    columns: (62%, 22%),
    align: center + horizon,
    stroke: ptl(0.4) + black,
    inset: (x: ptl(6), y: 0.5em),
    // un nombre de points donné en entier (20) ou en chaîne devient du contenu
    ..b.flatten().map(x => if type(x) == content { x } else [#x]),
  )
}

/// Page de garde d'un sujet du DNB (double cadre, barème).
#let _garde-brevet(d) = {
  set par(justify: false)
  align(center, {
    let lp(nom) = taille-latex(nom)
    block(text(size: lp("LARGE"), weight: "bold", d.examen))
    v(1.4em)
    block(text(size: lp("Large"), weight: "bold", style: "italic")[SESSION #d.session])
    v(3em)
    // double cadre : filet de 0,8 pt, 2 pt d'écart, filet de 0,4 pt
    block(stroke: ptl(0.8) + black, inset: ptl(2), block(stroke: ptl(0.4) + black, width: 86%, inset: 0pt, {
      v(1.4em)
      block(text(size: lp("LARGE"), weight: "bold", d.matiere))
      if d.serie != none { v(1.6em); block(text(size: lp("large"), d.serie)) }
      v(2.2em)
      block(width: 100%, pad(x: 1.2em, grid(columns: (1fr, auto),
        if d.duree != none [Durée : #d.duree],
        if d.coefficient != none [Coefficient : #d.coefficient])))
      v(1em)
    }))
    if d.annonce != none { v(2.4em); block(d.annonce) }
    if d.bareme != none { v(2.4em); _bareme(d.bareme) }
    if d.composition != none { v(2.2em); block(d.composition) }
    if d.calculatrice != none { v(2.2em); block(d.calculatrice) }
    if d.qualite != none { v(2.2em); block(d.qualite) }
    if d.infos != none { v(2.2em); block(d.infos) }
  })
  pagebreak()
}

/// \chapitreBac[clés] : modèle de sujet officiel (à employer par `#show: chapitreBac.with(…)`).
/// `style` : "bac" (défaut) ou "brevet" (\chapitreBrevet).
#let bf-chapitreBac(style: "bac", ..cles, doc) = {
  if style not in ("bac", "brevet") {
    panic("chapitre-bac : valeur invalide pour la clé « style » : " + repr(style) + ". Valeurs possibles : \"bac\" ou \"brevet\".")
  }
  let locales = cles.named()
  context {
    let p = reglages-resoudre(bf-divers-registre, pour: "chapitreBac", local: locales, commande: if style == "brevet" { "chapitreBrevet" } else { "chapitreBac" })
    let d = _defauts-style(p, style)
    set text(font: p.famille) if p.sans-serif and p.famille != none
    set par(first-line-indent: 0pt) if p.mise-en-page
    let suite = {
      if p.skin { if style == "brevet" { bf-styleExoBrevet() } else { bf-styleExoBac() } }
      if p.garde { if style == "brevet" { _garde-brevet(d) } else { _garde-bac(d) } }
      doc
    }
    // Sous `modele`, la page 1 porte déjà le bandeau : un `set page` ouvrirait une page et laisserait la page 1
    // vide. Le pied d'examen passe alors par l'état lu par le pied du modèle (`bf-pied-surcharge`).
    if bf-pied-modele.get() {
      bf-pied-surcharge.update(_pied-bac(p, style))
      suite
    } else {
      set page(footer: _pied-bac(p, style))
      suite
    }
  }
}

/// \chapitreBrevet[clés] = \chapitreBac[style=brevet, clés].
#let bf-chapitreBrevet(..cles, doc) = bf-chapitreBac(style: "brevet", ..cles, doc)
