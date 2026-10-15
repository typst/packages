// mesures.typ (bfcours-socle) — métriques de ligne, quad, espacements tcolorbox et largeur courante
// (\linewidth). Ces outils sont lus par
// les énumérations, les colonnes, les tableaux, les exercices et les points.

#import "etat.typ": bf-police, bf-interligne

/// Séquence de contenus (type des blocs `[…]`).
#let _sequence = [a *b*].func()

/// Quad LaTeX (1 em TeX) de la police courante, en em Typst. À appeler dans un `context`.
/// Utopia (fourier) : quad = 0,8767 × taille nominale LaTeX ; la taille Typst du corps vaut
/// nominale × bf-police.echelle. Latin Modern Sans (non réduite) : quad = 0,979 × taille.
#let bf-quad() = {
  let f = text.font
  let famille = if type(f) == array { f.at(0, default: "") } else { f }
  let famille = lower(if type(famille) == dictionary { famille.name } else { famille })
  if famille.contains("sans") or famille.contains("heros") { 0.979em } else {
    0.8767em / bf-police.get().echelle
  }
}

/// Métriques de ligne du contexte courant (à appeler dans un `context`).
///   bs     : \baselineskip LaTeX du document (état bf-interligne) ;
///   haut   : partie d'une ligne Typst au-dessus de la ligne de base (top-edge) ;
///   desc   : partie d'une ligne Typst sous la ligne de base (bottom-edge) ;
///   asc    : hauteur d'un ascendant (hauteur TeX d'une ligne ordinaire) ;
///   prof   : profondeur d'un jambage (profondeur TeX d'une ligne ordinaire) ;
///   espace : espace intermot de la police courante.
#let bf-metriques() = {
  let haut = measure(text(bottom-edge: "baseline", [A])).height
  let ligne = measure([A]).height
  (
    bs: bf-interligne.get().baselineskip,
    haut: haut,
    desc: ligne - haut,
    asc: measure(text(top-edge: "bounds", bottom-edge: "baseline", [l])).height,
    prof: measure(text(top-edge: "baseline", bottom-edge: "bounds", [p])).height,
    espace: measure([x x]).width - measure([xx]).width,
  )
}

/// Espacements « before/after skip balanced » de tcolorbox (défaut : 0,5\baselineskip) :
/// ligne de base précédente → haut de la boîte = 0,8 bs ; bas de la boîte → ligne de base suivante = 1,2 bs.
#let bf-espacement-tcb(m) = (above: 0.8 * m.bs - m.desc, below: 1.2 * m.bs - m.haut)

/// Retire les espaces de tête d'un contenu (équivalent de \ignorespaces).
#let bf-sans-espace-initial(c) = {
  if type(c) != content or c.func() != _sequence { return c }
  let enfants = c.children
  while enfants.len() > 0 and (enfants.at(0) == [ ] or enfants.at(0).func() == parbreak) {
    enfants = enfants.slice(1)
  }
  if enfants.len() == 0 { [] } else { _sequence(enfants) }
}

/// Largeur de ligne courante (\linewidth) : pile tenue par les conteneurs de la suite.
#let bf-largeur-ligne = state("bf-largeur-ligne", ())

/// Marge d'un côté de la page (« left », « right »…), à appeler dans un `context`.
#let bf-marge-page(c) = {
  let marges = page.margin
  let v = if type(marges) == dictionary { marges.at(c, default: auto) } else { marges }
  if v == auto { 2.5 / 21 * calc.min(page.width, page.height) } else if type(v) == relative {
    v.ratio * page.width + v.length
  } else if type(v) == ratio { v * page.width } else { v }
}

/// Largeur du texte de la page (\textwidth), à appeler dans un `context`.
#let bf-largeur-texte() = page.width - bf-marge-page("left") - bf-marge-page("right")

/// Abscisse (sur la page) du bord gauche des conteneurs de la suite : pile parallèle à bf-largeur-ligne.
#let bf-gauche-ligne = state("bf-gauche-ligne", ())

/// Largeur courante : celle du conteneur de la suite le plus proche, sinon celle du texte de la page.
/// Dans une tcolorbox (minipage), LaTeX donne cette valeur à \linewidth ET à \textwidth
/// (relevé : `p{0.56\textwidth}` d'un \printcompindex placé dans un tcbraster). À appeler dans un `context`.
#let bf-largeur-courante() = {
  let pile = bf-largeur-ligne.get()
  if pile.len() > 0 { pile.last() } else { bf-largeur-texte() }
}

/// Enveloppe `corps` pour que \tcbitempoint y connaisse \linewidth.
#let bf-avec-largeur(corps) = layout(taille => {
  // largeur du conteneur et abscisse de son bord gauche : la boîte « n pts » s'y range
  context {
    let x = here().position().x
    bf-largeur-ligne.update(p => p + (taille.width,))
    bf-gauche-ligne.update(p => p + (x,))
  }
  corps
  bf-largeur-ligne.update(p => p.slice(0, -1))
  bf-gauche-ligne.update(p => p.slice(0, -1))
})
