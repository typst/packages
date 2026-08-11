// # Examiner Signature. Assinatura do examinador.
// NBR 14724:2024 4.2.1.3

#import "../../common/style/style.typ": leading_for_common_text
#import "../../common/util/text.typ": capitalize_first_letter
#import "../components/people.typ": print_person

#let print_examiner(
  examiner: (
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
  role: {
    "orientador"
  },
) = {
  block(
    above: 1.5cm,
  )[
    #block(below: leading_for_common_text)[
      #line(length: 100%)
    ]
    #par()[
      #examiner.prefix
      #print_person(person: examiner)
      #if role != none [
        #sym.dash.en
        #capitalize_first_letter(role)
      ]
      #linebreak()
      #examiner.organization.name
    ]
  ]
}
