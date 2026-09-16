// # Approval page. Folha de aprovação.
// NBR 14724:2024 4.2.1.3, NBR 14724:2024 5.2.4

#import "../../../common/components/title.typ": print_title
#import "../../../common/style/style.typ": (
  font_family_sans, font_size_for_smaller_text, simple_leading_for_smaller_text, simple_spacing_for_smaller_text,
)
#import "../../../common/util/gender.typ": get_gender_ending
#import "../../components/examiner.typ": print_examiner
#import "../../components/heading.typ": not_start_on_new_page
#import "../../components/nature.typ": print_nature
#import "../../components/page.typ": consider_only_odd_pages, not_number_page
#import "../../components/people.typ": print_people
#import "../../util/advisors.typ": get_advisor_role

#let include_approval_page(
  authors: {
    (
      (
        first_name: "Fulano",
        middle_name: none,
        last_name: "Fonseca",
        gender: "masculine",
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
      gender: "masculine",
    )
  },
  program: {
    // (
    //   name: "Nome do programa",
    //   gender: "masculine",
    // )
  },
  type_of_work: {
    (
      name: "trabalho de conclusão de curso",
      gender: "masculine",
    )
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
        gender: "feminine",
        prefix: {
          // "Profª Drª"
        },
        organization: (
          name: "Nome da organização",
          gender: "feminine",
        ),
      ),
    )
  },
  examination_committee: {
    (
      (
        first_name: "Beltrano",
        middle_name: none,
        last_name: "Borges",
        gender: "masculine",
        prefix: {
          "Prof. Dr."
        },
        organization: (
          name: "Nome da organização",
          gender: "feminine",
        ),
      ),
    )
  },
  address: { "Local" },
  year: { "Ano" },
  custom_nature: {
    "Natureza do trabalho."
  },
  approval_date: {
    (
      day: [dia],
      month: [mês por extenso],
      year: [ano],
    )
  },
) = context {
  not_number_page(
    not_start_on_new_page()[
      #page()[
        // Approval page should not have title or numbering.
        #set align(center)
        #set text(
          font: font_family_sans,
        )

        // Authors
        #strong[
          #print_people(
            people: authors,
          )
        ]

        #v(0.25fr)

        // Title
        #print_title(
          title: title,
          subtitle: subtitle,
          with_weight: true,
        )

        #if volume_number != none [
          Volume #volume_number
          #parbreak()
        ]

        #v(0.25fr)

        #align(end)[
          #box(width: 50%)[
            #set align(start)
            #set text(
              size: font_size_for_smaller_text,
            )
            #set par(
              leading: simple_leading_for_smaller_text,
              spacing: simple_spacing_for_smaller_text,
            )
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

        #v(0.25fr)

        #align(start)[
          #set par(first-line-indent: 0pt)
          Aprovad#get_gender_ending(type_of_work.gender) em
          #approval_date.day
          de #approval_date.month
          de #approval_date.year
        ]

        #v(0.25fr)

        // Examination committee
        #text(weight: "bold")[
          #upper[Banca examinadora]
        ]

        #let is_first_advisor = true
        #for advisor in advisors {
          print_examiner(examiner: advisor, role: get_advisor_role(
            gender: advisor.gender,
            is_co_advisor: not is_first_advisor,
          ))
          is_first_advisor = false
        }
        #for examiner in examination_committee {
          print_examiner(
            examiner: examiner,
            role: none,
          )
        }
      ]

      #if not consider_only_odd_pages.get() {
        pagebreak(weak: true, to: "odd")
      }
    ],
  )
}
