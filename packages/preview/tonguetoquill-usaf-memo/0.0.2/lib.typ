// lib.typ: A Typst template backend for AFH 33-337 compliant official memorandums.

#import "utils.typ": *

// =============================================================================
// COMPILER VERSION COMPLIANCE CHECK
// =============================================================================

// Enforce minimum Typst compiler version for proper functionality
#let min-version = (0, 13, 0)
#let current-version = sys.version

#assert(
  current-version.at(0) > min-version.at(0)
    or (current-version.at(0) == min-version.at(0) and current-version.at(1) >= min-version.at(1)),
  message: "This template requires Typst compiler version 0.13.0 or higher. "
    + "Current version: "
    + str(current-version.at(0))
    + "."
    + str(current-version.at(1))
    + ". "
    + "Please update your Typst installation.",
)

// =============================================================================
// PARAMETER VALIDATION
// =============================================================================

/// Validates memorandum parameters for AFH 33-337 compliance.
/// - params (dictionary): Dictionary of memorandum parameters.
/// -> none
#let validate-memo-compliance(params) = {
  // Validate required parameters exist
  let required-params = ("letterhead-title", "memo-for", "from-block", "subject", "signature-block")
  for param in required-params {
    assert(
      param in params and params.at(param) != none,
      message: "Required parameter '"
        + param
        + "' is missing or empty. "
        + "AFH 33-337 compliance requires all mandatory elements.",
    )
  }

  // Validate font compliance
  if "body-font" in params {
    assert(
      params.at("body-font") == "Times New Roman",
      message: "AFH 33-337 requires Times New Roman font for body text. "
        + "Current font: "
        + str(params.at("body-font")),
    )
  }

  // Validate signature block format
  let sig-block = params.at("signature-block")
  assert(
    type(sig-block) == array and sig-block.len() >= 2,
    message: "Signature block must contain at least name and title lines per AFH 33-337",
  )
}

// =============================================================================
// INTERNAL RENDERING FUNCTIONS
// =============================================================================

/// Renders the document letterhead section.
/// - title (str): Primary organization title.
/// - caption (str): Sub-organization or command.
/// - seal-path (str): Seal image to place in the letterhead.
/// - font (str): Font for letterhead text.
/// -> content
#let render-letterhead(title, caption, letterhead-seal, font) = {
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
            // Use Arial as the backup font
            #text(12pt, font: (font, "Arial"), fill: rgb("#000099"))[#title]\
            #text(10.5pt, font: (font, "Arial"), fill: rgb("#000099"))[#caption]
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

/// Renders the date section (right-aligned).
/// -> content
#let render-date-section() = {
  align(right)[#datetime.today().display("[day] [month repr:long] [year]")]
}

/// Renders the MEMORANDUM FOR section.
/// - recipients (str | array): Recipient organization(s).
/// -> content
#let render-memo-for-section(recipients) = {
  blank-line()
  grid(
    columns: (auto, spacing.two-spaces, 1fr),
    "MEMORANDUM FOR",
    "",
    align(left)[
      #if type(recipients) == array {
        create-auto-grid(recipients, column-gutter: spacing.tab)
      } else {
        recipients
      }
    ],
  )
}

/// Renders the FROM section.
/// - from-info (array): Sender information array.
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

/// Renders the SUBJECT section.
/// - subject-text (str): Memorandum subject line.
/// -> content
#let render-subject-section(subject-text) = {
  blank-line()
  grid(
    columns: (auto, spacing.two-spaces, 1fr),
    "SUBJECT:", "", [#subject-text],
  )
}

/// Renders the optional references section.
/// - references (array): Array of reference documents.
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
/// Per AFH 33-337: "The signature block is never on a page by itself."
/// - signature-lines (array): Array of signature lines.
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

