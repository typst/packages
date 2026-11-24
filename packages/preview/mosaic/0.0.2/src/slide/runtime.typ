// Logical-slide runtime: frame policy, state, resolution, and page rendering.
#import "../shared.typ": fail, tag
#import "../grid/model.typ": plane-ids
#import "../grid/validation.typ": validate
#import "../grid/content.typ": body-cell-ids, resolve-content
#import "../incremental/analysis.typ": max-step
#import "../incremental/transform.typ": (
  transform,
  require-stable-temporal-headings,
)
#import "../incremental/heading.typ": strip-headings
#import "../note/analysis.typ": (
  notes-at,
  fixed-grid-notes-at,
  has-note,
  fixed-grid-has-note,
)
#import "../note/command.typ": is-note
#import "../grid/render.typ": (
  max-node,
  render,
  require-stable-grid-headings,
)
#import "../fit.typ": fit-ratio
#import "../layout/resolver.typ": resolve-layout
#import "../layout/core.typ": is-layout
#import "../layout/config.typ": unconfigured-layouts
#import "../deck-record.typ": read-deck-record
#import "../deck-state.typ": (
  logical-slide,
  logical-slide-id,
  logical-section,
  slide-numbered,
  inverted-slide-colors,
  section-title,
)

#let physical-steps(total, handout) = if handout {
  (total,)
} else {
  range(1, total + 1)
}

#let prepare-frame(step, location, handout: false) = context {
  if not handout and step > 1 {
    let record = read-deck-record()
    for value in record.frozen-counters + record.frozen-states {
      value.update(value.at(selector(location)))
    }
  }
}

// The palette of one inverted slide: ground and ink swap, and the derived
// tones follow. `muted` and `line` become translucent washes of the new ink so
// they read against the dark ground the way the palette's own muted and line
// read against the canvas; `surface` joins the ground because a raised panel
// has no darker ink to rise from. The semantic accent and the status colors
// survive untouched: they are chosen to carry on either polarity, and a deck
// that disagrees passes its own palette.
#let invert-colors(colors) = colors + (
  canvas: colors.text,
  surface: colors.text,
  text: colors.canvas,
  muted: colors.canvas.transparentize(30%),
  line: colors.canvas.transparentize(78%),
)

#let full-slide-layer(body) = place(
  top + left,
  block(width: 100%, height: 100%, body),
)

#let slide-frame(
  body,
  width: 100%,
  height: 100%,
  fill: none,
  stroke: none,
) = block(
  width: width,
  height: height,
  fill: fill,
  stroke: stroke,
  above: 0pt,
  below: 0pt,
  breakable: false,
  body,
)

// The printed pages carry no typography of their own. The note text and the
// frame heading render under the <mosaic-note-body> and <mosaic-note-heading>
// labels; setup states neutral paper-reading defaults for them as show rules,
// and any later rule on the same label overrides those. Only geometry comes
// from `settings.notes`.
#let note-list(notes, style) = {
  if notes.len() == 0 {
    emph[No speaker notes for this frame.]
  } else {
    notes.map(note => block(above: 0pt, below: style.note-gap, note)).join()
  }
}

// The heading text is wrapped before it is labeled. The `·` splits the markup
// into three text elements, so an unwrapped `text[..]` hands the label a bare
// sequence; flattened into the code-mode joins below, such a label carries its
// show rules into everything that follows, and the notes rendered bold.
#let note-heading(slide, step, steps) = [#block(text[Slide #slide · Frame #step of #steps])#label("mosaic-note-heading")]

#let bounded-note-list(notes, width, height, output, step, style) = {
  // The label wraps the block that is both measured and placed, so the
  // overflow check observes the same label rules the page renders with.
  let body = [#block(
    width: width,
    breakable: false,
    above: 0pt,
    below: 0pt,
    note-list(notes, style),
  )#label("mosaic-note-body")]
  let natural = measure(body, width: width)
  if natural.height > height {
    fail(output + " output notes overflow on frame " + str(step))
  }
  body
}

