#import "../touying.typ": utils
#import "metadata.typ": is-kind
#import "visibility.typ": is-covered

#let _query-headings(sel) = query(sel).filter(it => not is-covered(it))

// Auto-section headings precede a slide's body metadata in source order. Use
// the first heading on the appendix's first page as the navigation boundary.
#let _appendix-start(marker) = {
  let headings = query(heading).filter(it => it.location().page() >= marker.location().page())
  headings.first(default: marker).location()
}

/// Before appendix selection filter.
#let before-appendix-filter = sel => {
  let appendix-marker = query(<touying-metadata>)
    .filter(it => (
      is-kind(it, "touying-appendix")
    ))
    .first(default: none)
  let has-appendix = appendix-marker != none
  if has-appendix {
    sel.before(_appendix-start(appendix-marker), inclusive: false)
  } else {
    sel
  }
}


/// Appendix selection filter.
#let appendix-filter = sel => {
  let appendix-marker = query(<touying-metadata>)
    .filter(it => (
      is-kind(it, "touying-appendix")
    ))
    .first(default: none)
  let has-appendix = appendix-marker != none
  if has-appendix {
    if here().page() < appendix-marker.location().page() {
      sel.before(_appendix-start(appendix-marker), inclusive: false)
    } else {
      sel.after(_appendix-start(appendix-marker), inclusive: true)
    }
  } else {
    sel
  }
}


/// A selection filter.
#let reveal-after-appendix-filter = sel => {
  let appendix-marker = query(<touying-metadata>)
    .filter(it => (
      is-kind(it, "touying-appendix")
    ))
    .first(default: none)
  let has-appendix = appendix-marker != none
  if has-appendix and here().page() < appendix-marker.location().page() {
    sel.before(_appendix-start(appendix-marker), inclusive: false)
  } else {
    sel
  }
}


/// Get the current heading on or before the current page.
///
/// - level (int, auto): The level of the heading. If `level` is `auto`, it will return the last heading on or before the current page. If `level` is a number, it will return the last heading on or before the current page with the same level.
///
/// - hierachical (boolean): A value to indicate whether to return the heading hierarchically. If `hierachical` is `true`, it will return the last heading according to the hierarchical structure. If `hierachical` is `false`, it will return the last heading on or before the current page with the same level.
///
/// - depth (int): The maximum depth of the heading to search. Usually, it should be set as slide-level.
///
/// -> content
#let current-heading(level: auto, hierachical: true, depth: 9999, selector-filter: sel => sel) = {
  let current-page = here().page()
  if not hierachical and level != auto {
    let headings = _query-headings(selector-filter(heading.where())).filter(h => (
      h.location().page() <= current-page and h.level <= depth and h.level == level
    ))
    return headings.at(-1, default: none)
  }
  let headings = _query-headings(selector-filter(heading.where())).filter(h => (
    h.location().page() <= current-page and h.level <= depth
  ))
  if headings == () {
    return
  }
  if level == auto {
    return headings.last()
  }
  let current-level = headings.last().level
  let current-heading = headings.pop()
  while headings.len() > 0 and level < current-level {
    current-level = headings.last().level
    current-heading = headings.pop()
  }
  if level == current-level {
    return current-heading
  }
}


/// Display the current heading on the page.
///
/// - level (int, auto): The level of the heading. If `level` is `auto`, it will return the last heading on or before the current page. If `level` is a number, it will return the last heading on or before the current page with the same level.
///
/// - numbered (boolean): A value to indicate whether to display the numbering of the heading. Default is `true`.
///
/// - hierachical (boolean): A value to indicate whether to return the heading hierarchically. If `hierachical` is `true`, it will return the last heading according to the hierarchical structure. If `hierachical` is `false`, it will return the last heading on or before the current page with the same level.
///
/// - depth (int): The maximum depth of the heading to search. Usually, it should be set as slide-level.
///
/// - setting (function): The setting of the heading. Default is `body => body`.
///
/// - style (function): The style of the heading. If `style` is a function, it will use the function to style the heading. For example, `style: current-heading => current-heading.body`.
///
///   If you set it to `style: auto`, it will could be controlled by `show heading` rule.
///
/// -> content
#let display-current-heading(
  self: none,
  level: auto,
  hierachical: true,
  depth: 9999,
  selector-filter: sel => sel,
  style: (setting: body => body, numbered: true, current-heading) => setting({
    if numbered and current-heading.numbering != none {
      (
        std.numbering(
          current-heading.numbering,
          ..counter(heading).at(current-heading.location()),
        )
          + h(.3em)
      )
    }
    current-heading.body
  }),
  ..setting-args,
) = (
  context {
    let current-heading = current-heading(
      level: level,
      hierachical: hierachical,
      depth: depth,
      selector-filter: selector-filter,
    )
    if current-heading != none {
      link(current-heading.location(), if style == none {
        current-heading
      } else if style == auto {
        let current-level = current-heading.level
        if current-level == 1 {
          text(.715em, current-heading)
        } else if current-level == 2 {
          text(.835em, current-heading)
        } else {
          current-heading
        }
      } else {
        style(..setting-args, current-heading)
      })
    }
  }
)


