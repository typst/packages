// # Title page. Folha de rosto.
// NBR 14724:2024 4.2.1.1.1

#import "../../../common/components/title.typ": print_title
#import "../../../common/style/style.typ": (
  font_size_for_smaller_text, simple_leading_for_smaller_text, simple_spacing_for_smaller_text,
)
#import "../../../common/util/font_family.typ": font_family_for_highlighted_text_state
#import "../../components/advisors.typ": print_advisors
#import "../../components/heading.typ": not_start_on_new_page
#import "../../components/nature.typ": print_nature
#import "../../components/page.typ": not_number_page
#import "../../components/people.typ": print_people

#let include_title_page(
  authors: {
    (
      (
        first_name: "Fulano",
        middle_name: none,
        last_name: "Fonseca",
        gender: "m",
      ),
    )
  },
  title: { "Título do trabalho" },
  subtitle: {
    // "Subtítulo do trabalho"
  },
  volume_number: {
    // "1"
  },
  organization: {
    (
      name: "Nome da organização",
      gender: "m",
    )
  },
  program: {
    // (
    //   name: "Nome do programa",
    //   gender: "m",
    // )
  },
  type_of_work: {
    // (
    //   name: "trabalho de conclusão de curso",
    //   gender: "m",
    // )
  },
  degree: {
    // (
    //   name: "bacharelado",
    //   title: (
    //     masculine: "bacharel",
    //     feminine: "bacharela",
    //   ),
    // )
  },
  degree_topic: { "Tema do trabalho" },
  area_of_concentration: {
    // "Área de concentração"
  },
  advisors: {
    (
      (
        first_name: "Ciclana",
        middle_name: "de",
        last_name: "Castro",
        gender: "f",
        prefix: {
          // "Profª Drª"
        },
      ),
    )
  },
  address: { "Local" },
  year: { "Ano" },
  custom_nature: {
    "Natureza do trabalho."
  },
) = context {
  not_number_page(
    not_start_on_new_page()[
      #page()[
        #set align(center)
        #set text(
          font: font_family_for_highlighted_text_state.get(),
        )

        // Authors
        #strong[
          #print_people(people: authors)
        ]

        #v(1fr)

        // Title
        #print_title(title: title, subtitle: subtitle, with_weight: true)

        #if volume_number != none [
          Volume #volume_number
          #parbreak()
        ]

        #v(1fr)

        #align(end)[
          #box(width: 50%)[
            #set align(start)
            #set text(size: font_size_for_smaller_text)
            #set par(leading: simple_leading_for_smaller_text, spacing: simple_spacing_for_smaller_text)
            #if custom_nature != none [
              #custom_nature
            ] else [
              #print_nature(
                authors: authors,
                organization: organization,
                program: program,
                type_of_work: type_of_work,
                degree: degree,
                degree_topic: degree_topic,
                area_of_concentration: area_of_concentration,
              )
            ]
          ]
        ]

        #v(1fr)

        // Advisors
        #align(start)[
          #set par(first-line-indent: 0pt)
          #print_advisors(advisors: advisors)
        ]

        #v(1fr)

        // Publishing information
        #address
        #linebreak()
        #year
      ]
    ],
  )
}
