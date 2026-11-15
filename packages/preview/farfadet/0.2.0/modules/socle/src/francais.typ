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

/// Expression compilée une fois : écrite dans la règle `show math.equation`,
/// `regex(…)` était recompilée pour CHAQUE formule du document.
#let _pv-ou-decimal = regex(";|\d\.\d")

#let francais(corps) = {
  // Une seule règle d'expression régulière par formule (au lieu de deux) : « ; » espacé à la française, et
  // 3.14 affiché 3,14 — dans les formules seulement. Chaque règle est rejouée sur tout le texte de chaque
  // formule : les fusionner divise ce travail par deux, sans changer le rendu.
  show math.equation: it => {
    show _pv-ou-decimal: m => if m.text == ";" { pvfr } else { m.text.replace(".", ",") }
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
