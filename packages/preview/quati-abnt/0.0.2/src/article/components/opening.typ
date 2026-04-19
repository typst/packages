// # Opening. Abertura.
// NBR 6022:2018 5.1

#import "../../common/components/title.typ": print_title
#import "../../common/style/style.typ": leading_for_common_text, spacing_for_common_text

#let print_person(
  person: (
    first_name: "Fulano",
    middle_name: none,
    last_name: "Fonseca",
    curriculum: "",
  ),
) = {
  person.first_name + sym.space
  if person.middle_name != none {
    person.middle_name + sym.space
  }
  (
    person.last_name
      + footnote(
        numbering: "*",
        person.curriculum,
      )
  )
}

#let include_opening = (
  authors: {
    (
      (
        first_name: "Fulano",
        middle_name: none,
        last_name: "Fonseca",
        curriculum: "",
      ),
    )
  },
  title: { "Título do trabalho" },
  title_in_foreign_language: {
    none
  },
  subtitle: {
    // "Subtítulo do trabalho"
  },
) => {
  set par(
    first-line-indent: 0pt,
  )

  align(center)[
    // ## Title. Título.
    #print_title(
      title: title,
      subtitle: subtitle,
    )
    #parbreak()

    // ## Title in foreign language. Título em língua estrangeira.
    #if title_in_foreign_language != none [
      #title_in_foreign_language
      #parbreak()
    ]

    #v(spacing_for_common_text)
  ]

  align(right)[
    #(
      authors
        .map(
          person => print_person(
            person: person,
          ),
        )
        .join(
          linebreak(),
        )
    )
  ]
  parbreak()
}
