# Limitations and Discrepancies from AFH 33-337

This document catalogs known discrepancies between the `tonguetoquill-usaf-memo` implementation and the AFH 33-337 Chapter 14 "The Official Memorandum" formatting standards.

## Reference Document
All section references (§) refer to AFH 33-337, 27 MAY 2015, Chapter 14 "The Official Memorandum" unless otherwise noted.

---

## 1. Widow/Orphan Prevention

**AFH 33-337 Requirement:**
- "The signature block is never on a page by itself" (Signature Block section)
- "Type at least two lines of the text on each page. Avoid dividing a paragraph of less than four lines between two pages" (§11 Continuation Pages)

**Current Implementation:**
- Uses Typst's `weak: false` spacing and `breakable: false` blocks to discourage orphaning
- Uses `set text(costs: (orphan: 0%))` to reduce single-line orphans
- **Limitation:** Perfect enforcement isn't feasible without over-engineering. Typst's layout engine may still orphan signatures or create undesirable page breaks in edge cases.

**Reference:** `src/primitives.typ:132-137`, `src/primitives.typ:322-326`

---

## 2. Single Paragraph Detection

**AFH 33-337 Requirement:**
- "Number and letter each paragraph and subparagraph. A single paragraph is not numbered" (§2 Numbering paragraphs)

**Current Implementation:**
- Uses heuristic detection by examining the string representation of content for double newlines (`\n\n`) or `parbreak()` markers
- **Limitation:** Detection may not be 100% reliable for all content types or edge cases. Content that appears as a single paragraph visually might be detected as multiple if it contains internal paragraph breaks in the markup.

**Reference:** `src/primitives.typ:252-261`

---

## 3. Adaptive Margins for Short Memorandums

**AFH 33-337 Requirement:**
- "Use 1-inch margins on the left, right and bottom for most memorandums. For shorter communications, you may adjust the margins:" (§4)
  - 20 lines or more: 1 inch margins
  - 10-19 lines: 1 to 1½ inch margins
  - 1-9 lines: 1½ to 2 inch margins

**Current Implementation:**
- Fixed 1-inch margins on all sides for all documents
- **Limitation:** Does not automatically adjust margins based on content length. Users must manually adjust if desired.

**Reference:** `src/frontmatter.typ:44-50`

---

## 4. Vertical Centering for Short Communications

**AFH 33-337 Requirement:**
- "For short communications, you may adjust the top margin in order to balance the content toward the vertical center of the document by moving all elements from the date to the last line of the closing" (The Heading Section, introductory paragraph)

**Current Implementation:**
- Fixed 1.75-inch date placement from top of page
- **Limitation:** No automatic vertical centering for short memos. Users must manually adjust spacing if desired.

**Reference:** `src/frontmatter.typ:98-100`

---

## 5. Font Size Flexibility for Page Break Control

**AFH 33-337 Requirement:**
- "Use 12 point Times New Roman font for text. Smaller sizes, no smaller than 10 point, may be used when required to control page breaks. For example, shrink the font of all text in the memorandum to prevent a page break between the body and closing elements" (§5)

**Current Implementation:**
- Fixed 12pt font size (configurable via `font_size` parameter)
- **Limitation:** No automatic font size reduction to prevent page breaks. Users must manually specify smaller font size if needed.

**Reference:** `src/frontmatter.typ:41`, `src/utils.typ:47-54`

---

## 6. Page Number Omission for Short Memos

**AFH 33-337 Requirement:**
- "You may omit page numbers on a one- or two-page memorandum; however, memorandums longer than two pages must have page numbers" (§12 Page numbering)

**Current Implementation:**
- Page numbers always appear on page 2 and subsequent pages
- **Limitation:** No option to omit page numbers for one- or two-page memorandums. This is compliant but not flexible.

**Reference:** `src/frontmatter.typ:52-65`

---

## 7. IN TURN Distribution Format

**AFH 33-337 Requirement:**
- "When addressing several offices IN TURN, use the 'IN TURN' format to distribute the official memorandum to several individuals or offices in sequence" (MEMORANDUM FOR section)
- Requires typing "IN TURN" in uppercase, one line below the last address

**Current Implementation:**
- **Not implemented.** The template does not support IN TURN format for sequential distribution.

**Reference:** AFH 33-337 lines 95-109

---

## 8. ATTENTION Element

**AFH 33-337 Requirement:**
- "The attention element is aligned under the address or office symbol in the 'MEMORANDUM FOR' line... format is to place 'ATTENTION:' or 'ATTN:' or 'THROUGH:' with the abbreviated rank and last name" (ATTENTION: section)

**Current Implementation:**
- **Not implemented.** The template does not support ATTENTION, ATTN, or THROUGH elements.

**Reference:** AFH 33-337 lines 145-157

---

## 9. References in Subject Line (Single Reference)

**AFH 33-337 Requirement:**
- "There are two options for placement of the references element—within the subject line or below the subject line. Cite a single reference to a communication or a directive in parentheses immediately after the subject title" (References section)

**Current Implementation:**
- Only supports references below the subject line
- **Limitation:** Single references cannot be placed inline within the subject line as shown in examples like "SUBJECT: PACAF Work Center Standard (PACAF Memo, Same Subject, 6 June 2012)"

**Reference:** `src/primitives.typ:115-123`, AFH 33-337 lines 229-253

