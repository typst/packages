// acmcp format — ACM cover page (currently used by JDS), best-effort.
//
// Single-column, acmsmall-like geometry (6.75x10, probed), 9pt default. The title
// is narrowed by 6pc (acmart.dtx:6988) and sections are UNNUMBERED (secnumdepth
// -1, acmart.dtx:8501); the ACM reference format is off by default
// (\@ACM@printacmreffalse, acmart.dtx:3006). The cover layout is reproduced in
// lib.typ: the body sits on a light tint of the article colour, narrowed 6.5pc on
// the right (\@ACM@color@frame, acmart.dtx:5899) — ONLY the body, not the
// title/authors/abstract; the right-margin infobox (JDS logo over code/data links,
// keywords, contributions, contact info — acmart.dtx:6724) is right-aligned and
// bottom-aligned to the body frame; the rotated article-type label sits at the
// page's left edge.
#import "_base.typ": tp, size-ladder, make-format

#let acmcp(font-size: 9pt) = make-format(
  name: "acmcp",
  kind: "cover",
  ladder: size-ladder(font-size, format: "acmcp"),
  paper: (width: 6.75in, height: 10in),
  margin: (inside: 46 * tp, outside: 46 * tp, top: 85 * tp, bottom: 66.7 * tp), // head top 58
  foot-skip: 24 * tp,
  secnumdepth: -1,         // no section numbers (acmart.dtx:8501)
  title-width-reduction: 6 * 12 * tp, // narrow the title by 6pc to clear the infobox
  // \@authorfont \large\sffamily ; \@affiliationfont \small\normalfont (acmart.dtx:7234,
  // same as acmsmall — a step smaller than acmart's generic default).
  author-font: (family: "sans", weight: "regular", size: "large"),
  affil-font: (family: "serif", weight: "regular", size: "small"),
  // journal single-column top matter + generic sf-bold sections (acmsmall-like).
)
