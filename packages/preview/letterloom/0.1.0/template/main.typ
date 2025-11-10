/// letterloom Template
///
/// This template demonstrates how to use the letterloom package to create
/// professional letters with customizable formatting options.
///
/// Usage:
/// 1. Replace the placeholder values in the required fields (from, to, date, etc.)
/// 2. Uncomment and modify any optional configuration parameters as needed
/// 3. Add your letter content after the closing parenthesis
/// 4. Compile with: `typst compile main.typ`
///
/// Required Parameters:
/// - from: Sender's contact information (name and address)
/// - to: Recipient's contact information (name and address)
/// - date: Letter date (automatically set to today's date)
/// - salutation: Opening greeting (e.g., "Dear Mr. Smith,")
/// - subject: Letter subject line
/// - closing: Closing phrase (e.g., "Yours sincerely,")
/// - signatures: List of signatories with their names
///
/// Optional Parameters (commented out with default values):
/// - attn-line: Attention line for specific recipient within organization
/// - cc: List of carbon copy recipients
/// - enclosures: List of attached documents
/// - footer: Custom footer information
///
/// Document Settings:
/// - paper-size: Document paper size (default: "a4")
/// - margins: Page margins (default: auto)
/// - par-leading: Paragraph line spacing (default: 0.8em)
/// - par-spacing: Paragraph spacing (default: 1.8em)
/// - number-pages: Enable page numbering (default: false)
///
/// Typography Settings:
/// - main-font: Primary font family (default: "Libertinus Serif")
/// - main-font-size: Primary font size (default: 11pt)
/// - footer-font: Footer font family (default: "DejaVu Sans Mono")
/// - footer-font-size: Footer font size (default: 9pt)
/// - footnote-font: Footnote font family (default: "Libertinus Serif")
/// - footnote-font-size: Footnote font size (default: 7pt)
///
/// Layout Settings:
/// - from-alignment: Sender address alignment (default: right)
/// - footnote-alignment: Footnote alignment (default: left)
/// - link-color: Color for hyperlinks (default: blue)
///
/// For more information, see the letterloom documentation and manual.
#import "@preview/letterloom:0.1.0": *

#show: letterloom.with(
  from: (
    name: "Sender's Name",
    address: [Sender's Address]
  ),
  to: (
    name: "Receiver's Name",
    address: [Receiver's Address]
  ),
  date: datetime.today().display("[day padding:zero] [month repr:long] [year repr:full]"),
  salutation: "Dear Receiver's Name,",
  subject: "Subject",
  closing: "Yours sincerely,",
  signatures: (
    (
      name: "Sender's Name",
      // signature: image() // Add your signature image here
    )
  ),

  // Uncomment the following options below to customize the letter

  // Optional fields:
  //
  // attn-line: none,
  // cc: none,
  // enclosures: none,
  // footer: none,


  // Document settings:
  //
  // paper-size: "a4",
  // margins: auto,
  // par-leading: 0.8em,
  // par-spacing: 1.8em,
  // number-pages: false,

  // Typography settings:
  //
  // main-font: "Libertinus Serif",
  // main-font-size: 11pt,
  // footer-font: "DejaVu Sans Mono",
  // footer-font-size: 9pt,
  // footnote-font: "Libertinus Serif",
  // footnote-font-size: 7pt,

  // Layout settings:
  // 
  // from-alignment: right,
  // footnote-alignment: left,
  // link-color: blue,
)

// Write the body of your letter here
