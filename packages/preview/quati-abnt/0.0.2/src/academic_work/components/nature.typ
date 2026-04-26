// # Nature of the work. Natureza do trabalho.
// NBR 14724:2024 4.2.1.1.1, NBR 14724:2024 4.2.1.3

#import "../../common/util/gender.typ": get_gender_ending
#import "../../common/util/text.typ": capitalize_first_letter

#let print_nature(
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
  organization: {
    (
      name: "Nome da organização",
      gender: "masculine",
    )
  },
  program: {
    (
      name: "Nome do programa",
      gender: "masculine",
    )
  },
  type_of_work: {
    (
      name: "trabalho de conclusão de curso",
      gender: "masculine",
    )
  },
  degree: {
    (
      name: "bacharelado",
      title: (
        masculine: "bacharel",
        feminine: "bacharela",
      ),
    )
  },
  degree_topic: { "Tema do trabalho" },
  area_of_concentration: {
    // "Área de concentração"
  },
) = {
  let gender_ending_of_type_of_work = get_gender_ending(type_of_work.gender)

  let preposition_of_program = "à"
  if program.gender == "masculine" {
    preposition_of_program = "ao"
  }

  let degree_title = degree.title.feminine
  for author in authors {
    if author.gender == "masculine" {
      degree_title = degree.title.masculine
      break
    }
  }

  [
    #capitalize_first_letter(type_of_work.name)
    apresentad#gender_ending_of_type_of_work
    #preposition_of_program
    #program.name
    d#get_gender_ending(organization.gender)
    #organization.name
    como requisito parcial
    à obtenção do título de
    #capitalize_first_letter(degree_title) em
    #degree_topic.
    #if area_of_concentration != none [
      Área de concentração: #area_of_concentration.
    ]
  ]
}
