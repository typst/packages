// # Advisors. Orientadores.

#import "../../common/util/text.typ": capitalize_first_letter
#import "../util/advisors.typ": get_advisor_role
#import "../components/people.typ": print_person

#let print_advisors = (
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
        organization: (
          name: "Nome da organização",
          gender: "f",
        ),
      ),
    )
  },
) => {
  let is_first_advisor = true
  for advisor in advisors {
    [
      #capitalize_first_letter(get_advisor_role(gender: advisor.gender, is_co_advisor: not is_first_advisor)):
      #advisor.prefix
      #print_person(person: advisor)
      #linebreak()
    ]
    is_first_advisor = false
  }
}
