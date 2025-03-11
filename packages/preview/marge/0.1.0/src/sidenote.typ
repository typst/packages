#import "resolve.typ": *
#import "validate.typ": validate

/// Get the margin note state for a specific page.
#let page-state(page) = state("marge:0.1.0/page-" + str(page), ())
/// Get the container mark metadata for a specific page.
#let page-container(page) = metadata("marge:0.1.0/container-" + str(page))
/// The sidenote counter.
#let counter = counter("sidenote")

/// The default format for margin notes.
#let default-format(it) = {
  let num = if it.numbering != none {
    link(it.source, super(it.counter.display(it.numbering)))
    h(0.05em, weak: true)
  }
  par(
    hanging-indent: par.hanging-indent + measure(num).width,
    num + h(0pt, weak: true) + it.body
  )
}

/// A container of all margin notes of the current page.
///
/// To be used as the page's `background` or `foreground` parameter when the
/// page width is set to `auto`, as notes then cannot be automatically placed
/// in the right margin.
#let container = context {
  page-container(here().page())
  for note in page-state(here().page()).final() {
    place(top + note.side, note.body, dy: note.position.y)
  }
}

/// A sidenote to be placed in the page margin.
/// 
/// If this note ends up on the right margin of a page with width set to
/// `auto`, it cannot be placed automatically. In this case, the page's
/// `background` or `foreground` should be set to the include the `container`
/// provided by this package.
/// 
/// There are two correction mechanisms in place:
/// - When two notes would overlap, the second one is moved down to avoid this.
/// - When a note would overflow into the bottom margin, it is moved up. Any
///   previous notes that this note would now overlap with are also moved up.
/// 
/// # Parameters:
/// - `side`: The margin where the note should be placed.
/// - `dy`: A custom offset by which the note should be moved along the y-axis.
/// - `padding`: The space between the note and the page or content border.
/// - `gap`: The minimum gap between two consecutive notes.
/// - `numbering`: How the note should be numbered.
/// - `counter`: The counter to be used for numbering.
/// - `format`: The "show rule" of the note.
/// - `body`: The body of the note.
#let sidenote(
  side: auto,
  dy: 0pt,
  padding: 2em,
  gap: 0.4em,
  numbering: none,
  counter: counter,
  format: it => it.default,
  body
) = {
  // Validate parameters.
  validate(
    side: side,
    dy: dy,
    padding: padding,
    gap: gap,
    numbering: numbering,
    counter: counter,
    format: format,
    body: body
  )

  // Place number in paragraph.
  if numbering != none {
    counter.step()
    context {
      let state = page-state(here().page())
      let note = state.final().at(state.get().len())
      let pos = note.position
      pos.x += note.padding.left

      let num = counter.display(numbering)
      h(0pt, weak: true) + link(pos, super(num))
    }
  }
  
  h(0pt, weak: true) + sym.zwj + context {
    // Use side with largest margin if side is `auto`.
    let side = if side != auto { side } else {
      let margin-left = resolve-margin(left)
      let margin-right = resolve-margin(right)

      if margin-left > margin-right { left }
      else if margin-right > margin-left { right }
      else { "outside" }
    }

    // Resolve values.
    let side = resolve-side(side)
    let padding = resolve-padding(padding)
    let margin = resolve-margin(side)
    let bottom-margin = resolve-margin(bottom)
    let (width: page-width, height: page-height) = resolve-page-size()
    let gap = gap.to-absolute()
    let leading = par.leading.to-absolute()

    // Create note content.
    let note-body = block(inset: padding, width: margin, {
      set align(start)
      set text(size: 0.85em)
      set par(leading: 0.5em)

      let source = here()
      context {
        let it = (
          side: side,
          numbering: numbering,
          counter: counter,
          padding: padding,
          margin: margin,
          source: source,
          body: body,
        )
        it.default = default-format(it)
        format(it)
      }
    })
    
    // Resolve dy relative to note-height (if given as ratio).
    let note-height = measure(note-body).height
    let dy = if type(dy) == length { dy }
             else if type(dy) == ratio { dy * note-height }
             else if type(dy) == relative { dy.ratio * note-height + dy.length }
  
    // Calculate position of note on y-axis. The note is moved up, so that it
    // aligns with the line of the paragraph.
    let position = here().position()
    position.y += dy.to-absolute() - measure[x].height

    // Set x-position of note depending on side.
    position.x = if side == right and page-width != auto { page-width - margin }
                 else { 0pt }

    page-state(here().page()).update(notes => {
      let position = position
      
      // Move note down to avoid overlap with previous one.
      let prev = notes.at(-1, default: none)
      position.y += if prev != none and prev.side == side {
        let gap = calc.max(gap, prev.gap)
        let overlap = prev.position.y + prev.height - position.y + leading + gap
        calc.max(0pt, overlap)
      }

      // Move note up to avoid overflow into bottom page margin.
      let overflow = position.y + note-height - page-height + bottom-margin
      position.y -= calc.max(0pt, overflow)

      // Summarize data of the new note.
      let new = (
        position: position,
        height: note-height,
        side: side,
        gap: gap,
        padding: padding,
        body: note-body
      )

      // Move previous notes up to restore the gap and prevent overlap with
      // previously moved up notes, starting from the bottom.
      let current = new
      for (i, prev) in notes.enumerate().rev().filter(((_, note)) => note.side == side) {
        let gap = calc.max(current.gap, prev.gap)
        let overlap = prev.position.y + prev.height - current.position.y + leading + gap
        notes.at(i).position.y -= calc.max(0pt, overlap)
        current = notes.at(i)
      }

      // Append new note to the list of all notes on this page.
      notes + (new,)
    })

    // Place the note on the page. Only use this automatic placement
    // if no container is used for this page!
    if page-container(here().page()) not in query(metadata) {
      let index = page-state(here().page()).get().len()
      let final = page-state(here().page()).final().at(index, default: none)

      if final != none {
        assert(page-width != auto or final.side == left, message: {
          "cannot place note on right margin of page with width auto.\n"
          "hint: import the `container` value of the package and use it as the "
          "page background or foreground"
        })

        box(place(
          final.body,
          dx: final.position.x - here().position().x,
          dy: final.position.y - here().position().y
        ))
      }
    }
  }
}
