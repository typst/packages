#import "config.typ" as cf
#import "formatting.typ" as formatting
#import "measure.typ" as me
#import "rendering.typ" as re
#import "utils.typ" as ut

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------

/// Write a comment in pseudo code, between the lines where it is written.
///
/// - body (content): The content of the comment.
/// - args (arguments): The settings of the comment (`style`, `indent`, `fill`, `separate`, `marker`, `marker-fill`, see `set-uraw-pseudo`).
/// -> content
#let pseudo-comment(body, ..args) = {
  assert(
    args.pos().len() == 0,
    message: "`pseudo-comment` takes a single content.",
  )
  let settings = ut.known-keys(
    args.named(),
    cf.pseudo-pre-default.comment.keys(),
  )
  metadata((uraw-pseudo-comment: settings + (content: body)))
}

/// Write a special information comment in pseudo code.
///
/// #example(`
/// #uraw-pseudo[
///   #pseudo-info[*Input* a number $n$]
///   + *return* $n + 1$
/// ]
/// `)
///
/// - body (content): The information.
/// -> content
#let pseudo-info(body) = pseudo-comment(
  indent: false,
  fill: none,
  separate: false,
  marker: none,
  style: none,
  body,
)

// -----------------------------------------------------------------------------
// Rendering
// -----------------------------------------------------------------------------

#let pseudo-to-uraw(args, lines, comments, base-style) = {
  // The blocks of uraw (including the one of `layout`) do not take the block settings of the document
  set block(
    above: auto,
    below: auto,
    width: auto,
    height: auto,
    fill: none,
    stroke: none,
    // (an empty dictionary would keep the sides set by the document)
    inset: 0pt,
    outset: 0pt,
    radius: 0pt,
  )

  // The states (settings) are read outside of `layout`, whose content can be laid out without them (as when measuring an auto column of a grid)
  context {
    let general = cf.pseudo-category-parser("general", args)
    let with-default-thickness(stroke) = ut.with-default-thickness(
      stroke,
      general.default-stroke-thickness,
    )

    let frame = cf.pseudo-category-parser("frame", args)
    let header = cf.pseudo-category-parser("header", args)
    let footer = cf.pseudo-category-parser("footer", args)
    let number = cf.pseudo-category-parser("numbers", args)
    let code = cf.pseudo-category-parser("code", args)
    let comment = cf.pseudo-category-parser("comment", args)

    // (`auto` is the leading of the paragraphs around)
    if code.line-spacing == auto { code.line-spacing = par.leading }
    set par(leading: code.line-spacing)

    layout(layout-size => {
      let frame = formatting.frame-width(frame, layout-size)

      // The measures only take the settings above into account in a new context
      context {
        // (the settings are modified below)
        let (frame, header, footer, number, code, comment) = (
          frame,
          header,
          footer,
          number,
          code,
          comment,
        )

        // Basic formatting (pseudo code has no lang tag)
        let lang-tag = (visible: false, placement: none, in-code: false)
        frame = formatting.frame(frame, lang-tag, with-default-thickness)
        code = formatting.code(code, frame, with-default-thickness)
        code.indent-size = code.indent-size.to-absolute()

        // Numbers
        let nbr-lines = lines.len()
        number.visible = number.format != none
        number = formatting.number(
          number,
          nbr-lines,
          (),
          with-default-thickness,
        )
        let line-numbers = range(nbr-lines).map(k => number.start + k)

        // Coloring
        (number, code) = formatting.coloring(
          number,
          code,
          general,
          frame,
          line-numbers,
          nbr-lines,
        )

        // Comments (at the level where they are written, their marker being in the number column)
        let comments = comments.map(c => {
          let f = formatting.single-comment(
            ut.filter-add-dict(
              comment + (marker-placement: "numbers"),
              c.settings,
            )
              + (content: c.settings.content, copy-before: true),
            c.gap,
            none,
            number,
            code,
            base-style,
            with-default-thickness,
          )
          // (the indentation positions, in indent sizes)
          f.pos-indent = range(c.level + 1)
          f
        })

        // Markers (pseudo code only has the ones of its comments)
        let marker = formatting.marker(
          general + (markers-over-numbers: false),
          number,
        )
        let (number-markers, markers, marker) = formatting.markers(
          lines.map(_ => none),
          comments,
          marker,
          auto,
        )
        let insets = formatting.cell-insets(
          frame,
          number,
          marker.visible,
          code.line-spacing,
        )
        number.inset = insets.number
        marker.inset = insets.marker
        code.inset = insets.code
        number = formatting.number-cells(
          number,
          general,
          number-markers,
          line-numbers,
        )

        // Header & footer
        (header, footer) = formatting.header-footer(
          header,
          footer,
          frame,
          code,
          lang-tag,
          base-style,
          nbr-lines,
          with-default-thickness,
        )
        (frame, header, footer) = formatting.frame-block(frame, header, footer)

        // Lines
        let bodies = lines.map(l => formatting.pseudo-line-body(l, code))

        // Available width

        let (numbers-width, markers-width) = me.numbers-markers-width(
          number,
          marker,
          monotonic: type(number.format) != function,
        )

        // The width of the columns before the code
        let pre-width = numbers-width + markers-width

        let code-width = me.available-code-width(
          layout-size,
          frame,
          code,
          pre-width,
        )
        let max-code-width = code-width

        // Comments position (the indentation positions being in indent sizes)
        comments = formatting.comments-position(
          comments,
          (),
          code,
          pre-width,
          marker.inset,
          code.indent-size,
        )

        // Width

        (header, footer) = formatting.align-header-footer(
          header,
          footer,
          pre-width,
          code,
        )

        let header-width = if header.content != none {
          measure(width: layout-size.width, block(
            inset: header.inset,
            header.content,
          )).width
        } else { 0mm }
        let footer-width = if footer.content != none {
          measure(width: layout-size.width, block(
            inset: footer.inset,
            footer.content,
          )).width
        } else { 0mm }

        code-width = me.pseudo-code-width(frame, code-width, bodies)
        code-width = me.hf-code-width(
          header-width,
          pre-width,
          code,
          code-width,
          footer-width,
        )
        code-width = me.comments-code-width(
          frame,
          comments,
          code,
          code-width,
          max-code-width,
        )
        if frame.width == auto {
          frame.width = (
            pre-width + code.inset.left + code-width + code.inset.right
          )
        }

        // Height

        let char-height = measure("#").height
        let lines-height = me.pseudo-lines-height(
          bodies,
          code,
          code-width,
          char-height,
        )

        // Comments size
        let comments-map = formatting.comments-by-gap(
          comments,
          code,
          code-width,
          number,
          numbers-width,
          marker,
          markers-width,
          nbr-lines,
        )

        // Rendering

        let line-cell(i, height, radius, stroke, fill, color, extra) = (
          re.pseudo-line-cell(
            lines.at(i),
            bodies.at(i),
            code,
            code-width,
            height,
            radius,
            stroke,
            fill,
            color,
            extra,
          )
        )

        let frame-content = re.render(
          nbr-lines,
          number,
          numbers-width,
          code,
          (),
          code-width,
          lines-height,
          frame,
          header,
          footer,
          lang-tag,
          none,
          // (the indentation guides of the comments being spaced by the indent size)
          code.indent-size,
          char-height,
          range(nbr-lines).map(_ => ()),
          comments-map,
          line-cell: line-cell,
          marker: marker,
          markers-width: markers-width,
          markers: markers,
        )

        block(
          fill: frame.block.fill,
          radius: frame.block.radius,
          stroke: frame.block.stroke,
          clip: not frame.sharp-page-break,
          width: frame.width,
          breakable: frame.breakable,
          frame-content,
        )
      }
    })
  }
}

