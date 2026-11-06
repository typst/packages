#import "../component/title.typ": (
  approved-and-agreed-fields,
  detailed-sign-field,
  per-line,
)
#import "../utils.typ": fetch-field, sign-field

#let arguments(..args, year: auto) = {
  let args = args.named()
  args.organization = fetch-field(
    args.at("organization", default: none),
    ("*full", "short"),
    hint: "организации",
  )
  args.approved-by = fetch-field(
    args.at("approved-by", default: none),
    ("name*", "position*", "year"),
    default: (year: auto),
    hint: "согласования",
  )
  args.agreed-by = fetch-field(
    args.at("agreed-by", default: none),
    ("name*", "position*", "year"),
    default: (year: auto),
    hint: "утверждения",
  )
  args.stage = fetch-field(
    args.at("stage", default: none),
    ("type*", "num"),
    hint: "этапа",
  )
  args.manager = fetch-field(
    args.at("manager", default: none),
    ("position*", "name*", "title"),
    default: (title: "Руководитель НИР,"),
    hint: "руководителя",
  )

  if args.approved-by.year == auto {
    args.approved-by.year = year
  }
  if args.agreed-by.year == auto {
    args.agreed-by.year = year
  }
  return args
}

#let template(
  ministry: none,
  organization: (full: none, short: none),
  udk: none,
  research-number: none,
  report-number: none,
  approved-by: (name: none, position: none, year: auto),
  agreed-by: (name: none, position: none, year: none),
  report-type: "Отчёт",
  about: none,
  bare-subject: false,
  research: none,
  subject: none,
  part: none,
  stage: none,
  federal: none,
  manager: (position: none, name: none, title: none),
  performer: none,
) = {
  per-line(
    force-indent: true,
    ministry,
    (value: upper(organization.full), when-present: organization.full),
    (value: upper[(#organization.short)], when-present: organization.short),
  )

  per-line(
    force-indent: true,
    align: left,
    (value: [УДК: #udk], when-present: udk),
    (value: [Рег. №: #research-number], when-present: research-number),
    (value: [Рег. № ИКРБС: #report-number], when-present: report-number),
  )

  approved-and-agreed-fields(approved-by, agreed-by)

  per-line(
    align: center,
    indent: 2fr,
    (value: upper(report-type), when-present: report-type),
    (value: upper(about), when-present: about),
    (value: research, when-present: research),
    (value: [по теме:], when-rule: not bare-subject),
    (value: upper(subject), when-present: subject),
    (
      value: [(#stage.type)],
      when-rule: (stage.type != none and stage.num == none),
    ),
    (
      value: [(#stage.type, этап #stage.num)],
      when-present: (stage.type, stage.num),
    ),
    (value: [\ Книга #part], when-present: part),
    (federal),
  )

  if manager.name != none {
    let title = if type(manager.title) == str and manager.title != "" {
      manager.title + linebreak()
    } else {
      none
    }
    sign-field(manager.at("name"), [#title #manager.at("position")])
  }

  if performer != none {
    let title = if type(performer.title) == str and manager.title != "" {
      performer.title + linebreak()
    } else {
      none
    }
    sign-field(
      performer.at("name", default: none),
      [#title #performer.at("position", default: none)],
      part: performer.at("part", default: none),
    )
  }

  v(0.5fr)
}
