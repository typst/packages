# Stanford format requirements → template behaviour

A clause-by-clause map from the Office of the University Registrar's published
requirements to what this template does. Quotes are verbatim, so that when
Stanford changes the wording you can diff it against this file.

**Sources**

| Key | Page |
|---|---|
| `FMT` | [Format Requirements for Your Dissertation or Thesis](https://studentservices.stanford.edu/my-academics/earn-my-degree/graduate-degree-progress/dissertations-and-theses/prepare-your-work-0) |
| `TP-PHD` | [Title Page for Ph.D. Dissertation](https://studentservices.stanford.edu/my-academics/earn-my-degree/graduate-degree-progress/dissertations-and-theses/prepare-your-work-1) |
| `TP-ENG` | [Title Page for an Engineer Thesis](https://studentservices.stanford.edu/my-academics/earn-my-degree/graduate-degree-progress/dissertations-and-theses/prepare-your-work-2) |

Last checked against the live pages: **17 August 2026.**

> `FMT`: "The Office of the University Registrar does not endorse or verify the
> accuracy of any dissertation or thesis formatting templates that may be
> available to you. It is your student responsibility to make sure that the
> formatting meets these requirements."

That applies to this template. Nothing here is approved by Stanford.

---

## Handled by the template

| Requirement | Quote | How |
|---|---|---|
| Page size | "Pages should be standard U.S. letter size (8.5 x 11 inches)." | `paper: "us-letter"` |
| Margins | "Inner margins … must be 1.5 inches. All other margins must be one inch." | `margin-inner: 1.5in`, `margin-outer: 1in`; alternates by page parity when `double-sided: true` |
| Margins on title page | "Margin requirements should apply to the entire document, including the title page." | Same page setup applies; see the caveat on centring below |
| Pagination inset | "no closer than one-half inch from the edge of the page" | `page-number-margin: 0.5in`, measured at exactly 0.500 in by `tests/check.py` |
| Font size | "type size should be 10, 11, or 12 point" | `body-size: 10pt` |
| Font colour | "The font color must be black." | `set text(fill: black)` |
| Font family | "Computer Modern (or Computer Modern Roman)" is on the acceptable list | `body-font: "New Computer Modern"`, which ships with Typst so it resolves with nothing installed |
| Font embedding | "you must embed the font into the PDF that is submitted" | Typst embeds all fonts; asserted by `tests/check.py` |
| Line spacing | "The main body text … should be one-and-a-half or double-spaced lines" | `body-leading: 1.32em` → 15.02 pt baseline-to-baseline at 10 pt = **1.502×** the font size, measured by `tests/check.py` |
| Single spacing exceptions | "except where conventional usage calls for single spacing, such as footnotes, indented quotations, tables, appendices" | Captions, legends, and table content use `caption-leading` |
| Headings not stranded | "any heading or subheading at the bottom of a page that is not followed by text" should be avoided | Headings render inside `block(sticky: true)` |
| Title page content | See `TP-PHD` / `TP-ENG` sample wording | Generated from `degree`, `department`/`program`; the exact wording is asserted by `tests/check.py` |
| Title page case | "Use uppercase letters" | `title-page-case: "standard"` uppercases title and degree block; `"all"` also uppercases author and date |
| Title page weight | "No bold type and no pagination on the title page" | Default text weight, and `numbering` is unset until after the title page |
| No copyright page | "The dissertation or thesis PDF uploaded in Axess should not contain a copyright page." | Not emitted; absence asserted by `tests/check.py` |
| No signature page | "should also not contain a signature page" | Not emitted; absence asserted by `tests/check.py` |
| Preliminary numbering | "For the preliminary pages, use small Roman numerals" | `numbering: "i"` |
| Title page counts as i | "The title page is not physically numbered, but counts as page i." | `counter(page).update(4)` after the title page |
| Numbering starts at iv | "Physical pagination must begin immediately after the title page, on the Abstract page using the number 'iv'." | The Abstract is the first numbered page and carries iv; asserted by `tests/check.py` |
| Double-sided variant | "If the document is formatted for double-sided printing … pagination will begin on a blank page (page 'iv') and the Abstract should be numbered as page 'v'" | Off by default, since the quoted rule is conditional. `blank-page-iv: true` inserts that blank page and moves the Abstract to v. Independent of `double-sided`, which only governs the binding margin and running heads |
| Arabic restart | "use continuous Arabic pagination only … Remember to start with Arabic numbered page 1, as this is not a continuation of the Roman numeral numbering" | `main-body` sets `numbering: "1"` and resets the counter to 1; asserted by `tests/check.py` |
| Consistent placement | "The placement of page numbers should be consistent throughout the document." | One `page-number-position` setting governs every numbered page. Running heads live separately in the header, so preliminary and main-body folios cannot drift apart |
| Section order | "Your dissertation or thesis must contain the following sections" | `template/main.typ` is ordered title → abstract → acknowledgements/preface → contents → list of figures → list of tables → main body → appendices → references; order asserted by `tests/check.py` |
| Lists optional | "List of Tables … This list is optional." / "List of Illustrations … optional" | Both `#outline` calls can be deleted |
| Appendices optional | "Appendices. This is optional." | The `#show: appendix` block can be deleted |
| Language | "The dissertation and thesis must be in English." | `body` text is English; set `text(lang:)` yourself if you need otherwise |
| Single file | "All sections must be included in a single digital file for upload." | One `main.typ` compiles to one PDF |

## Your responsibility, not the template's

The template cannot check these. `template/chapters/03_conclusions.typ` repeats
them as a pre-submission checklist inside the example document itself.

| Requirement | Quote |
|---|---|
| Image format | "The format of images embedded in the PDF should be JPEG or EPS … GIF and PNG are not preferred image file formats." Typst cannot read EPS, so use JPEG. The bundled example figures are JPEG |
| Image resolution | "Image resolution should be 150 dots per inch (dpi), though resolutions as low as 72 dpi (and no lower) are acceptable." |
| Image dimensions | "The dimensions should not exceed the size of the standard letter-size page (8.5" x 11")." |
| Large graphics | "Large images … should not be included in the main dissertation or thesis file. Instead, they can be submitted separately as supplemental files" |
| Main file size | "The maximum file size accepted for submission is 100 MB." |
| Supplemental files | "A maximum of twenty supplemental files can be submitted … The maximum file size is 1 GB." |
| No multimedia | "Multimedia, such as audio, video, animation, etc., must not be embedded in the body" |
| Spelled-out URLs | "Spell out each URL in its entirety (e.g., http://www.stanford.edu) rather than embedding the link in text" — clickable links are fine, hidden ones are not |
| No encryption | Do not password-protect the PDF (`tests/check.py` asserts the example is not encrypted) |
| Title wording | "Use word substitutes for formulas, symbols, superscripts, subscripts, Greek letters, etc." |
| Submission date | "The month and year must be the actual month and year in which you submit" |
| Word division | "Words should be divided correctly at the end of a line and may not be divided from one page to the next." Typst hyphenates when justifying; check your final page breaks |
| Widows | "Avoid short lines that end a paragraph at the top of a page" |
| Online abstract | The Axess form's abstract is separate and "limited to 5,000 characters", plain text only |
| File name | Alphanumerics, hyphens, underscores, `@`, spaces, `&`, commas; ≤120 characters; must not start with a space, period, underscore, or hyphen |
| Published chapters | "Published Papers and Multiple Authorship" — declare these, conventionally in the preface |
| Style guide | "Select a standard style approved by your department or dissertation advisor and use it consistently." |

## Known deviations from the letter of the requirements

**Title page centring.** `TP-PHD` and `TP-ENG` both say the title page should be
"centered within the margins both vertically and horizontally". With an inner
margin of 1.5 in and an outer margin of 1 in, the centre of the text block is
0.25 in from the centre of the sheet, so the two readings differ visibly.

The default, `title-page-centering: "page"`, centres on the physical sheet,
which looks symmetric when the page is viewed or printed on its own. Set
`title-page-centering: "margins"` for the literal reading.

**Monospace font.** The acceptable-families list names Courier for monospace.
The default `mono-font: "DejaVu Sans Mono"` is used because it ships with Typst
and therefore never fails to resolve; Courier is not bundled. If your document
contains code or verbatim text and you want to stay strictly on the list, set
`mono-font: "Courier New"`.