/// Display pseudo code.
///
/// #example(`
/// #uraw-pseudo(header: [*Algorithm* Sleeping])[
///   #pseudo-info[*Output* sleep instruction]
///   + *if* you're tired *then*
///     + sleep
///   + *else*
///     + don't sleep
///   + *end if*
/// ]
/// `)
///
/// If the show rule is used (`#show: uraw`), lines of an `uraw-pseudo` in a labeled figure can be referenced with `@label.n`.
///
/// - args (arguments): The settings (see `set-uraw-pseudo` for their description).
///
/// - body (content): The lines of pseudo code as a numbered list. Comments are written with `pseudo-comment`.
///
/// -> content
#let uraw-pseudo(body, ..args) = {
  assert(
    args.pos().len() == 0 and type(body) == content,
    message: "`uraw-pseudo` takes its lines as a numbered list (`+ ...`) in a single content block.",
  )
  // Settings given by category or flat (e.g. `header-fill`)
  let settings = cf.normalize-settings(args.named(), cf.pseudo-spec)
  let (lines, comments) = formatting.pseudo-lines(body)

  // Mark the pseudo code, so that the figures containing it can be algorithms
  formatting.pseudo-marker(
    settings.at("general", default: (:)).at("algorithm-figure", default: auto),
  )

  // The style outside of the pseudo code, used by the headers, footers and comments
  context {
    let style = cf.outside-style()
    pseudo-to-uraw(settings, lines, comments, () => style)
  }
}
