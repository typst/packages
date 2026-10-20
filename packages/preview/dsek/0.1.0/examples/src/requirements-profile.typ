#import "@preview/dsek:0.1.0": *
#import strings: styr

#show: kravprofil.with(
  position: styr.ordf, // or a plain string: "Ordförande"
  requirements: (
    "Godkänd i B2",
  ),
  merits: (
    "Erfarenhet av projektledning",
    "Tidigare ordföranderoll i studentförening",
  ),
  year: 2025,
  mandate: (
    // set to `auto` or omit for default of jan 1 – dec 31
    from: date(1, 7, 2026),
    to: date(30, 6, 2027),
  ),
)

Ordförande leder sektionens styrelse och representerar sektionen utåt.
