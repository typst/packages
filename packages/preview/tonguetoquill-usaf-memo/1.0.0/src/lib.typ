// lib.typ: Public API for USAF memorandum template
//
// This module provides a composable API for creating United States Air Force
// memorandums that comply with AFH 33-337 "The Tongue and Quill" Chapter 14
// "The Official Memorandum" formatting standards.
//
// AFH 33-337 Chapter 14 specifies exact requirements for:
// - Margins: 1 inch on all sides (§4)
// - Font: 12pt Times New Roman (§5)
// - Date placement: 1.75 inches from top, 1 inch from right (Date section)
// - Heading elements: MEMORANDUM FOR, FROM, SUBJECT with 2-line spacing
// - Paragraph numbering: Hierarchical 1., a., (1), (a) format (§2)
// - Signature block: 4.5 inches from left, never orphaned (Signature Block section)
// - Backmatter: Attachments, cc:, distribution with specific spacing
//
// Key features:
// - Composable show rules for frontmatter and mainmatter
// - Function-based backmatter and indorsements for correct ordering
// - No global state - configuration flows through metadata
// - Reusable primitives for common rendering tasks
// - AFH 33-337 compliant formatting throughout
//
// Basic usage:
//
// #import "@preview/tonguetoquill-usaf-memo:0.2.0": frontmatter, mainmatter, backmatter, indorsement
//
// #show: frontmatter.with(
//   subject: "Your Subject Here",
//   memo_for: ("OFFICE/SYMBOL",),
//   memo_from: ("YOUR/SYMBOL",),
// )
//
// #show: mainmatter
//
// Your memo body content here.
// (Paragraphs are automatically numbered per AFH 33-337)
//
// #backmatter(
//   signature_block: ("NAME, Rank, USAF", "Title"),
//   attachments: (...),
//   cc: (...),
// )
//
// #indorsement(
//   from: "ORG/SYMBOL",
//   to: "RECIPIENT/SYMBOL",
//   signature_block: ("NAME, Rank, USAF", "Title"),
// )[
//   Indorsement content here.
// ]

#import "frontmatter.typ": frontmatter
#import "mainmatter.typ": mainmatter
#import "backmatter.typ": backmatter
#import "indorsement.typ": indorsement
