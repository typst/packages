#let signature(
  city:"",
  date:none,
  name:"",
) = {
  grid(
    columns: (auto, auto),
    align(left)[
      #city, #date.display("[month repr:long] [day], [year]")
      #h(12pt)
    ],
    align(right)[
      #move(dy: 8pt, line(length: 100%, stroke: (thickness: 0.5pt)))
      #move(dy: 2pt,name)
    ],
  )
}

#let declaration-of-authorship(
  city: "",
  date: none,
  name: "",
) = {
  set heading(outlined: false)

  page(
    footer: [],
    [
      == Eidesstattliche Erklärung
      Ich erkläre hiermit an Eides Statt, dass ich die vorliegende Arbeit selbstständig verfasst und keine anderen als die angegebenen Quellen und Hilfsmittel verwendet habe.

      == Statement in Lieu of an Oath
      I hereby confirm that I have written this thesis on my own and that I have not used any other media or materials than the ones referred to in this thesis.

      #v(70pt)

      == Einverständniserklärung
      Ich bin damit einverstanden, dass meine (bestandene) Arbeit in beiden Versionen in die Bibliothek der Informatik aufgenommen und damit veröffentlicht wird.

      == Declaration of Consent
      I agree to make both versions of my thesis (with a passing grade) accessible to the public by having them added to the library of the Computer Science Department.

      #v(100pt)
      #signature(city: city, date: date, name: name)
    ]
  )

  pagebreak(weak: true, to: "odd")
}
