#let title = "Praxisbericht"
#let subtitle = "Hier ist Platz für einen Untertitel"

// set up to 6 authors
// set a trailing comma after the author's object
#let authors = (
  (
    name: "Rainer Zufall",
    short: "RZ",
    studentId: 1234567,
    email: "rainer.zufall@hs-rm.de",
    color: red,
  ),
  (
    name: "Frank Reich",
    short: "FR",
    studentId: 1212121,
    email: "frank.reich@hs-rm.de",
    color: aqua,
  ),
)

#let uni-name = "Name der Hochschule"
#let uni-supervisor = "Prof. Dr. Hand Lauf"
#let uni-logo = image("generic-uni-logo.png", height: 3cm)

#let company-name = "Unternehmen XY"
#let company-supervisor = "Hand Schuh"
#let company-logo = image("generic-company-logo.png", height: 2.6cm) // adjust the logo size here

#let line-spacing = .8em // maximum is set to a multiple of 1.2 to comply with hsrm's requirements
#let legend-on-outline = true
#let heading-font = "TeX Gyre Heros"
#let text-font = "Stix Two Text" // change to "Times New Roman" or "Arial" to meet hsrm's formal requirements
