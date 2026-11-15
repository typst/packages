#import "@preview/dsek:0.1.0": *
#import strings: styr

#show: kallelse.with(
  meeting: "S05",
  time: date(15, 3, 2025, time: (13, 0)),
  location: [E:A, LTH],
  authors: (
    // position defaults to "Sektionsmedlem" / "Guild member",
    // message defaults to "Lund, dag som ovan" / "Lund, day as above"
    (name: "Truls Teknolog", position: styr.ordf),
  ),
)

Kära Sektionsmedlemmar,

idag har vi den stora äran att än en gång få kalla er till sektionsmöte.
Tyvärr räckte inte budgeten till fika, men vi hoppas att ni kommer ändå.

- [] OFMÖ // [] = no action label
- [Sång] Sektionshymn
  + #link("https://dsek.se/hymn")[Text]    // link shown in Bilaga / Annex column with label Text
- [Beslut] Val av justerare
- [Information] Ekonomisk status
  + #link("https://dsek.se/rambudget")     // numbered: 1
  + #link("https://dsek.se/detaljbudget")  // numbered: 2
- [Beslut] Motion: Jag tycker sektionen borde ha Financial Times
  + #link("https://dsek.se/rambudget")     // numbered: 1 (same link)
- [] OFMA
