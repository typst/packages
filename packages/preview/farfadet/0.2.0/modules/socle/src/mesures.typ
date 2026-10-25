// mesures.typ (farfadet-socle) — métriques de ligne, quad, espacements tcolorbox et largeur courante
// (\linewidth). Ces outils sont lus par
// les énumérations, les colonnes, les tableaux, les exercices et les points.

#import "etat.typ": bf-police, bf-interligne, bf-interligne-p, bf-police-p
#import "precoce.typ": bf-porter, bf-porte, bf-lire

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
    0.8767em / bf-lire(bf-police-p).echelle
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
    bs: bf-lire(bf-interligne-p).baselineskip,
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
/// La largeur est portée par la chaîne de styles (`bf-porter`, portée lexicale) : elle est exacte dès le
/// premier tour de mise en page, quel que soit l'emboîtement des conteneurs (une pile d'états ne la
/// donnait qu'avec un tour de retard par niveau d'emboîtement).
#let bf-largeur-courante() = {
  let l = bf-porte("bf-largeur-ligne")
  if l != none { l } else { bf-largeur-texte() }
}

/// Enveloppe `corps` pour que \tcbitempoint y connaisse \linewidth.
/// Largeur et emplacement du conteneur sont portés par la chaîne de styles (`bf-porter`) : la largeur est
/// exacte dès le premier tour ; l'emplacement (`here()`, sans introspection) ne sert qu'aux boîtes de
/// points, qui seules lisent sa position (`bf-conteneur-ici`). Les piles d'états `bf-largeur-ligne` et
/// `bf-gauche-ligne` ne sont plus tenues (elles donnaient un tour de retard par emboîtement et faisaient
/// recomposer chaque conteneur dès qu'une position changeait sur la page).
///
/// `avant` : contenu posé dans le même conteneur, juste avant `corps`, mais HORS de la portée (pastille d'un
/// item, mise à jour d'état). Les valeurs portées (largeur, emplacement `here()`) sont propres à chaque
/// conteneur : tout ce qui est composé sous elles a une chaîne de styles unique et ne profite d'aucun cache
/// (deux pastilles « 1. » identiques étaient composées deux fois). Ce qui n'en a pas besoin passe par `avant`.
#let bf-avec-largeur(corps, avant: none) = layout(taille => {
  avant
  bf-porter(("bf-largeur-ligne": taille.width, "bf-conteneur": here()), corps)
})

/// Largeur et abscisse du bord gauche du conteneur le plus proche (`bf-avec-largeur`), sinon celles du
/// texte de la page : `(x0, largeur)`. Lit une position (introspection) : réservé aux boîtes de points.
/// À appeler dans un `context`.
#let bf-conteneur-ici() = {
  let l = bf-porte("bf-largeur-ligne")
  let loc = bf-porte("bf-conteneur")
  if l != none and loc != none { (loc.position().x, l) } else { (bf-marge-page("left"), bf-largeur-texte()) }
}
