#import "@preview/dsek:0.1.0": *
#import strings: otherpos

#show: föredragningslista.with(
  meeting: "HTM1",
  time: date(15, 3, 2026, time: (17, 15)),
  authors: (
    (name: "Truls Teknolog", position: otherpos.talman),
  ),
)

- [] TFMÖ                                  // [] = no action label
- [Sång] Sektionshymn
  + #link("https://dsek.se/hymn")[Text]    // link shown in Annex / Bilaga column with label "Text"
- [Beslut] Val av justerare
- [Information] Ekonomisk status
  + #link("https://dsek.se/rambudget")     // numbered: 1
  + #link("https://dsek.se/detaljbudget")  // numbered: 2
- [Beslut] Motion: Jag tycker sektionen borde ha Financial Times
  + #link("https://dsek.se/rambudget")     // numbered: 1 (same link)
- [] TFMA
