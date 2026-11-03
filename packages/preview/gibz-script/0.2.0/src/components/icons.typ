#import "../colors.typ": gibz-blue

// Inline brand icons (e.g. Moodle, Script) for referencing related
// resources in prose. Icon-only by default; optionally paired with a label
// and/or wrapped in a link.
//
// `label-content` is taken positionally (not as a `text:` named param) so it
// doesn't shadow the built-in `text()` function, which is needed below.
#let _icon-link(path, label-content, target: none) = {
  let icon = box(height: 1em, baseline: 0.2em, image(path))
  let content = if label-content != none {
    [#icon #h(0.3em) #label-content]
  } else {
    icon
  }

  if target != none {
    // The document's global `show link` rule also appends an external-link
    // arrow for http(s) targets; skip just that part here since the brand
    // icon already signals "this points to an external resource" — but
    // keep the blue link color (text() doesn't tint the image, only text).
    show link: it => text(fill: gibz-blue, it.body)
    link(target, content)
  } else {
    content
  }
}

#let icon-moodle(text: none, target: none) = _icon-link("../../icons/moodle.svg", text, target: target)
#let icon-script(text: none, target: none) = _icon-link("../../icons/script.svg", text, target: target)
#let icon-exercise(text: none, target: none) = _icon-link("../../icons/exercise.svg", text, target: target)
