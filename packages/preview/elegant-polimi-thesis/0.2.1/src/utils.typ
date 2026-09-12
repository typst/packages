/// LaTeX sizes to match original templates (https://tex.stackexchange.com/questions/24599/what-point-pt-font-size-are-large-etc)
/// -> dict
#let _sizes = (
  "10pt": (
    tiny: 5pt,
    scriptsize: 7pt,
    footnotesize: 8pt,
    small: 9pt,
    normalsize: 10pt,
    large: 12pt,
    Large: 14.4pt,
    LARGE: 17.28pt,
    huge: 20.74pt,
    Huge: 24.88pt,
  ),
  "11pt": (
    tiny: 6pt,
    scriptsize: 8pt,
    footnotesize: 9pt,
    small: 10pt,
    normalsize: 10.95pt,
    large: 12pt,
    Large: 14.4pt,
    LARGE: 17.28pt,
    huge: 20.74pt,
    Huge: 24.88pt,
  ),
  "12pt": (
    tiny: 6pt,
    scriptsize: 8pt,
    footnotesize: 10pt,
    small: 10.95pt,
    normalsize: 12pt,
    large: 14.4pt,
    Large: 17.28pt,
    LARGE: 20.74pt,
    huge: 24.88pt,
    Huge: 24.88pt,
  ),
)

/// The current state (title page, \*matter...)
/// -> state
#let _document-state = state("init", "TITLE_PAGE")

/// The current type of document.
/// -> state
#let _document-type = state("init", "phd")

/// Localization dictionary. It could be deprecated since theses are written exclusively in English.
/// -> dict
#let _localization = yaml("locale.yaml")

/// Signature PoliMi colour (#box(baseline: 0.1em, rect(height: 0.7em, width: 0.7em, fill: rgb("#5f859f")))), used in headings and labels.
/// -> color
#let bluepoli = rgb("#5f859f")

// Raggiera related functions

// https://forum.typst.app/t/how-to-use-set-page-without-adding-an-unwanted-pagebreak/3129/2

/// Adds an empty page between an odd page and the next. Used to check when to remove the header and place a raggiera in the bottom left corner.
/// -> content
#let _empty-page() = {
  [#metadata(none) <__chapter-end>]
  pagebreak(weak: true, to: "odd")
  [#metadata(none) <__chapter-start>]
}

/// Check if the current page is between the given labels.
/// -> bool
#let _is-page-between-labels(
  /// The start label.
  /// -> label
  start-label,
  /// The end label.
  /// -> label
  end-label,
  /// Function to apply to the array.
  /// -> function
  function,
) = query(start-label).zip(query(end-label)).any(function)

/// Check if a page is empty.
/// -> bool
#let _is-page-empty() = _is-page-between-labels(
  <__chapter-end>,
  <__chapter-start>,
  ((start, end)) => {
    let page = here().page()
    let first-page = start.location().page()
    let last-page = end.location().page()
    return page > first-page and page < last-page
  },
)

/// Check if a page is in an outline.
/// -> bool
#let _is-page-in-outline() = _is-page-between-labels(
  <__toc-start>,
  <__toc-end>,
  ((start, end)) => {
    let page = here().page()
    let first-page = start.location().page()
    let last-page = end.location().page()
    return not _is-page-empty() and page > first-page and page < last-page or page == first-page or page == last-page
  },
)

/// Inserts a raggiera, given a specified width.
/// -> content
#let _raggiera-image(
  /// Side of the raggiera.
  /// -> length
  side,
) = (
  image(
    width: side,
    height: side,
    "img/raggiera.svg",
  )
)

/// Draw a banner.
/// -> content
#let banner(
  /// Body of the banner.
  /// -> content
  body,
) = rect(
  width: 100%,
  fill: bluepoli.lighten(40%), // #9AAFC2
  inset: (rest: 1em, x: 1.7em),
  text(
    fill: white,
    body,
  ),
)

// Numbering functions

