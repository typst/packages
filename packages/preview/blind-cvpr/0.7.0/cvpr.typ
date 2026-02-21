/**
 * cvpr.typ
 *
 * Templates for Computer Vision and Pattern Recognition Conference (CVPR)
 * series.
 */

#import "/cvpr2022.typ": cvpr2022, conf-name, eg, etal, indent
#import "/cvpr2025.typ": cvpr2025, conf-year

/**
 * cvpr - Template for Computer Vision and Pattern Recognition Conference
 * (CVPR) series.
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
 *   aux: An optional dictionary to adjust conference specific features.
 */
#let cvpr(
  title: [],
  authors: (),
  keywords: (),
  date: auto,
  abstract: [],
  bibliography: none,
  appendix: none,
  accepted: false,
  id: none,
  aux: (:),
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
    aux: aux,
  )
  body
}
