#import "@preview/touying:0.6.2": utils


/// Before appendix selection filter.
#let before-appendix-filter = sel => {
  let appendix-marker = query(<touying-metadata>)
    .filter(it => (
      utils.is-kind(it, "touying-appendix")
    ))
    .first(default: none)
  let has-appendix = appendix-marker != none
  if has-appendix {
    sel.before(appendix-marker.location())
  } else {
    sel
  }
}


/// Appendix selection filter.
#let appendix-filter = sel => {
  let appendix-marker = query(<touying-metadata>)
    .filter(it => (
      utils.is-kind(it, "touying-appendix")
    ))
    .first(default: none)
  let has-appendix = appendix-marker != none
  if has-appendix {
    if here().page() < appendix-marker.location().page() {
      sel.before(appendix-marker.location())
    } else {
      sel.after(appendix-marker.location())
    }
  } else {
    sel
  }
}


/// A selection filter.
#let reveal-after-appendix-filter = sel => {
  let appendix-marker = query(<touying-metadata>)
    .filter(it => (
      utils.is-kind(it, "touying-appendix")
    ))
    .first(default: none)
  let has-appendix = appendix-marker != none
  if has-appendix and here().page() < appendix-marker.location().page() {
    sel.before(appendix-marker.location())
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
    let headings = query(selector-filter(heading.where())).filter(h => (
      h.location().page() <= current-page and h.level <= depth and h.level == level
    ))
    return headings.at(-1, default: none)
  }
  let headings = query(selector-filter(heading.where())).filter(h => (
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
    let headings = query(selector-filter(heading.where())).filter(h => (
      h.location().page() == current-page and h.level <= depth and h.level == level
    ))
    if headings.len() > 0 {
      return headings
    }

    let headings = query(selector-filter(heading.where())).filter(h => (
      h.location().page() <= current-page and h.level <= depth and h.level == level
    ))
    if headings.len() > 0 {
      return (headings.last(),)
    } else {
      return
    }
  }

  let headings = query(selector-filter(heading.where())).filter(h => (
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

  let headings = query(selector-filter(heading.where())).filter(h => (
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
          current-heading
        } else if style == auto {
          let current-level = current-heading.level
          if current-level == 1 {
            ctn = text(.715em, current-heading)
          } else if current-level == 2 {
            ctn = text(.835em, current-heading)
          } else {
            current-heading
          }
        } else {
          ctn = style(..setting-args, current-heading)
        }

        blocks.push(link(current-heading.location(), ctn))
      }
      blocks.join(h(spacing))
    }
  }
)


/// Call a `self => {..}` function recursively and return the final result, or just return the content.
///
/// -> content
#let call-or-display(self, it) = {
  while type(it) == function {
    it = it(self)
  }
  return [#it]
}


/// Call a `self => {..}` function recursively and return the final result.
///
/// -> content
#let call-or-return(self, it) = {
  while type(it) == function {
    it = it(self)
  }
  return it
}


/// Display text with adaptive size to fit in its container
#let adaptive-display(body, min-size: 4pt) = layout(bounds => context {
  let low = min-size.pt()
  let high = text.size.pt()
  for _ in range(15) {
    // binary search
    let mid = (low + high) / 2
    let current-size = mid * 1pt
    let m = measure(block(width: bounds.width, text(size: current-size, body)))
    if m.height <= bounds.height {
      low = mid
    } else {
      high = mid
    }
  }
  text(size: low * 1pt, body)
})


/// Prose display title and subtitle with adaptive size to fit in its container
#let adaptive-prose-display-title-subtitle(
  title,
  subtitle,
  spacing: 1em,
  min-size: 4pt,
) = layout(bounds => context {
  let low = min-size.pt()
  let high = text.size.pt()
  let content = title + h(spacing) + subtitle
  for _ in range(15) {
    // binary search
    let mid = (low + high) / 2
    let current-size = mid * 1pt
    let m = measure(block(width: bounds.width, text(size: current-size, content)))
    if m.height <= bounds.height {
      low = mid
    } else {
      high = mid
    }
  }
  text(size: low * 1pt, content)
})


/// Alert content with a color.
/// Unlike default alert, this function can
/// be used inside a context.
///
/// Example: `utils.alert[important]`
///
/// -> content
#let alert(it) = [#metadata(it)<touying-greyc-alert>]


/// i18n Outline Title
///
/// -> content
#let i18n-outline-title = context {
  let mapping = (
    ar: "المحتويات",
    ca: "Índex",
    cs: "Obsah",
    da: "Indhold",
    en: "Outline",
    es: "Índice",
    et: "Sisukord",
    fi: "Sisällys",
    fr: "Sommaire",
    ja: "目次",
    ru: "Содержание",
    zh-TW: "目錄",
    zh: "目录",
    vn: "Nội Dung",
  )
  mapping.at(text.lang, default: mapping.en)
}


/// i18n Bibliography Title
///
/// -> content
#let i18n-bibliography-title = context {
  let mapping = (
    ar: "المراجع",
    ca: "Bibliografia",
    cs: "Literatura",
    da: "Litteraturliste",
    en: "Bibliography",
    es: "Bibliografía",
    et: "Bibliograafia",
    fi: "Kirjallisuusluettelo",
    fr: "Bibliographie",
    ja: "参考文献",
    ru: "Список литературы",
    zh-TW: "參考文獻",
    zh: "参考文献",
    vn: "Tài Liệu Tham Khảo",
  )
  mapping.at(text.lang, default: mapping.en)
}
