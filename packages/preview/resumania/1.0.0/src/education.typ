// These are the Resumania data structures and functions for organizing and
// creating sections of education for a resume, such as degrees earned from
// universities or certifications.
//
// Here is a usage example:
// ```typst
// #let free-degree = education(
//   institution: "Anonymous University",
//   location: "Nowhere",
//   kind: "PhD",
//   study: "Omniscience",
//   timeframe: datetime(year: 2042, month: 5, day: 1),
//   score: $infinity$,
//   scale: $infinity$,
// )
//
// #let educations = education-section(free-degree)
//
// #show-section(educations)
// ```
// -----------------------------------------------------------------------------

#import "debug.typ": *
#import "section.typ": section
#import "style.typ"
#import "timeframe.typ": show-timeframe

// Define a course of study, such as a degree earned at a university or a
// certification, etc.
//
// = Parameters
// - `institution`: `str` | `content` | `none`
//     The institution which bestowed the degree of study.
// - `location`: `str` | `content` | `none`
//     The location of the institution or where the education was received.
// - `kind`: `str` | `content` | `none`
//     The kind of education earned, typically `"B.S."`, `"M.A."`, etc.; though
//     any kind of education can probably be represented.
// - `study`: `str` | `content` | `none`
//     The area of study during the course of education, such as a major.
// - `timeframe`: `datetime` | `dictionary` | `array` | `any`
//     The timeframe in which the education was completed. It may be any valid
//     data type that can be passed to `show-timeframe`.
// - `score`: `str` | `content` | `float` | `none`
//     The overall score earned for the degree. Typically this is a GPA (Grade
//     Point Average) or some scoring system for grades throughout the course of
//     study.
// - `scale`: `str` | `content` | `float` | `none`
//     The scale with which to put the `score` in perspective. Often, for GPAs,
//     this is `4.0`.
#let education(
  institution: none,
  location: none,
  kind: none,
  study: none,
  timeframe: none,
  score: none,
  scale: none,
) = {
  return (
    institution: institution,
    location: location,
    kind: kind,
    study: study,
    timeframe: timeframe,
    score: score,
    scale: scale,
  )
}

// Turn an education into content.
//
// The education will be formatted as follows:
//
//   `institution`{ --- }`location`
//
//   `kind` `study`{ --- }`score`{/}`scale` ... `timeframe`
//
// Where anything in "{}" will be inserted depending on whether both of the
// fields adjacent to it exist. Everything left of the "..." will be
// left-aligned, and everything right of it will be right-aligned.
//
// = Parameters
// - `education`: `dictionary`
//     The education to show, which should be formatted like the one returned
//     from `education`.
//
// = Notes
// - If no score is provided, the scale will not be displayed even if it is
//   provided.
#let show-education(education) = {
  let result = none

  let (institution, location, kind, study, timeframe, score, scale) = education

  institution = style.element(institution)

  let timeframe-content = show-timeframe(timeframe)

  let header = none

  header += institution

  if header != none and location != none {
    header += [ --- ]
  }
  header += style.location(location)
  header += h(1fr) + style.timeframe(timeframe-content)

  let academic-content = none
  academic-content += kind + sym.space + study

  if academic-content != none and score != none {
    academic-content += [ --- #score]

    if scale != none {
      academic-content += [/#scale]
    }
  }

  result += style.header(header)
  result += style.body(list(academic-content))

  return debug-block(result)
}

// A convenience function to gather a list of educations together that can be
// displayed as a section in the resume.
//
// = Parameters
// - `title`: `str` | `content` | `none`
//     The title to display for the education section.
// - `educations`: `arguments`
//     Educations should be dictionaries formatted like the ones returned from
//     `education` such that it can be used in `show-education`. Arguments may
//     be named or not; in either case they are appended in the order in which
//     they were passed, with the named educations first.
#let education-section(title: [Education], ..educations) = {
  return section(
    title,
    show-education,
    ..educations,
  )
}
