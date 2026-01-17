// NTNU Physics Lab Report Template
// Initialize with: typst init @preview/ntnu-physics-report

#import "@preview/ntnu-physics-report:0.1.0": *

#show: ntnu-rapport.with(
  title: "Tittel på rapporten",
  authors: (
    (name: "Ditt Navn", affiliations: (1,)),
    (name: "Medstudent", affiliations: (1,)),
  ),
  affiliations: (
    "Institutt for fysikk, Norges Teknisk-Naturvitenskapelige Universitet, N-7491 Trondheim, Norway.",
  ),
  supervisor: "Veileders Navn",
  abstract: [
    Her skriver du et sammendrag av rapporten. Sammendraget skal være veldig kort
    men må inneholde svaret på tre spørsmål: 1. Hva gjorde du (hva målte du)? 2. Hvordan
    gjorde du det (hvilken metode)? 3. Hva fant du (resultat)?
  ],
  // bibliography-file: "references.bib",
  two-column: true,
)

= Innledning

Her begynner rapporten. Beskriv bakgrunnen for eksperimentet og hva du ønsker å undersøke.


= Teori

Her presenterer du den relevante teorien. For eksempel kan svingetiden til en pendel uttrykkes som
$ T = 2 pi sqrt(l / g), $ <svingetid>
der $l$ er lengden til pendelen og $g$ er tyngdeakselerasjonen.

Vi kan referere til ligning @svingetid senere i teksten.


= Metode og apparatur

Beskriv utstyret du brukte og hvordan eksperimentet ble utført.

// Eksempel på figur (fjern kommentar når du har en bildefil):
// #figure(
//   image("figur.png", width: 50%),
//   caption: [Beskrivelse av figuren.],
// ) <min-figur>


= Resultat og diskusjon

Presenter resultatene dine. For eksempel: Vi målte lengden til $l = 1,000 plus.minus 0,001 "m"$.

// Eksempel på tabell:
#figure(
  table(
    columns: 3,
    align: center,
    stroke: none,
    inset: (x: 8pt, y: 4pt),
    toprule,
    [$l$ (m)], [$T$ (s)], [$g$ (m/s²)],
    midrule,
    [0,50], [1,42], [9,80],
    [0,75], [1,74], [9,81],
    [1,00], [2,01], [9,79],
    bottomrule,
  ),
  caption: [Målte verdier for pendellengde, svingetid og beregnet tyngdeakselerasjon.],
  kind: table,
) <resultater>

Resultatene i @resultater viser at...


= Konklusjon

Oppsummer funnene dine og gi en konklusjon.


// Referanser - bruk enten manuell liste eller .bib-fil
#heading(level: 1)[Referanser]

#set par(first-line-indent: 0pt, hanging-indent: 1.5em)

\[1\] Forfatter. _Tittel_. Utgiver, År.