#let render-printed-page(frame, notes, slide, step, steps, source-size, fill, style, output) = layout(region => {
  let heading = note-heading(slide, step, steps)
  let heading-height = measure(heading, width: region.width).height
  // The vertical budget, stated as the sum of what the page actually places
  // rather than as one combined allowance. The speaker path subtracts its
  // thumbnail from this shared budget below.
  let notes-height = (
    region.height
      - heading-height
      - style.heading-gap
      - style.bottom-gap
  )
  if output == "speaker" {
    let source = slide-frame(
      frame,
      width: source-size.width,
      height: source-size.height,
      fill: fill,
      stroke: style.thumbnail-stroke,
    )
    // The thumbnail is a whole slide scaled into the notes column, which is the
    // same width problem the fitters solve, so the factor comes from their shared
    // geometry rather than from a second copy of the arithmetic here.
    let factor = fit-ratio(source-size, width: region.width)
    let thumbnail-height = source-size.height * factor
    [
      #scale(
        x: factor,
        y: factor,
        reflow: true,
        origin: top + left,
        source,
      )
      #v(style.thumbnail-gap)
      #heading
      #v(style.heading-gap)
      #bounded-note-list(
        notes,
        region.width,
        notes-height - thumbnail-height - style.thumbnail-gap,
        "speaker",
        step,
        style,
      )
    ]
  } else {
    // Lay out the semantic slide invisibly so native counters and state updates
    // retain the same frame semantics as the slide and speaker outputs.
    place(hide(slide-frame(
      frame,
      width: source-size.width,
      height: source-size.height,
      fill: fill,
    )))
    heading
    v(style.heading-gap)
    bounded-note-list(
      notes,
      region.width,
      notes-height,
      "notes",
      step,
      style,
    )
  }
})

// One `split` page: the slide at its true size on the left half, the same
// heading-and-notes column the `notes` output prints on the right half.
//
// The geometry is the contract, not a style choice. Presenter tools recognize
// this layout by aspect ratio alone — pympress treats any page wider than 2:1
// as slide-plus-notes, and pdfpc cuts on `--notes=right` — and then split the
// page at its exact midpoint. So the page is twice the slide wide, carries no
// margin of its own, and the slide half is placed unscaled at the origin: what
// the audience screen shows is the deck's own canvas, pixel for pixel, and the
// presenter screen gets everything to the right of the cut.
//
// The notes half is deliberately paper, not canvas. It is read off a laptop by
// one person under house lights, so it keeps the white ground and black text
// the printed outputs use whatever polarity the deck itself carries.
#let render-split-page(frame, notes, slide, step, steps, source-size, slide-fill, style) = {
  place(top + left, slide-frame(
    frame,
    width: source-size.width,
    height: source-size.height,
    fill: slide-fill,
  ))
  place(top + left, dx: source-size.width, block(
    width: source-size.width,
    height: source-size.height,
    inset: style.split-inset,
    layout(region => {
      let heading = note-heading(slide, step, steps)
      let heading-height = measure(heading, width: region.width).height
      heading
      v(style.heading-gap)
      bounded-note-list(
        notes,
        region.width,
        region.height - heading-height - style.heading-gap - style.bottom-gap,
        "split",
        step,
        style,
      )
    }),
  ))
}

// A plane renders as one full-slide block labeled <mosaic-ID> (ID is
// "background" or "foreground"), so native label rules can style it without
// conflating planes with grid cells. As in render-cell, a `set block` show-set
// on the label paints this block itself, and the reset just inside confines
// it to the plane's own surface rather than every block in the plane content.
#let render-plane(body, step, heading-scope) = if body == none {
  []
} else {
  let body = block(
    width: 100%,
    height: 100%,
    {
      set block(fill: none, stroke: none, radius: 0pt)
      transform(
        body,
        step,
        headings: "visual",
        heading-scope: heading-scope,
      )
    },
  )
  [#body#label("mosaic-" + heading-scope)]
}

#let select-layout(value, configured) = if value == auto {
  ("content", configured.content)
} else if type(value) == str {
  // Configurable names come from setup; the rest are selectable-only stubs
  // that the slide's own named fields refine.
  (value, configured.at(value, default: unconfigured-layouts.at(value, default: none)))
} else if is-layout(value) {
  (value.name, value)
} else {
  ("content", value)
}

