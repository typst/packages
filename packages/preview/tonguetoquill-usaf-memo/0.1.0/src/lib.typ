// lib.typ: A Typst template backend for AFH 33-337 compliant official memorandums.
//
// This module provides the core functionality for creating United States Air Force
// memorandums that comply with AFH 33-337 "The Tongue and Quill" formatting standards.
// It includes functions for rendering all standard memorandum sections and handling
// proper document structure, typography, and spacing.
//
// Key features:
// - Automatic AFH 33-337 compliant formatting
// - Hierarchical paragraph numbering with proper indentation
// - Smart page break handling for backmatter sections
// - Professional typography with configurable fonts
// - Complete letterhead automation including seal placement
// - Flexible content management for various memo types
// - Proper signature block positioning and orphan prevention

#import "utils.typ": *

// =============================================================================
// GLOBAL STATE AND CONFIGURATION
// =============================================================================

/// Global state tracking whether we are in the main memo or indorsements.
/// This is used internally to manage document structure and formatting.
/// -> state
#let MAIN_MEMO = state("main-memo-state", none)

/// Default fonts for letterhead text.
/// Uses Copperplate CC (open-source clone of Copperplate Gothic Bold).
/// -> array
#let DEFAULT_LETTERHEAD_FONTS = ("Copperplate CC",)

/// Default fonts for body text.
/// Prioritizes Times New Roman, falls back to TeX Gyre Termes (open-source clone).
/// -> array
#let DEFAULT_BODY_FONTS = ("times new roman","tex gyre termes")

/// Standard color for letterhead text per AFH 33-337 guidelines.
/// -> color
#let LETTERHEAD_COLOR = rgb("#000099")

// =============================================================================
// DOCUMENT RENDERING FUNCTIONS
// =============================================================================

/// Renders the document letterhead section with organization title, caption, and optional seal.
/// 
/// Positions elements according to AFH 33-337 standards:
/// - Title and caption are centered at 5/8" from top of page
/// - Optional seal is placed in the upper left corner with automatic scaling
/// - Uses standard DoD blue color (#000099) for text
/// 
/// - title (str): Primary organization title (e.g., "DEPARTMENT OF THE AIR FORCE")
/// - caption (str): Sub-organization or command (e.g., "123RD EXAMPLE SQUADRON")
/// - letterhead-seal (content): Organization seal image content to display
/// - font (str | array): Font(s) for letterhead text, normalized to array internally
/// -> content
#let render-letterhead(title, caption, letterhead-seal, font) = {
  //Normalize to array
  if type(font) != array {
    if type(font) != str {
      font = ()
    }
    else{
      font = (font,)
    }
  }
  place(
    dy: 0.625in - spacing.margin, // 5/8in from top of page
    box(
      width: 100%,
      //height: 1.75in - .625in, // 1.75in from top of page minus 5/8in from top margin
      fill: none,
      stroke: none,
      [
        #place(
          center + top,
          align(center)[
            #text(12pt, font: font, fill: LETTERHEAD_COLOR)[#title]\
            #text(10.5pt, font: font, fill: LETTERHEAD_COLOR)[#caption]
          ],
        )
      ],
    ),
  )
  if letterhead-seal != none {
    place(
      left + top,
      dx: -0.5in,
      dy: -.5in,
      block[
        #fit-box(width: 2in, height: 1in)[#letterhead-seal]
      ],
    )
  }
}

/// Renders the date section in proper AFH 33-337 format.
/// 
/// Displays the date right-aligned using standard military date format
/// (e.g., "1 January 2024"). The date appears immediately below the letterhead.
/// 
/// - date (datetime): The date to display in the memorandum header
/// -> content
#let render-date-section(date) = {
  align(right)[#display-date(date)]
}

/// Renders the "MEMORANDUM FOR" section with recipient organization(s).
/// 
/// Formats recipients in a grid layout when multiple recipients are provided.
/// Supports both single recipient (string) and multiple recipients (array).
/// Grid columns are configurable to accommodate varying numbers of recipients.
/// 
/// - recipients (str | array): Recipient organization(s) or individual(s)
/// - cols (int): Number of columns for recipient grid layout (default: 3)
/// -> content
#let render-for-section(recipients, cols) = {
  blank-line()
  grid(
    columns: (auto, spacing.two-spaces, 1fr),
    "MEMORANDUM FOR",
    "",
    align(left)[
      #if type(recipients) == array {
        create-auto-grid(recipients, column-gutter: spacing.tab, cols: cols)
      } else {
        recipients
      }
    ],
  )
}

