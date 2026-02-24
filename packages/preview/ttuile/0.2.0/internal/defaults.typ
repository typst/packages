/* ------------------------------- Font sizes ------------------------------- */
#let fsize-base = 12pt
#let fsize-header = 10.5pt
#let fsize-footer = 10pt
#let fsize-caption = 10pt
#let fsize-footnote = 9pt

// Headline font sizes, in order : [lead, title]
#let fsize-headline = (14pt, 18pt)

// Heading font sizes, in order : [h1, h2, h3, h4]
#let fsize-heading = (14pt, 13pt, 13pt, 12pt)

#let fsize-appendices-outline-title = (16pt,)

/* ---------------------------------- Fonts --------------------------------- */
#let ffam-base = "HK Grotesk"
#let ffam-heading = "HK Grotesk"
#let ffam-special = "Liberation Serif"
#let ffam-outline = "Libertinus Serif"


/* --------------------------------- Lengths -------------------------------- */
#let indent-base = 0.76cm
#let indent-outline = 0.4cm
#let indent-heading = 0.50cm
#let indent-numbering = 0.2cm

// Spacing around headings, in order : [above, below]
#let vspacing-heading = (15pt, 12pt)

#let vspacing-appendices-outline = 4.25pt
#let vspacing-appendices-heading = 3 * 4.25pt

/* --------------------------------- Colors --------------------------------- */

// Used for the headline
#let color-headline = color.red

// This one for figures' captions
#let color-blue-caption = color.rgb(0, 69, 134)

// Heading colors, in order : [h1, h2, h3, h4]
#let color-heading = (
  color.rgb(0, 169, 51), // Green
  color.rgb(52, 101, 164), // Blue
  color.rgb(166, 77, 121), // Purple
  black,
)


/* ---------------------------------- Misc ---------------------------------- */
#let style-numbering-h1 = "I."
#let style-numbering-h2 = "1."
#let style-numbering-h3 = "A."
#let style-numbering-base = style-numbering-h1 + style-numbering-h2 + style-numbering-h3
#let style-numbering-appendices = "A.1.1.1"

// Prefix showing before the error messages in `assert`s and `panic`s
#let prefix-errors = "[ template / ttuile ] > "

#let outline-depth = 3

// These are supposed to be random IDs used as markers/tags,
// so that we can tell for sure where the appendices begin and end.
#let metadata-appendices-start = "6a359bbd-b367-4af5-bd82-c80e83a64c78"
#let metadata-appendices-end = "ea2899f8-e9f3-4c70-b4b0-4e6afe77da9c"
