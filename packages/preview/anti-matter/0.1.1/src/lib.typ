#import "core.typ"
#import "rules.typ"

/// Mark the end of a part of your document, place this on the last page of your current part. This
/// must be put into the document exactly twice.
///
/// - label (label): the label to use for the fences
/// -> content
#let fence(label: <anti-matter:fence>) = [#metadata("anti-matter-fence") #label]

/// Set the numbering for the current part.
///
/// - numbering (str, function, none): the new numbering for the current part
/// -> content
#let set-numbering(numbering) = locate(loc => {
  import "util.typ"

  util.assert-pattern(numbering)

  let key = core.part(loc)
  let (_, idx) = core.select(key)
  core.numbering-state().update(value => {
    value.numbering.at(idx) = numbering
    value
  })
})

/// Returns and formats the page number for the given location.
///
/// If `passthrough` is `true` and `loc` is not `none`, then a dictionary is returned which contains
/// the current and last number, as well as whether the numbering was `none` at this location. If
/// the numbering was `none`, then the current number is from the last page with numbering.
///
/// - passthrough (bool): if `false` the page number is not formatted and instead the numbers are
///   returned directly
/// - loc (location, none): the location at which to get the numbers for
/// -> (content, array, none)
#let page-number(
  passthrough: false,
  loc: none,
) = {
  import "util.typ"

  util.maybe-locate(loc, loc => {
    let key = core.part(loc)
    let (counter, idx) = core.select(key)
  
    let at = counter.at(loc).last()
    let last = counter.final(loc).last()

    if passthrough {
      (current: at, last: last, at-none: num == none)
    } else {
      let num = core.numbering-state().at(loc).numbering.at(idx)
      if type(num) == function or (type(num) == str and util.cardinality(num) == 2) {
        numbering(num, at, last)
      } else if type(num) == str {
        numbering(num, at)
      }
    }
  })
}

/// Step the anti-matter counter for the current part.
///
/// -> content
#let step() = locate(loc => {
  let key = core.part(loc)
  let (counter, idx) = core.select(key)
  let num = core.numbering-state().at(loc).numbering.at(idx)
  if num != none { counter.step() }
})

/// A template function which applies the page numbering and a show rule for `outline.entry` to fix
/// its page numbering. If you need more granular control over outline entries and page headers see
/// the library documentation. This should be used as a show rule.
///
/// - header (content, none): the page header to display
/// - numbering (array): an array of numberings describing the numberings for each part of your
///   document, the numberings can be a `str`, `function` or `none`, functions receive the current
///   and final amount as arguments
/// - label (label): the label to use for document fences
/// - body (content): the content to render with anti-matter numbering
/// -> content
#let anti-matter(
  header: none,
  numbering: ("I", "1", "I"),
  label: <anti-matter:fence>,
  body,
) = {
  import "util.typ"

  assert.eq(numbering.len(), 3, message: util.oxifmt.strfmt(
    "Must have exactly 3 numberings, got {}",
    numbering.len(),
  ))

  for n in numbering {
    util.assert-pattern(n)
  }

  set page(
    header: step() + header,
    numbering: (..args) => page-number(),
  )

  show outline.entry: rules.outline-entry.with(func: loc => page-number(loc: loc))
  locate(loc => {
    let fences =  query(label, loc)
    assert.eq(fences.len(), 2, message: util.oxifmt.strfmt(
      "Must have exactly 2 fences, found {}, did you use `fence()` (`<{}>`) more than twice?",
      fences.len(),
      label,
    ))
  })

  // NOTE: for some reason the state needs a default even when it is set here,
  //       before any page is rendered
  core.numbering-state(label: label, numbering: numbering).update((
    label: label,
    numbering: numbering,
  ))
  body
}
