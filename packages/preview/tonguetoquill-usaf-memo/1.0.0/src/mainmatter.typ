// mainmatter.typ: Mainmatter show rule for USAF memorandum
//
// This module implements the mainmatter (body text) of a USAF memorandum per
// AFH 33-337 Chapter 14 "The Text of the Official Memorandum" (§1-12).

#import "primitives.typ": *

/// Mainmatter show rule for USAF memorandum body content.
///
/// AFH 33-337 "The Text of the Official Memorandum" §1-12 requirements:
/// - Begin text on second line below subject/references
/// - Single-space text, double-space between paragraphs
/// - Number and letter each paragraph/subparagraph
/// - "A single paragraph is not numbered" (§2)
/// - First paragraph flush left, never indented
///
/// Applies AFH 33-337 paragraph numbering and formatting to the main body
/// of the memorandum. Automatically detects single vs. multiple paragraphs
/// to comply with AFH 33-337 numbering requirements.
///
/// - content (content): The body content to render
/// -> content
#let mainmatter(it) = {
  render-paragraph-body(it)
}
