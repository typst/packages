#import "@preview/tonguetoquill-usaf-memo:0.1.0": official-memorandum, indorsement

#official-memorandum(
  letterhead-title: "DEPARTMENT OF THE AIR FORCE",
  letterhead-caption: "123RD EXAMPLE SQUADRON",
  letterhead-seal: image("assets/dod_seal.gif"),
  memo-for: (
    "123 ES/CC", "123 ES/DO", "123 ES/CSS", "456 ES/CC", "456 ES/DO", "456 ES/CSS"
  ),
  memo-from: (
    "ORG/SYMBOL",
    "Organization",
    "Street Address",
    "City ST 12345-6789"
  ),
  subject: "Format for the Official Memorandum",
  references: (
    "AFM 33-326, 31 July 2019, Preparing Official Communications",
    "DoDM 5110.04-M-V2, 16 June 2020, Manual for Written Material: Examples and Reference Material"
  ),
  signature-block: (
    "FIRST M. LAST, Rank, USAF",
    "Duty Title"
  ),
  attachments: (
    "Attachment description, date",
    "Additional attachment description, date"
  ),
  cc: (
    "Rank and name, ORG/SYMBOL, or both"
  ),
  distribution: (
    "ORG/SYMBOL or Organization Name"
  ),
  indorsements: (
    indorsement(
      office-symbol: "ORG/SYMBOL [Office symbol for 1st Indorsement Official]",
      memo-for: "ORG/SYMBOL [Office symbol for 2d Indorsement official]",
      signature-block: (
        "FIRST M LAST, Rank, USAF",
        "Duty Title"
      ),
    )[
        Number each indorsement in sequence (1st Ind, 2d Ind, 3d Ind, …).~ Begin the first indorsement on the second line below the last element of the official memorandum.~ Begin subsequent indorsements on the second line below the last element of the previous indorsement.~ Follow the indorsement number with your office symbol.
        
        When inserting a new indorsement element (either on the same page or as a separate page), the numbering will need to be reset.~ This is accomplished by right-clicking the number on the list, then selecting “Restart at 1”.
        
        Use a separate page indorsement when there isn’t space remaining on the original memorandum or previous indorsement page.~ The separate-page indorsement is basically the same as the one for the same page, except the top line always cites the indorsement number with the originator’s office, date, and subject of the original communication; the second line reflects the functional address symbol of the indorsing office with the date.
        ],
    indorsement(
      office-symbol: "[Indorser ORG/SYMBOL]",
      memo-for: "ORG/SYMBOL [Originator]",
      signature-block: (
        "FIRST M LAST, Rank, USAF",
        "Duty Title"
      ),
      separate-page: true,
    )[
        Use a separate page indorsement when there isn’t space remaining on the original memorandum or previous indorsement page.~ The separate-page indorsement is basically the same as the one for the same page, except the top line always cites the indorsement number with the originator’s office, date, and subject of the original communication; the second line reflects the functional address symbol of the indorsing office with the date.
      ],
  ),
  //leading-backmatter-pagebreak: true, // Forces a break before backmatter sections (attachments, cc, distribution)
)[

Use only approved organizational letterhead for all correspondence.~ This applies to all letterhead, both pre-printed and computer generated.~ Reference (a) details the format and style of official letterhead such as centering the first line of the header 5/8ths of an inch from the top of the page in 12 point Copperplate Gothic Bold font.~ The second header line is centered 3 points below the first line in 10.5 point Copperplate Gothic Bold font.

  - *If you are on the Typst app, upload #text(color.blue)[#link("https://github.com/SnpM/tonguetoquill-usaf-memo/blob/bebba4c1a51f9d67ca66e08109439b2c637e1015/template/assets/fonts/CopperplateCC-Heavy.otf")[Copperplate CC]] to your project folder*


Note that this template provides proper formatting for various elements via Typst functions.~ The recipient line uses proper grid formatting, the body uses automatic paragraph numbering, the signature block uses precise positioning, and so on.~ The template handles all AFH 33-337 formatting requirements automatically.

Place "MEMORANDUM FOR" on the second line below the date.~ Leave two spaces between "MEMORANDUM FOR" and the recipient's office symbol.~ If there are multiple recipients, two or three office symbols may be placed on each line aligned under the entries on the first line.~ If there are numerous recipients, type "DISTRIBUTION" after "MEMORANDUM FOR" and use a "DISTRIBUTION" element below the signature block.

Place "FROM:" on the second line below the "MEMORANDUM FOR" line.~ Leave two spaces between the colon in "FROM:" and the originator's office symbol.~ The "FROM:" element contains the full mailing address of the originator's office unless the mailing address is in the header or if all the recipients are located in the same installation as the originator.

Place "SUBJECT:" in uppercase letters on the second line below the last line of the FROM element.~ Leave two spaces between the colon in "SUBJECT:" and the subject.~ Capitalize the first letter of each word except articles, prepositions, and conjunctions (this is sometimes referred to as "title case").~ Be clear and concise.~ If the subject is long, try to revise and shorten the subject; if shortening is not feasible, align the second line under the first word of the subject.

Body text begins on the second line below the last line in the subject element and is flush with the left margin.~ If the Reference element is used, then the body text begins on the second line below the last line on the Reference element.

+ When a paragraph is split between pages, there must be at least two lines from the paragraph on both pages.~ This template automatically handles this formatting, but in the case of widowed sentences you can use manual page breaks.~ Similarly, avoid single-sentence paragraphs by revising or reorganizing the content.

+ Number or letter each body text paragraph and subparagraph according to the format for subdividing paragraphs in official memorandums presented in the Tongue and Quill.~ This subdivision format is provided automatically in this template.~ When a memorandum is subdivided, the number of levels used should be relative to the length of the memorandum.~ Shorter products typically use three or fewer levels.~ Longer products may use more levels, but only the number of levels needed.


Follow the spacing guidance between the text, signature block, attachment element, courtesy copy element, and distribution lists carefully.~ The signature block starts on the fifth line below the body text – this spacing is handled automatically by the template.~ Never separate the text from the signature block: the signature page must include body text above the signature block.~ Also, the first element below the signature block begins on the third line below the last line of the duty title; this applies to attachments, courtesy copies, and distribution lists, whichever is used first.

Elements of the Official Memorandum can be inserted as templated parts in MS Word.~ Select the "Insert" menu, "Quick Parts", and then select the desired element.~ Follow the formatting instructions provided with the element template.

+ To add classification banner markings (including FOUO markings), click on the header or footer, and in the "Header & Footer Tools" tab, select the Header / Footer dropdown menus on the left side.~ Use the pre-generated headers and footers – note that the first page is different from the second page onward, and so the second page header and footer must be applied separately.

When a paragraph is split between pages, there must be at least two lines from the paragraph on both pages.~ This template automatically handles this formatting, but in the case of widowed sentences you can use manual page breaks.~ Similarly, avoid single-sentence paragraphs by revising or reorganizing the content.

Number or letter each body text paragraph and subparagraph according to the format for subdividing paragraphs in official memorandums presented in the Tongue and Quill.~ This subdivision format is provided automatically in this template.~ When a memorandum is subdivided, the number of levels used should be relative to the length of the memorandum.~ Shorter products typically use three or fewer levels.~ Longer products may use more levels, but only the number of levels needed.

Follow the spacing guidance between the text, signature block, attachment element, courtesy copy element, and distribution lists carefully.~ The signature block starts on the fifth line below the body text – this spacing is handled automatically by the template.~ Never separate the text from the signature block: the signature page must include body text above the signature block.~ Also, the first element below the signature block begins on the third line below the last line of the duty title; this applies to attachments, courtesy copies, and distribution lists, whichever is used first.

Elements of the Official Memorandum can be inserted as templated parts in MS Word.~ Select the “Insert” menu, “Quick Parts”, and then select the desired element.~ Follow the formatting instructions provided with the element template.

To add classification banner markings (including FOUO markings), click on the header or footer, and in the “Header & Footer Tools” tab, select the Header / Footer dropdown menus on the left side.~ Use the pre-generated headers and footers – note that the first page is different from the second page onward, and so the second page header and footer must be applied separately.~ 

The example of this memorandum applies to many official memorandums that Airmen may be tasked to prepare; however, there are additional elements for special uses of the official memorandum.~ Refer to the Tongue and Quill discussion on the official memorandum for more details, or consult published guidance applicable to your duties.
]