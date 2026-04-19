#import "@preview/tonguetoquill-usaf-memo:3.0.0": backmatter, frontmatter, indorsement, mainmatter

#show: frontmatter.with(
  letterhead_title: "DEPARTMENT OF THE AIR FORCE",
  letterhead_caption: "123RD EXAMPLE SQUADRON",
  letterhead_seal: image("assets/dow_seal.png"),
  subject: "Format for the Official Memorandum",
  memo_for: (
    "123 ES/CC",
    "123 ES/DO",
    "123 ES/CSS",
    "456 ES/CC",
    "456 ES/DO",
    "456 ES/CSS",
  ),
  memo_from: (
    "ORG/SYMBOL",
    "Organization",
    "Street Address",
    "City ST 12345-6789",
  ),
  references: (
    "AFM 33-326, 31 July 2019, Preparing Official Communications",
    "DoDM 5110.04-M-V2, 16 June 2020, Manual for Written Material: Examples and Reference Material",
  ),
)

#mainmatter[
  Use approved organizational letterhead for all correspondence. This applies to all letterhead, both pre-printed and computer generated. Reference (a) describes placement of the official header lines; this template centers the first line 5/8 inch from the top in 12 point bold Times New Roman (or *NimbusRomNo9L*), with the second line 3 points below in 10.5 point.

  - #strong[If you are on the Typst app, upload the #text(color.blue)[#link("https://github.com/nibsbin/tonguetoquill-usaf-memo/tree/main/fonts/NimbusRomanNo9L")[NimbusRomNo9L]] font files (or install Times New Roman) so letterhead and body text render correctly]

  Note that this template provides proper formatting for various elements via Typst functions. The recipient line uses proper grid formatting, the body uses automatic paragraph numbering, the signature block uses precise positioning, and so on. The template handles all AFH 33-337 formatting requirements automatically.

  Place "MEMORANDUM FOR" on the second line below the date. Leave two spaces between "MEMORANDUM FOR" and the recipient's office symbol. If there are multiple recipients, two or three office symbols may be placed on each line aligned under the entries on the first line. If there are numerous recipients, type "DISTRIBUTION" after "MEMORANDUM FOR" and use a "DISTRIBUTION" element below the signature block.

  Place "FROM:" on the second line below the "MEMORANDUM FOR" line. Leave two spaces between the colon in "FROM:" and the originator's office symbol. The "FROM:" element contains the full mailing address of the originator's office unless the mailing address is in the header or if all the recipients are located in the same installation as the originator.

  Place "SUBJECT:" in uppercase letters on the second line below the last line of the FROM element. Leave two spaces between the colon in "SUBJECT:" and the subject. Capitalize the first letter of each word except articles, prepositions, and conjunctions (this is sometimes referred to as "title case"). Be clear and concise. If the subject is long, try to revise and shorten the subject; if shortening is not feasible, align the second line under the first word of the subject.

  Body text begins on the second line below the last line in the subject element and is flush with the left margin. If the Reference element is used, then the body text begins on the second line below the last line on the Reference element.

  + When a paragraph is split between pages, there must be at least two lines from the paragraph on both pages. This template automatically handles this formatting, but in the case of widowed sentences you can use manual page breaks. Similarly, avoid single-sentence paragraphs by revising or reorganizing the content.

  + Number or letter each body text paragraph and subparagraph according to the format for subdividing paragraphs in official memorandums presented in the Tongue and Quill. This subdivision format is provided automatically in this template. When a memorandum is subdivided, the number of levels used should be relative to the length of the memorandum. Shorter products typically use three or fewer levels. Longer products may use more levels, but only the number of levels needed.


  Follow the spacing guidance between the text, signature block, attachment element, courtesy copy element, and distribution lists carefully. The signature block starts on the fifth line below the body text – this spacing is handled automatically by the template. Never separate the text from the signature block: the signature page must include body text above the signature block. Also, the first element below the signature block begins on the third line below the last line of the duty title; this applies to attachments, courtesy copies, and distribution lists, whichever is used first.

  Elements of the Official Memorandum can be inserted as templated parts in MS Word. Select the "Insert" menu, "Quick Parts", and then select the desired element. Follow the formatting instructions provided with the element template.

  + To add classification banner markings (including FOUO markings), click on the header or footer, and in the "Header & Footer Tools" tab, select the Header / Footer dropdown menus on the left side. Use the pre-generated headers and footers – note that the first page is different from the second page onward, and so the second page header and footer must be applied separately.

  When a paragraph is split between pages, there must be at least two lines from the paragraph on both pages. This template automatically handles this formatting, but in the case of widowed sentences you can use manual page breaks. Similarly, avoid single-sentence paragraphs by revising or reorganizing the content.

  Number or letter each body text paragraph and subparagraph according to the format for subdividing paragraphs in official memorandums presented in the Tongue and Quill. This subdivision format is provided automatically in this template. When a memorandum is subdivided, the number of levels used should be relative to the length of the memorandum. Shorter products typically use three or fewer levels. Longer products may use more levels, but only the number of levels needed.

  Follow the spacing guidance between the text, signature block, attachment element, courtesy copy element, and distribution lists carefully. The signature block starts on the fifth line below the body text – this spacing is handled automatically by the template. Never separate the text from the signature block: the signature page must include body text above the signature block. Also, the first element below the signature block begins on the third line below the last line of the duty title; this applies to attachments, courtesy copies, and distribution lists, whichever is used first.

  Elements of the Official Memorandum can be inserted as templated parts in MS Word. Select the "Insert" menu, "Quick Parts", and then select the desired element. Follow the formatting instructions provided with the element template.

  To add classification banner markings (including FOUO markings), click on the header or footer, and in the "Header & Footer Tools" tab, select the Header / Footer dropdown menus on the left side. Use the pre-generated headers and footers – note that the first page is different from the second page onward, and so the second page header and footer must be applied separately.

  The example of this memorandum applies to many official memorandums that Airmen may be tasked to prepare; however, there are additional elements for special uses of the official memorandum. Refer to the Tongue and Quill discussion on the official memorandum for more details, or consult published guidance applicable to your duties.

  Tables may be embedded directly in the body of the memorandum as shown below. They are rendered with simple black cell borders and inherit the standard 12-point Times New Roman body font, consistent with the plain, formal style of official USAF correspondence.

  #table(
    columns: (1fr, 1fr, 1fr),
    table.header([Element], [Placement], [Reference]),
    [Date], [1.75 in from top, 1 in from right], [AFH 33-337 §Date],
    [MEMORANDUM FOR], [2nd line below date], [AFH 33-337 §For],
    [FROM], [2nd line below MEMORANDUM FOR], [AFH 33-337 §From],
    [SUBJECT], [2nd line below FROM], [AFH 33-337 §Subject],
    [Body Text], [2nd line below SUBJECT], [AFH 33-337 §1],
    [Signature Block], [5th line below body text, 4.5 in from left], [AFH 33-337 §Sig],
  )
]