#let render-slide-with-record(command, record, settings) = context {
  // Inversion happens here, before the layout resolves, so every reader of
  // `settings.colors` below — variant resolvers, muted tiers, accents — paints
  // from the swapped palette without knowing the slide is inverted.
  let settings = settings
  if command.invert {
    settings.colors = invert-colors(settings.colors)
  }
  let (layout-name, requested-layout) = select-layout(
    command.layout,
    record.layouts,
  )
  // Field overlay (see `slide-command`): the slide's named arguments and the
  // deck compiler's automatic section tagline. It refines the configured
  // layout rather than replacing it, so a theme's variant, accent, and image
  // survive. Each layout's resolver re-validates the merged field set, so an
  // overlay cannot smuggle an unsupported combination past construction.
  let overlay = command.at("fields", default: (:))
  let named-cells = command.cells
  if overlay.len() > 0 {
    if not is-layout(requested-layout) {
      if command.automatic and overlay.keys() == ("subtitle",) {
        // The automatic section tagline has no field to land in when the
        // configured section layout is a raw grid, and a heading-generated
        // slide has no constructor to move it to, so it renders in the
        // section cell below the heading instead.
        named-cells.insert(
          "section",
          named-cells.at("section", default: []) + overlay.subtitle,
        )
      } else {
        fail(
          "the configured " + layout-name + " layout is a raw grid, which "
            + "cannot carry layout fields; supply them on an explicit "
            + "slide layout instead",
        )
      }
    } else {
      requested-layout = requested-layout + (
        fields: requested-layout.fields + overlay,
      )
    }
  }
  let resolved-grid = if is-layout(requested-layout) {
    resolve-layout(requested-layout, settings)
  } else {
    requested-layout
  }
  validate(resolved-grid)
  // Automatic heading slides name the cells the standard layouts carry —
  // "header" and "body" on content slides, "section" on section slides — but
  // a configured layout may not have them all: a "body" content variant has
  // no header cell, and a custom grid may name its cells differently. The
  // author never wrote these ids, so content addressed to a cell this layout
  // lacks folds into the first content-bearing cell not already claimed by an
  // exact match, rather than failing on a name that appears nowhere in the
  // deck's source.
  if command.automatic and named-cells.len() > 0 {
    let ids = body-cell-ids(resolved-grid)
    if ids.len() == 0 {
      fail(
        "the configured " + layout-name + " layout has no content-bearing "
          + "cell to receive an automatic heading slide",
      )
    }
    let matched = named-cells.keys().filter(id => id in ids)
    let unclaimed = ids.find(id => id not in matched)
    let fallback = if unclaimed == none { ids.first() } else { unclaimed }
    let folded = (:)
    for (id, value) in named-cells {
      let target = if id in ids { id } else { fallback }
      folded.insert(target, folded.at(target, default: []) + value)
    }
    named-cells = folded
  }
  // Planes arrive as their own command fields, already validated on the slide
  // and on `setup`: `auto` inherits the deck plane, anything else is this
  // slide's own, and `none` omits it.
  let planes = (:)
  for id in plane-ids {
    let override = command.at(id)
    planes.insert(id, if override == auto { settings.at(id) } else { override })
  }
  // Named and positional content collapse to one id -> content map before
  // rendering, so the renderer, overflow, and incremental paths look content up
  // by cell id with no positional cursor.
  let contents = resolve-content(
    resolved-grid,
    named-cells,
    command.bodies,
    defaults: settings.cells,
  )
  let steps = calc.max(
    max-node(resolved-grid),
    max-step(contents.values()),
    max-step(planes.background),
    max-step(planes.foreground),
  )
  logical-slide-id.step()
  let numbered = if command.numbered == auto {
    // Only deck chrome goes unnumbered by default: title and section slides.
    // Everything else — content, image, raw grids — is ordinary material and
    // counts.
    layout-name not in ("title", "section")
  } else {
    command.numbered
  }
  if numbered {
    logical-slide.step()
  }
  // Written before the planes render, so deck furniture can quiet itself on
  // unnumbered pages; see slide-numbered in deck-state.
  slide-numbered.update(_ => numbered)
  // Published for layout-time color readers (components, the cell renderer's
  // ink restatement); `none` on every slide that is not inverted.
  let published-colors = if command.invert { settings.colors } else { none }
  inverted-slide-colors.update(_ => published-colors)
  if layout-name == "section" {
    logical-section.step()
    // Heading-stripped, so consumers re-render it without minting duplicate
    // outline entries.
    let title = strip-headings(contents.at("section", default: none))
    // The section this and every following slide is in, until the next section
    // slide overwrites it. This is what `info().section.title` reports.
    section-title.update(_ => title)
    // The same title as a queryable record, emitted right after the step so
    // `logical-section.at(location)` gives this slide's section number. The
    // state answers "which section am I in"; the records answer "what are all
    // the sections", which is what the toc section variant draws.
    [#metadata((mosaic: tag, kind: "section-title", title: title)) <mosaic-section-title>]
  }
  // Heading stability is a property of the slide's structure, not of any one
  // frame, so both checks run here rather than inside the render and transform
  // walks that the frame loop repeats.
  require-stable-grid-headings(resolved-grid, contents)
  for value in contents.values() {
    require-stable-temporal-headings(value)
  }
  require-stable-temporal-headings(planes.background)
  require-stable-temporal-headings(planes.foreground)
  // Whether this slide holds any note at all, asked once rather than once per
  // frame. Note extraction is four content walks per frame, and a deck with no
  // notes would otherwise pay all of them on every page.
  let any-notes = (
    fixed-grid-has-note(resolved-grid)
      or has-note(contents.values())
      or has-note(planes.background)
      or has-note(planes.foreground)
  )
  let slide = logical-slide-id.get().first()
  let freeze-location = here()
  let handout = record.handout
  let output = record.output
  let paper = record.paper
  // An inverted slide's ground is its own inverted canvas, whatever the page
  // paints; the printed thumbnails need the same answer.
  let slide-fill = if command.invert or page.fill == auto {
    settings.colors.canvas
  } else {
    page.fill
  }
  for step in physical-steps(steps, handout) {
    // The whole cell grid carries <mosaic-slide>, so one native rule can reach
    // every cell of a slide at once:
    //
    //   show label("mosaic-slide"): set text(fill: white)
    //
    // Without it, styling a slide means naming each cell the resolved layout
    // happens to produce, and a change of variant silently leaves a cell
    // behind. Per-cell labels still apply, and sit inside this one, so a
    // <mosaic-cell-*> rule refines what this sets.
    let rendered = [
      #render(
        resolved-grid,
        contents,
        step,
        overflow: settings.overflow,
        slide: slide,
      )
      #label("mosaic-slide")
    ]
    pagebreak(weak: true)
    prepare-frame(step, freeze-location, handout: handout)
    let background-content = render-plane(planes.background, step, "background")
    let foreground-content = render-plane(planes.foreground, step, "foreground")
    let notes = if not any-notes { () } else {
      (
        fixed-grid-notes-at(resolved-grid, step)
          + notes-at(contents.values(), step)
          + notes-at(planes.background, step)
          + notes-at(planes.foreground, step)
      )
    }
    let frame = [
        #show metadata: it => if is-note(it) { [] } else { it }
        #full-slide-layer(background-content)
        #full-slide-layer(rendered)
        #full-slide-layer(foreground-content)
    ]
    if command.invert {
      // The knocked-out ink, stated inside the frame so it overrides the
      // theme's document-level fill, plus the same statement on headings,
      // which themes pin through show-set rules a plain `set` cannot reach.
      frame = {
        set text(fill: settings.colors.text)
        show heading: set text(fill: settings.colors.text)
        frame
      }
    }
    place(hide([
      #metadata((
        mosaic: tag,
        kind: "speaker-notes",
        logical-slide: slide,
        frame: step,
        notes: notes,
      )) <mosaic-speaker-notes>
    ]))
    if output == "slides" {
      slide-frame(frame, fill: if command.invert { settings.colors.canvas } else { none })
    } else if output == "split" {
      // Always an explicit fill: the page ground under a split page is the
      // notes half's white, so the slide half cannot inherit its canvas from
      // the page the way the `slides` output does.
      render-split-page(
        frame, notes, slide, step, steps, paper, settings.colors.canvas,
        settings.notes,
      )
    } else {
      render-printed-page(
        frame, notes, slide, step, steps, paper, slide-fill, settings.notes, output,
      )
    }
  }
}

// The deck's resolved body text size, read here rather than stored at setup.
// Themes own every `set text` rule, so the engine cannot know the size in
// advance; this context sits inside the theme's rules but outside the labeled
// cells, so it observes the body size the deck actually renders at, before any
// <mosaic-cell-*> display scale applies. Layouts anchor their composed tiers to
// it, which is what keeps a title's subtitle proportional to its own theme.
#let render-slide(command) = context {
  let record = read-deck-record()
  let settings = record.settings
  if settings != none {
    settings.insert("base-size", text.size)
  }
  render-slide-with-record(command, record, settings)
}