/// Renders the "FROM" section with sender information.
/// 
/// Displays sender organization, address, and contact information in standard format.
/// Accepts either a single string or array of strings, automatically joining
/// array elements with newlines for proper address formatting.
/// 
/// - from-info (str | array): Sender information (organization, address, etc.)
/// -> content
#let render-from-section(from-info) = {
  blank-line()
  //if from-info is an array, join with newlines
  if type(from-info) == array {
    from-info = from-info.join("\n")
  }

  grid(
    columns: (auto, spacing.two-spaces, 1fr),
    "FROM:", "", align(left)[#from-info],
  )
}

/// Renders the "SUBJECT" section with memorandum topic.
/// 
/// Displays the subject line in proper format with consistent spacing.
/// The subject should be descriptive and in title case per AFH 33-337 standards.
/// 
/// - subject-text (str): Memorandum subject line in title case
/// -> content
#let render-subject-section(subject-text) = {
  blank-line()
  grid(
    columns: (auto, spacing.two-spaces, 1fr),
    "SUBJECT:", "", [#subject-text],
  )
}

/// Renders the optional "References" section with supporting documents.
/// 
/// Lists reference documents in lettered format (a), (b), (c), etc.
/// Only renders if references are provided (not empty or none).
/// Commonly used for regulations, instructions, or prior correspondence.
/// 
/// - references (array): Array of reference document strings
/// -> content
#let render-references-section(references) = {
  if not falsey(references) {
    blank-line()
    grid(
      columns: (auto, spacing.two-spaces, 1fr),
      "References:", "", enum(..references, numbering: "(a)"),
    )
  }
}

/// Renders a signature block with proper AFH 33-337 formatting and orphan prevention.
/// 
/// Positions the signature block at the bottom right of the memorandum with:
/// - 5 blank lines above for handwritten signature space
/// - 4.5" left margin positioning (right-aligned)
/// - Hanging indent of 1em for multi-line entries
/// - Breakable: false to prevent orphaned signature blocks
/// 
/// Per AFH 33-337: "The signature block is never on a page by itself."
/// 
/// - signature-lines (array): Array of signature lines (name/rank, title, organization)
/// -> content
#let render-signature-block(signature-lines) = {
  blank-lines(5, weak: false)
  block(breakable: false)[
    #align(left)[
      #pad(left: 4.5in - spacing.margin)[
        #text(hyphenate: false)[
          #for line in signature-lines {
            par(hanging-indent: 1em, justify: false)[#line]
          }
        ]
      ]
    ]
  ]
}

