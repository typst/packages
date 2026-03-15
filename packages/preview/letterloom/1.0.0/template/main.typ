/// letterloom Template
/// For more information, see the letterloom documentation and manual.
#import "@preview/letterloom:1.0.0": *

#show: letterloom.with(
  // Sender's contact information (name and address)
  from-name: "Sender's Name",
  from-address: [Sender's Address],
  // from-alignment: right,

  // Recipient's contact information (name and address)
  to-name: "Receiver's Name",
  to-address: [Receiver's Address],

  // attn-name: "Attn: Receiver's Name",
  // attn-address: "Attn:",
  // attn-position: "above",

  // Letter date (automatically set to today's date)
  date: datetime.today().display("[day padding:zero] [month repr:long] [year repr:full]"),

  // Opening greeting
  salutation: "Dear Receiver's Name,",

  // Letter subject line
  subject: "Subject",

  // Closing phrase
  closing: "Yours sincerely,",

  // List of signatures with their name, optional signature image, title and affiliation
  signatures: (
    (
      name: "Sender's Name",
      // title: "Title",
      // affiliation: "Affiliation",
      // signature: image("sender-sig.png")
    ),
  ),

  // signature-alignment: left,

  // cc: none,
  // cc-label: "cc:",
  // enclosures: none,
  // enclosures-label: "encl:",
  // footer: none,

  // paper-size: "a4",
  // margins: auto,
  // par-leading: 0.8em,
  // par-spacing: 1.8em,
  // number-pages: false,

  // main-font: "Libertinus Serif",
  // main-font-size: 11pt,
  // footer-font: "DejaVu Sans Mono",
  // footer-font-size: 9pt,
  // footnote-font: "Libertinus Serif",
  // footnote-font-size: 7pt,

  // footnote-alignment: left,
  // link-color: blue,
)

// Write the body of your letter here
