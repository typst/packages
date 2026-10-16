// Boîte à outils « maths à la française » (voir l'étape 2).
//
//   #import "francais.typ": *
//   #show: francais          // s'applique à tout le document
//
// Ou localement : francais[$3.14$]

// « ; » espacé des deux côtés, comme dans [0 ; 1] ou A(1 ; 3).
#let pvfr = math.class("relation", ";")

// Intervalles : iff(0, 1) → [0 ; 1], ioo(2, +oo) → ]2 ; +∞[, etc.
#let iff(a, b) = $lr(bracket.l #a #pvfr #b bracket.r)$
#let ioo(a, b) = $lr(bracket.r #a #pvfr #b bracket.l)$
#let ifo(a, b) = $lr(bracket.l #a #pvfr #b bracket.l)$
#let iof(a, b) = $lr(bracket.r #a #pvfr #b bracket.r)$

#let francais(corps) = {
  show math.equation: it => {
    show ";": pvfr
    // On tape 3.14, Typst affiche 3,14 — dans les formules seulement.
    show regex("\d\.\d"): m => m.text.replace(".", ",")
    it
  }
  // Coordonnées de vecteurs en taille normale, même au fil du texte.
  show math.vec: math.display
  // Références d'équations affichées « (1) » au lieu de « Équation 1 ».
  show ref: it => {
    let el = it.element
    if el != none and el.func() == math.equation and el.numbering != none {
      link(el.location(), numbering(el.numbering, ..counter(math.equation).at(el.location())))
    } else { it }
  }
  corps
}
