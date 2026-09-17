// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// The deck: the document-level show rule that gives every slide of a document its shape.
//
//     #show: animo.with(width: 16cm, height: 9cm)
//
// The deck's tempo is three arguments here as well, because the runtime reads a custom
// property and an author writes typst.
//
// A show rule rather than a call, because it receives the whole document, so it can carry
// the HTML shell and the stylesheet in the HTML target and leave the paged targets alone.
// The shape reaches the slides through a state rather than through an argument,
// because the slides are already content by the time the rule runs.

#import "anim.typ": check-seconds
#import "runtime.typ": pt-of
#import "site.typ": describe

// The shape a deck has when its show rule is not told otherwise.
// Stated once, because the show rule's own arguments default to it as well.
#let deck-defaults = (width: 16cm, height: 9cm, margin: 1cm)

// The shape of the deck, as a dictionary with `width`, `height` and `margin`.
// A document without the show rule still has slides, and they take these defaults.
#let deck-shape = state("animo-deck", deck-defaults)

// Which paged output is being compiled.
//
// The HTML target is detected with `target()`; the paged modes are selected explicitly
// with `--input animo=presentation`, and default to the handout.
#let paged-mode() = {
  let mode = sys.inputs.at("animo", default: "handout")
  assert(
    mode in ("handout", "presentation"),
    message: "--input animo= takes `handout` or `presentation`, got "
      + repr(mode),
  )
  mode
}

// What the handout holds, as `slides` and the `pages` they asked for.
//
// A slide knows its own states, so it knows what it contributes, but a handout with no
// pages at all is a property of the whole deck and only the deck can see it.
// The two numbers are kept apart because a document with no slides is an empty document
// rather than a handout whose every page was turned down.
#let handout-tally = state("animo-handout", (slides: 0, pages: 0))

// Refuse a handout that holds no page at all.
//
// `handout:` is the only thing that says what a handout holds, so a deck whose every state
// turned its page down would produce a handout with no content.
// Typst does not refuse such a document and emits one blank page of its own default size,
// which looks like a rendering failure rather than like the flag doing what it was told
// (measured on typst 0.15.1; see *Findings*).
//
// This runs in a context block of its own that emits nothing, so a panic here empties no
// slide and leaves nothing for the next introspection pass to disagree about.
//
// Must be called in a context.
#let check-handout-pages() = {
  let tally = handout-tally.final()
  assert(
    tally.slides == 0 or tally.pages > 0,
    message: "every state of this deck gave up its handout page, so the handout holds "
      + "no page at all; handout: is the only thing that says what a handout holds, "
      + "so let at least one state keep its page with sub(handout: true) or "
      + "slide(handout: true)",
  )
}

// The timing functions a deck may name, as the CSS keywords they already are.
//
// A list rather than any string the author writes.
// An easing the browser rejects throws when the first step runs, which happens during the
// presentation, so the name is checked at compile time.
#let easings = ("linear", "ease", "ease-in", "ease-out", "ease-in-out")

// One of the deck's durations as the CSS time it becomes.
//
// `which` names the argument in the diagnosis, and the rule is the one every other time an
// author writes follows, so `primitive-duration: -1` and `delay: -1` are refused in the same
// words.
// Seconds are the author's unit everywhere in animo; the `s` is added here because a
// custom property read as a CSS `<time>` carries a unit and a bare number is not one.
// The digits are cut for the same reason `pt-of` cuts them.
#let css-seconds(which, value) = {
  let seconds = check-seconds("animo", which, value)
  str(calc.round(seconds, digits: 4)) + "s"
}

// The deck's tempo as the CSS values it becomes, checked as it is stated.
#let deck-timing(primitive-duration, transition-duration, easing) = {
  assert(
    easing in easings,
    message: "animo takes easing as one of "
      + easings.map(repr).join(", ")
      + ", got "
      + describe(easing),
  )
  (
    primitive-duration: css-seconds("primitive-duration", primitive-duration),
    transition-duration: css-seconds(
      "transition-duration",
      transition-duration,
    ),
    easing: easing,
  )
}

