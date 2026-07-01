// Glossary (Verklarende woordenlijst, begrippenlijst)
// Abbreviations (Afkortingen) - abbreviations include acronyms, initialism, ...

#let glossary-entries = (
  ugent: (short: "UGent", long: "Universiteit Gent"),
  API  : (short: "API", long: "Application Programming Interface"),
  DAG  : (short: "DAG", long: "directed acyclic graph",
          description: "Gerichte, acyclische graaf"),
  ECTS : (short: "ECTS", long: "European Credit Transfer and Accumulation System",
          description: [#link("https://education.ec.europa.eu/nl/education-levels/higher-education/inclusive-and-connected-higher-education/european-credit-transfer-and-accumulation-system")[
            Het Europees studiepuntensysteem], ook gehanteerd door
            de @ugent:short:noref en dan meestal ook kortweg 'studiepunten'
            genoemd.
          ]
         ),
  AI   : (short: "AI", long: "artificial intelligence"),
)

// EDIT: remove this clutter if you do not care about the described goals
#let glossary-reset-usage = [
  // The 'first use' behaviour of glossy first has to be fixed, see:
  // https://github.com/swaits/typst-collection/issues/39
  // This is partially fixed in https://github.com/th1j5/typst-glossy/tree/main/glossy
  // (commit a0f2bcfa32b92cf604fee1272e289b493c1b79e0) Not yet fixed: a global
  // reset function to reset ALL entries at that point (just before a new chapter)
  //
  // Only when the fixed version is used, the following statements would valid.
  // The idea is to reset the first-use counters each new chapter, by placing
  // this content at the start.
  // Furthermore, for some entries the short form should always be used.
  //
  //#glossary-reset-first-use()
  @ECTS:use:noindex[] // Always show the short form when writing @ECTS
]
