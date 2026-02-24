#import "@preview/tonguetoquill-usaf-memo:1.0.0": frontmatter, mainmatter, backmatter

#show: frontmatter.with(
  letterhead_title: "DEPARTMENT OF THE SPACE FORCE",
  letterhead_caption: "1ST SPACE OPERATIONS SQUADRON",
  letterhead_seal: image("assets/dow_seal.png"),
  subject: "Space Force Memorandum Template Format",
  memo_for: "SPACECOM/CC",
  memo_from: (
    "1 SOPS/CC",
    "1st Space Operations Squadron",
    "Schriever Space Force Base",
    "Colorado Springs CO 80912-7001"
  ),
  footer_tag_line: "semper supra",
)

#show: mainmatter

This memorandum demonstrates the proper format for Space Force official correspondence following AFH 33-337 standards. The Space Force adopted Air Force correspondence formats with appropriate service-specific modifications.

All formatting, spacing, fonts, and organizational elements remain consistent with AFH 33-337 requirements while reflecting proper Space Force organizational structure and rank designations.

+ Space Force personnel should use appropriate service-specific elements including proper rank abbreviations (USSF), organizational symbols, and duty titles specific to Space Force operations.

+ The letterhead should reflect the appropriate Space Force organization title, typically "DEPARTMENT OF THE SPACE FORCE" followed by the specific unit or command designation.

This template ensures full compliance with official correspondence standards while maintaining Space Force identity and organizational structure.

#backmatter(
  signature_block: (
    "JOHN A. GUARDIAN, Colonel, USSF",
    "Commander",
    "1st Space Operations Squadron"
  ),
  attachments: (
    "Space Force Instruction 33-301, 1 Aug 2020",
    "DoD Directive 8000.01, 15 Feb 2013"
  ),
)
