/// The default question container. Produce a grid of 2 columns: the question number, and the question content.
///
/// - func (function): The original container function.
/// - args (dictionary): The original non-content arguments for the function.
/// - items (dictionary): Items that can show up as content.
/// - config (dictionary): The config used by the container's feeder.
/// -> content
#let question-container(
  func,
  args,
  items,
  config: (:),
) = {
  let (number, point, main) = items
  func(
    ..args,
    number,
    point + main,
  )
}

/// The default solution container. Produce a grid of 1 or 2 columns: the solution content, and optionally, the markings.
///
/// - func (function): The original container function.
/// - args (dictionary): The original non-content arguments for the function.
/// - items (dictionary): Items that can be used for output.
/// - markscheme (bool): Whether to enable the marking column.
/// - marking-width (length, relative, fraction, auto): A column width, for the markings.
/// - config (dictionary): The config used by the container's feeder.
/// -> content
#let solution-container(
  func,
  args,
  items,
  markscheme: false,
  marking-width: 7.2em,
  config: (:),
) = {
  let (target, supplement, main, marking, marking-extension) = items
  let bodies = target + supplement + main
  if markscheme {
    args += (columns: (100% - marking-width, marking-width))
    bodies = (
      bodies + marking-extension,
      grid.vline(stroke: config.solution.stroke-minor),
      marking(marking-width),
    )
  }
  func(
    ..args,
    ..(bodies,).flatten(),
  )
}

/// The default name formatter. Produce a formatted English name from a first name and a last name.
///
/// - first (str, content): The first name.
/// - last (str, content): The last name, i.e. surname. It is turned bold.
/// - sink (aurguments): Sink arguments which this formatter does not use.
/// -> content
#let author-name-formatter(first, last, ..sink) = [#first *#last*]

/// Apply affixes to a name.
///
/// - name (str, content): The name.
/// - prefix (str, content, none): The prefix.
/// - suffix (str, content, none): The suffix.
/// - sink (arguments): Sink arguments which this formatter does not use.
/// -> content
#let author-affix-formatter(name, prefix, suffix, ..sink) = {
  if prefix != none [#prefix]
  name
  if suffix != none [ (#suffix)]
}

/// The default author container. Produce a top-to-bottom stack of full name and ID.
///
/// - func (function): The original container function.
/// - args (dictionary): The original non-content arguments.
/// - items (dictionary): Items that can be used for output.
/// - config (dictionary): The config used by the container's feeder.
/// -> content
#let author-container(
  func,
  args,
  items,
  config: (:),
) = {
  let (name, id) = items
  func(
    ..args,
    name,
    id,
  )
}

/// The default author set container. Produce a grid-in-grid, maximum 4 authors spread out on each row.
///
/// - func (function): The original container function.
/// - args (dictionary): The original non-content arguments.
/// - items (dictionary): Items that can be used for output.
/// - config (dictionary): The config used by the container's feeder.
/// -> content
#let author-set-container(
  func,
  args,
  items,
  config: (:),
) = {
  let (rows,) = items
  func(
    ..args,
    ..rows,
  )
}

#let head-container(
  func,
  args,
  items,
  config: (:),
) = {
  let (title, group, authors) = items
  func(
    ..args,
    title,
    group,
    authors,
  )
}

/// The default config.
#let config = (
  global: (
    color-major: black,
    color-minor: blue.darken(67%),
    font-major: ("DejaVu Serif", "New Computer Modern"),
    font-minor: ("DejaVu Serif", "New Computer Modern"),
    font-cjk: (
      sc: "Noto Sans CJK SC",
      tc: "Noto Sans CJK TC",
      hk: "Noto Sans CJK HK",
      jp: "Noto Sans CJK JP",
      kr: "Noto Sans CJK KR",
    ),
    font-size: 11pt,
    background: box(fill: white, width: 100%, height: 100%),
    rule: body => body,
  ),
  link: (
    color-major: blue.darken(30%),
    rule: body => body,
  ),
  ref: (
    color-major: green.darken(40%),
    rule: body => body,
  ),
  raw: (
    font-major: "MonaspiceAr NFM",
    color-major: black,
    rule: body => body,
  ),
  title: (
    format: it => text(size: 1.2em, weight: "bold", upper(it)),
  ),
  group: (
    format: it => text(size: 1.2em, it),
  ),
  author: (
    name-format: author-name-formatter,
    affix-format: author-affix-formatter,
    container: author-container,
    set-container: author-set-container,
    rule: body => body,
  ),
  head: (
    container: head-container,
  ),
  question: (
    supplement: "Question",
    numbering: ("1.", "a.", "i."),
    labelling: ("1", "a", "i"),
    container: question-container,
    rule: body => body,
    color-major: black,
    color-minor: white,
    stroke-major: 0pt + black,
    stroke-minor: 0pt + black,
  ),
  solution: (
    supplement: "Solution",
    container: solution-container,
    rule: body => body,
    color-major: black,
    color-minor: rgb(10%, 50%, 10%),
    stroke-major: 1pt + rgb(10%, 50%, 10%),
    stroke-minor: .8pt + rgb(10%, 50%, 10%).transparentize(50%),
  ),
  math: (
    color-major: black,
    color-minor: maroon,
    font-major: "New Computer Modern Math",
    rule: body => body,
    equate: true,
    implicit-numbering: false,
    numbering: "(1.1)",
    transpose: true,
  ),
)
