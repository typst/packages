#import "@preview/fontawesome:0.6.0": *

/// A cover letter template matching the nabcv design.
///
/// - sender (dictionary): Keys: name (required), phone (opt),
///   email (opt), linkedin (opt), github (opt), address (opt).
/// - recipient (content, none): Free-form address block.
/// - date (content, str, none): Display content, or "auto" for today's date.
/// - subject (content, none): Subject line shown as "Re: …".
/// - salutation (content, none): Opening salutation line.
/// - closing (content): Closing phrase before the signature.
/// - footer-items (array): Sender fields to show in the footer.
///   Supported values: "name", "phone", "email", "linkedin", "github", "address".
/// - contact-icons (dictionary): Override icon names for contact fields.
///   Keys: "phone", "email", "linkedin", "github", "address".
/// - contact-url-bases (dictionary): Override URL prefixes for contact fields.
///   Keys: "email", "linkedin", "github". Values are prepended to the field value.
/// - theme (dictionary): Override any theme colour. Keys: primary, header,
///   footer, links, header-bg.
/// - text-size (dictionary): Override any font size. Keys: body, name, header, footer.
/// - font-family (dictionary): Override any font family. Keys: body.
/// - font-weight (dictionary): Override any font weight. Keys: body, name, header,
///   footer, recipient-name, subject, signature.
/// - body (content): The letter paragraphs.
#let letter(
  sender: (:),
  recipient: none,
  date: "auto",
  subject: none,
  salutation: none,
  closing: [Kind regards],
  footer-items: ("phone", "email", "linkedin"),
  contact-icons: (:),
  contact-url-bases: (:),
  theme: (:),
  text-size: (:),
  font-family: (:),
  font-weight: (:),
  body,
) = {
  // --- Default theme ---
  let t = (
    (
      primary: rgb("#000000"),
      header: rgb("#6B6B6B"),
      footer: rgb("#6B6B6B"),
      links: rgb("#1565C0"),
      header-bg: rgb("#F5F1ED"),
    )
      + theme
  )

  // --- Sizes / weights / gaps ---
  let ts = (
    (
      body: 11pt,
      name: 28pt,
      header: 9.5pt,
      footer: 8pt,
    )
      + text-size
  )

  let ff = (
    (
      body: "IBM Plex Sans",
    )
      + font-family
  )

  let fw = (
    (
      body: "light",
      name: "bold",
      header: "light",
      footer: "light",
      recipient-name: "medium",
      subject: "bold",
      signature: "medium",
    )
      + font-weight
  )

  let gap = (
    name-to-headline: -16pt,
    headline-to-contact: 4pt,
    header-bottom-pad: 12pt,
    header-to-body: 36pt,
    recipient-to-subject: 10pt,
    subject-to-salutation: 10pt,
    salutation-to-body: 10pt,
    between-paragraphs: 8pt,
    closing-to-signature: 15pt,
    signature-space: 25pt,
    header-separator: 12pt,
    footer-separator: 12pt,
    header-icon-to-text: 4pt,
    footer-icon-to-text: 2pt,
  )

  let layout = (
    margin-left: 0.7in,
    margin-right: 0.7in,
    margin-top: 0.8in,
    margin-bottom: 0.8in,
    header-bg-height: 1in,
  )

  // --- Contact icon / URL defaults ---
  let ci = (
    (
      phone: "phone",
      email: "envelope",
      linkedin: "linkedin",
      github: "github",
      address: "location-dot",
    )
      + contact-icons
  )

  let cu = (
    (
      email: "mailto:",
      linkedin: "https://linkedin.com/in/",
      github: "https://github.com/",
    )
      + contact-url-bases
  )

  // --- Helpers ---
  let contact-line(s) = {
    let items = ("phone", "email", "linkedin", "github", "address")
    let parts = items
      .filter(key => s.at(key, default: none) != none)
      .map(key => {
        let val = s.at(key)
        let icon = ci.at(key, default: none)
        let base = cu.at(key, default: none)
        let disp = if base != none { link(base + val)[#val] } else { val }
        if icon != none {
          fa-icon(icon) + h(gap.header-icon-to-text) + disp
        } else { disp }
      })
    text(
      size: ts.header,
      weight: fw.header,
      fill: t.header,
      parts.join(h(gap.header-separator)),
    )
  }

  // --- Header ---
  let build-header() = {
    let s = sender
    text(size: ts.name, weight: fw.name, fill: t.primary)[#s.name]
    v(gap.name-to-headline)
    v(gap.headline-to-contact)
    contact-line(s)
    v(gap.header-bottom-pad)
  }

  // --- Body ---
  let build-body() = {
    // Date + Recipient block
    grid(
      columns: (1fr, auto),
      align: (left, right + top),
      recipient,
      if date == none {
        none
      } else if date == "auto" {
        datetime.today().display("[month repr:long] [day], [year]")
      } else {
        date
      },
    )
    v(gap.recipient-to-subject)

    // Subject
    if subject != none {
      text(weight: fw.subject)[Re: #subject]
      v(gap.subject-to-salutation)
    }

    // Salutation
    if salutation != none [
      #salutation, #v(gap.salutation-to-body)
    ]

    // Body paragraphs
    body
    v(gap.closing-to-signature)

    // Closing + signature
    [#closing,]
    v(gap.signature-space)
    text(weight: fw.signature)[#sender.name]
  }

  // --- Footer ---
  let build-footer() = context {
    let s = sender
    let parts = footer-items
      .filter(k => k == "name" or s.at(k, default: none) != none)
      .map(k => {
        if k == "name" { return s.name }
        let val = s.at(k)
        let icon = ci.at(k, default: none)
        if icon != none {
          [#fa-icon(icon) #h(gap.footer-icon-to-text) #val]
        } else { val }
      })
    align(center, text(
      size: ts.footer,
      weight: fw.footer,
      fill: t.footer,
      parts.join[#h(gap.footer-separator)],
    ))
  }

  // --- Page setup ---
  set page(
    paper: "us-letter",
    margin: (
      left: layout.margin-left,
      right: layout.margin-right,
      top: layout.margin-top,
      bottom: layout.margin-bottom,
    ),
    footer: build-footer(),
    background: place(top + left, rect(
      width: 100%,
      height: layout.header-bg-height + layout.margin-top,
      fill: t.header-bg,
    )),
  )
  set text(font: ff.body, size: ts.body, weight: fw.body)
  set par(justify: true, leading: 0.65em)

  // --- Assembly ---
  build-header()
  v(gap.header-to-body)
  build-body()
}
