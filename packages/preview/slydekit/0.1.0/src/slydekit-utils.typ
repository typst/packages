#import "slydekit-defaults.typ": *
#import "slydekit-animation.typ": split-at-pause, split-at-meanwhile, analyze-max-step

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

  if title != none and title != [] {
    sk-states.current-slide-title.update(title)
  }

  // Split the body into parallel tracks at <meanwhile> boundaries, then
  // each track into chunks at <pause> labels. With no <meanwhile> at all, this is a single track equal to the previous flat chunk list, so existing slides are unaffected.
  let tracks = split-at-meanwhile(body).map(split-at-pause)

  // Compute the total number of steps requested by uncover/only and <pause> labels
  let max-reveal-step = analyze-max-step(body)
  let max-track-length = calc.max(..tracks.map(t => t.len()))
  let total = calc.max(max-track-length, max-reveal-step)
  if steps != none {
    total = calc.max(total, steps)
  }

  sk-states.subslide-total.update(total)

  pagebreak(weak: true)

  // Invisible marker, placed at each call, regardless of the title
  [#metadata(title)<sk-slide>]

  context {
    if sk-states.appendix.get() {
      sk-states.app-slide-number.step()
    } else {
      sk-states.slide-number.step()
    }

    // Metadata to attach a label to the slide, if requested
    if label != none {
      [#metadata((kind: "slide"))#label]
    }

    // Direct generation of the slide content, without subslides
    if sk-states.handout.get() {
      // Handout mode: a single page per slide, in its fully revealed state. Content gated on one exact step (only(2)[..], not uncover(from: 2)[..]) never appears here, since intermediate steps are never rendered. Each track is joined on its own: tracks is an array of arrays of chunks (one array per parallel track), so tracks.join() would try to join arrays together instead of content, this joins the chunks inside each track first.
      sk-states.subslide-step.update(total)
      for chunks in tracks {
        chunks.join()
      }
    } else {
      for i in range(1, total + 1) {
        sk-states.subslide-step.update(i)
        if i > 1 {
          pagebreak(weak: true)
        }

        for chunks in tracks {
          for (idx, chunk) in chunks.enumerate() {
            if idx < i {
              chunk
            } else {
              hide(chunk)
            }
          }
        }
      }
    }
  }
}

// Appendix
#let appendix(body) = context {
  pagebreak(weak: true)
  sk-states.appendix.update(true)
  counter(heading).update(0)

  body
}

// Hide new section slide
#let hide-new-section-slide(body) = {
  show heading.where(level: 1): none
  body
}

// Row images
#let row-img(logos) = {
  let n = logos.len()
  grid(
    columns: (1fr,)*n,
    column-gutter: 1fr,
    ..logos.enumerate().map(((i, item)) => {
      if n == 1 {
        align(right + horizon)[#item]
      } else if i == 0 {
        align(left + horizon)[#item]
      } else if i == n - 1 {
        align(right + horizon)[#item]
      } else {
        align(center + horizon)[#item]
      }
    })
  )
}

// Cell
#let cell = block.with(
  width: 100%,
  height: 100%,
  above: 0pt,
  below: 0pt,
  outset: 0pt,
  breakable: false,
)

// Full-width block helper (page bleed)
#let full-width(fill: none, anchor: top, body) = context {
  let margin = page.margin
  let margin-left = if type(margin) == dictionary {
    margin.at("left", default: margin.at("x", default: 0pt))
  } else {
    margin
  }
  let margin-right = if type(margin) == dictionary {
    margin.at("right", default: margin.at("x", default: 0pt))
  } else {
    margin
  }

  place(
    anchor,
    dx: -margin-left,
    box(
      width: 100% + margin-left + margin-right,
      height: 100%,
      fill: fill,
      body,
    ),
  )
}

// Section progress bar
#let progress-bar(ratio, active-color, inactive-color, row-height: (), gutter: ()) = {
  grid(
    columns: (ratio*100%, 1fr),
    rows: row-height,
    gutter: gutter,
    cell(fill: active-color),
    cell(fill: inactive-color)
  )
}

#let section-progress-bar(active-color, inactive-color) = context {
  let current-sec = query(heading.where(level: 1)
    .before(here()))
    .filter(h => not sk-states.appendix.at(h.location()))
    .len()

  let total-sec = query(heading.where(level: 1))
    .filter(h => not sk-states.appendix.at(h.location()))
    .len()

  let ratio = if total-sec > 0 { current-sec / total-sec } else { 1 }

  progress-bar(ratio, active-color, inactive-color)
}

#let slide-progress-bar(active-color, inactive-color, height: 2pt) = context {
  let current-page = sk-states.slide-number.get().first()
  let total-page = sk-states.slide-number.final().first()

  let ratio = if total-page > 0 { current-page / total-page } else { 1 }

  block(
    width: 100%,
    progress-bar(ratio, active-color, inactive-color, row-height: height, gutter: 0pt)
  )
}

// Boxes - Utility
#let box-title(a, b) = {
  grid(columns: 2, column-gutter: 0.5em, align: (horizon),
    a,
    b
  )
}

#let colorize(svg, color) = {
  let blk = black.to-hex();
  if svg.contains(blk) {
    svg.replace(blk, color.to-hex())
  } else {
    svg.replace("<svg ", "<svg fill=\""+ color.to-hex() + "\" ")
  }
}

#let color-svg(
  path,
  color,
  ..args,
) = {
  let data = colorize(read(path), color)
  return image(bytes(data), ..args)
}

#let footcite(key, supplement: none) = context {
  let elems = query(bibliography)
  if elems.len() > 0 {
    super(cite(key, supplement: supplement))
    sk-states.is-footcite.update(true)
    hide(footnote(cite(key, form: "full", style: "resources/short_ref.csl")))
    sk-states.is-footcite.update(false)
  } else {
    panic("No bibliography found. Please add a bibliography to use notecite.")
  }
}

#let show-ref(it) = {
  let el = it.element
  // if el == none { return it }
  if el == none { return footcite(it.target) }

  // Detect slides created via #slide(..., label: <...>)
  let is-metadata-slide = (
    el.func() == metadata
    and type(el.value) == dictionary
    and el.value.at("kind", default: none) == "slide"
  )

  // Detect slides created via == Title <...>
  let is-heading-slide = (
    el.func() == heading
    and el.has("level")
    and el.level == 2
  )

  if is-metadata-slide or is-heading-slide {
    let loc = el.location()
    let is-app = sk-states.appendix.at(loc)

    let base-num = if is-app {
      sk-states.app-slide-number.at(loc).first()
    } else {
      sk-states.slide-number.at(loc).first()
    }

    // A heading just before the .step(), we add +1. For a metadata, the .step() has already occurred, we keep base-num.
    let num = if is-heading-slide { base-num + 1 } else { base-num }
    let prefix = if is-app { "A." } else { "" }

    link(loc, [#prefix#num])
  } else {
    it
  }
}

#let set-text(lang: "en", body) = context {
  let sk-fonts = sk-states.fonts.get()
  set text(font: sk-fonts.at("body", default: default-fonts.body), size: sk-fonts.at("size", default: default-fonts.size), lang: lang, region: lang)
  show math.equation: set text(font: sk-fonts.at("math", default: default-fonts.math), size: sk-fonts.at("size", default: default-fonts.size))
  show raw: set text(font: sk-fonts.at("raw", default: default-fonts.raw), size: sk-fonts.at("size", default: default-fonts.size))

  body
}

// Short or long title
#let short-or-long(short, long) = [#metadata((short: short, long: long))<sk-title>]