/// Processes document body content with automatic paragraph numbering and AFH 33-337 compliance.
/// 
/// Handles the complex logic for:
/// - Automatic hierarchical paragraph numbering (1., a., (1), (a), etc.)
/// - Converting Typst enum/list items to proper military paragraph format
/// - Managing paragraph indentation and spacing
/// - Tracking paragraph levels and counter states
/// 
/// The function intercepts Typst's native enum and list structures and converts
/// them to AFH 33-337 compliant numbered paragraphs with proper indentation.
/// 
/// - content (content): Document body content with enums/lists for paragraph structure
/// -> content
#let render-body(content) = {
  counter("par-counter-0").update(1)
  let s = state("par-count", 0)

  context {
    // Embed enum processing to calculate paragraph levels
    let processed_content = context {
      //erase enums
      show enum.item: _enum_item => {}
      show list.item: _enum_item => {}


      // Hacky way to track enum level
      let enum-level = state("enum-level", 1)


      // Convert enums to SET_LEVEL paragraphs
      show enum.item: _enum_item => {
        context {
          enum-level.update(l => l + 1)
          SET_LEVEL(enum-level.get())
          let paragraph = _enum_item.body
          _enum_item

          //Empty vertical space to force paragraph segmentation
          v(0em, weak: true)
          _enum_item.body
          SET_LEVEL(0)
          enum-level.update(l => l - 1)
        }
      }

      // Convert lists to SET_LEVEL paragraphs
      // Treat lists the same as enums for paragraph numbering
      show list.item: list_item => {
        context {
          enum-level.update(l => l + 1)
          SET_LEVEL(enum-level.get())
          let paragraph = list_item.body
          list_item

          //Empty vertical space to force paragraph segmentation
          v(0em, weak: true)
          list_item.body
          SET_LEVEL(0)
          enum-level.update(l => l - 1)
        }
      }
      content
    }

    //Count total paragraphs in body
    let total-par-counter = counter("total-par-counter")
    total-par-counter.update(0)

    let total-par-count-content = {
      SET_LEVEL(0)
      show par: it => {
        context {
          total-par-counter.step()
        }
      }
      processed_content
    }

    // Wrap all paragraphs with memo-par
    // Use separate counter to detect last paragraph
    let par-counter = counter("par-counter")
    par-counter.update(1)
    context {
      show par: it => {
        context {
          blank-line()
          par-counter.step()
          let cur_count = par-counter.get().at(0)
          let par_count = total-par-counter.get().at(0)
          let paragraph = memo-par([#it.body])
          //Check if this is the last paragraph
          if cur_count == par_count {
            set text(costs: (orphan: 0%))
            block(breakable: true, sticky: true)[#paragraph]
          } else {
            block(breakable: true)[#paragraph]
          }
        }
      }
      total-par-count-content
      SET_LEVEL(0)
      processed_content
    }
    
  }
}

/// Renders all backmatter sections with proper spacing and page breaks.
/// 
/// Handles the formatting of optional memorandum backmatter sections:
/// - Attachments: Supporting documents attached to the memorandum
/// - CC (Courtesy Copy): Additional recipients who receive copies
/// - Distribution: Broader distribution list for information
/// 
/// Features smart page break handling to prevent orphaned section headers
/// and provides continuation formatting when sections span multiple pages.
/// 
/// - attachments (array): Array of attachment descriptions
/// - cc (array): Array of courtesy copy recipients  
/// - distribution (array): Array of distribution list entries
/// - leading-backmatter-pagebreak (bool): Whether to force page break before backmatter
/// -> content
#let render-backmatter-sections(
  attachments: none,
  cc: none,
  distribution: none,
  leading-backmatter-pagebreak: false,
) = {
  let has-backmatter = (
    (attachments != none and attachments.len() > 0)
      or (cc != none and cc.len() > 0)
      or (distribution != none and distribution.len() > 0)
  )

  if leading-backmatter-pagebreak and has-backmatter {
    pagebreak(weak: true)
  }

  // Attachments section
  if attachments != none and attachments.len() > 0 {
    calculate-backmatter-spacing(true)
    let attachment-count = attachments.len()
    let section-label = if attachment-count == 1 { "Attachment:" } else { str(attachment-count) + " Attachments:" }
    let continuation-label = (
      (if attachment-count == 1 { "Attachment" } else { str(attachment-count) + " Attachments" })
        + " (listed on next page):"
    )
    render-backmatter-section(attachments, section-label, numbering-style: "1.", continuation-label: continuation-label)
  }

  // Courtesy copies section
  if cc != none and cc.len() > 0 {
    calculate-backmatter-spacing(attachments == none or attachments.len() == 0)
    render-backmatter-section(cc, "cc:")
  }

  // Distribution section
  if distribution != none and distribution.len() > 0 {
    calculate-backmatter-spacing((attachments == none or attachments.len() == 0) and (cc == none or cc.len() == 0))
    render-backmatter-section(distribution, "DISTRIBUTION:")
  }
}

// =============================================================================
// INDORSEMENT DATA STRUCTURE
// =============================================================================

/// Creates an indorsement object with proper AFH 33-337 formatting.
/// 
/// Indorsements are used to forward, comment on, or take action on a memorandum
/// as it moves through the chain of command. Each indorsement is numbered sequentially
/// (1st Ind, 2nd Ind, etc.) and includes its own signature block and optional backmatter.
/// 
/// Key features:
/// - Automatic indorsement numbering (1st Ind, 2nd Ind, etc.)
/// - Proper date and subject line formatting referencing the original memorandum
/// - Support for both same-page and separate-page indorsement formats
/// - Individual signature blocks and backmatter sections
/// - Page break control for document flow management
/// 
/// - office-symbol (str): Sending organization symbol for the indorsement
/// - memo-for (str): Recipient organization symbol
/// - signature-block (array): Array of signature lines for the indorsing official
/// - attachments (array): Array of attachment descriptions (optional)
/// - cc (array): Array of courtesy copy recipients (optional)
/// - leading-pagebreak (bool): Whether to force page break before this indorsement
/// - separate-page (bool): Whether to use separate-page indorsement format
/// - indorsement-date (datetime): Date of the indorsement (defaults to today)
/// - body (content): Indorsement body content
/// -> dictionary
#let indorsement(
  office-symbol: "ORG/SYMBOL",
  memo-for: "ORG/SYMBOL",
  signature-block: (
    "FIRST M. LAST, Rank, USAF",
    "Duty Title",
    "Organization (if not on letterhead)",
  ),
  attachments: none,
  cc: none,
  leading-pagebreak: false,
  separate-page: false,
  indorsement-date: datetime.today(),
  body,
) = {
  let ind = (
    office-symbol: office-symbol,
    memo-for: memo-for,
    signature-block: signature-block,
    attachments: attachments,
    cc: cc,
    leading-pagebreak: leading-pagebreak,
    separate-page: separate-page,
    body: body,
  )

  /// Renders the indorsement with proper formatting.
  /// - body-font (str): Font to use for body text.
  /// -> content
  ind.render = (body-font: DEFAULT_BODY_FONTS ) => configure(body-font, {
    counters.indorsement.step()

    context {
      let main-memo = MAIN_MEMO.get()
      assert(type(main-memo) != none,message: "Internal error: MAIN_MEMO state not initialized.")
      let original-date = datetime.today()
      // Get original subject from main-memo
      let original-subject = main-memo.subject
      // Extract original-office from memo-from; if multiple lines, use the first line
      let original-office = if type(main-memo.memo-from) == array {
          main-memo.memo-from.at(0)
        } else {
          main-memo.memo-from
        }

      let indorsement-number = counters.indorsement.get().first()
      let indorsement-label = format-indorsement-number(indorsement-number)

      if ind.leading-pagebreak or separate-page {
        pagebreak()
      }

      if ind.separate-page {
        // Separate-page indorsement format per AFH 33-337
        [#indorsement-label to #original-office, #display-date(original-date), #original-subject]

        blank-line()
        grid(
          columns: (auto, 1fr),
          ind.office-symbol, align(right)[#display-date(indorsement-date)],
        )

        blank-line()
        grid(
          columns: (auto, spacing.two-spaces, 1fr),
          "MEMORANDUM FOR", "", ind.memo-for,
        )
      } else {
        // Standard indorsement format
        // Add spacing only if we didn't just do a pagebreak
        if not ind.leading-pagebreak {
          blank-line()
        }
        [#indorsement-label, #ind.office-symbol]

        blank-line()
        grid(
          columns: (auto, spacing.two-spaces, 1fr),
          "MEMORANDUM FOR", "", ind.memo-for,
        )
      }
      // Render body content
      render-body(ind.body)

      // Signature block positioning per AFH 33-337
      render-signature-block(ind.signature-block)


      // Attachments section
      if not falsey(ind.attachments) {
        calculate-backmatter-spacing(true)
        let attachment-count = ind.attachments.len()
        let section-label = if attachment-count == 1 { "Attachment:" } else { str(attachment-count) + " Attachments:" }

        [#section-label]
        parbreak()
        enum(..ind.attachments, numbering: "1.")
      }

      // Courtesy copies section
      if not falsey((ind.cc)) {
        calculate-backmatter-spacing(falsey(ind.attachments))
        [cc:]
        parbreak()
        ind.cc.join("\n")
      }
    }
  })

  return ind
}


// =============================================================================
// MAIN MEMORANDUM TEMPLATE
// =============================================================================

/// Creates an official memorandum following AFH 33-337 "The Tongue and Quill" standards.
/// 
/// This is the main template function that generates a complete, properly formatted
/// United States Air Force memorandum. It handles all aspects of document structure,
/// typography, spacing, and formatting to ensure full compliance with military
/// correspondence standards.
/// 
/// Key features:
/// - Automatic letterhead with configurable organization title, caption, and seal
/// - Proper header sections (date, memo for, from, subject, references)
/// - AFH 33-337 compliant paragraph numbering and indentation
/// - Professional signature block positioning with orphan prevention
/// - Optional backmatter sections (attachments, cc, distribution)
/// - Support for indorsements with proper sequential numbering
/// - Configurable fonts and styling options
/// - Smart page break handling and continuation formatting
/// 
/// Required parameters:
/// - subject: Memorandum subject line (must be descriptive and in title case)
/// - body: Main memorandum content (use enums for numbered paragraphs)
/// 
/// - letterhead-title (str): Primary organization title (e.g., "DEPARTMENT OF THE AIR FORCE")
/// - letterhead-caption (str): Sub-organization or command (e.g., "123RD EXAMPLE SQUADRON")
/// - letterhead-seal (content): Organization seal image content (optional)
/// - date (datetime): Date of the memorandum; defaults to today if not provided
/// - memo-for (str | array): Recipient(s) - string or array of organization symbols
/// - memo-from (str | array): Sender information (organization, address, contact info)
/// - subject (str): Memorandum subject line in title case (REQUIRED)
/// - references (array): Optional array of reference documents (AFI, regulation citations)
/// - signature-block (array): Array of signature lines (name/rank, title, organization)
/// - attachments (array): Array of attachment descriptions (optional)
/// - cc (array): Array of courtesy copy recipients (optional)
/// - distribution (array): Array of distribution list entries (optional)
/// - indorsements (array): Array of indorsement objects for document routing (optional)
/// - letterhead-font (str | array): Font(s) for letterhead text (defaults to Copperplate CC)
/// - body-font (str | array): Font(s) for body text (defaults to Times New Roman/TeX Gyre Termes)
/// - memo-for-cols (int): Number of columns for recipient grid layout (default: 3)
/// - paragraph-block-indent (bool): Enable paragraph block indentation (default: false)
/// - leading-backmatter-pagebreak (bool): Force page break before backmatter sections (default: false)
/// - body (content): Main memorandum content with paragraph structure using enums
/// -> content
#let official-memorandum(
  letterhead-title: "DEPARTMENT OF THE AIR FORCE",
  letterhead-caption: "[YOUR SQUADRON/UNIT NAME]",
  letterhead-seal: none,
  date: none,
  memo-for: (
    "[FIRST/OFFICE]", "[SECOND/OFFICE]", "[THIRD/OFFICE]", "[FOURTH/OFFICE]", "[FIFTH/OFFICE]", "[SIXTH/OFFICE]"
  ),
  memo-from: (
    "[YOUR/SYMBOL]",
    "[Your Organization Name]",
    "[Street Address]",
    "[City ST 12345-6789]",
  ),
  subject: "[Your Subject in Title Case - Required Field]",
  references: none,
  signature-block: (
    "[FIRST M. LAST, Rank, USAF]",
    "[Your Official Duty Title]",
    "[Organization (optional)]",
  ),
  attachments: none,
  cc: none,
  distribution: none,
  indorsements: none,
  // Optional styling parameters
  letterhead-font: DEFAULT_LETTERHEAD_FONTS,
  body-font: DEFAULT_BODY_FONTS,
  memo-for-cols: 3,
  paragraph-block-indent: false,
  leading-backmatter-pagebreak: false,
  body,
) = configure(body-font, {
  // Initialize document counters and settings

  let self = (
    letterhead-title: letterhead-title,
    letterhead-caption: letterhead-caption,
    letterhead-seal: letterhead-seal,
    date: if date == none { datetime.today() } else { date },
    memo-for: memo-for,
    memo-from: memo-from,
    subject: subject,
    references: references,
    signature-block: signature-block,
    attachments: attachments,
    cc: cc,
    distribution: distribution,
    indorsements: indorsements,
    letterhead-font: letterhead-font,
    body-font: body-font,
    memo-for-cols: memo-for-cols,
    paragraph-block-indent: paragraph-block-indent,
    leading-backmatter-pagebreak: leading-backmatter-pagebreak,
    body: body,
  )
  MAIN_MEMO.update(self)

  counters.indorsement.update(0)
  set page(
    paper: "us-letter",
    margin: (left: spacing.margin, right: spacing.margin, top: spacing.margin, bottom: spacing.margin),
    header: context {
      // Page numbering starting from page 2
      // Position 0.5 inches from top, flush with right margin
      if counter(page).get().first() > 1 {
        place(
          dy: +.5in,
          block(
            width: 100%,
            align(right,
              text(12pt)[#counter(page).display()]
            )
          )
        )
        
      }
    }
  )
  paragraph-config.block-indent-state.update(self.paragraph-block-indent)

  // Document letterhead
  render-letterhead(self.letterhead-title, self.letterhead-caption, self.letterhead-seal, self.letterhead-font)

  // Document header sections
  v(1.75in - spacing.margin) // 1.75in from top of the page
  context {
    render-date-section(self.date)
  }
  render-for-section(self.memo-for, self.memo-for-cols)
  render-from-section(self.memo-from)
  render-subject-section(self.subject)
  render-references-section(self.references)

  // Main document body
  // Render body content
  render-body(self.body)

  // Signature block positioning per AFH 33-337
  render-signature-block(self.signature-block)

  // Backmatter sections with proper spacing and page breaks
  render-backmatter-sections(
    attachments: self.attachments,
    cc: self.cc,
    distribution: self.distribution,
    leading-backmatter-pagebreak: self.leading-backmatter-pagebreak,
  )

  // Indorsements
  process-indorsements(self.indorsements, body-font: self.body-font)
})

