// These are the Resumania data structures and functions for organizing and
// creating sections of projects for a resume.
//
// Here is a usage example:
// ```typst
// #let hello-world = project(
//   title: "Hello World",
//   location: "Earth",
//   timeframe: (
//     start: datetime(year: 2042, month: 01, day: 01),
//     end:   datetime(year: 2042, month: 01, day: 02),
//   ),
// )[
// - I wrote "Hello, World!" in `typst` and produced a PDF file greeting the
//     whole world.
// ]
//
// #let projects = project-section(hello-world)
//
// #show-section(projects)
// ```
// -----------------------------------------------------------------------------

#import "debug.typ": *
#import "section.typ": section
#import "style.typ"
#import "timeframe.typ": show-timeframe

// Define a project.
//
// = Parameters
// - `title`: `str` | `content` | `none`
//     The title of the project.
// - `location`: `str` | `content` | `none`
//     The location where the project was completed. It can be anything from a
//     state, province, prefecture, school, a full address, or any description
//     of the location. If the project wasn't completed as part of an
//     organization and was personal, this field can be instead listed as
//     `"Personal"` or just left empty.
// - `timeframe`: `datetime` | `dictionary` | `array` | `any`
//     The timeframe in which the project was completed. It may be any valid
//     data type that can be passed to `show-timeframe`.
// - `body`: `content`
//     The content to provide when showing the project in the resume. This is
//     typically a bulleted list of information about the project, but it may
//     also be any content that adequately describes the project.
//
// = Notes
// - If the project was completed during a standard period of time (e.g. a
//   given semester of school), `end` can be left as `none` while passing
//   `start` as `content` or `str` (for example, `"Spring 2042"`).
#let project(title: none, location: none, timeframe: none,  body) = {
  return (title: title, location: location, timeframe: timeframe, body: body)
}


// Turn a project into content.
//
// The project will be formatted as follows:
//
//   `title`{ --- }`location` ... `start`{--}`end`
//
//   `body`
//
// Where anything in "{}" will be inserted depending on whether both of the
// fields adjacent to it exist. The exception is that the en-dash between the
// start and end dates will be inserted even if only one of the fields exists.
// Everything left of the "..." will be left-aligned, and everything right of it
// will be right-aligned.
//
// = Parameters
// - `project`: `dictionary`
//     The project to show; it should be a dictionary formatted like the one
//     returned from `project`.
#let show-project(project) = {
  let result = none

  let (title, location, timeframe, body) = project

  title = style.element(title)

  let header = none

  header += title

  if header != none and location != none {
    header += [ --- ]
  }

  header += style.location(location)

  let timeframe-content = show-timeframe(timeframe)

  if timeframe-content != none {
    header += h(1fr)
  }

  header += style.timeframe(timeframe-content)

  result += style.header(header)
  result += style.body(body)

  return result
}


// A convenience function to gather a list of projects together that can be
// displayed as a section in the resume.
//
// = Parameters
// - `title`: `str` | `content` | `none`
//     The title to display for the project section.
// - `projects`: `arguments`
//     Projects should be dictionaries formatted like the ones returned from
//     `project` such that it can be used in `show-project`. Arguments may be
//     named or not; in either case they are appended in the order in which they
//     were passed, with the named projects first.
#let project-section(title: [Projects], ..projects) = {
  return section(
    title,
    show-project,
    ..projects,
  )
}
