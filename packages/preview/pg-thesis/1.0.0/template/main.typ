#import "@preview/pg-thesis:1.0.0": *

#show: thesis.with(
  // Język pracy: "pl" lub "en".
  lang: "pl",
  // "bachelor" (licencjacka), "engineering" (inżynierska),
  // "engineering-project" (projekt inżynierski) lub "master" (magisterska).
  kind: "engineering",

  title-pl: [Tytuł pracy dyplomowej w języku polskim],
  title-en: [Diploma thesis title in English],
  // Przy pracy zespołowej najpierw student firmujący dany egzemplarz.
  authors: (
    (name: "Jan Kowalski", album: "123456"),
  ),
  supervisor: "dr inż. Jan Nowak",
  faculty: "Wydział Elektroniki, Telekomunikacji i Informatyki",
  field: "Informatyka",
  specialization: "Algorytmy i modelowanie systemów",

  // Strona tytułowa: w wersji ostatecznej wstaw PDF pobrany z Moja PG, np.
  //   title-page: image("strona-tytulowa.pdf"),
  // `auto` generuje stronę o tym samym układzie (do wersji roboczych).
  title-page: auto,
  // Opcjonalne oświadczenie na stronie 2: statement: image("oswiadczenie.pdf"),

  abstract-pl: include "abstract-pl.typ",
  keywords-pl: ("słowo kluczowe", "drugie słowo kluczowe"),
  oecd-pl: [inżynieria informatyczna],
  abstract-en: include "abstract-en.typ",
  keywords-en: ("keyword", "another keyword"),
  oecd-en: [information engineering],

  // Pary (oznaczenie, opis); można też podać słownik (PG: [...], ...).
  abbreviations: (
    ($e$, [niepewność pomiaru]),
    ($f$, [częstotliwość [Hz]]),
    ($k$, [stała Boltzmanna $1,38 dot 10^(-23)$ Ws/K]),
    ([OECD], [Organisation for Economic Co-operation and Development (Organizacja Współpracy Gospodarczej i~Rozwoju)]),
    ([PG], [Politechnika Gdańska]),
  ),

  bibliography: bibliography("bibliography.bib"),
  appendices: include "appendix.typ",
)

#include "chapters/01-wstep.typ"
#include "chapters/02-elementy.typ"
#include "chapters/03-podsumowanie.typ"
