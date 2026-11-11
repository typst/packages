// Compilation of top-level Typst content into explicit and automatic slides.
#import "shared.typ": fail, typst-sequence, typst-space, typst-styled
#import "slide/command.typ": is-slide-command, slide-command
#import "slide/runtime.typ": render-slide

#let typst-context = (context []).func()

// Which heading depths open an automatic slide, and what each one opens.
//
// The default reads a deck the way its outline does: `=` starts a section,
// `==` starts a content slide, and anything deeper is ordinary content inside
// the current slide. A document with a different hierarchy (chapters at `=`,
// sections at `==`, slides at `===`) passes its own map instead, so the
// compiler is not the thing that decides what a heading level means.
// Keyed by the depth written as a string, because Typst dictionary keys are
// strings; `heading-role` below does the conversion in one place.
#let default-heading-policy = ("1": "section", "2": "slide")

#let validate-heading-policy(value) = {
  let name = "setup headings"
  if type(value) != dictionary {
    fail(
      name + " must be a dictionary mapping heading level to \"section\" or "
        + "\"slide\"",
    )
  }
  for (level, role) in value {
    // Checked as a canonical decimal spelling rather than through `int()`: a
    // non-numeric key would abort with a raw conversion error, and a
    // zero-padded key would never match the `str(level)` lookup in
    // `heading-role` below.
    if level.match(regex("^[1-9][0-9]*$")) == none {
      fail(
        name + " levels must be positive integers written without leading "
          + "zeros",
      )
    }
    if role not in ("section", "slide") {
      fail(name + " " + repr(level) + " must be \"section\" or \"slide\"")
    }
  }
  value
}

#let heading-role(policy, level) = if level == none {
  none
} else {
  policy.at(str(level), default: none)
}
#let is-heading-space(value) = (
  value == []
    or (
      type(value) == content
        and value.func() in (parbreak, typst-space)
    )
)

#let wrap-content(value, wrappers) = {
  for wrapper in wrappers.rev() {
    value = (wrapper.func)(value, wrapper.styles)
  }
  value
}

#let top-level-content(body, wrappers: (), path: ()) = if (
  type(body) == content and body.func() == typst-sequence
) {
  body.children.enumerate().map(((index, child)) => top-level-content(
    child,
    wrappers: wrappers,
    path: path + (index,),
  )).flatten()
} else if type(body) == content and body.func() == typst-styled {
  top-level-content(
    body.child,
    wrappers: wrappers + ((
      func: body.func(),
      styles: body.styles,
      // The tree position of the styled element this wrapper came from, so
      // two entries share a wrapper prefix only when they sit inside the very
      // same styled elements, not merely equally many.
      id: path,
    ),),
    path: path + (0,),
  )
} else {
  ((
    raw: body,
    shown: wrap-content(body, wrappers),
    wrappers: wrappers,
  ),)
}

#let wrapper-ids(wrappers) = wrappers.map(wrapper => wrapper.id)
// Automatic and explicit pages use the same layout-based slide command.
#let compile-deck(body, headings: default-heading-policy) = {
  let output = ()
  let mode = none
  let section = none
  let current = ()
  let flushed = none
  let slide-wrappers = ()

  // Automatic slides re-apply the user's captured set/show wrappers around
  // the rendered slide, exactly as explicit slide commands do, so deck-level
  // rules (including label-targeted cell rules) see the rendered cell
  // structure.
  let flush(mode, section, current, wrappers) = {
    if mode == "slide" {
      let body = current.sum(default: [])
      wrap-content(
        render-slide(slide-command(
          (),
          layout: "content",
          automatic: true,
          cells: (header: section, body: body),
        )),
        wrappers,
      )
    } else if mode == "section" {
      // Content between `=` and the next `==` is the section's tagline. It
      // reaches the configured section layout as its `subtitle` field, so an
      // automatic section slide looks exactly like the explicit
      // `m.layouts.section(subtitle: ...)` form and the heading keeps its
      // outline entry.
      let tagline = current.sum(default: none)
      wrap-content(
        render-slide(slide-command(
          (),
          layout: "section",
          automatic: true,
          cells: (section: section),
          fields: if tagline == none { (:) } else { (subtitle: tagline) },
        )),
        wrappers,
      )
    } else {
      none
    }
  }

  let flush-current(mode, section, current, wrappers) = (
    flush(mode, section, current, wrappers),
    none,
    none,
    (),
  )

  for entry in top-level-content(body) {
    let value = entry.raw
    let shown = entry.shown
    // Content collected into an automatic slide is re-styled by
    // the outer wrap in flush(); strip the slide-level wrapper prefix from
    // each piece so those styles are not applied twice (relative units such
    // as em sizes would compound). Only a genuine prefix is stripped — the
    // piece must sit inside the very styled elements that wrap the heading —
    // so a separately styled sibling keeps its own styles through `shown`.
    let inner = if (
      entry.wrappers.len() >= slide-wrappers.len()
        and wrapper-ids(entry.wrappers.slice(0, slide-wrappers.len()))
          == wrapper-ids(slide-wrappers)
    ) {
      wrap-content(value, entry.wrappers.slice(slide-wrappers.len()))
    } else {
      shown
    }
    let level = if (
      type(value) == content and value.func() == heading
    ) {
      // Markup headings carry `depth`; a heading constructed with
      // `heading(level: ..)` carries `level` instead, and reading the absent
      // field would abort with a raw Typst error. Anything non-numeric (an
      // explicit `level: auto`) falls back to the native default depth of 1.
      let fields = value.fields()
      let depth = fields.at("depth", default: fields.at("level", default: 1))
      if type(depth) == int { depth } else { 1 }
    } else {
      none
    }
    let role = heading-role(headings, level)

    if is-slide-command(value) {
      (flushed, mode, section, current) = flush-current(mode, section, current, slide-wrappers)
      if flushed != none { output.push(flushed) }
      output.push(wrap-content(
        render-slide(value.value),
        entry.wrappers,
      ))
    } else if role != none {
      (flushed, mode, section, current) = flush-current(mode, section, current, slide-wrappers)
      if flushed != none { output.push(flushed) }
      mode = role
      section = value
      current = ()
      slide-wrappers = entry.wrappers
    } else if is-heading-space(value) {
      // In section mode, spacing separates tagline paragraphs but must not
      // open the tagline with an empty block.
      if mode == "slide" or (mode == "section" and current.len() > 0) {
        current.push(inner)
      }
    } else if (
      mode == none
        and type(value) == content
        and value.func() in (metadata, typst-context)
    ) {
      output.push(shown)
    } else if mode in ("slide", "section") {
      current.push(inner)
    } else {
      // Name the levels the deck actually compiles on, which the heading
      // policy may have moved.
      fail(
        "content appears before the first heading handled by setup; expected "
          + "one of heading levels "
          + headings.keys().map(level => int(level)).sorted()
            .map(str).join(", "),
      )
    }
  }

  let flushed = flush(mode, section, current, slide-wrappers)
  if flushed != none { output.push(flushed) }
  output.sum(default: [])
}
