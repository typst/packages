#let debug = false

//---------------------------------------------|  INFO  |---------------------------------------------//

#let degree-level-en = "Master"
#let degree-level-sv = "Avancerad nivå"

#assert(degree-level-en in ("Master", "Bachelor"), message: "Variable 'degree-level-en' must be either 'Master' or 'Bachelor'")
#assert(degree-level-sv in ("Avancerad nivå", "Grundnivå"), message: "Variable 'degree-level-sv' must be either 'Avancerad nivå' or 'Grundnivå'")

#let department-en = "Department of Electrical and Information Technology"
#let department-short-en = "EIT"
#let department-sv = "Insitutionen för elektro- och informationsteknik"
#let department-short-sv = "EIT"
#let department-link = link("http://www.eit.lth.se")

//---------------------------------------------|  TEXT  |---------------------------------------------//

// Body text size
#let size-main = 10pt
// Secondary text size, used in headers, footers and figure captions
#let size-secondary = size-main * 0.8
// Level 1 headings font size
#let size-heading = size-main * 1.8
// Level 2 headings font size
#let size-sub-heading = size-main * 1.4
// Level 3 headings font size
#let size-sub-sub-heading = size-main * 1.2
#let size-chapter-nbr = size-main * 4

//---------------------------------------------|  FONTS  |---------------------------------------------//

// Serif font
#let font-main = "EB Garamond"
// Sans-serif font
#let font-secondary = "Lato"
#let font-chapter-nbr = font-main
#let font-code = "Source Code Pro"
#let font-math = "Libertinus Math"

//---------------------------------------------|  COLORS  |---------------------------------------------//

// Colours, taken from the official graphic profile of Lund University
#let lu-bronze = color.spot("PANTONE 1395 U", rgb(156, 97, 20)).tint(100%) //cmyk(9%, 57%, 100%, 41%)
#let lu-blue = color.spot("PANTONE 280 U", rgb(0, 0, 128)).tint(100%) //cmyk(100%, 85%, 5%, 22%)
#let lu-grey = color.spot("PANTONE BLACK 7 C", rgb(77, 76, 68)).tint(100%) //cmyk(0%, 0%, 15%, 85%)
#let lu-light-brown = color.spot("PANTONE 7527 C", rgb(214, 210, 196)).tint(100%) //cmyk(3%, 4%, 14%, 8%)
#let colour-main = black
#let colour-secondary = lu-grey