// A CSS colour for a typst colour.
#let css-color(value) = value.to-hex()

// A length as a bare number of typst points, written as `pt-of` rounds it.
#let pt-number(value) = str(pt-of(value))

// A length as a CSS length that covers that many typst points at any window size.
//
// `--animo-unit` is one typst point as the window currently renders it, so every length
// animo emits is that unit times a number and never one length divided by another.
// Chromium computes `calc(<length> / <length>)` to a number and firefox 153 does not,
// dropping the whole declaration, so animo does not use that form. See *Findings*.
#let unit-length(value) = "calc(var(--animo-unit) * " + pt-number(value) + ")"

// The custom properties a deck writes for itself: its geometry, and its tempo.
//
// The viewport is the slide's visible box, as large as the window allows at the deck's
// aspect ratio, and `--animo-unit` is that width divided by the slide width in points:
// one typst point, as a CSS length, at whatever size the window currently has.
// Dividing a length by a *number* is arithmetic every engine supports, so this resolves the
// pt of a frame against the px of a window without the runtime having to measure anything or
// listen for a resize.
//
// The three times are here rather than in `animo.css` because they differ per deck and the
// file is shared by every deck. The runtime reads them at every step.
#let properties(shape, timing) = {
  let aspect = shape.width.to-absolute() / shape.height.to-absolute()
  (
    "--animo-aspect": str(calc.round(aspect, digits: 6)),
    "--animo-viewport": "min(100vw, 100vh * " + str(aspect) + ")",
    "--animo-unit": "calc(var(--animo-viewport) / "
      + pt-number(shape.width)
      + ")",
    "--animo-primitive-duration": timing.primitive-duration,
    "--animo-transition-duration": timing.transition-duration,
    "--animo-easing": timing.easing,
  )
}

// The stylesheet of one deck: the static rules, followed by the deck's own answers.
//
// The reduced-motion query wins by the `!important` it carries rather than by source order,
// because this block comes after it. See `animo.css`.
#let stylesheet(shape, timing) = {
  let declarations = properties(shape, timing)
    .pairs()
    .map(((name, value)) => "  " + name + ": " + value + ";")
    .join("\n")
  read("animo.css") + "\n:root {\n" + declarations + "\n}\n"
}

// The HTML page a deck becomes: the stylesheet, the runtime and one container for the slides.
#let html-shell(shape, timing, body) = html.html({
  html.head({
    html.meta(charset: "utf-8")
    html.elem("meta", attrs: (
      name: "viewport",
      content: "width=device-width, initial-scale=1",
    ))
    html.elem("style", stylesheet(shape, timing))
    // A module script is deferred by default, so the runtime finds the slides in place.
    html.elem("script", attrs: (type: "module"), read("animo.js"))
  })
  html.body(html.elem("div", attrs: (class: "animo-deck"), body))
})

#let animo(
  body,
  width: deck-defaults.width,
  height: deck-defaults.height,
  margin: deck-defaults.margin,
  primitive-duration: 0.4,
  transition-duration: 0.4,
  easing: "ease-in-out",
) = {
  assert(
    margin * 2 < width and margin * 2 < height,
    message: "the margin leaves no room for the body of a slide",
  )
  let shape = (width: width, height: height, margin: margin)
  // Checked in every target, although only the HTML one has a clock to measure it on,
  // so that a deck that compiles to a PDF compiles to a presentation as well.
  let timing = deck-timing(primitive-duration, transition-duration, easing)
  context {
    if target() == "html" {
      html-shell(shape, timing, {
        deck-shape.update(shape)
        body
      })
    } else {
      deck-shape.update(shape)
      body
      // After the slides, because it counts what they contributed.
      if paged-mode() == "handout" {
        context check-handout-pages()
      }
    }
  }
}