#backmatter(
  signature_block: (
    "FIRST M. LAST, Rank, USAF",
    "Duty Title",
  ),
  attachments: (
    "Attachment description, date",
    "Additional attachment description, date",
  ),
  cc: (
    "Rank and name, ORG/SYMBOL, or both"
  ),
  distribution: (
    "ORG/SYMBOL or Organization Name"
  ),
)

#indorsement(
  from: "ORG/SYMBOL [Office symbol for 1st Indorsement Official]",
  to: "ORG/SYMBOL [Office symbol for 2d Indorsement official]",
  action: "approve",
  signature_block: (
    "FIRST M LAST, Rank, USAF",
    "Duty Title",
  ),
)[
  Approved with the following condition: funding must be identified from within existing squadron budget NLT 1 Oct.
]

#indorsement(
  from: "[Indorser ORG/SYMBOL]",
  to: "ORG/SYMBOL [Originator]",
  signature_block: (
    "FIRST M LAST, Rank, USAF",
    "Duty Title",
  ),
  format: "separate_page",
  date: datetime(year: 2001, month: 1, day: 1),
)[
  Use a new page indorsement when there isn't space remaining on the original memorandum or previous indorsement page. The new-page indorsement is basically the same as the one for the same page, except the top line always cites the indorsement number with the originator's office, date, and subject of the original communication; the second line reflects the functional address symbol of the indorsing office with the date.
]