/// Processes document body content with automatic paragraph numbering.
/// - content (content): Document body content.
/// -> content
#let render-body(content) = {
  counter("par-counter-0").update(1)
  let s = state("par-count", 0)

  context {
    // Embed enum processing to calculate paragraph levels
    let processed_content = context {
      //erase enums
      show enum.item: _enum_item => {}

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
// =============================================================================
// INDORSEMENT DATA STRUCTURE
// =============================================================================

/// Creates an indorsement object with proper AFH 33-337 formatting.
/// - office-symbol (str): Sending organization symbol.
/// - memo-for (str): Recipient organization symbol.
/// - signature-block (array): Array of signature lines.
/// - attachments (array): Array of attachment descriptions.
/// - cc (array): Array of courtesy copy recipients.
/// - leading-pagebreak (bool): Whether to force page break before indorsement.
/// - separate-page (bool): Whether to use separate-page indorsement format.
/// - original-office (none | str): Original memo's office symbol (for separate-page format).
/// - original-date (none | str): Original memo's date (for separate-page format).
/// - original-subject (none | str): Original memo's subject (for separate-page format).
/// - body (content): Indorsement body content.
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
  original-office: none,
  original-date: none,
  original-subject: none,
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
    original-office: original-office,
    original-date: original-date,
    original-subject: original-subject,
    body: body,
  )

  /// Renders the indorsement with proper formatting.
  /// - body-font (str): Font to use for body text.
  /// -> content
  ind.render = (body-font: "Times New Roman") => configure(body-font, {
    let current-date = datetime.today().display("[day] [month repr:short] [year]")
    counters.indorsement.step()

    context {
      let indorsement-number = counters.indorsement.get().first()
      let indorsement-label = format-indorsement-number(indorsement-number)

      if ind.leading-pagebreak or separate-page {
        pagebreak()
      }

      if ind.separate-page and ind.original-office != none {
        // Separate-page indorsement format per AFH 33-337
        [#indorsement-label to #ind.original-office, #current-date, #ind.original-subject]

        blank-line()
        grid(
          columns: (auto, 1fr),
          ind.office-symbol, align(right)[#current-date],
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

/// Renders all backmatter sections with proper spacing and page breaks.
/// - attachments (array): Array of attachment descriptions.
/// - cc (array): Array of courtesy copy recipients.
/// - distribution (array): Array of distribution list entries.
/// - leading-backmatter-pagebreak (bool): Whether to force page break before backmatter.
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
// MAIN MEMORANDUM TEMPLATE
// =============================================================================

/// Creates an official memorandum following AFH 33-337 standards.
/// - letterhead-title (str): Primary organization title.
/// - letterhead-caption (str): Sub-organization or command.
/// - letterhead-seal (str): Image content for organization seal.
/// - memo-for (str | array): Recipient(s) - string, array, or nested array for grid layout.
/// - from-block (array): Sender information as array of strings.
/// - subject (str): Memorandum subject line.
/// - references (array): Optional array of reference documents.
/// - signature-block (array): Array of signature lines.
/// - attachments (array): Array of attachment descriptions.
/// - cc (array): Array of courtesy copy recipients.
/// - distribution (array): Array of distribution list entries.
/// - indorsements (array): Array of Indorsement objects.
/// - letterhead-font (str): Font for letterhead text.
/// - body-font (str): Font for body text.
/// - paragraph-block-indent (bool): Enable paragraph block indentation.
/// - leading-backmatter-pagebreak (bool): Force page break before backmatter sections.
/// - body (content): Main memorandum content.
/// -> content
#let official-memorandum(
  letterhead-title: "DEPARTMENT OF THE AIR FORCE",
  letterhead-caption: "[YOUR SQUADRON/UNIT NAME]",
  letterhead-seal: none,
  memo-for: (
    ("[FIRST/OFFICE]", "[SECOND/OFFICE]", "[THIRD/OFFICE]"),
    ("[FOURTH/OFFICE]", "[FIFTH/OFFICE]", "[SIXTH/OFFICE]"),
  ),
  from-block: (
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
  letterhead-font: "Arial",
  body-font: "Times New Roman",
  paragraph-block-indent: false,
  leading-backmatter-pagebreak: false,
  body,
) = configure(body-font, {
  // Validate AFH 33-337 compliance before proceeding
  let params = (
    letterhead-title: letterhead-title,
    memo-for: memo-for,
    from-block: from-block,
    subject: subject,
    signature-block: signature-block,
    body-font: body-font,
  )
  validate-memo-compliance(params)

  // Initialize document counters and settings
  counters.indorsement.update(0)
  set page(
    paper: "us-letter",
    margin: (left: spacing.margin, right: spacing.margin, top: spacing.margin, bottom: spacing.margin),
  )
  set text(font: body-font, size: 12pt)
  set text()
  paragraph-config.block-indent-state.update(paragraph-block-indent)

  // Page numbering starting from page 2
  context {
    if counter(page).get().first() > 1 {
      place(
        top + right,
        dx: 0in,
        dy: -0.5in,
        text(12pt)[#counter(page).display()],
      )
    }
  }

  // Document letterhead
  render-letterhead(letterhead-title, letterhead-caption, letterhead-seal, letterhead-font)

  // Document header sections
  v(1.75in - spacing.margin) // 1.75in from top of the page
  render-date-section()
  render-memo-for-section(memo-for)
  render-from-section(from-block)
  render-subject-section(subject)
  render-references-section(references)

  // Main document body
  // Render body content
  render-body(body)

  // Signature block positioning per AFH 33-337
  render-signature-block(signature-block)

  // Backmatter sections with proper spacing and page breaks
  render-backmatter-sections(
    attachments: attachments,
    cc: cc,
    distribution: distribution,
    leading-backmatter-pagebreak: leading-backmatter-pagebreak,
  )

  // Indorsements
  process-indorsements(indorsements, body-font: body-font)
})
