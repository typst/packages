#import "@preview/tonguetoquill-usaf-memo:0.1.0": official-memorandum, indorsement

#set page(margin: 0.75in)
#set text(size: 10pt)

#official-memorandum(
  // LETTERHEAD CONFIGURATION
  letterhead-title: "DEPARTMENT OF THE AIR FORCE",
  letterhead-caption: "[YOUR SQUADRON/UNIT NAME]",
  letterhead-seal: image("assets/dod_seal.gif"),
  
  // RECIPIENTS - Multiple format options shown
  memo-for: (
    "[FIRST/OFFICE]", "[SECOND/OFFICE]", "[THIRD/OFFICE]", "[FOURTH/OFFICE]", "[FIFTH/OFFICE]", "[SIXTH/OFFICE]"
    // Alternative single recipient: "[SINGLE/OFFICE]"
  ),
  
  // SENDER INFORMATION BLOCK
  from-block: (
    "[YOUR/SYMBOL]",                    // Organization symbol
    "[Your Organization Name]",         // Full organization name  
    "[Street Address]",                 // Mailing address
    "[City ST 12345-6789]"             // City, state, ZIP
  ),
  
  // MEMO SUBJECT LINE
  subject: "[Your Subject in Title Case - Required Field]",
  
  // OPTIONAL: REFERENCE DOCUMENTS
  references: (
    "[Reference 1: Regulation/Directive, Date, Title]",
    "[Reference 2: AFI/AFH Number, Date, Title]",
    "[Reference 3: Local instruction or guidance]"
  ),
  
  // SIGNATURE BLOCK - Who signs the memo
  signature-block: (
    "[FIRST M. LAST, Rank, USAF]",     // Full name and rank
    "[Your Official Duty Title]",      // Position/title
    "[Organization (optional)]"        // Optional third line
  ),
  
  // ATTACHMENTS - Supporting documents
  attachments: (
    "[Description for first attachment, Date]",
    "[Description for second attachment, Date]"
  ),
  
  // COURTESY COPIES - Who gets copies
  cc: (
    "[First CC Recipient, ORG/SYMBOL]",
    "[Second CC Recipient, ORG/SYMBOL]",
  ),
  
  // DISTRIBUTION LIST - Who receives memo
  distribution: (
    "[ORGANIZATION/SYMBOL]",
    "[Another Organization Name]",
    "[Third Distribution Point]"
  ),
  
  // FORMATTING OPTIONS - Customize appearance
  body-font: "Times New Roman",               // Body text font (TNR for AFH 33-337)
  paragraph-block-indent: false,             // true = indent paragraphs, false = block style
  leading-backmatter-pagebreak: false,         // true = force page break before attachments/cc
  memo-for-cols: 3,                        // Number of columns for recipient grid (default 3)
                                           
  
  // INDORSEMENTS - For routing through multiple offices
  indorsements: (
    indorsement(
      office-symbol: "[REVIEWING/OFFICE]",
      memo-for: "[NEXT/OFFICE]",
      signature-block: (
        "[REVIEWER NAME], [Rank], USAF",
        "[REVIEWER TITLE]"
      ),
    )[
      [First indorsement body text. This is where the reviewing office adds their comments, recommendations, or approval. Indorsements are automatically numbered as "1st Ind", "2d Ind", etc.]
    ],
    
    indorsement(
      office-symbol: "[FINAL/AUTHORITY]",
      memo-for: "[ORIGINAL/SENDER]",
      signature-block: (
        "[FINAL OFFICIAL, Rank, USAF]",
        "[Final Authority Title]"
      ),
      separate-page: true,                   // Use separate page format (common for final authority)
    )[
      [Final indorsement text. This indorsement uses separate page format, commonly used when returning to the original sender with final approval or disapproval.]
    ]
  )
)[
 #link("https://github.com/SnpM/tonguetoquill-usaf-memo")[`tonguetoquill-usaf-memo`] is an open-source project maintained on GitHub. See #link("https://github.com/snpm/tonguetoquill-usaf-memo")[the README] for documentation. Please send bug reports and contributions to this repository.

This memo template demonstrates every parameter and feature of the USAF memorandum template. Replace all bracketed placeholders with your actual content.

This memorandum serves as both a comprehensive guide and working example of the USAF memo template system. The template automatically handles all AFH 33-337 formatting requirements while providing flexibility for various memo types and organizational needs.

+ *Required Parameters.* Only two parameters are required: `memo-for` (recipients) and `subject` (subject line in title case). Recipients can be formatted as a string, array, or 2D array for grid layout.

+ *Optional Components.* All other parameters are optional and can be omitted if not needed. This includes references, attachments, courtesy copies, distribution lists, and indorsements.

The template provides intelligent paragraph structuring that automatically numbers and formats content according to Air Force standards. Each paragraph and subparagraph is properly spaced and indented without manual intervention.

+ *Paragraph Structure.* Use Typst's enum syntax to create hierarchical subparagraphs:

  + Base paragraphs have no enum markers. They are automatically numbered (1., 2., 3., etc.) and formatted per AFH 33-337.

  + First-level subparagraphs use `+ [content]`. These are lettered (a., b., c., etc.) and automatically increment.

    + Use progressive tab indentation before `+` for deeper subparagraphs.

Writing content in Typst follows a markup-based approach that combines simplicity with powerful formatting capabilities. Understanding Typst content mode is essential for effective memo creation.

+ *Typst Content Basics.* In Typst, you write content in "content mode" where text flows naturally. Functions are called with `#function-name[]` syntax, and the square brackets contain the content or parameters.

+ *Text Formatting.* Use standard markup for emphasis: `*bold text*` for *bold text*, `_italic text_` for _italic text_, and `` `code text` `` for `code text`. These can be combined as needed.

+ *Special Characters.* Typst handles most special characters automatically. For literal hash symbols or other Typst syntax characters, escape them with a backslash: `\#` produces \#.

+ *Line Breaks and Spacing.* Single line breaks are ignored (like LaTeX). Use double line breaks to create new paragraphs. The template handles all official spacing requirements automatically.

Template features include automatic AFH 33-337 compliant formatting, smart paragraph and subparagraph numbering, intelligent page break handling, grid layout support for multiple recipients, complete indorsement system for routing, and enforcement of all Air Force publishing standards.

]
