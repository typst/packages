#import "../lib.typ": qfd
#import "coffee-data.typ": needs-functions, functions-components
#set page(paper: "a3", margin: 15mm)
#set text(font: ("IBM Plex Sans", "New Computer Modern"), size: 10pt)
#set par(leading: 0.6em)
#text(font: ("IBM Plex Serif", "Libertinus Serif"), size: 22pt)[Coffee at home]
#v(1mm)
#text(size: 12pt)[A worked deployment from household needs to components]
#v(4mm)
#block(width: 100%)[
  The intended substitution is a coffee prepared at home instead of a visit to the local café.
  The provisional system boundary includes the machine, a sealed preground dose, and its packaging.
  All weights, relations, and roof signs below are illustrative workshop judgments.

  *Acceptance comes first.* Taste, drink temperature, and household safety require separate
  pass/fail checks. Their thresholds and validation protocols must be agreed before a concept
  is accepted. Relative priority cannot compensate for failing one of these gates.
]
#v(4mm)
#text(size: 16pt, weight: "bold")[1 · Translate needs into functions]
#v(2mm)
#qfd(..needs-functions, width: 100%)
#v(3mm)
#block(width: 100%)[
  Function groups cover water storage and energy conversion; pressure, flow, and extraction;
  preservation of grounds; serving and waste collection; guidance and protection.
  Brewing-water temperature of 92 ± 2 °C, about 25 s of contact, and six months of freshness
  are provisional targets. They are not measured results or universal capsule specifications.
]
#pagebreak()
#text(size: 16pt, weight: "bold")[2 · Deploy priorities into components]
#v(2mm)
#qfd(..functions-components, width: 100%, what-width: 64mm)
#v(3mm)
#block(width: 100%)[
  The row weights are inherited from stage 1 without rounding. The proposed components organize
  possible implementations; a turbine flowmeter or a particular pump technology still requires
  selection and testing. No stepper motor is assumed.

  *Next evidence:* compare blind taste and temperature at serving with the chosen café reference;
  repeat a three-drink sequence; observe setup and cleanup; test stored sealed doses; assess footprint
  and foreseeable household misuse. No competitive scores have been measured in this example.
  See COFFEE.md for protocols, limitations, and sources.
]
