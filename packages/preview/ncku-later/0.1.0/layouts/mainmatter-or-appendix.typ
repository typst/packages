// Helper function: check whether the current heading is lavel-1 heading
#let is-chapter-start-page() = {
  // find chapter headings on the current page.
  let all-level-one-heading = query(heading.where(level: 1))
  let current-page = here().page()
  return (
    all-level-one-heading
      .filter(it => {
        it.location().page() == current-page
      })
      .len()
      > 0
  )
}

// define custom numbering function
#let custom-numbering-mainmatter(..args) = {
  if args.pos().len() == 1 {
    "Chapter " + str(args.pos().at(0)) + "."
  } else {
    numbering("1.1.1.", ..args)
  }
}
#let custom-numbering-appendix(..args) = {
  if args.pos().len() == 1 {
    "Appendix " + numbering("A", args.pos().at(0)) + "."
  } else {
    numbering("A.1.1.", ..args)
  }
}

/*
 * NOTE: this should be applied to the mainmatter of the thesis/dissertation which excludes the appendix part
 */
#let mainmatter-or-appendix(mode: (mainmatter: true, appendix: false), doc) = {
  // check mode
  assert(
    (
      (mode.mainmatter and (not mode.appendix))
        or (mode.appendix and (not mode.mainmatter))
    ),
    message: "You should only chose one mode! mainmatter or appendix",
  )

  // chose custom numbering function type according to mode
  let custom-numbering(..args) = if mode.mainmatter {
    custom-numbering-mainmatter(..args)
  } else { custom-numbering-appendix(..args) }

  // reset heading counter
  counter(heading).update(0)

  // Set the page numbering to arabic numerals.
  //
  // Although we use custom headers and footers to display the page numbers in the body part,
  // this is still required to show the page numbers in arabic numerals in the outlines.
  set page(
    margin: (top: 23mm, bottom: 35mm, left: 30mm, right: 25mm),
    numbering: "1",
    header: context {
      if not is-chapter-start-page() {
        let level-1-heading-so-far = query(
          heading.where(level: 1).before(here()),
        )
        let current-chapter-heading = level-1-heading-so-far.last()

        // smallcaps([Chapter ] + str(current-chapter-number) + ".")
        // h(0.75em)
        // smallcaps(current-chapter-heading.body)
        // display chapter info on the left
        smallcaps(
          custom-numbering(counter(heading).get().at(0))
            + " "
            + current-chapter-heading.body,
        )
        // display page number on the right
        h(1fr)
        counter(page).display() // page number
      }
    },
    footer: context {
      if is-chapter-start-page() {
        h(1fr)
        counter(page).display() // page number
      }
    },
  )

  // set paragraph
  set par(
    leading: 1.2em,
    first-line-indent: 1em,
    linebreaks: "optimized",
  )

  set heading(numbering: custom-numbering)

  // NOTE: heading rule 1 -> apply to all headings except for level-1 heading
  show heading: it => {
    if (it.level > 1) {
      set text(size: 14pt)
      v(0.75cm)
      block(
        width: 100%,
        {
          let all-prev-headings = query(
            selector(heading).before(here(), inclusive: false),
          )
          if all-prev-headings.len() > 1 {
            let pre-heading = all-prev-headings.last()
            let is-same-page = (
              pre-heading.location().page() == it.location().page()
            )
            let is-colse = (
              pre-heading.location().position().y + 65pt
                >= it.location().position().y
            )
            if (is-same-page and is-colse) {
              v(-30pt)
            }
          }
          set par(justify: false)
          grid(
            columns: 2,
            gutter: 1em,
            counter(heading).display(it.numbering), it.body,
          )
          v(1em)
        },
      )
    }
  }

  // NOTE: heading rule 2 -> apply to all level-1 headings
  show heading.where(level: 1): it => {
    // Start a chapter on a new page unless it's the 1st chapter,
    // in which case it is already on a new page.
    if counter(heading).get().at(0) != 1 {
      pagebreak()
    }

    // Do not justify top-level headings, which have a large font.
    set par(justify: false)

    if it.numbering == none {
      // Show the body of the heading.
      block(
        width: 100%,
        {
          set text(size: 24pt)
          v(1.5em)
          it.body
          v(1em)
        },
      )
    } else {
      // Show "Chapter n" and the body of the heading on 2 separate lines.
      align(
        center,
        block(
          width: 100%,
          {
            set text(size: 21pt)
            text(counter(heading).display(it.numbering))
            linebreak()
            it.body
            v(1.2cm)
          },
        ),
      )
    }
  }

  // WARN: the order of heading-rule-1 and heading-rule-2 is important
  // WARN: this is because that the first rule only redering all heading except for level-1
  // WARN: then the seoncd rule renders the level-1 headings
  // WARN: swaping of the order will make the rendering rule of level-1 headings be overwritten
  // WARN: which makes level-1 headings disapper

  // display contents
  doc
}

