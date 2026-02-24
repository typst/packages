/**
 * icml2025.typ
 *
 * International Conference on Machine Learning (ICML) 2025.
 */

#import "/icml2024.typ": icml2024

#let public-notice = [
  _Proceedings of the 42#super[nd] International Conference on Machine
  Learning_, Vancouver, Canada. PMLR 267, 2025. Copyright 2025 by the
  author(s).
]

/**
 * icml2025 - International Conference On Machine Learning (ICML) 2025.
 *
 * Args:
 *   title: The paper's title as content.
 *   authors: An array of author dictionaries. Each of the author dictionaries
 *     must have a name key and can have the keys department, organization,
 *     location, and email.
 *   abstract: The content of a brief summary of the paper or none. Appears at
 *     the top under the title.
 *   bibliography: The result of a call to the bibliography function or none.
 *     The function also accepts a single, positional argument for the body of
 *     the paper.
 *   accepted: Valid values are `none`, `false`, and `true`. Missing value
 *     (`none`) is designed to prepare arxiv publication. Default is `false`.
 *   aux: Provide knobs for template adjusting. Specifically, it allows to
 *     customize public notice with `public-notice` attribute or to override
 *     default serif with `font-family`.
 */
#let icml2025(
  title: [],
  authors: (),
  keywords: (),
  date: auto,
  abstract: none,
  bibliography: none,
  header: none,
  appendix: none,
  accepted: false,
  aux: (:),
  body,
) = {
  aux.public-notice = public-notice
  show: icml2024.with(
    title: title, authors: authors, keywords: keywords, date: date,
    abstract: abstract, bibliography: bibliography, header: header,
    appendix: appendix, accepted: accepted, aux: aux)
  body
}
