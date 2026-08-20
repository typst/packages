#import "@preview/ukw-bipg-unofficial-thesis:0.1.0": ukw-thesis, zalacznik

#show: ukw-thesis.with(
  // ——— Dane do strony tytułowej (zał. nr 2) ———
  title: "Proceduralne generowanie poziomów jako narzędzie projektowania rozgrywki",
  subtitle: none,
  author: "Anna Kowalska",
  album: "123456",
  supervisor: "dr Jan Nowak",
  field: "Badanie i Projektowanie Gier",
  study-type: "studia stacjonarne pierwszego stopnia",
  degree: "bachelor",   // "bachelor" (licencjacka) lub "master" (magisterska)
  year: "2026",
  lang: "pl",           // §2 ust. 1: praca po polsku albo angielsku

  // ——— Streszczenie i słowa kluczowe (zał. nr 3, max. 1000 znaków, max. 10 słów) ———
  keywords: (
    "proceduralne generowanie", "projektowanie poziomów", "mechaniki gier",
    "roguelike", "game design",
  ),
  abstract: [
    Praca analizuje wykorzystanie proceduralnego generowania poziomów w projektowaniu
    rozgrywki gier cyfrowych. Celem badania jest ustalenie, w jaki sposób parametry
    algorytmów generacyjnych przekładają się na doświadczenie gracza. W części
    teoretycznej omówiono stan badań, w części praktycznej przedstawiono prototyp
    oraz wyniki testów z udziałem graczy.
  ],

  // ——— Bibliografia ———
  bibliography-file: "bibliografia.bib",
  bibliography-style: "apa",

  // ——— Spisy pomocnicze ———
  list-of-figures: true,
  list-of-tables: true,

  // draft: true — wyłącza puste strony i wymuszanie rozdziałów od strony nieparzystej
  // (wygodne przy pisaniu; przed wydrukiem dwustronnym ustaw na false)
  draft: false,
)

= Wstęp

Tutaj przedstawiasz temat, cel pracy, hipotezy oraz zakres podmiotowy i przedmiotowy
badania — czyli dokładnie te elementy, o których będziesz mówić podczas omówienia
pracy na egzaminie dyplomowym (§3 ust. 3 Regulaminu).

Przypis merytoryczny umieszczasz na dole strony w ten sposób.#footnote[Numeracja
przypisów jest ciągła w całej pracy — wymaga tego §2 ust. 4.]
Odwołanie śródtekstowe do literatury zapisujesz konsekwentnie jednym systemem
@juul2005.

== Cel i hipotezy

Sformułuj cel główny oraz hipotezy badawcze.

== Metody badawcze

Opisz zastosowane metody oraz wykorzystane źródła informacji.

= Stan badań

Przegląd literatury przedmiotu.

#figure(
  rect(width: 60%, height: 4cm, stroke: 0.5pt),
  caption: [Schemat pętli rozgrywki w analizowanym prototypie.],
) <fig-petla>

Do rysunku odwołujesz się przez etykietę: @fig-petla.

= Część analityczna / projektowa

#figure(
  table(
    columns: 3,
    stroke: 0.5pt,
    table.header([*Parametr*], [*Wartość*], [*Wpływ na rozgrywkę*]),
    [Gęstość korytarzy], [0,4], [Tempo eksploracji],
    [Liczba pomieszczeń], [12], [Długość sesji],
    [Ziarno losowe], [stałe / losowe], [Powtarzalność testów],
  ),
  caption: [Parametry generatora poziomów.],
) <tab-parametry>

= Zakończenie

Wnioski, ograniczenia badania oraz kierunki dalszych prac.

// ——— Załączniki (opcjonalnie) ———
// #zalacznik(1, "Scenariusz testów z użytkownikami")[
//   Treść załącznika.
// ]
