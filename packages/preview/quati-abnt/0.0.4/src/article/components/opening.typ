// # Opening. Abertura.
// NBR 6022:2018 5.1

#import "../../common/components/title.typ": print_title
#import "../../common/style/style.typ": (
  font_size_for_common_text, font_size_for_larger_text, leading_for_common_text, leading_for_larger_text,
  spacing_for_common_text, spacing_for_larger_text,
)
#import "../../common/template.typ": should_use_larger_text_to_highlight_state
#import "../../common/util/font_family.typ": font_family_for_common_text_state, font_family_for_highlighted_text_state

#let print_person(
  person: (
    first_name: "Fulano",
    middle_name: none,
    last_name: "Fonseca",
    curriculum: "",
  ),
) = context {
  person.first_name + sym.space
  if person.middle_name != none {
    person.middle_name + sym.space
  }
  (
    person.last_name
      + text(
        font: font_family_for_common_text_state.get(),
        footnote(
          numbering: "*",
          person.curriculum,
        ),
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
) => context {
  set text(
    font: font_family_for_highlighted_text_state.get(),
  )
  set par(
    first-line-indent: 0pt,
  )

  align(center)[
    #let should_use_larger_text_to_highlight = should_use_larger_text_to_highlight_state.get()

    #let size = font_size_for_common_text
    #let leading = leading_for_common_text
    #let spacing = spacing_for_common_text

    #if should_use_larger_text_to_highlight {
      size = font_size_for_larger_text
      leading = leading_for_larger_text
      spacing = spacing_for_common_text
    }

    #set text(
      size: size,
    )
    #set par(
      leading: leading,
      spacing: spacing,
    )

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

  counter(footnote).update(0)
}