/// Alternative numbering: ```typc "1.1." + h-space```.
/// -> content
#let tab-numbering(
  /// Horizontal space.
  /// -> length
  h-space: 0.7em,
  /// Numbers.
  /// -> arguments
  ..n,
) = return n.pos().map(str).join(".") + "." + h(h-space)

/// Chapter numbering.
/// -> content
#let chapter-numbering(
  /// Numbers.
  /// -> arguments
  ..n,
) = return text(weight: "bold", str(n.pos().first())) + h(1.5mm) + "|" + h(7.5mm)

/// Numbering used in the theses header.
/// -> content
#let header-numbering(
  /// Numbers.
  /// -> arguments
  ..n,
) = return str(n.pos().first()) + "| "

#let shared-formatting(title, author, language, body, text-size: 11pt, keywords: "") = {
  set document(
    title: title,
    author: author,
    keywords: keywords,
  )

  set text(
    lang: language,
    size: text-size,
    font: "New Computer Modern",
    hyphenate: true,
  )
  show math.equation: set text(font: "New Computer Modern Math")

  set par(
    justify: true,
    linebreaks: "optimized",
    spacing: 0.7em,
    first-line-indent: 0pt,
  )

  set figure(gap: 1.5em)
  show figure: set block(breakable: true)
  show: _style-figures.with(colored-caption: true, heading-levels: 1)

  body
}

/// Helper function to detect whether a field is present and, if true, show it.
/// -> content
#let _show-field(
  /// Prefix (e.g. "Prof: "),
  /// -> str
  prefix,
  /// Exact field to check (e.g. title).
  /// -> variable
  field,
  /// Separator between fields.
  /// -> function | content
  separator: linebreak(),
) = {
  if (field != none and field != "") {
    return prefix + field + separator
  }
}

/// Helper function to handle (co)supervisor(s).
/// -> content
#let _show-starvisor(
  /// (Co)Supervisor(s) of the thesis.
  /// -> str | array
  starvisor,
  /// The key to look for in the locale dictionary
  /// -> "supervisor" | "cosupervisor"
  locale-key,
  /// How to seperate the key from the content.
  /// -> string | content
  separator: ": ",
  /// How to separate multiple starvisors.
  /// -> string | content
  join-separator: ", ",
  /// Function that will be applied to the key.
  /// -> function
  key: x => x,
  /// Function that will be applied to the content.
  /// -> function
  out: x => x,
) = {
  if (starvisor == none) { return }
  context {
    if type(starvisor) == str or (type(starvisor) == array and starvisor.len() == 1) {
      key(_localization.at(text.lang).at(locale-key)) + separator + out(starvisor)
    } else if type(starvisor) == array and starvisor.len() > 1 {
      key(_localization.at(text.lang).at(locale-key + "s")) + separator + starvisor.map(out).join(join-separator)
    } else {
      panic("(Co)supervisor(s) must be passed as string or as array.")
    }
    linebreak()
  }
}

/// Helper function to show localized author.
/// -> content
#let _show-author() = context {
  return _localization.at(text.lang).author + ": "
}

/// Helper function to show localized academic year.
/// -> content
#let _show-academic-year(year: none) = context {
  if (year == none) {
    return _localization.at(text.lang).academic-year
  } else {
    return _localization.at(text.lang).academic-year + ": " + year
  }
}

/// Helper function to show the thesis cycle.
/// -> content
#let _show-cycle(cycle) = context {
  if (cycle != none) {
    " -- " + cycle + " " + _localization.at(text.lang).cycle
  } else {
    linebreak()
  }
}

// =====================
// PRESENTATION
// =====================

#import "@preview/touying:0.7.4": *

/// The background panes used in some slides.
/// -> dict
#let _pane = (
  left: 15.86cm,
  right: 51.86cm,
)

