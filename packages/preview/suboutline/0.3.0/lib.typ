#let suboutline(
  title: none,
  target: heading.where(outlined: true),
  depth: none,
  indent: auto,
  fill: repeat([.], gap: 0.15em),
) = {
  if depth == none {
    depth = calc.inf
  }

  set outline.entry(fill: fill)

  context {
    let current_location = here()

    let previous_headings = query(selector(heading.where(outlined: true)).before(current_location))
    if previous_headings == () {
      outline(title: title, target: target, depth: depth, indent: indent)
    }

    let current_heading = previous_headings.last()
    let min_level = current_heading.level
    let max_level = min_level + depth

    let following_headings = query(selector(heading.where(outlined: true)).after(current_location))
    if following_headings == () {
      max_level = if max_level == calc.inf {
        none
      } else {
        max_level
      }

      outline(
        title: title,
        target: selector(target).after(
          current_heading.location(),
          inclusive: false,
        ),
        depth: max_level,
        indent: indent,
      )
    } else {
      let last_subheading = none
      for following_heading in following_headings {
        if following_heading.level <= min_level {
          break
        }
        last_subheading = following_heading
      }

      max_level = if max_level == calc.inf {
        calc.max(..following_headings.map(s => s.level))
      } else {
        max_level
      }

      if last_subheading != none {
        outline(
          title: title,
          target: selector(target)
            .after(
              current_heading.location(),
              inclusive: false,
            )
            .before(last_subheading.location()),
          depth: max_level,
          indent: indent,
        )
      }
    }
  }
}