---

## 10. Authority Line Alternative Placement

**AFH 33-337 Requirement:**
- "Add 'FOR THE COMMANDER' (or appropriate title) in uppercase on the second line below the last line of the text and 4.5 inches from the left edge of the page or three spaces to the right of the page center" (Authority Line section, emphasis added)

**Current Implementation:**
- **Not implemented.** Authority line feature is not currently available in the template.
- If implemented, would need to support both placement options: 4.5 inches from left OR three spaces right of center.

**Reference:** AFH 33-337 lines 367-401

---

## 11. Dual Signature Blocks

**AFH 33-337 Requirement:**
- "If dual signatures are required, type the junior ranking official's signature block at the left margin; type the senior ranking official's signature block 4.5 inches from the left edge of the page" (Signature Block section)

**Current Implementation:**
- **Not implemented.** Only single signature blocks are supported.

**Reference:** AFH 33-337 lines 402-411

---

## 12. Continuation Page Headers for Long Attachments/Distribution Lists

**AFH 33-337 Requirement:**
- "Do not divide attachment listings between two pages. If the listing is too long, type 'Attachments: (listed on next page),' and list the attachments on a separate page" (Attachment or Attachments section)
- Similar guidance for distribution lists

**Current Implementation:**
- Implements continuation page handling with automatic page breaks and continuation labels
- **Limitation:** While implemented, the exact formatting of continuation pages may differ slightly from manual examples in AFH 33-337.

**Reference:** `src/primitives.typ:154-166`, `src/primitives.typ:191-211`

---

## 13. Record/Coordination Copy Markings

**AFH 33-337 Requirement:**
- Detailed guidance for showing coordination, internal courtesy copy distribution, writer identification, and magnetic storage media annotations on record copies (Record or Coordination Copy section)

**Current Implementation:**
- **Not implemented.** The template focuses on final document output and does not support record copy markup features.

**Reference:** AFH 33-337 lines 583-615

---

## 14. Memorandum for Record (MR/MFR) Format

**AFH 33-337 Requirement:**
- "When preparing a MR, whether it is for another office or when using it as your primary record, write or type on the record copy any information needed for the record" (Preparing a Memorandum for Record)

**Current Implementation:**
- **Not implemented.** Memorandum for Record is a distinct format variant not currently supported.

**Reference:** AFH 33-337 lines 610-614

---

## 15. Typeset Correspondence Features

**AFH 33-337 Requirement:**
- "You may typeset correspondence for a large audience... Use the full range of typesetting capabilities, including, but not limited to, two columns, italics, bold type, variable spacing, boxed inserts, and screened backgrounds" (Typeset Correspondence section)

**Current Implementation:**
- Basic typesetting features (bold, italics) are available through standard Typst markup
- **Limitation:** Template does not provide specific support for advanced typesetting layouts like two-column format, boxed inserts, or screened backgrounds for large-audience memorandums.

**Reference:** AFH 33-337 lines 576-581

---

## 16. Attachment Appendix/Annex/Exhibit Hierarchy

**AFH 33-337 Requirement:**
- Detailed hierarchy for marking attachments and their sub-documents: Attachment → Appendix → Annex → Exhibit (Arranging and Marking Attachments section)
- Specific marking formats: Atch 1, Appendix A, Annex 1, Exhibit A

**Current Implementation:**
- Only basic attachment listing is supported
- **Limitation:** No automated support for appendices, annexes, or exhibits. No automated marking/numbering of attachment pages.

**Reference:** `src/primitives.typ:191-211`, AFH 33-337 lines 625-645

---

## 17. Date Format Options

**AFH 33-337 Requirement:**
- Three format options: "Day Month Year" (15 October 2014), "DD Mmm YY" (15 Oct 14) for military, or "Month Day, Year" (October 15, 2014) for civilian

**Current Implementation:**
- Only implements "Day Month Year" format (e.g., "1 January 2024")
- **Limitation:** Does not support abbreviated "DD Mmm YY" format or civilian "Month Day, Year" format.

**Reference:** `src/utils.typ:176-200`, AFH 33-337 lines 55-70

---

## 18. Special Handling for Classified Correspondence

**AFH 33-337 Requirement:**
- "Follow AFI 31-401, Information Security Program Management, applicable executive orders and DoD guidance for the necessary markings on classified correspondence" (§3)
- Includes specific guidance for classified attachment markings showing classification symbols

**Current Implementation:**
- Basic classification marking in header/footer with appropriate colors
- **Limitation:** May not fully implement all AFI 31-401 requirements for classified correspondence markings, portion markings, or classified attachment handling.

**Reference:** `src/frontmatter.typ:67-79`, `src/config.typ:50-64`, AFH 33-337 lines 28-29, 495-497

---

## Summary

This implementation provides a solid foundation for creating AFH 33-337 compliant USAF memorandums with the most commonly used features. However, users should be aware of the limitations listed above and may need to manually adjust formatting or add elements for specific use cases, particularly:

- Classified correspondence requiring full AFI 31-401 compliance
- IN TURN distribution memorandums
- Memorandums requiring authority lines or dual signatures
- Short memorandums requiring vertical centering or adjusted margins
- Documents with complex attachment hierarchies (appendices, annexes, exhibits)

For questions about specific requirements or to report additional discrepancies, please file an issue at the project repository.
