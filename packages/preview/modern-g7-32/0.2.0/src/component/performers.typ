#import "headings.typ": structural-heading-titles
#import "../utils.typ": fetch-field, sign-field

// TODO: Доработать логику работы с исполнителями
// TODO: Запретить организацию для одного исполнителя

#let fetch-performers(performers) = {
  let performers-args = (
    "name*",
    "position*",
    "co-performer",
    "part",
    "organization",
    "title", // Только для одного исполнителя
  )
  if type(performers) == array {
    let current-organization = none
    let result = ()
    for (i, performer) in performers.enumerate() {
      if type(performer) == str {
        current-organization = performer
        continue
      } else {
        if (
          type(performer) == dictionary
            and performers.len() > 1
            and performer.at("title", default: none) != none
        ) {
          panic("Если исполнителей несколько, заголовок не требуется")
        }
      }
      let performer = fetch-field(
        performer,
        performers-args,
        default: (
          co-performer: false,
          title: "Исполнитель НИР,",
        ),
        hint: "исполнителя №" + str(i + 1),
      )
      performer.organization = current-organization
      result.push(performer)
    }
    return result
  } else if type(performers) == dictionary {
    let performer = fetch-field(
      performers,
      performers-args,
      default: (
        co-performer: false,
        title: "Исполнитель НИР,",
      ),
      hint: "исполнителя",
    )
    return (performer,)
  } else {
    panic("Некорректный тип поля исполнителей")
  }
}

#let group-organizations(performers) = {
  set par(spacing: 0.5em)
  let organizations = performers
    .map(performer => performer.organization)
    .dedup()
    .filter(org => org != none)
  let organizations-with-performers = organizations
    .map(organization => (
      organization,
      performers.filter(performer => performer.organization == organization),
    ))
    .to-dict()
  let without-organization = performers.filter(performer => (
    performer.organization == none
  ))
  for performer in without-organization {
    [#sign-field(performer.name, performer.position, part: performer.part)]
  }
  for (organization, performers) in organizations-with-performers.pairs() {
    [#block([#organization:])]
    for performer in performers {
      sign-field(performer.name, performer.position, part: performer.part)
    }
  }
}

#let performers-page(performers) = {
  heading(structural-heading-titles.performers, outlined: false)

  let not-co-performers = performers.filter(performer => (
    performer.co-performer == false
  ))
  let co-performers = performers.filter(performer => (
    performer.co-performer == true
  ))

  group-organizations(not-co-performers)

  let contains-co-performers = performers.any(performer => (
    if "co-performer" in performer.keys() and performer.co-performer != none {
      performer.co-performer
    } else {
      false
    }
  ))

  if contains-co-performers {
    block[Соисполнители:]
    group-organizations(co-performers)
  }
}
