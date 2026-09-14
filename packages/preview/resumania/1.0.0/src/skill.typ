// These are the Resumania data structures and functions for organizing and
// creating skill sections.
//
// Here is a usage example:
// ```typst
// #let skills = skills-section(
//   skillset("No Skills", "Can't Teleport", "Unable to Fly"),
//   skillset("All Skills", "Super-strength", "Invulnerable", "Omni-immune"),
// )
//
// #show-section(skills)
// ```
// -----------------------------------------------------------------------------

#import "debug.typ": *
#import "section.typ": section
#import "style.typ"

// The separator between skills in a skillset. This may be customized by
// changing its value to something else. For example `[ | ]` would result in
// skills being separated with the pipe ("|") character.
#let skill-separator = state("resumania:skill:skill-separator", [, ])


// Create a set of skills belonging to some category.
//
// = Parameters
// - `category`: `str` | `content`
//     The category that describes the set of skills.
// - `skills`: `str` | `content`
//     The set of skills belonging to the category. As this is an argument sink,
//     named and unnamed arguments will be treated slightly differently; that
//     is, any named argument will be prepended to the list of skills and any
//     unnamed argument will be appended. The named argument *names* will be
//     simply ignored.
#let skillset(category, ..skills) = {
  return (category: category, skills: skills.named().values() + skills.pos())
}


// Turn a skillset into content.
//
// The skillset will be formatted by the category, followed by a colon, followed
// by a comma-separated list of the skills in the set.
//
// = Parameters
// - `skillset`: `dictionary`
//     The skillset to show; it should be a dictionary formatted like the one
//     returned from `skillset`.
#let show-skillset(skillset) = {
  let result = none

  let header = style.element(skillset.category +  sym.colon + sym.space)

  let skills = context skillset.skills.join(skill-separator.get())

  result += box(style.header(header))
  result += box(style.body(skills))

  return result
}

// A convenience function to gather a list of skillsets together that can be
// displayed as a section in the resume.
//
// = Parameters
// - `title`: `str` | `content` | `none`
//     The title to display for the skills section.
// - `skillsets`: `arguments`
//     Skillsets should be dictionaries formatted like the ones returned from
//     `skillset` such that it can be used in `show-skillset`. Arguments may be
//     named or not; in either case they are appended in the order in which they
//     were passed, with the named skillsets first.
#let skills-section(title: [Skills], ..skillsets) = {
  return section(title, show-skillset, ..skillsets)
}
