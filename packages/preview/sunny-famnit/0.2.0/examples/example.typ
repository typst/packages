#import "@preview/sunny-famnit:0.2.0": project
#import "attachments.typ" as pr

#let input = (
  izvleček: [
    To je krako delo spisano za pomoč pri uporabi Typsta za delo zaključnega dela. V izvlečku se uporabi največ 250 besed. Tu se izpiše probleme, metode, rezultate, ključne ugotovitve in njihov pomen.
  ],
  abstract: [
    This is a stub written to help you with use of Typst for thesis work. A maximum of 250 words is used in the abstract. Problems, methods, results, key findings and their significance are listed here.
  ],
  ključne_besede: ("Typst", "Zaključna naloga", "Pisanje", "Navodila"),
  key_words: ("Typst", "Final work", "Writing", "Tutorial"),
  kratice: (
    "Famnit": "Fakulteta za matematiko naravoslovje in informacijske tehnologije",
    "PDF": "Portable document format",
  ),
  priloge: (
    "Raw koda": raw(read("example.typ"), lang: "typst", block: true),
    "some obscurly long ass text that would be so long that it goes into another line to test. But hey you still need more words for it to go there.": pr.a, // sample of importing priloge.
  ),
  zahvala: [
    Opcijsko se lahko tu zahvalite typst-u za olajšanje dela. Če zahvale ne želite napisati, zamenjajte content( to so vsebinski bloki znotraj `[]`) z `none`
  ],
)

#show: project.with(
  date: datetime(day: 1, month: 1, year: 2024),
  author: "Tilen Gimpelj",
  studij: "Bioinformatika",
  mentor:(
    name: "Oge So-Kul", 
    sl: ("dr.",""),
    en: ("",".phD"),
    ),
  somentor: none, // optional somentor, written in the same way as mentor
  work_mentor: none, // optional work mentor can be written the same way as mentor

  naslov: "Naslov zaključne naloge",
  title: "Title of the final work",

  bib_file: bibliography(
    "my_references.bib",
    style: "ieee",
    title: [Bibliography],
  ),
  ..input, // Dodajanje večjega dela stvari za lepšo preglednost.
  /* Additional options, defaults shown
  kraj: "Koper",
  */
  text_lang: "en", // this can be chaged to "sl" for slovene works, there are small differences for it.

)

= Uvod

This @PDF and its source-code in @priloga_1 are for demonstration of the template.

all Attachments are referencable, and so are abbriviations.


you can add subheadings:

== subheading

you can add figures:

#figure(
  caption: [some spicy figure],
  image("image.png", width: 80%)
)

#let data = range(1,10).map(i => ([#i],[#(i * i)], [#(calc.pow(i,i))],[#(calc.ln(i))])).flatten()


or a table:
#figure(
  caption: [oh look, a table],
  table(
    columns: 4,
    [$x$],[$x * x$], [$x^x$],[$ln(x)$],
    ..data
  )
)

Referencing is simple as doing @darwin_1859_on
