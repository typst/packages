#import "config.typ" as cf
#import "formatting.typ" as formatting
#import "highlight.typ" as hl
#import "../styling/highlights.typ" as hs
#import "measure.typ" as me
#import "rendering.typ" as re
#import "utils.typ" as ut

#let diff-to-uraw(args, old-it, new-it, entries, base-style, first-lines) = {
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
    let lang = (new-it, old-it)
      .map(it => it.at("lang", default: none))
      .find(l => l != none)
    let general = cf.diff-category-parser("general", args, lang)
    let with-default-thickness(stroke) = ut.with-default-thickness(
      stroke,
      general.default-stroke-thickness,
    )

    let frame = cf.diff-category-parser("frame", args, lang)
    let header = cf.diff-category-parser("header", args, lang)
    let footer = cf.diff-category-parser("footer", args, lang)
    let number = cf.diff-category-parser("numbers", args, lang)
    let code = cf.diff-category-parser("code", args, lang)
    let lang-tag = cf.diff-category-parser("lang-tag", args, lang)
    let comment = cf.diff-category-parser("comment", args, lang)
    let jump = cf.diff-category-parser("jump", args, lang)
    let highlight = cf.diff-category-parser("highlight", args, lang)
    let diff-marker = cf.diff-category-parser("diff-marker", args, lang)
    let confs = (
      old: cf.diff-category-parser("old", args, lang),
      new: cf.diff-category-parser("new", args, lang),
    )

    // (`auto` is the leading of the paragraphs around)
    if code.line-spacing == auto { code.line-spacing = par.leading }
    set par(leading: code.line-spacing)

    layout(layout-size => {
      let frame = formatting.frame-width(frame, layout-size)

      // The measures only take the settings above into account in a new context
      context {
        // (the settings are modified below)
        let (general, frame, header, footer, number, code, lang-tag) = (
          general,
          frame,
          header,
          footer,
          number,
          code,
          lang-tag,
        )
        let diff-marker = diff-marker
        let columns = formatting.diff-columns(general.columns)
        let same-code = columns.len() == 1
        // (the start and end of the numbers, and the continuations, can be given by version)
        number.start = formatting.by-version(number.start, auto)
        number.end = formatting.by-version(number.end, none)
        let follows = formatting.by-version(
          args.at("follows", default: false),
          false,
        )
        let precedes = formatting.by-version(
          args.at("precedes", default: false),
          false,
        )

        // Continuation: the diff follows or precedes another one, as at a page break
        // For each version, the last line of the preceding block (the lines being numbered from the next one), the largest number of the following blocks (the number column being wide enough for it), and the widest markers of both (the marker column being wide enough for them)
        let (widest-number, widest-markers) = ((:), (:))
        for v in ("old", "new") {
          let (last-line, follows-marker) = formatting.continuation(
            follows.at(v),
            "follows",
          )
          let (largest-line, precedes-marker) = formatting.continuation(
            precedes.at(v),
            "precedes",
          )
          if last-line != none { number.start.at(v) = last-line + 1 }
          widest-number.insert(
            v,
            if largest-line != none and number.format != none {
              formatting.shown-number(number, largest-line)
            },
          )
          widest-markers.insert(v, (follows-marker, precedes-marker).filter(
            m => m != none,
          ))
        }
        let (follows, precedes) = (follows, precedes).map(c => (
          c.values().any(x => x != false)
        ))

        // Basic formatting
        lang-tag.visible = (
          lang-tag.visible
            and not (
              lang-tag.icon == none
                and (
                  lang-tag.name == none
                    or (lang-tag.name == auto and lang == none)
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
          lang,
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
        general.sep = with-default-thickness(general.sep)

        // Difference
        let its = (old: old-it, new: new-it)
        let diff = formatting.compute-diff(
          old-it.lines.map(l => l.text),
          new-it.lines.map(l => l.text),
        )
        let nbr-lines = (old: old-it.lines.len(), new: new-it.lines.len())

        // Numbers (the colors follow the rows)
        number.visible = number.format != none
        general.coloring-follow-numbers = false
        let numbers = formatting.diff-numbers(
          number,
          entries.jumps,
          nbr-lines,
          first-lines,
          with-default-thickness,
        )
        // The lines skipped by the jumps are not shown, nor compared
        let kept = (old: numbers.old.kept, new: numbers.new.kept)
        if kept.old.len() < nbr-lines.old or kept.new.len() < nbr-lines.new {
          let kept-texts(v) = kept.at(v).map(i => its.at(v).lines.at(i).text)
          diff = formatting.compute-diff(kept-texts("old"), kept-texts("new"))
          nbr-lines = (old: kept.old.len(), new: kept.new.len())
        }
        let (_, colored-code) = formatting.coloring(
          numbers.new.number,
          code,
          general,
          frame,
          (),
          calc.max(..nbr-lines.values()),
        )
        // (the lang tag being in the color of the code of the first line by default)
        if lang-tag.color == auto { lang-tag.color = (colored-code.color)(0) }
        lang-tag.block = formatting.lang-tag-block(lang, lang-tag, frame)
        lang-tag.insert(
          "width",
          if lang-tag.visible and (lang-tag.in-code or lang-tag.in-header) {
            measure(lang-tag.block).width + lang-tag.spacing.to-absolute()
          } else { 0pt },
        )

        // The comments of each version
        let comments = (:)
        for v in ("old", "new") {
          let n = numbers.at(v)
          let single-comment(c, g, k) = (
            formatting.single-comment(
              c,
              g,
              k,
              n.number,
              colored-code,
              base-style,
              with-default-thickness,
            )
              + (version: v)
          )
          // (without numbers, only the jumps skipping lines have an effect)
          let jumps-of(version) = formatting
            .of-version(entries.jumps, version)
            .filter(j => (
              number.visible or j.at("skip-lines", default: false)
            ))
          comments.insert(
            v,
            (
              formatting.jump-comments(
                jumps-of(v),
                jump,
                comment,
                n.line-index,
                single-comment,
              )
                + formatting.comments(
                  formatting.of-version(entries.comments, v),
                  comment,
                  n.line-numbers,
                  single-comment,
                )
            ),
          )
        }
        // The markers of the spanning comments are in the gutter of the old code
        let spanning(c) = c.span and not same-code
        let marker-comments = (
          old: comments.old + comments.new.filter(spanning),
          new: comments.new.filter(c => not spanning(c)),
        )

        // Each version: its markers, numbers and highlights
        let char-height = measure("#").height
        let versions = (:)
        for v in ("old", "new") {
          let n = numbers.at(v)
          let marker = formatting.marker(general, n.number)
          let (number-markers, markers, marker) = formatting.markers(
            cf.parse-markers(
              formatting.of-version(entries.markers, v),
              n.line-index,
              n.line-numbers,
            ),
            marker-comments.at(v),
            marker,
            char-height,
          )
          // (the column of the markers is wide enough for the widest markers of the preceding and following blocks, the marker column being shown)
          if marker.over-numbers {
            marker.number-markers += widest-markers.at(v)
          } else if widest-markers.at(v).len() > 0 {
            marker.visible = true
            marker.markers += widest-markers.at(v)
          }
          let version-number = formatting.number-cells(
            n.number,
            general,
            number-markers,
            n.line-numbers,
            version: v,
          )
          (version-number, _) = formatting.coloring(
            version-number,
            code,
            general,
            frame,
            (),
            nbr-lines.at(v),
          )

          // (the highlights are on all the lines of the code, the shown ones being kept)
          let code-lines = formatting.lines(its.at(v), code)
          versions.insert(v, (
            conf: confs.at(v),
            status: diff.at(v).status,
            number: version-number,
            comments: comments.at(v),
            marker: marker,
            markers: markers,
            code-lines: code-lines,
            lines: kept.at(v).map(i => code-lines.at(i)),
            // (the changes first, so that the highlights are drawn over them)
            highlights: (
              (
                formatting.diff-changes(
                  diff,
                  v,
                  confs.at(v),
                  highlight,
                  kept.at(v),
                ),
                (),
              ),
              (entries.delimited.at(v), entries.highlights.at(v)),
            )
              .map(((delimited, manual)) => formatting.highlights(
                manual,
                delimited,
                code-lines,
                k => kept.at(v).at((n.line-index)(k)),
                with-default-thickness,
              ))
              .join(),
          ))
        }
        code = colored-code
        number = versions.new.number

        // Header & footer
        (header, footer) = formatting.header-footer(
          header,
          footer,
          frame,
          code,
          lang-tag,
          base-style,
          calc.max(..nbr-lines.values()),
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

        // The merged codes share their marker column
        if same-code {
          let visible = (
            versions.old.marker.visible or versions.new.marker.visible
          )
          let markers = (
            versions.old.marker.markers + versions.new.marker.markers
          )
          for v in ("old", "new") {
            versions.at(v).marker.visible = visible
            versions.at(v).marker.markers = markers
          }
        }

        // The insets of the cells (the merged old numbers being followed by the new ones, the frame inset on each side)
        assert(
          type(diff-marker.gutter) == length,
          message: "The `gutter` of the diff markers must be a length.",
        )
        let side-visible = (
          versions.old.marker.visible or versions.new.marker.visible
        )
        diff-marker.inset = formatting
          .cell-insets(frame, number, side-visible, code.line-spacing)
          .diff-marker
        let code-insets = (:)
        for v in ("old", "new") {
          let insets = formatting.cell-insets(
            frame,
            number,
            versions.at(v).marker.visible,
            code.line-spacing,
            diff-marker-visible: diff-marker.visible,
          )
          versions.at(v).number.inset = insets.number
          versions.at(v).marker.inset = insets.marker
          if diff-marker.visible {
            insets.code.left = diff-marker.gutter
          }
          code-insets.insert(v, insets.code)
        }
        if same-code {
          versions.old.number.inset.right = versions.old.number.inset.left
        }
        code.inset = code-insets.new

        // Widths before the codes

        let char-width = measure("#").width
        for v in ("old", "new") {
          let (numbers-width, markers-width) = me.numbers-markers-width(
            versions.at(v).number,
            versions.at(v).marker,
            widest: widest-number.at(v),
            monotonic: type(number.format) != function,
          )
          versions.at(v).numbers-width = numbers-width
          versions.at(v).markers-width = markers-width
        }

        diff-marker.width = if diff-marker.visible {
          (
            diff-marker.inset.left
              + calc.max(
                ..(
                  confs.old.diff-marker,
                  confs.new.diff-marker,
                  diff-marker.unchanged,
                ).map(m => measure(m).width),
              )
              + diff-marker.inset.right
          )
        } else { 0pt }

        // The gutter between the separated codes, with the separator at its center (its first half being in the old code)
        let frame-width = (
          if frame.width == auto { layout-size.width } else { frame.width }
        ).to-absolute()
        let sep-thickness = if general.sep == none { 0pt } else {
          let t = stroke(general.sep).thickness
          (if t == auto { 1pt } else { t }).to-absolute()
        }
        let column-gutter = general.column-gutter
        column-gutter = if type(column-gutter) == ratio {
          frame-width * column-gutter
        } else if type(column-gutter) == relative {
          frame-width * column-gutter.ratio + column-gutter.length.to-absolute()
        } else { column-gutter.to-absolute() }
        let gutter = if same-code { 0pt } else {
          calc.max(column-gutter, sep-thickness) / 2
        }

        // The gutter of each version (both number columns for merged codes), and the start of its code
        for v in ("old", "new") {
          versions.at(v).code = code + (inset: code-insets.at(v))
          versions.at(v).pre-width = if same-code {
            (
              versions.old.numbers-width
                + versions.new.numbers-width
                + versions.new.markers-width
            )
          } else { versions.at(v).numbers-width + versions.at(v).markers-width }
          versions.at(v).code-start = (
            versions.at(v).pre-width + diff-marker.width
          ).to-absolute()
        }
        versions.old.code.inset.right += gutter

        // The lang tag in the code is on the first line (of the new code for separated codes)
        let lang-tag-of(v) = if same-code or v == "new" { lang-tag } else {
          lang-tag + (visible: false, width: 0pt)
        }

        // Comments position
        for v in ("old", "new") {
          versions.at(v).comments = formatting.comments-position(
            versions.at(v).comments,
            versions.at(v).lines,
            versions.at(v).code,
            versions.at(v).pre-width,
            versions.at(v).marker.inset,
            char-width,
            code-start: versions.at(v).code-start,
          )
        }

        // Available width

        let insets(v) = (
          versions.at(v).code.inset.left + versions.at(v).code.inset.right
        ).to-absolute()
        let available = (
          if same-code {
            frame-width - versions.new.code-start - insets("new")
          } else {
            (
              frame-width
                - versions.old.code-start
                - versions.new.code-start
                - insets("old")
                - insets("new")
                - gutter
            )
          }
        ).to-absolute()

        // Width

        let natural(v) = {
          let lines = formatting.break-lines(
            versions.at(v).lines,
            available,
            lang-tag-of(v),
            char-width,
            indented: code.indented-line-return,
          )
          let width = me.tight-code-width(
            (width: auto),
            available,
            lang-tag-of(v),
            lines,
            char-width,
          )
          me.comments-code-width(
            (width: auto),
            versions.at(v).comments,
            versions.at(v).code,
            width,
            available,
          )
        }
        let code-widths = me.diff-code-widths(
          columns,
          if same-code { (calc.max(natural("old"), natural("new")),) } else {
            (natural("old"), natural("new"))
          },
          available,
          frame.width != auto,
        )
        versions.old.code-width = code-widths.first()
        versions.new.code-width = code-widths.last()

        let side-width(v) = (
          versions.at(v).code-start + insets(v) + versions.at(v).code-width
        ).to-absolute()
        let total-width = if same-code { side-width("new") } else {
          side-width("old") + gutter + side-width("new")
        }

        // The header and the footer can enlarge the codes
        (header, footer) = formatting.align-header-footer(
          header,
          footer,
          versions.old.code-start,
          code,
        )
        let header-width = if header.content != none {
          measure(width: layout-size.width, block(
            inset: header.inset,
            header.content,
          )).width
        } else { 0pt }
        let footer-width = if footer.content != none {
          measure(width: layout-size.width, block(
            inset: footer.inset,
            footer.content,
          )).width
        } else { 0pt }
        let hf-width = calc.max(header-width, footer-width)
        if hf-width > total-width {
          versions.new.code-width += hf-width - total-width
          if same-code { versions.old.code-width = versions.new.code-width }
          total-width = hf-width
        }
        frame.width = total-width

        // Lines, comments and highlights
        let comments = (:)
        for v in ("old", "new") {
          let code-lines = formatting.break-lines(
            versions.at(v).code-lines,
            versions.at(v).code-width,
            lang-tag-of(v),
            char-width,
            indented: code.indented-line-return,
          )
          versions.at(v).lines = kept.at(v).map(i => code-lines.at(i))
          versions.at(v).highlights = formatting.kept-highlights(
            formatting.highlights-by-line(
              versions.at(v).highlights,
              code-lines,
              versions.at(v).code-width,
              versions.at(v).code,
              char-width,
            ),
            kept.at(v),
          )
          comments.insert(v, formatting.comments-by-gap(
            versions.at(v).comments,
            versions.at(v).code,
            versions.at(v).code-width,
            versions.at(v).number,
            versions.at(v).numbers-width,
            versions.at(v).marker,
            versions.at(v).markers-width,
            nbr-lines.at(v),
          ))
        }

        // Rendering

        let frame-content = re.render-diff(
          formatting.diff-rows(diff, comments, same-code),
          versions,
          same-code,
          number,
          code,
          diff-marker,
          general,
          gutter,
          frame,
          header,
          footer,
          if lang-tag.visible and lang-tag.in-code { lang-tag.block },
          char-width,
          char-height,
        )

        let frame-block = block(
          fill: frame.block.fill,
          radius: frame.block.radius,
          stroke: frame.block.stroke,
          clip: not frame.sharp-page-break,
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
              align(alignment, lang-tag.block),
            )
            if is-top {
              stack(dir: ttb, lang-tag.block, frame-block)
            } else {
              stack(dir: ttb, frame-block, lang-tag.block)
            }
          }
        } else {
          frame-block
        }
      }
    })
  }
}

