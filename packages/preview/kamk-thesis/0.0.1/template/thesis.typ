#import "@preview/kamk-thesis:0.0.1" as template

// Single source of truth for the thesis language; reused by every render-* call below.
#let language = "fi"

#show: template.frontmatter.with(
  // Perustiedot
  authors: ("Meikäläinen Matti",),
  date: datetime.today(),
  language: language,
  // cover-image: image("my-custom-cover.jpg", alt: "My custom cover image"), // Optional; defaults to package asset
  // cover-image: false,                                                      // Optional; explicitly disable the cover image entirely

  // Suomenkieliset tiedot
  title: "Opinnäytetyön otsikko suomeksi",
  degree-title: "Tradenomi (AMK)",
  degree-programme: "Tietojenkäsittely",
  keywords-fi: ("aerosolifysiikka", "avainsana 2", "avainsana 3"),
  abstract-fi: [
    Tähän tulee opinnäytetyön suomenkielinen tiivistelmä. Typst sallii kappalejakojen tekemisen yksinkertaisesti jättämällä tyhjän rivin tekstien väliin.

    Tämä tässä on toinen kappale tiivistelmässä.
  ],

  // Englanninkieliset tiedot
  title-en: "The title of the thesis in English",
  degree-title-en: "Bachelor of Business Administration",
  degree-programme-en: "Business Information Technology",
  keywords-en: ("aerosol physics", "keyword 2", "keyword 3"),
  abstract-en: [

    #lorem(50)

    #lorem(30)

    #lorem(70)
  ],

  // Alkusanat (valinnainen)
  foreword: [
    Tähän voit kirjoittaa opinnäytetyön alkusanat, esimerkiksi kiitokset ohjaajalle, toimeksiantajalle tai muille tahoille.
  ],

  // Symboliluettelo (valinnainen)
  symbols: (
    ("AMK", "Ammattikorkeakoulu"),
    ("API", "Application Programming Interface"),
  ),
)

/*
  Tästä alkaa opinnäytetyön varsinainen sisältö. Jokainen kappale on oma tiedostonsa, joka tuodaan tähän päädokumenttiin. Tiedostot sijaitsevat kansiossa `src/chapters/`. Kappaleiden järjestystä voi muuttaa muuttamalla tuontijärjestystä. Nämä tiedostot ja niiden sisällön kirjoittaminen on sinun tehtäväsi opinnäytetyön kirjoittajana.
*/
#include "chapters/johdanto.typ"
#include "chapters/sivut.typ"

#template.render-ai-usage(
  language: language,
  tools: [(Syötä tiedot tähän)],
  usage: [(Kuvaa tähän, mihin tarkoitukseen ja miten tekoälyä on käytetty opinnäytetyössä ja opinnäytetyöprosessin eri vaiheissa.)],
)

#template.render-bibliography(
  language: language,
  source: path("references.bib"),
  // cover_image_source: "Photo by John Doe on Unsplash (CC-BY 4.0). URL: https://unsplash.com...", // Uncomment and fill if using a custom cover image
)

// Arabic page numbers stop here; appendix pages carry their own "Liite N i/total" numbering.
#set page(numbering: none)

#let appendix-items = (
  (
    title: "Sparkin asennus Windows-koneille",
    content: [#lorem(140)], // Can be of any length now
  ),
  (
    title: "Toinen esimerkkiliite",
    content: include "appendices/toinen_liite.typ", // Cleaner to split large appendices
  ),
)

#template.render-appendices(language: language, items: appendix-items)
