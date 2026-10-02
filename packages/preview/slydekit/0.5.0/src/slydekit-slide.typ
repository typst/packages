#import "slydekit-defaults.typ": *
#import "slydekit-animation.typ": split-at-pause, split-at-meanwhile, analyze-max-step, resolve-nested-pauses, pauses-to-uncover-chain

// Slides
#let slide(..args, steps: none, label: none) = {
  // Extraction and analysis of the positional arguments: title and body. If no title is provided, the first argument is the body. If two arguments are provided, the first is the title and the second is the body.
  let pos = args.pos()
  let (title, body) = if pos.len() == 0 {
    (none, [])
  } else if pos.len() == 1 {
    // Case : #slide[...] (no title, the only argument is the content)
    (none, pos.at(0))
  } else {
    // Case : #slide("Title")[...] (2 arguments : title then content)
    (pos.at(0), pos.at(1))
  }


  // Invisible marker for slide-parser only, placed first thing at each call, before any state mutation below. This is distinct from <sk-slide> further down: this one's own location is irrelevant, it exists purely so slide-parser can detect "an explicit #slide(..) call starts here" and close off whatever heading-driven slide was still accumulating, before this call's state updates (title, slide index, subslide total...) can leak into that preceding slide's body. <sk-slide> below stays exactly where it was, right after the pagebreak, since mini-slides and progressive-outline rely on its page location to delimit slides.
  [#metadata(none)<sk-slide-parser-boundary>]

  if title != none and title != [] {
    sk-states.current-slide-title.update(title)

    let hidden = label == <hide-toc>
    sk-states.numbering-hidden.update(hidden)

    context if not hidden {
      counter(heading).step(level: sk-states.slide-level.get())
    }
  }

  // Resolve pauses/meanwhiles hidden behind a layout wrapper (#set align(center), #align(center)[..], etc.) into an internal uncover(from: ..) chain before any splitting below, so such a wrapper is only ever instantiated once (see resolve-nested-pauses in slydekit-animation.typ).
  body = resolve-nested-pauses(body)

  // A title-only slide has an empty body: `slide(it.body)[]` in non-parser mode, or a heading with no content in parser mode (chunks.join() is `none` for an empty array). resolve-nested-pauses also returns `none` when it recurses into an empty sequence. Normalize to `[]` so split-at-meanwhile / analyze-max-step below always get content.
  if body == none {
    body = []
  }

  // Split the body into parallel tracks at <sk-meanwhile> boundaries, then each track into chunks at <sk-pause> labels. With no <sk-meanwhile> at all, this is a single track equal to the previous flat chunk list, so existing slides are unaffected.
  let tracks = split-at-meanwhile(body).map(split-at-pause)

  // Compute the total number of steps requested by uncover/only and <sk-pause> labels
  let max-reveal-step = analyze-max-step(body)
  let max-track-length = calc.max(..tracks.map(t => t.len()))
  let total = calc.max(max-track-length, max-reveal-step)
  if steps != none {total = calc.max(total, steps)}

  pagebreak(weak: true)

  // Invisible marker, placed at each call, regardless of the title
  [#metadata(title)<sk-slide>]

  context {
    if sk-states.appendix.get() {
      sk-states.app-slide-number.step()
    } else {
      sk-states.slide-number.step()
    }
  }

  context {
    // Metadata to attach a label to the slide, if requested
    if label != none {
      [#metadata((kind: "slide"))#label]
    }

    // Native counters frozen at their value at the start of the slide.
    let number-targets = sk-states.frozen-counters.get()
    let saved-numbers = number-targets.map(c => c.get())
    let reset-numbers() = {
      for (c, val) in number-targets.zip(saved-numbers) {
        c.update(val)
      }
    }

    // Direct generation of the slide content, without subslides
    if sk-states.handout.get() {
      // Handout mode: a single page per slide, in its fully revealed state. Content gated on one exact step (only(2)[..], not uncover(from: 2)[..]) never appears here, since intermediate steps are never rendered. Each track is joined on its own: tracks is an array of arrays of chunks (one array per parallel track), so tracks.join() would try to join arrays together instead of content, this joins the chunks inside each track first.
      reset-numbers()
      sk-states.subslide-step.update(total)
      // Only one page exists in handout mode, so every subslide-label marker resolves unconditionally rather than needing an idx/i match.
      show metadata.where(label: <sk-subslide-label-request>): it => {
        [#metadata(none)#it.value.lbl]
      }
      for chunks in tracks {
        chunks.join()
      }
    } else {
      for i in range(1, total + 1) {
        // Reset before every substep, including the last one, without exception: making an exception for the last one would make it inherit the increment left by the penultimate one and double the progression on the page that is actually kept (verified).
        reset-numbers()

        sk-states.subslide-step.update(i)
        if i > 1 {
          pagebreak(weak: true)
        }

        for chunks in tracks {
          for (idx, chunk) in chunks.enumerate() {
            // A subslide-label marker inside this chunk resolves to its real label exactly once across the whole slide: on the first subslide (i) that reaches this chunk's own index (idx). idx and i are both already known synchronously here, no context needed for this part.
            let chunk-with-label = {
              show metadata.where(label: <sk-subslide-label-request>): it => {
                if idx + 1 == i {
                  [#metadata(none)#it.value.lbl]
                } else {
                  none
                }
              }
              chunk
            }

            if idx < i {
              chunk-with-label
            } else {
              hide(chunk-with-label)
            }
          }
        }
      }
    }
  }
}

// Helper functions for slide-parser
// Heading-driven slides
#let heading-slide(heading, body) = {
  if heading.has("child") and heading.has("styles") {
    return heading.func()(heading-slide(heading.child, body), heading.styles)
  }

  if heading.has("label") {
    slide(heading.body, body, label: heading.label)
  } else {
    slide(heading.body, body)
  }
}

#let flush-slide(heading, chunks) = {
  if heading != none {
    heading-slide(heading, chunks.join())
  } else if chunks.len() > 0 {
    chunks.join()
  } else {
    none
  }
}

// Helper function to flatten content and extract nested markers
#let flatten-sequence(body) = {
  if type(body) != content {
    return ()
  }
  if body.func() == [].func() {
    // If it's a sequence, we recursively flatten all its children into a flat array
    body.children.map(flatten-sequence).join()
  } else {
    (body,)
  }
}

// Wraps body with wrap's style, splitting only at <sk-slide-parser-boundary> (each side belongs to a different slide and needs its own style instance). Pauses/meanwhiles within a segment are folded into a single uncover(from: ..) chain via pauses-to-uncover-chain instead of being split into as many separate style instances, since re-instantiating a block-level style (e.g. #set align(center)) once per chunk would turn each chunk into its own independent layout block.
#let style-body-with-pauses-fn(wrap, body) = {
  let output = ()
  let current-body = ()

  for child in body {
    if child.has("label") and child.label == <sk-slide-parser-boundary> {
      if current-body.len() > 0 {
        output.push(wrap(pauses-to-uncover-chain(current-body.join())))
      }
      output.push(child)
      current-body = ()
    } else {
      current-body.push(child)
    }
  }

  if current-body.len() > 0 {
    output.push(wrap(pauses-to-uncover-chain(current-body.join())))
  }

  output.join()
}