/// Display a diff between an old and a new version of some code.
///
/// #example(````
/// #uraw-diff(
///   markers: (old: (5, sym.arrow.r.hook), new: ((4, sym.arrow.r.hook), (6, sym.arrow.r.hook))),
///   ```typ
///   #let check-recipe(ingredients) = {
///     if not "salt" in ingredients {
///       panic("*!There is no salt !!!!*")
///     } else {
///       [Make sure it includes umami flavors.]
///     }
///   }
///   ```,
///   ```typ
///   #let correct-recipe(ingredients) = {
///     if not "salt" in ingredients {
///       ingredients.push("*|A pinch of salt.|*")
///       msg = [It lacked some salt.]
///     } else {
///       msg = [Make sure it includes umami flavors.]
///     }
///     return (msg, ingredients)
///   }
///   ```,
/// )
/// ````)
///
/// For `markers`, `highlights`, `comments` and `jumps`, a single entry, an array of entries or a dictionary grouping entries by version (`(old: ..., new: ...)`) are all valid. Under the dictionary form, entries are given without their `version`.
///
/// If the show rule is used (`#show: uraw`), lines of an `uraw-diff` in a labeled figure can be referenced with `@label.version.n`.
///
/// Look at the #link("https://github.com/JulesViennotFranca/ultraw/blob/main/docs/doc.pdf")[Docs] for a complete overview of what is possible with `uraw-diff`.
///
/// - args (arguments): The settings (see `set-uraw` and `set-uraw-diff` for their description). The numbers `start` and `end` can be given by version, as `(old: ..., new: ...)` dictionaries.
///
/// - markers (array, dictionary): Each marker is given as `(version, line, content)` or `(version: ..., line: ..., content: ...)`. `line` takes a single line or a range `(from, to)`.
///
/// - highlights (array, dictionary): Each highlight targets a `version` and the range it covers is given either by `line` or `start` and `end`. `line` can take a single line number or a pair `(from, to)`. `start` and `end` both can take a single line number (meaning the start and end of that line) or a pair `(line, character)` to point at an exact code location. Each highlight can have specific styling parameters (`fill`, `stroke`, `radius`, `code-style`, `sticky`, `expand`, see `set-uraw` for more details).
///
/// - comments (array, dictionary): Each comment is given as `(version, line, content)` (the comment is displayed after the line) or a dictionary with `version`, `after` / `before` indicating the targeted line, `content`, and styling parameters (`style`, `indent`, `fill`, `separate`, `marker`, `marker-fill`, `marker-placement`, see `set-uraw` for more details). Additionally, comments can `span` over both code versions (see `set-uraw-diff` for more details).
///
/// - jumps (array, dictionary): Each jump is given as `(version, from, to)` or a dictionary with `version`, `from`, `to`, whether to `skip-lines (bool)` of the raw text of the version, and the associated comment parameters (`comment`, `indent`, `fill`, `separate`, `marker`, `marker-fill`, `marker-placement`, see `set-uraw` for more details, and the additional `span` parameter, see `set-uraw-diff` for more details). `from` and `to` take integer values or `start` and `end`.
///
/// - follows (bool, int, content, array, dictionary): Whether the block continues a previous one; it then renders as after a page break (no top radius, no top stroke, etc.). For a correct numbering and to display the accurate width of the numbers column, an integer value represents the last line of the preceding block, content is the widest marker of the preceding blocks (the marker column being shown and made wide enough for it), and a pair `(number, marker)` gives both. This can be specific to each version by giving an `(old: ..., new: ...)` dictionary.
///
/// - precedes (bool, int, content, array, dictionary): Whether the block is continued by a next one; it then renders as before a page break (no bottom radius, no bottom stroke, etc.). To display the accurate width of the numbers column, an integer value is the largest line number of the following blocks, content is their widest marker, and a pair `(number, marker)` gives both. This can be specific to each version by giving an `(old: ..., new: ...)` dictionary.
///
/// - old (content | raw | path | dictionary): The old code, given as a raw text block, a path indicating the file to read the code from, or the dictionary output of `read-code`.
///
/// - new (content | raw | path | dictionary): The new code, given as a raw text block, a path indicating the file to read the code from, or the dictionary output of `read-code`.
///
/// -> content
#let uraw-diff(
  markers: (),
  highlights: (),
  comments: (),
  jumps: (),
  follows: false,
  precedes: false,
  old,
  new,
  ..args,
) = {
  let (old, old-first-line) = cf.code-input(old)
  let (new, new-first-line) = cf.code-input(new)
  let lang = (new, old)
    .map(it => it.at("lang", default: none))
    .find(l => l != none)
  // Settings given by category or flat (e.g. `header-fill`)
  let args = cf.normalize-settings(args.named(), cf.diff-spec)
  args += (follows: follows, precedes: precedes)
  let entries = (
    markers: formatting.versioned(markers, ("line", "content")),
    comments: formatting.versioned(comments, ("after", "content")),
    jumps: formatting.versioned(jumps, ("from", "to")),
  )
  let highlights = formatting.versioned(highlights, ())

  // The style outside of the raw environments, used by the headers, footers and comments (stored in a state, so that the raw element is not in a context: a figure containing a diff is then a listing)
  context {
    let style = cf.outside-style()
    cf.uraw-style.update(styles => styles + (style,))
  }
  {
    // (only the raw elements of this diff: a raw block in a comment is another one)
    show <uraw-diff-src>: src-it => if src-it.text != new.text { src-it } else {
      context {
        let highlight = cf.diff-category-parser("highlight", args, lang)
        let pre-highlights = hs.list()
        let formatted-pre-highlights = pre-highlights.map(
          h => hl.format-pre-highlight(h, highlight),
        )

        // The highlights read from the delimiters, and the texts without them
        let texts = (:)
        let entries = entries + (delimited: (:), highlights: (:))
        for (v, it) in (old: old, new: new) {
          let (dels, lines) = hl.parse-delimiters(
            it.text.split("\n"),
            formatted-pre-highlights,
          )
          texts.insert(v, lines.join("\n", default: ""))
          entries.delimited.insert(v, dels.map(del => hl.format-highlight(
            hl.make-highlight(formatted-pre-highlights.at(del.idx), del),
            highlight,
          )))
          entries.highlights.insert(
            v,
            formatting
              .of-version(highlights, v)
              .map(h => hl.format-highlight(h, highlight)),
          )
        }

        // (`auto` keeps the theme of each original raw element, a theme set with `set raw` applying when it has none)
        let code-theme = cf.diff-category-parser("code", args, lang).theme
        let theme(it) = if code-theme == auto {
          if it.has("theme") { (theme: it.theme) } else { (:) }
        } else { (theme: code-theme) }

        // The two codes are shown as raw elements, to get their highlighted lines
        set text(1.25em)
        show <uraw-diff-new>: new-it => if new-it.text != texts.new {
          new-it
        } else {
          show <uraw-diff-old>: old-it => if old-it.text != texts.old {
            old-it
          } else {
            diff-to-uraw(
              args,
              old-it,
              new-it,
              entries,
              cf.base-style,
              (old: old-first-line, new: new-first-line),
            )
          }
          set text(1.25em)
          [#raw(
            texts.old,
            lang: lang,
            block: true,
            ..theme(old),
          )<uraw-diff-old>]
        }
        [#raw(texts.new, lang: lang, block: true, ..theme(new))<uraw-diff-new>]
      }
    }
    [#raw(new.text, lang: lang, block: true)<uraw-diff-src>]
  }
  cf.uraw-style.update(styles => styles.slice(0, -1))
}
