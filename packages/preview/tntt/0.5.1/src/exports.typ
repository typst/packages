/*
 This module exports all layouts and pages.
*/

/// ------ ///
/// Layout ///
/// ------ ///

#import "layouts/doc.typ": doc, meta
#import "layouts/front-matter.typ": front-matter
#import "layouts/main-matter.typ": main-matter
#import "layouts/back-matter.typ": back-matter

/// ----- ///
/// Pages ///
/// ----- ///

// before content
#import "pages/fonts-display.typ": fonts-display
// #import "pages/cover.typ": cover, cover-en // Not for distribution due to copyright issues
#import "pages/spine.typ": spine
#import "pages/committee.typ": committee
#import "pages/copyright.typ": copyright

// front matter
#import "pages/abstract.typ": abstract, abstract-en
#import "pages/outline-wrapper.typ": outline-wrapper
#import "pages/list-of.typ": equation-list, figure-list, figure-table-list, master-list, table-list
#import "pages/notation.typ": notation

// main matter
// (no specific pages)

// back matter
#import "pages/bilingual-bibliography.typ": bilingual-bibliography
// (appendices, no specific pages)
#import "pages/acknowledge.typ": acknowledge
#import "pages/declaration.typ": declaration
#import "pages/achievement.typ": achievement
#import "pages/review-of.typ": comments, record-sheet, resolution