#let style-body-with-pauses(style-wrapper, body) = style-body-with-pauses-fn(
  content => style-wrapper.func()(content, style-wrapper.styles),
  body,
)

// Peels off a chain of directly-nested style wrappers -- produced when several
// #set/#show rules appear one after another at the top of a block, each nesting
// the rest as its own child instead of being a sibling in a sequence -- down to
// the actual sequence they wrap, composing a single function that reapplies every
// layer, in the right order, around replacement content. `seq` is none when child
// isn't such a chain (e.g. its innermost body isn't a sequence at all).
#let unwrap-style-chain(node) = {
  if not (node.has("child") and node.has("styles")) {
    return (seq: none, wrap: body => body)
  }

  if node.child.func() == [].func() {
    (seq: node.child, wrap: body => node.func()(body, node.styles))
  } else {
    let inner = unwrap-style-chain(node.child)
    if inner.seq == none {
      (seq: none, wrap: body => body)
    } else {
      (seq: inner.seq, wrap: body => node.func()((inner.wrap)(body), node.styles))
    }
  }
}

#let expose-styled-headings(body, slide-level: 2) = {
  let children = if type(body) == array {
    body
  } else if type(body) == content and body.func() == [].func() {
    body.children
  } else {
    return body
  }

  let output = ()
  for child in children {
    if child.func() == [].func() {
      for nested in expose-styled-headings(child.children, slide-level: slide-level) {
        output.push(nested)
      }
    } else if child.has("child") and child.has("styles") and unwrap-style-chain(child).seq != none {
      let chain = unwrap-style-chain(child)
      let current-body = ()
      let nested-children = expose-styled-headings(chain.seq.children, slide-level: slide-level)
      for nested in nested-children {
        let is-heading = nested.func() == heading and nested.depth < slide-level
        let is-slide-boundary = nested.has("label") and (
          nested.label == <sk-slide-parser-boundary>
        )
        if is-heading or is-slide-boundary {
          if current-body.len() > 0 {
            output.push(style-body-with-pauses-fn(chain.wrap, current-body))
          }
          if is-heading {
            output.push((chain.wrap)(nested))
          } else {
            output.push(nested)
          }
          current-body = ()
        } else {
          current-body.push(nested)
        }
      }
      if current-body.len() > 0 {
        output.push(style-body-with-pauses-fn(chain.wrap, current-body))
      }
    } else {
      output.push(child)
    }
  }

  output
}

