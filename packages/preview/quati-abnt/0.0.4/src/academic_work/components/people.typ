// # People. Pessoas.

#let print_person(
  person: (
    first_name: "Fulano",
    middle_name: none,
    last_name: "Fonseca",
    gender: "m",
  ),
  last_name_first: false,
) = {
  if last_name_first {
    person.last_name + ", "
    person.first_name
    if person.middle_name != none {
      sym.space + person.middle_name
    }
  } else {
    person.first_name + sym.space
    if person.middle_name != none {
      person.middle_name + sym.space
    }
    person.last_name
  }
}

#let print_people(
  people: (),
  joiner: ", ",
) = {
  (
    people
      .map(person => print_person(
        person: person,
        last_name_first: false,
      ))
      .join(joiner)
  )
}
