// These are the Resumania data structures and functions for organizing and
// creating sections of work experiences for a resume.
//
// Here is a usage example:
// ```typst
// #let lemonade-stand = work(
//   company:  "Lemonade Stand LLC",
//   location: "Sidewalk of 5th St.",
//   position: "Owner",
//   timeframe: (
//     start:    datetime(year: 2042, month: 01, day: 01),
//     end:      datetime(year: 2042, month: 01, day: 02),
//   ),
// )[
// - I ran a lemonade stand in my front yard for people in my neighborhood.
// ]
//
// #let works = work-section(lemonade-stand)
//
// #show-section(works)
// ```
// -----------------------------------------------------------------------------

#import "debug.typ": *
#import "section.typ": section
#import "style.typ"
#import "timeframe.typ": show-timeframe

// Define a work experience.
//
// = Parameters
// - `company`: `str` | `content` | `none`
//     The company where the work was performed.
// - `location`: `str` | `content` | `none`
//     The location where the company is located or where work was done. This
//     can just simply be an abbreviation for a state, province, prefecture,
//     etc., or a full address, or any description of the location.
// - `position`: `str` | `content` | `none`
//     The title of the position.
// - `timeframe`: `datetime` | `dictionary` | `array` | `any`
//     The timeframe in which the experience was completed. It may be any valid
//     data type that can be passed to `show-timeframe`.
// - `body`: `content`
//     The content to provide when showing the experience in the resume. This
//     can simply be a bulleted list of information describing what work was
//     performed, or it may be any content that satisfies describing the work
//     experience.
#let work(
  company: none,
  location: none,
  position: none,
  timeframe: none,
  body,
  ) = {
  return (
    company: company,
    location: location,
    position: position,
    timeframe: timeframe,
    body: body,
  )
}

// Turn a work experience into content.
//
// The work experience will be formatted as follows:
//
//   `position`{, }`company`{ --- }`location` ... `start`{--}`end`
//
//   `body`
//
// Where anything in "{}" will be inserted depending on whether both of the
// fields adjacent to it exist. The exception is that the en-dash between the
// start and end dates will be inserted even if only one of the fields exist.
// Everything left of the "..." will be left-aligned, and everything right of it
// will be right-aligned.
//
// = Parameters
// - `work`: `dictionary`
//     The experience to show; it should be a dictionary formatted like the one
//     returned from `work`.
#let show-work(work) = {
  let result = none

  let (company, location, position, timeframe, body) = work

  position = style.element(position)
  company = style.element(company)

  let header = none

  header += position

  if header != none and company != none {
    header += [, ]
  }
  header += company

  if header != none and location != none {
    header += [ --- ]
  }
  header += style.location(location)

  let timeframe-content = show-timeframe(timeframe)

  header += [#h(1fr) #style.timeframe(timeframe-content)]

  result += style.header(header)
  result += style.body(body)

  return result
}

// A convenience function to gather a list of work experiences together that can
// be displayed as a section in the resume.
//
// = Parameters
// - `title`: `str` | `content` | `none`
//     The title to display for the work section.
// - `works`: `arguments`
//     These should be dictionaries formatted like the ones returned from `work`
//     such that it can be used in `show-work`. Arguments may be named or not;
//     in either case they are appended in the order in which they were passed,
//     with the named experiences first.
#let work-section(title: [Work Experience], ..works) = {
  return section(
    title,
    show-work,
    ..works,
  )
}