// Detects the invisible <sk-slide-parser-boundary> marker placed at the very start of every explicit #slide(..) call, before any state mutation. Distinct from <sk-slide> (used by mini-slides/progressive-outline for page-based slide counting), which stays after the pagebreak and is passed through untouched once this boundary has been detected.
#let is-slide-marker(child) = (
  child.func() == metadata and child.has("label") and child.label == <sk-slide-parser-boundary>
)

#let unstyled-heading(child) = {
  if child.func() == heading {
    child
  } else if child.has("child") and child.has("styles") {
    unstyled-heading(child.child)
  } else {
    none
  }
}

// Slide parser - This function aims to encapsulate the document's body into a sequence of slides to allow the user to write a document in a natural way, without having to explicitly call #slide(..) for every slide.

// True for nodes that only contribute whitespace between block-level elements (the empty paragraph Typst inserts for a blank line, or a stray space). Used to look past them when deciding whether the whole body is a single style wrapper.
#let is-blank-node(node) = {
  let f = node.func()
  f == parbreak or f == [ ].func() or (node.has("text") and node.text.trim() == "")
}

#let slide-parser(body, slide-level: 2) = {
  // Whole-document style wrapper: a top-level #set/#show rule placed right after `#show: slydekit.with(..)` makes Typst hand the entire remaining document to this function as a single styled element -- on its own when the rule sits on the line just below the show rule, or preceded by an empty paragraph when a blank line separates them. Recurse into the wrapper's child and re-wrap the parsed result so the rule applies globally, across every slide. This is safe precisely because the wrapper spans the whole body -- every slide boundary sits inside it, so re-wrapping the finished slide sequence keeps the structure intact. It is distinct from a style wrapper around a mid-slide chunk (handled by expose-styled-headings / resolve-nested-pauses), which must stay inside its slide so pauses can still split it.
  let flat = flatten-sequence(body)
  let lead = flat.filter(n => is-blank-node(n))
  let rest = flat.filter(n => not is-blank-node(n))
  if rest.len() == 1 and rest.at(0).has("child") and rest.at(0).has("styles") {
    let wrapper = rest.at(0)
    return lead.join() + wrapper.func()(
      slide-parser(wrapper.child, slide-level: slide-level),
      wrapper.styles,
    )
  }

  let children = expose-styled-headings(flat, slide-level: slide-level)

  let current-heading = none
  let current-body = ()
  let output = ()

  let in-explicit-slide = false

  for child in children {
    if child.func() == heading and child.depth <= slide-level {
      let flushed = flush-slide(current-heading, current-body)

      if flushed != none {
        output.push(flushed)
      }

      current-body = ()
      in-explicit-slide = false

      if child.depth == slide-level {
        current-heading = child
      } else {
        current-heading = none
        output.push(child)
      }

    } else if is-slide-marker(child) {
      let flushed = flush-slide(current-heading, current-body)

      if flushed != none {
        output.push(flushed)
      }

      current-heading = none
      current-body = ()
      in-explicit-slide = true

      // The parser boundary itself is internal.
      // Do not emit it.

    } else if in-explicit-slide {
      output.push(child)

    } else {
      current-body.push(child)
    }
  }

  let flushed = flush-slide(current-heading, current-body)

  if flushed != none {
    output.push(flushed)
  }

  output.join()
}