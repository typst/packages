#import "./basic.typ": template as base-template

/// Template for homework
///
/// - lang (str): language identifier used in `set text(lang: lang)`
/// - use-patch (bool | (list?: bool, enum?: bool)):
///   whether to use the patch for list and/or enum, default enabled when
///   ignored
/// - course (str): course name
/// - number (int): homework number
/// - transform-title (auto | (course: str, number: int) -> str):
///   title transformation function, default to `auto`, which generates the
///   title as `"{course}{hw-literal} {number}"` where `hw-literal` is
///   " Homework" in English and "作业" in Chinese
/// - student-infos (array[(name: str, id: str)]): list of student names and ids
/// - team-name (str | none): team name. When set to a string, the team name
//    will be displayed in the header. This is useful when there are multiple
//    students, since the header only handles the case that there is only one
//    student
/// - body (content): content
/// -> content
#let template(
  lang: "en",
  use-patch: true,
  course: "Course Name",
  number: 1,
  transform-title: auto,
  student-infos: ((name: "Student Name", id: "Student ID"),),
  team-name: none,
  body,
) = {
  let title = if transform-title == auto {
    (
      course
        + (
          en: " Homework",
          zh: "作业",
        ).at(lang)
        + " "
        + str(number)
    )
  } else { transform-title(course, number) }

  show: base-template.with(
    lang: lang,
    use-patch: use-patch,
    title: title,
    author-infos: student-infos,
    display-author-block: info => {
      info.name
      linebreak()
      info.id
    },
    display-author-header: if team-name == none {
      true
    } else { _ => text(team-name) },
  )

  body
}
