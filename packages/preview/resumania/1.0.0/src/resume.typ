// This is the main entry into the Resumania resume builder.
//
// Along with the main `resume` template function, there is also a `state`
// provided that can be used to change/alter/add other set and show rules to the
// document. Because of the way Typst handles these rules, they can't simply be
// used in the main document after showing the resume since they wouldn't be
// applied to the custom building blocks (a consequence of the design of this
// builder).
//
// As such, the state can instead be updated prior to showing the resume resume
// with a function that behaves similarly to `default-rules` (in theory, it
// could also be used to add other content as well, but that is left up to the
// user to decide if/how to use such power).
//
// Here is an example of how to expand on the default rules:
// ```typst
// // Change the rules to use a monospace font instead of the default Open Sans.
// #let custom-rules(author, result) = {
//   return default-rules(
//     author,
//     [
//       #set text(font: "Liberation Mono", lang: "en", size: 10pt)
//       #result
//     ],
//   )
// }
//
// #resume-rules.update(
// // A function is required here because of the way `update` treats function
// // arguments (which includes updating to `custom-rules`).
//   original => { custom-rules }
// )
// ```
// -----------------------------------------------------------------------------

#import "style.typ": name
#import "section.typ": show-section

// The default set/show rules to apply to the resume.
#let default-rules(author, body) = {
  set document(author: author, title: "Resume")
  set page(margin: (left: 10mm, right: 10mm, top: 10mm, bottom: 10mm))
  set text(font: "Open Sans", lang: "en", size: 10pt)

  // Supposedly ligatures can cause issues with resume parsers:
  //   https://github.com/stuxf/basic-typst-resume-template/blob/8dbfb4bfa2135a3cafde41a6d370a48b04575d73/src/resume.typ#L34
  set text(ligatures: false)

  set block(spacing: 10pt)

  body
}

// The set/show rules to apply to the resume when showing it. This may be
// changed at will, but should happen *prior* to showing the resume with
// `resume` in order for them to take effect.
#let resume-rules = state("resumania:resume:resume-rules", default-rules)

// This is a convenience function for updating the `resume-rules` state with a
// new rules function.
//
// The only parameter, `new-rules`, should be a function with a compatible
// signature to `default-rules`.
#let update-resume-rules(new-rules) = {
  resume-rules.update(original => { new-rules })
}

// Create a resume from the provided building blocks.
//
// The `sections` argument should be a list of sections that can be given to
// `show-section` for displaying in the resume. The argument `author` should be
// the name of the person whose resume is being built.
//
// If horizontal lines are desired between sections, the `lines` argument may be
// set to `true`.
#let resume(
  author,
  sections: (),
  lines: false,
  body,
) = {
  let separator = if lines {line(length: 100%, stroke: 1pt)} else {none}

  let everything = (
    name(author)
  + sections.map(show-section).intersperse(separator).sum(default: [])
  + body
  )

  context resume-rules.get()(author, everything)
}
