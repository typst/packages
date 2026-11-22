#import "content.typ" as ct
#import "formatting.typ" as formatting
#import "highlight.typ" as hl
#import "../styling/highlights.typ" as hs
#import "measure.typ" as me
#import "rendering.typ" as re
#import "config.typ" as cf
#import "utils.typ" as ut


/// Whether a figure is turned into an algorithm: it is a figure of image kind (the kind of figures whose kind cannot be detected) containing pseudo code with the `algorithm-figure` setting.
#let is-algorithm-figure(fig, at: none) = {
  if fig.func() != figure or fig.kind != image { return false }
  let marker = formatting.find-pseudo-marker(fig.body)
  if marker == none { return false }
  if marker.algorithm-figure != auto { return marker.algorithm-figure }
  let conf = if at == none { cf.uraw-pseudo-config-state.get() } else {
    cf.uraw-pseudo-config-state.at(at)
  }
  conf.general.algorithm-figure
}

/// The algorithm figure replacing a figure, or the figure itself.
#let resolve-figure(fig) = if is-algorithm-figure(fig, at: fig.location()) {
  query(figure.where(kind: "algorithm").after(fig.location())).first()
} else {
  fig
}

#let raw-to-uraw(
  args,
  markers,
  manual-highlights,
  highlights,
  comments,
  jumps,
  base-style,
  first-line,
  it,
) = {
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

  // The states (settings, outside style) are read outside of `layout`, whose content can be laid out without them (as when measuring an auto column of a grid)
  context {
    let style = base-style()
    let base-style() = style
    let general = cf.category-parser("general", args, it.lang)
    let with-default-thickness(stroke) = ut.with-default-thickness(
      stroke,
      general.default-stroke-thickness,
    )

    let frame = cf.category-parser("frame", args, it.lang)
    let header = cf.category-parser("header", args, it.lang)
    let footer = cf.category-parser("footer", args, it.lang)
    let number = cf.category-parser("numbers", args, it.lang)
    let code = cf.category-parser("code", args, it.lang)
    let lang-tag = cf.category-parser("lang-tag", args, it.lang)
    let comment = cf.category-parser("comment", args, it.lang)
    let jump = cf.category-parser("jump", args, it.lang)

    // (`auto` is the leading of the paragraphs around)
    if code.line-spacing == auto { code.line-spacing = par.leading }
    set par(leading: code.line-spacing)

    layout(layout-size => {
      let frame = formatting.frame-width(frame, layout-size)

      // The measures (of the comments, headers, ...) only take the settings above into account in a new context
      context {
        // (the settings are modified below)
        let (frame, header, footer, number, code, lang-tag, comment, jump) = (
          frame,
          header,
          footer,
          number,
          code,
          lang-tag,
          comment,
          jump,
        )

        // Continuation: the block follows or precedes another one, as at a page break
        let follows = args.at("follows", default: false)
        let precedes = args.at("precedes", default: false)
        // The last line of the preceding block (the lines being numbered from the next one), the largest number of the following blocks (the number column being wide enough for it), and the widest markers of both (the marker column being wide enough for them)
        let (last-line, follows-marker) = formatting.continuation(
          follows,
          "follows",
        )
        let (largest-line, precedes-marker) = formatting.continuation(
          precedes,
          "precedes",
        )
        if last-line != none { number.start = last-line + 1 }
        let widest-number = if largest-line != none and number.format != none {
          formatting.shown-number(number, largest-line)
        }
        let widest-markers = (follows-marker, precedes-marker).filter(m => (
          m != none
        ))
        let (follows, precedes) = (follows != false, precedes != false)
        // The numbers start by default at the first line of the code (in its file)
        if number.start == auto { number.start = first-line }

        // Basic formatting
        lang-tag.visible = (
          lang-tag.visible
            and not (
              lang-tag.icon == none
                and (
                  lang-tag.name == none
                    or (lang-tag.name == auto and it.lang == none)
                )
            )
        )
        // The lang tag is removed from the open sides
        if (
          follows
            and (
              lang-tag.placement in ("code", "inline", "header")
                or lang-tag.placement.starts-with("top")
            )
        ) { lang-tag.visible = false }
        if precedes and lang-tag.placement.starts-with("bottom") {
          lang-tag.visible = false
        }
        frame = formatting.frame(frame, lang-tag, with-default-thickness)
        lang-tag = formatting.lang-tag(
          lang-tag,
          it.lang,
          frame,
          header,
          with-default-thickness,
        )
        let (is-top, is-left, is-right, is-bottom) = {
          if lang-tag.visible and lang-tag.on-frame {
            formatting.lang-tag-position(lang-tag)
          } else {
            (none, none, none, none)
          }
        }
        code = formatting.code(code, frame, with-default-thickness)

        // Numbers and markers (the lines skipped by the jumps are not shown)
        number.visible = number.format != none
        let (jumps, jumps-map) = formatting.jumps(
          jumps,
          number,
          it.lines.len(),
        )
        let nbr-lines = it.lines.len() - formatting.nbr-skipped(jumps)
        number = formatting.number(
          number,
          nbr-lines,
          jumps,
          with-default-thickness,
        )
        let (line-numbers, line-index, kept) = formatting.line-numbers(
          number,
          it.lines.len(),
          jumps,
          jumps-map,
        )
        // Coloring
        (number, code) = formatting.coloring(
          number,
          code,
          general,
          frame,
          line-numbers,
          nbr-lines,
        )
        // (the lang tag being in the color of the code of the first line by default)
        if lang-tag.color == auto { lang-tag.color = (code.color)(0) }
        lang-tag.block = formatting.lang-tag-block(it.lang, lang-tag, frame)
        lang-tag.insert(
          "width",
          if lang-tag.visible and (lang-tag.in-code or lang-tag.in-header) {
            measure(lang-tag.block).width + lang-tag.spacing.to-absolute()
          },
        )

        // Comments
        let single-comment(c, g, k) = (
          formatting.single-comment(
            c,
            g,
            k,
            number,
            code,
            base-style,
            with-default-thickness,
          )
        )
        let jump-comments = formatting.jump-comments(
          jumps,
          jump,
          comment,
          line-index,
          single-comment,
        )
        let comments = formatting.comments(
          comments,
          comment,
          line-numbers,
          single-comment,
        )
        comments = jump-comments + comments

        // Markers
        let char-height = measure("#").height
        let marker = formatting.marker(general, number)
        let (number-markers, markers, marker) = formatting.markers(
          cf.parse-markers(markers, line-index, line-numbers),
          comments,
          marker,
          char-height,
        )
        // (the column of the markers is wide enough for the widest markers of the preceding and following blocks, the marker column being shown)
        if marker.over-numbers {
          marker.number-markers += widest-markers
        } else if widest-markers.len() > 0 {
          marker.visible = true
          marker.markers += widest-markers
        }
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

        // The open sides have no radius, no stroke and no code inset, the header and footer are only shown if they repeat
        if follows {
          if not header.repeat {
            header.content = none
            code.edge.top = 0pt
          }
          header.radius = (:)
          frame.radius.top-left = 0pt
          frame.radius.top-right = 0pt
          frame.stroke.top = none
        }
        if precedes {
          if not footer.repeat {
            footer.content = none
            code.edge.bottom = 0pt
          }
          footer.radius = (:)
          frame.radius.bottom-left = 0pt
          frame.radius.bottom-right = 0pt
          frame.stroke.bottom = none
        }
        (frame, header, footer) = formatting.frame-block(frame, header, footer)

        // Lines & highlights (the highlights are on all the lines of the code, the shown ones being kept)
        let code-lines = formatting.lines(it, code)
        let it-lines = kept.map(i => code-lines.at(i))
        let highlights = formatting.highlights(
          manual-highlights,
          highlights,
          code-lines,
          n => kept.at(line-index(n)),
          with-default-thickness,
        )

        // Available width

        let char-width = measure("#").width

        let (numbers-width, markers-width) = me.numbers-markers-width(
          number,
          marker,
          widest: widest-number,
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

        // Comments position
        comments = formatting.comments-position(
          comments,
          it-lines,
          code,
          pre-width,
          marker.inset,
          char-width,
        )

        // Break lines in sub-lines
        code-lines = formatting.break-lines(
          code-lines,
          code-width,
          lang-tag,
          char-width,
          indented: code.indented-line-return,
        )
        it-lines = kept.map(i => code-lines.at(i))

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

        code-width = me.tight-code-width(
          frame,
          code-width,
          lang-tag,
          it-lines,
          char-width,
        )
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

        let it-lines-height = it-lines.map(l => (
          l.slines.len() * (char-height + code.line-spacing)
        ))

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

        // Highlights by line
        let highlights-map = formatting.kept-highlights(
          formatting.highlights-by-line(
            highlights,
            code-lines,
            code-width,
            code,
            char-width,
          ),
          kept,
        )

        // Rendering

        let frame-content = re.render(
          nbr-lines,
          number,
          numbers-width,
          code,
          it-lines,
          code-width,
          it-lines-height,
          frame,
          header,
          footer,
          lang-tag,
          lang-tag.block,
          char-width,
          char-height,
          highlights-map,
          comments-map,
          marker: marker,
          markers-width: markers-width,
          markers: markers,
        )

        let frame-block = block(
          fill: frame.block.fill,
          radius: frame.block.radius,
          stroke: frame.block.stroke,
          clip: not frame.sharp-page-break,
          sticky: lang-tag.visible and lang-tag.on-frame and is-bottom,
          width: frame.width,
          breakable: frame.breakable,
          frame-content,
        )

        if lang-tag.visible and lang-tag.on-frame {
          if is-left or is-right {
            block({
              re.place-frame-lang-tag(lang-tag, lang-tag.block, frame)
              frame-block
            })
          } else {
            let alignment = re.lang-tag-alignment(lang-tag)
            lang-tag.block = block(
              width: frame.width,
              sticky: is-top,
              above: if is-bottom { 0mm } else { auto },
              below: if is-top { 0mm } else { auto },
              align(alignment, lang-tag.block),
            )
            if is-top {
              lang-tag.block
              frame-block
            } else {
              frame-block
              lang-tag.block
            }
          }
        } else {
          frame-block
        }
      }
    })
  }
}

/// Display raw text.
///
/// #example(````
/// #uraw(
///   ```typ
///   #let *|greeting|*(name) = "Hello " + name + "!"
///
///   #let greet(name, polite: true) = box(
///     stroke: purple,
///     inset: *!2pt!*,
///     if polite { *|greeting|*(name) + " Nice to meet you." } else { "<•>_<•>" }
///   )
///   ```,
/// )
/// ````)
///
/// For `markers`, `highlights`, `comments` and `jumps`, a single entry or an array of entries are both valid.
///
/// If the show rule is used (`#show: uraw`), lines of an `uraw` block in a labeled figure can be referenced with `@label.n`.
///
/// Look at the #link("https://github.com/JulesViennotFranca/ultraw/blob/main/docs/doc.pdf")[Docs] for a complete overview of what is possible with `uraw`.
///
/// - args (arguments): The settings (see `set-uraw` for their description).
///
/// - markers (array, dictionary): Each marker is given as `(line, content)` or `(line: ..., content: ...)`. `line` takes a single line or a range `(from, to)`.
///
/// - highlights (array, dictionary): For each highlight, the range it covers is given either by `line` or `start` and `end`. `line` can take a single line number or a pair `(from, to)`. `start` and `end` both can take a single line number (meaning the start and end of that line) or a pair `(line, character)` to point at an exact code location. Each highlight can have specific styling parameters (`fill`, `stroke`, `radius`, `code-style`, `sticky`, `expand`, see `set-uraw` for more details).
///
/// - comments (array, dictionary): Each comment is given as `(line, content)` (the comment is displayed after the line) or a dictionary with `after` / `before` indicating the targeted line, `content`, and styling parameters (`style`, `indent`, `fill`, `separate`, `marker`, `marker-fill`, `marker-placement`, see `set-uraw` for more details).
///
/// - jumps (array, dictionary): Each jump is given as `(from, to)` or a dictionary with `from`, `to`, whether to `skip-lines (bool)` of the raw text, and the associated comment parameters (`comment`, `indent`, `fill`, `separate`, `marker`, `marker-fill`, `marker-placement`, see `set-uraw` for more details). `from` and `to` take integer values or `start` and `end`.
///
/// - follows (bool, int, content, array): Whether the block continues a previous one; it then renders as after a page break (no top radius, no top stroke, etc.). For a correct numbering and to display the accurate width of the numbers column, an integer value represents the last line of the preceding block, content is the widest marker of the preceding blocks (the marker column being shown and made wide enough for it), and a pair `(number, marker)` gives both.
///
/// - precedes (bool, int, content, array): Whether the block is continued by a next one; it then renders as before a page break (no bottom radius, no bottom stroke, etc.). To display the accurate width of the numbers column, an integer value is the largest line number of the following blocks, content is their widest marker, and a pair `(number, marker)` gives both.
///
/// - body (content | raw | path | dictionary): Either the whole document to apply the show rule (`#show: uraw`), some raw text block to format, a path indicating the file to read the code from, or the dictionary output of `read-code`.
///
/// -> content
#let uraw(
  markers: (),
  highlights: (),
  comments: (),
  jumps: (),
  follows: false,
  precedes: false,
  body,
  ..args,
) = {
  let (body, first-line) = cf.code-input(body)
  // Settings given by section or flat (e.g. `header-fill`)
  let args = cf.normalize-settings(args.named(), cf.uraw-spec)
  args += (follows: follows, precedes: precedes)

  /// The show rules displaying the raw blocks, with the function giving the text style of the headers, footers, and comments.
  let with-base-style(base-style) = {
    // The lines of the code in a labeled figure are labeled after it: their anchors become references `<figure-label.n>`
    // (by a show rule rather than a state, so that the labels never depend on the layout)
    let label-lines(fig-label, body) = {
      show <uraw-line-anchor>: a => {
        let line = a.value.uraw-line-anchor
        [#metadata((uraw-line-ref: line + (figure: fig-label)))#label(
            str(fig-label)
              + if line.version != none { "." + line.version }
              + "."
              + str(line.number),
          )]
      }
      body
    }
    show figure: it => if it.has("label") { label-lines(it.label, it) } else {
      it
    }

    // Figures containing pseudo code are algorithms (with their own numbering),
    // their supplement can be changed by a later show-set rule
    show figure.where(kind: "algorithm"): set figure(supplement: [Algorithm])
    show figure.where(kind: image): it => if is-algorithm-figure(it) {
      let fields = it.fields()
      let alg = figure(
        it.body,
        kind: "algorithm",
        caption: if it.caption != none { it.caption.body },
        ..("placement", "scope", "gap", "numbering", "outlined")
          .filter(key => key in fields)
          .map(key => (key, fields.at(key)))
          .to-dict(),
      )
      // The lines are labeled after the replaced figure, which is the one referenced
      if it.has("label") { label-lines(it.label, alg) } else { alg }
      // The replaced figure is not an image
      counter(figure.where(kind: image)).update(n => n - 1)
    } else {
      it
    }
    show outline.entry: it => if is-algorithm-figure(
      it.element,
      at: it.element.location(),
    ) { none } else { it }

    // A reference to a figure containing pseudo code refers to its algorithm
    show ref: it => {
      let el = it.element
      if el == none or not is-algorithm-figure(el, at: el.location()) {
        return it
      }
      let alg = resolve-figure(el)
      let supplement = if it.supplement == auto {
        alg.supplement
      } else if type(it.supplement) == function {
        (it.supplement)(alg)
      } else {
        it.supplement
      }
      link(
        alg.location(),
        if supplement in (none, []) { [] } else { supplement + [~] }
          + numbering(
            alg.numbering,
            ..counter(figure.where(kind: "algorithm")).at(alg.location()),
          ),
      )
    }

    // A reference to a line `@figure-label.n` displays the reference to its figure followed by `.n`,
    // and links to the line number
    show ref: it => {
      let el = it.element
      if (
        el == none
          or el.func() != metadata
          or type(el.value) != dictionary
          or not "uraw-line-ref" in el.value
      ) {
        return it
      }

      let line-ref = el.value.uraw-line-ref
      let (figure-label, n, line-reference) = (
        line-ref.figure,
        line-ref.number,
        line-ref.reference,
      )
      let version = line-ref.at("version", default: none)
      let fig = resolve-figure(query(figure-label).first())
      assert(
        fig.numbering != none,
        message: "Cannot reference a line of a figure without numbering.",
      )

      let fig-number = numbering(
        fig.numbering,
        ..counter(figure.where(kind: fig.kind)).at(fig.location()),
      )
      let supplement = if it.supplement == auto {
        fig.supplement
      } else if type(it.supplement) == function {
        (it.supplement)(fig)
      } else {
        it.supplement
      }

      link(
        el.location(),
        if supplement in (none, []) { [] } else { supplement + [~] }
          + fig-number
          + if version != none {
            line-reference(n, version)
          } else {
            line-reference(n)
          },
      )
    }

    // (for a single raw block, only this one: a raw block in one of its comments would take its comments, and be shown again inside itself)
    let single = type(body) == content and body.func() == raw
    show raw.where(block: true): it => if single and it.text != body.text {
      it
    } else {
      context {
        set text(1.25em)

        // The default values of the highlights
        let highlight = cf.category-parser("highlight", args, it.lang)

        // Reading highlights from the raw text
        let pre-highlights = hs.list()
        let formatted-pre-highlights = pre-highlights.map(
          h => hl.format-pre-highlight(h, highlight),
        )
        let (dels, lines) = hl.parse-delimiters(
          it.lines.map(l => l.text),
          formatted-pre-highlights,
        )
        let delimited-highlights = dels.map(del => hl.make-highlight(
          formatted-pre-highlights.at(del.idx),
          del,
        ))
        let manual-highlights = ut
          .single-to-list(highlights)
          .map(h => hl.format-highlight(h, highlight))

        // The raw element without the highlights delimiters is the one displayed (only this one: a raw block in a comment is another one)
        let shown-text = lines.join("\n", default: "")
        show <uraw-code>: code-it => if code-it.text != shown-text {
          code-it
        } else {
          raw-to-uraw(
            args,
            markers,
            manual-highlights,
            delimited-highlights.map(h => hl.format-highlight(h, highlight)),
            comments,
            jumps,
            base-style,
            first-line,
            code-it,
          )
        }

        // (`auto` keeps the theme of the original raw element)
        let theme = cf.category-parser("code", args, it.lang).theme
        if theme == auto { theme = it.theme }
        [#raw(
          lang: it.lang,
          theme: theme,
          shown-text,
        )<uraw-code>]
      }
    }

    body
  }

  // The style outside of the raw environments, used by the headers, footers and comments:
  // - for a whole document (`#show: uraw`), it is read directly, which costs no layout pass,
  // - for a raw block (which can be the body of a figure, whose kind is detected only if the raw block is not in a context), it is stored in a state
  if type(body) == content and body.func() == raw {
    context {
      let style = cf.outside-style()
      cf.uraw-style.update(styles => styles + (style,))
    }
    with-base-style(cf.base-style)
    cf.uraw-style.update(styles => styles.slice(0, -1))
  } else {
    context {
      let style = cf.outside-style()
      with-base-style(() => style)
    }
  }
}
