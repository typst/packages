/**
 * iclr.typ
 */

#import "/iclr2025.typ": default-header-title, iclr2025

/**
 * iclr - Template for International Conference on Learning Representations
 * (ICLR).
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
 *   aux: Auxiliary parameters to tune font settings (e.g. font familty) or
 *   page decorations (e.g. page header).
 */
#let iclr(
  title: [],
  authors: (),
  keywords: (),
  date: auto,
  abstract: [],
  bibliography: none,
  appendix: none,
  accepted: false,
  aux: (:),
  body,
) = {
  show: iclr2025.with(
    title: title,
    authors: authors,
    keywords: keywords,
    date: date,
    abstract: abstract,
    bibliography: bibliography,
    appendix: appendix,
    accepted: accepted,
    aux: aux,
  )
  body
}
