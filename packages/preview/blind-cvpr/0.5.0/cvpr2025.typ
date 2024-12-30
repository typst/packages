/**
 * cvpr2025.typ
 *
 * CVPR 2025 template.
 */

#import "/cvpr2022.typ": cvpr2022

#let conf-year = [2025]

/**
 * cvpr2025 - Template for Computer Vision and Pattern Recognition Conference
 * (CVPR) 2025.
 *
 * Args:
 *   title: Paper title.
 *   authors: Tuple of author objects and affilation dictionary.
 *   keywords: Publication keywords (used in PDF metadata).
 *   date: Creation date (used in PDF metadata).
 *   abstract: Paper abstract.
 *   bibliography: Bibliography content. If it is not specified then there is
 *   not reference section.
 *   appendix: Content to append after bibliography section.
 *   accepted: Valid values are `none`, `false`, and `true`. Missing value
 *   (`none`) is designed to prepare arxiv publication. Default is `false`.
 *   id: Submission identifier.
 */
#let cvpr2025(
  title: [],
  authors: (),
  keywords: (),
  date: auto,
  abstract: [],
  bibliography: none,
  appendix: none,
  accepted: false,
  id: none,
  body,
) = {
  show: cvpr2022.with(
    title: title,
    authors: authors,
    keywords: keywords,
    date: date,
    abstract: abstract,
    bibliography: bibliography,
    appendix: appendix,
    accepted: accepted,
    id: id,
    aux: (conf-year: [2025]),
  )
  body
}