/// (1..20) -> (01,02,03,..., 10, 11, 12,...,20)
/// -> numbering
#let _numbering-with-padding = (..args) => {
  let numbers = args.pos()
  let output = numbering(
    "1",
    ..numbers,
  )
  if (str(numbers.first()).len() == 1) {
    output = "0" + output
  }
  return output
}

/// Empty block.
/// -> content
#let _spacer(width, height) = block(
  width: width,
  height: height,
)

/// Internal stroke.
/// -> stroke
#let _stroke-no-border(color) = (x, y) => (
  top: if (y > 0) { (paint: color, thickness: 0.1pt) },
  left: if (x > 0) { (paint: color, thickness: 0.1pt) },
)

/// Custom made header.
/// -> content
#let _poli-header(
  /// The text arguments for the title.
  /// -> dict
  text-args: (size: 15pt, weight: "regular", fill: rgb("#5e5e5e")),
  self,
) = context {
  set text(..text-args)
  let svg-bytes = read("img/9-cerchi.svg")
  svg-bytes = svg-bytes.replace(
    "#aaaaaa",
    text-args.fill.to-hex(),
  )
  let toc-label = query(<_polimi-digital-presentation-toc>)
  show: pad.with(left: 2cm, right: 1.25cm)
  grid(
    columns: (_pane.left, 1fr),
    {
      _numbering-with-padding(counter(heading.where(level: 1)).at(here()).at(0))
      ". "
      utils.display-current-heading(level: 1, numbered: false)
    },
    {
      let arr = ()
      if (self.info.title != none) {
        arr.push(self.info.title)
      }
      if (self.info.date != none) {
        arr.push(utils.display-info-date(self))
      }
      arr.join(" | ")
      h(1fr)
      if toc-label.len() != 0 {
        link(
          (page: toc-label.first().location().page(), x: 0pt, y: 0pt),
          box(
            image(bytes(svg-bytes), height: 1em),
            baseline: 10%,
          ),
        )
      }
      h(1cm)
      context utils.slide-counter.display()
    },
  )
}

/// Apply a fill colour to the panes.
/// -> content
#let _poli-bg-split() = {
  set rect(stroke: none, height: 100%)
  stack(
    dir: ltr,
    rect(width: _pane.left, fill: rgb("#fdfdfd")),
    rect(width: _pane.right, fill: rgb("#f3f3f3")),
  )
}

// DIVIDER

/// New section body, that is title, lettering and chapter number.
/// -> content
#let _divider-body(title, lettering, number, text-fill) = {
  if title != none {
    pad(
      top: 7.54cm,
      left: 15.93cm,
      text(
        size: 54pt,
        weight: "bold",
        fill: text-fill,
        title,
      ),
    )
  }
  if lettering != none {
    place(
      bottom,
      pad(
        bottom: 0.32cm, // forse da sistemare
        left: 15.93cm,
        text(
          fill: text-fill,
          lettering,
        ),
      ),
    )
  }
  if number != none {
    place(
      right + bottom,
      pad(
        right: 2.71cm,
        bottom: 2cm,
        text(
          size: 200pt,
          weight: "light",
          fill: text-fill,
          number,
        ),
      ),
    )
  }
}

/// Style the new section background.
/// -> content
#let _divider-bg-args(fill, stroke) = {
  return (
    fill: fill,
    background: {
      place(top + left, grid(
        columns: (auto, 1fr),
        stroke: _stroke-no-border(stroke),
        inset: (right: 0.1cm),
        align: horizon,
        [], _spacer(100%, 20%),
        circle(radius: 72mm / 2, stroke: stroke), [],
        _spacer(auto, 1fr),
      ))
    },
  )
}

/// Standard subslide preamble.
/// -> content
#let _basic-subslide-preamble(
  self,
  inset: (top: 4.6cm),
  text-args: (
    size: 42pt,
  ),
) = {
  return block(
    inset: inset,
    text(
      ..text-args,
      weight: "light",
      fill: self.colors.primary,
      utils.display-current-heading(level: self.slide-level),
    ),
  )
}