/// Get all current headings on or before the current page.
///
/// - level (int, auto): The level of the heading. If `level` is `auto`, it will return the last heading on or before the current page. If `level` is a number, it will return the last heading on or before the current page with the same level.
///
/// - hierachical (boolean): A value to indicate whether to return the heading hierarchically. If `hierachical` is `true`, it will return the last heading according to the hierarchical structure. If `hierachical` is `false`, it will return the last heading on or before the current page with the same level.
///
/// - depth (int): The maximum depth of the heading to search. Usually, it should be set as slide-level.
///
/// -> array
#let current-headings(level: auto, hierachical: false, depth: 9999, selector-filter: sel => sel) = {
  let current-page = here().page()
  if not hierachical and level != auto {
    let headings = _query-headings(selector-filter(heading.where())).filter(h => (
      h.location().page() == current-page and h.level <= depth and h.level == level
    ))
    if headings.len() > 0 {
      return headings
    }

    let headings = _query-headings(selector-filter(heading.where())).filter(h => (
      h.location().page() <= current-page and h.level <= depth and h.level == level
    ))
    if headings.len() > 0 {
      return (headings.last(),)
    } else {
      return
    }
  }

  let headings = _query-headings(selector-filter(heading.where())).filter(h => (
    h.location().page() == current-page and h.level <= depth
  ))
  if level == auto {
    return
  }
  if headings.len() > 0 {
    let current-level = headings.last().level
    let current-heading = headings.last()
    while headings.len() > 0 and level < current-level {
      current-level = headings.last().level
      headings.pop()
    }
    headings = headings.filter(h => h.level == level)
    if headings.len() > 0 and level == current-level {
      return headings
    }
  }

  let headings = _query-headings(selector-filter(heading.where())).filter(h => (
    h.location().page() <= current-page and h.level <= depth
  ))
  if headings == () or level == auto {
    return
  }

  let current-level = headings.last().level
  let current-heading = headings.pop()
  while headings.len() > 0 and level < current-level {
    current-level = headings.last().level
    current-heading = headings.pop()
  }
  if level == current-level {
    return (current-heading,)
  }
}


/// Display all current headings on the page.
///
/// - level (int, auto): The level of the heading. If `level` is `auto`, it will return the last heading on or before the current page. If `level` is a number, it will return the last heading on or before the current page with the same level.
///
/// - numbered (boolean): A value to indicate whether to display the numbering of the heading. Default is `true`.
///
/// - hierachical (boolean): A value to indicate whether to return the heading hierarchically. If `hierachical` is `true`, it will return the last heading according to the hierarchical structure. If `hierachical` is `false`, it will return the last heading on or before the current page with the same level.
///
/// - depth (int): The maximum depth of the heading to search. Usually, it should be set as slide-level.
///
/// - setting (function): The setting of the heading. Default is `body => body`.
///
/// - style (function): The style of the heading. If `style` is a function, it will use the function to style the heading. For example, `style: current-heading => current-heading.body`.
///
///   If you set it to `style: auto`, it will could be controlled by `show heading` rule.
///
/// -> content
#let prose-display-current-headings(
  self: none,
  level: auto,
  hierachical: true,
  depth: 9999,
  selector-filter: sel => sel,
  dir: ttb,
  spacing: none,
  style: (setting: body => body, numbered: true, current-heading) => setting({
    if numbered and current-heading.numbering != none {
      (
        std.numbering(
          current-heading.numbering,
          ..counter(heading).at(current-heading.location()),
        )
          + h(.3em)
      )
    }
    current-heading.body
  }),
  ..setting-args,
) = (
  context {
    let current-headings = current-headings(
      level: level,
      hierachical: hierachical,
      depth: depth,
      selector-filter: selector-filter,
    )
    if current-headings != none {
      let blocks = ()
      for i in range(current-headings.len()) {
        let current-heading = current-headings.at(i)
        let ctn = none
        // similar to display-current-heading
        if style == none {
          ctn = current-heading
        } else if style == auto {
          let current-level = current-heading.level
          if current-level == 1 {
            ctn = text(.715em, current-heading)
          } else if current-level == 2 {
            ctn = text(.835em, current-heading)
          } else {
            ctn = current-heading
          }
        } else {
          ctn = style(..setting-args, current-heading)
        }

        blocks.push(link(current-heading.location(), ctn))
      }
      if spacing == none { blocks.join() } else { blocks.join(h(spacing)) }
    }
  }
)
