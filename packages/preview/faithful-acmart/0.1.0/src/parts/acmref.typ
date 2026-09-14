// Public facade for the pure-Typst ACM bibliography backends.
//
// The implementation is split by responsibility:
//   * acmref-common.typ: rendering/state primitives shared by both backends,
//   * acmref-bst.typ: ACM-Reference-Format.bst renderer,
//   * acmref-biblatex.typ: ACM BibLaTeX + software drivers,
//   * acmref-cite.typ: cite registration, sorting, labels, and bibliography output.

#import "acmref-common.typ": tex-render-state as _tex-render-state
#import "acmref-cite.typ": bbl-cite as _bbl-cite, bbl-citet as _bbl-citet, bbl-citeyear as _bbl-citeyear, bbl-citeauthor as _bbl-citeauthor, bbl-bibliography as _bbl-bibliography, cite-style-state as _cite-style-state

#let tex-render-state = _tex-render-state
#let cite-style-state = _cite-style-state
#let bbl-cite = _bbl-cite
#let bbl-citet = _bbl-citet
#let bbl-citeyear = _bbl-citeyear
#let bbl-citeauthor = _bbl-citeauthor
#let bbl-bibliography = _bbl-bibliography
