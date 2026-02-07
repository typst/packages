#import "structure.typ": find-short-titles
#import "utils.typ": resolve-body

/// Extraction of the presentation structure.
/// Returns a dictionary with sections, each containing subsections, each containing logical slides.
#let get-structure(slide-selector: auto, filter-selector: none, all-shorts: none) = {
  let headings = query(heading.where(outlined: true).or(heading.where(level: 1)).or(heading.where(level: 2)).or(heading.where(level: 3)))
  
  // Determine allowed pages if a filter is provided
  let allowed-pages = if filter-selector != none {
    query(filter-selector).map(m => m.location().page()).dedup()
  } else { none }

  let selector = if slide-selector == auto { metadata } else { slide-selector }
  
  let candidates = query(selector)
  if slide-selector == auto {
    candidates = candidates.filter(m => type(m.value) == dictionary and m.value.at("t", default: none) == "LogicalSlide")
  }
  
  let unique-slides = ()
  let seen-slide-numbers = ()
  
  for m in candidates {
    let pg = m.location().page()
    
    // Apply page filter: skip slides on pages that don't match the filter-selector
    if allowed-pages != none and pg not in allowed-pages { continue }

    // Safe value extraction: fallback to page number if .value is missing (e.g. for headings)
    let val = if m.has("value") {
      if type(m.value) == dictionary and "v" in m.value { m.value.v } else { m.value }
    } else { pg }
    
    // Fallback if value is not an integer (e.g. simple metadata marker)
    if type(val) != int { val = pg }
    
    if val not in seen-slide-numbers {
      seen-slide-numbers.push(val)
      unique-slides.push((number: val, loc: m.location()))
    }
  }

  let structure = ()
  let current-section = none
  let current-subsection = none
  let current-subsubsection = none

  // Sort headings by location
  let sorted-headings = headings.sorted(key: h => (h.location().page(), if h.location().position() != none { h.location().position().y } else { 0pt }))
  
  let short-titles = if all-shorts != none { find-short-titles(sorted-headings, all-shorts) } else { () }
  
  for (i, h) in sorted-headings.enumerate() {
    let s-title = if short-titles.len() > i { short-titles.at(i) } else { none }
    if h.level == 1 {
      current-section = (
        title: h.body,
        short-title: s-title,
        numbering: h.numbering,
        counter: counter(heading).at(h.location()),
        level: h.level,
        loc: h.location(),
        subsections: ()
      )
      structure.push(current-section)
      current-subsection = none
      current-subsubsection = none
    } else if h.level == 2 {
      if current-section == none {
        current-section = (title: none, numbering: none, counter: (), level: 1, loc: h.location(), subsections: ())
        structure.push(current-section)
      }
      current-subsection = (
        title: h.body,
        short-title: s-title,
        numbering: h.numbering,
        counter: counter(heading).at(h.location()),
        level: h.level,
        loc: h.location(),
        subsections: () 
      )
      structure.last().subsections.push(current-subsection)
      current-subsubsection = none
    } else if h.level == 3 {
      if current-subsection == none {
        if current-section == none {
          current-section = (title: none, numbering: none, counter: (), level: 1, loc: h.location(), subsections: ())
          structure.push(current-section)
        }
        current-subsection = (title: none, numbering: none, counter: (), level: 2, loc: h.location(), subsections: ())
        structure.last().subsections.push(current-subsection)
      }
      current-subsubsection = (
        title: h.body,
        short-title: s-title,
        numbering: h.numbering,
        counter: counter(heading).at(h.location()),
        level: h.level,
        loc: h.location(),
        slides: ()
      )
      structure.last().subsections.last().subsections.push(current-subsubsection)
    }
  }

  if structure.len() == 0 {
    structure.push((title: none, loc: none, subsections: ((title: none, loc: none, slides: ()),)))
  }

  // Assign slides to the deepest level
  for s in unique-slides {
    let best-h1-idx = -1
    let best-h2-idx = -1
    let best-h3-idx = -1

    for (i, h1) in structure.enumerate() {
      if h1.loc == none or s.loc.page() > h1.loc.page() or (s.loc.page() == h1.loc.page() and s.loc.position().y >= h1.loc.position().y) {
        best-h1-idx = i
        best-h2-idx = -1
        for (j, h2) in h1.subsections.enumerate() {
          if h2.loc == none or s.loc.page() > h2.loc.page() or (s.loc.page() == h2.loc.page() and s.loc.position().y >= h2.loc.position().y) {
            best-h2-idx = j
            best-h3-idx = -1
            if h2.at("subsections", default: none) != none {
              for (k, h3) in h2.subsections.enumerate() {
                if h3.loc == none or s.loc.page() > h3.loc.page() or (s.loc.page() == h3.loc.page() and s.loc.position().y >= h3.loc.position().y) {
                  best-h3-idx = k
                }
              }
            }
          }
        }
      }
    }

    if best-h1-idx != -1 {
      let sec = structure.at(best-h1-idx)
      if best-h2-idx == -1 {
        if sec.subsections.len() == 0 {
          structure.at(best-h1-idx).subsections.push((title: none, loc: none, slides: (s,)))
        } else {
          let sub = sec.subsections.at(0)
          if sub.at("slides", default: none) != none { structure.at(best-h1-idx).subsections.at(0).slides.push(s) }
          else { 
             if structure.at(best-h1-idx).subsections.at(0).subsections.len() == 0 {
               structure.at(best-h1-idx).subsections.at(0).subsections.push((title: none, loc: none, slides: (s,)))
             } else {
               structure.at(best-h1-idx).subsections.at(0).subsections.at(0).slides.push(s) 
             }
          }
        }
      } else {
        let sub = sec.subsections.at(best-h2-idx)
        if best-h3-idx == -1 {
          if sub.at("slides", default: none) != none { structure.at(best-h1-idx).subsections.at(best-h2-idx).slides.push(s) }
          else if sub.at("subsections", default: none) != none and sub.subsections.len() > 0 {
             structure.at(best-h1-idx).subsections.at(best-h2-idx).subsections.at(0).slides.push(s)
          } else {
             structure.at(best-h1-idx).subsections.at(best-h2-idx).subsections = ((title: none, loc: none, slides: (s,)),)
          }
        } else {
          structure.at(best-h1-idx).subsections.at(best-h2-idx).subsections.at(best-h3-idx).slides.push(s)
        }
      }
    }
  }

  return structure
}

#let get-current-logical-slide-number(slide-selector: auto, filter-selector: none) = {
  let current-page = here().page()
  let selector = if slide-selector == auto { metadata } else { slide-selector }
  
  // Determine allowed pages if a filter is provided
  let allowed-pages = if filter-selector != none {
    query(filter-selector).map(m => m.location().page()).dedup()
  } else { none }

  let slides = query(selector)
  if slide-selector == auto {
    slides = slides.filter(m => type(m.value) == dictionary and m.value.at("t", default: none) == "LogicalSlide")
  }
  
  let past-slides = slides.filter(m => {
    let pg = m.location().page()
    if allowed-pages != none and pg not in allowed-pages { return false }
    pg <= current-page
  })

  if past-slides.len() > 0 {
    let m = past-slides.last()
    let val = if m.has("value") {
      if type(m.value) == dictionary and "v" in m.value { m.value.v } else { m.value }
    } else { m.location().page() }
    
    if type(val) != int { return m.location().page() }
    return val
  }
  return 1
}

#let render-miniframes(
  ..args,
) = {
  let pos = args.pos()
  let named = args.named()
  
  let structure = pos.at(0, default: named.at("structure", default: auto))
  let current-slide-num = pos.at(1, default: named.at("current-slide-num", default: auto))
  
  let fill = named.at("fill", default: auto)
  let text-color = named.at("text-color", default: auto)
  let text-size = named.at("text-size", default: 10pt)
  let font = named.at("font", default: none)
  let active-color = named.at("active-color", default: auto)
  let inactive-color = named.at("inactive-color", default: auto)
  let marker-shape = named.at("marker-shape", default: "circle")
  let marker-size = named.at("marker-size", default: 4pt)
  let style = named.at("style", default: auto)
  let align-mode = named.at("align-mode", default: "left")
  let dots-align = named.at("dots-align", default: "left")
  let show-level1-titles = named.at("show-level1-titles", default: true)
  let show-level2-titles = named.at("show-level2-titles", default: true)
  let show-numbering = named.at("show-numbering", default: false)
  let numbering-format = named.at("numbering-format", default: "1.1")
  let gap = named.at("gap", default: 1.5em)
  let line-spacing = named.at("line-spacing", default: 4pt)
  let inset = named.at("inset", default: (x: 1em, y: 0.5em))
  let width = named.at("width", default: 100%)
  let outset-x = named.at("outset-x", default: 0pt)
  let radius = named.at("radius", default: 0pt)
  let navigation-pos = named.at("navigation-pos", default: "bottom")
  let max-length = named.at("max-length", default: auto)
  let use-short-title = named.at("use-short-title", default: auto)

  import "structure.typ": navigator-config
  
  context {
    let config = navigator-config.get()
    
    let final-slide-selector = config.at("slide-selector", default: metadata.where(value: (t: "ContentSlide")))
    let final-structure = if structure == auto { get-structure(slide-selector: final-slide-selector) } else { structure }
    let final-current-slide-num = if current-slide-num == auto { get-current-logical-slide-number(slide-selector: final-slide-selector) } else { current-slide-num }
    
    let m-config = config.at("miniframes", default: (:))
    let final-fill = if fill == auto { m-config.at("fill", default: none) } else { fill }
    let final-active-color = if active-color == auto { m-config.at("active-color", default: white) } else { active-color }
    let final-inactive-color = if inactive-color == auto { m-config.at("inactive-color", default: gray) } else { inactive-color }
    let final-style = if style == auto { m-config.at("style", default: "grid") } else { style }
    let final-text-color = if text-color == auto { if final-fill == none { black } else { white } } else { text-color }

    let final-max-length = if max-length == auto { config.at("max-length", default: none) } else { max-length }
    let final-use-short = if use-short-title == auto { config.at("use-short-title", default: true) } else { use-short-title }

    let marker(is-active, is-future) = {
      let color = if is-active { final-active-color } else if is-future { final-inactive-color } else { final-active-color.transparentize(40%) }
      let radius = if marker-shape == "circle" { 50% } else { 0% }
      box(
        width: marker-size,
        height: marker-size,
        fill: color,
        radius: radius,
        baseline: marker-size * 0.1
      )
    }

    let render-dot-group(slides) = {
      slides.map(s => {
        let is-active = s.number == final-current-slide-num
        let is-future = s.number > final-current-slide-num
        let m = marker(is-active, is-future)
        if s.loc != none { link(s.loc, m) } else { m }
      })
    }
    
    let fmt-title(item) = {
      let level = item.at("level", default: 1)
      
      let current-max-length = if type(final-max-length) == dictionary {
        final-max-length.at("level-" + str(level), default: final-max-length.at(str(level), default: none))
      } else {
        final-max-length
      }

      let current-use-short = if type(final-use-short) == dictionary {
        final-use-short.at("level-" + str(level), default: final-use-short.at(str(level), default: true))
      } else {
        final-use-short
      }

      let t = resolve-body(
        item.title, 
        short-title: item.at("short-title", default: none),
        use-short-title: current-use-short,
        max-length: current-max-length
      )

      if t == none { return none }
      if show-numbering {
        let fmt = if numbering-format == auto { item.at("numbering", default: none) } else { numbering-format }
        if fmt != none and item.counter.any(v => v > 0) {
          let num = numbering(fmt, ..item.counter)
          t = [#num #t]
        }
      }
      t
    }

    let content-body = {
      set text(fill: final-text-color, size: text-size)
      set par(leading: 0.8em)
      if font != none { set text(font: font) }
      
      let items = ()
      for root in final-structure {
        let is-root-active = root.subsections.any(sub => {
          if sub.at("slides", default: none) != none {
            return sub.slides.any(s => s.number == final-current-slide-num)
          } else if sub.at("subsections", default: none) != none {
            return sub.subsections.any(ss => ss.slides.any(s => s.number == final-current-slide-num))
          }
          false
        })
        
        let title-part = if show-level1-titles and root.title != none {
          let t = fmt-title(root)
          let title-text = if is-root-active { strong(t) } else { t }
          let title-link = if root.loc != none { link(root.loc, title-text) } else { title-text }
          align(eval(dots-align), title-link)
        }

        let dots-part = if final-style == "compact" {
          let all-slides = ()
          for sub in root.subsections {
            if sub.at("slides", default: none) != none { all-slides += sub.slides }
            else if sub.at("subsections", default: none) != none {
              for ss in sub.subsections { all-slides += ss.slides }
            }
          }
          align(eval(dots-align), stack(dir: ltr, spacing: marker-size * 0.8, ..render-dot-group(all-slides)))
        }

        let root-content = if final-style == "compact" {
          let elements = if navigation-pos == "bottom" { (title-part, dots-part) } else { (dots-part, title-part) }
          stack(
            dir: ttb,
            spacing: line-spacing,
            ..elements.filter(e => e != none)
          )
        } else {
          stack(
            dir: ttb,
            spacing: line-spacing,
            ..((title-part, 
            {
              let rows = ()
              for child in root.subsections {
                let is-child-active = if child.at("slides", default: none) != none {
                  child.slides.any(s => s.number == final-current-slide-num)
                } else {
                  child.subsections.any(ss => ss.slides.any(s => s.number == final-current-slide-num))
                }

                let title-cell = if show-level2-titles {
                  let t = fmt-title(child)
                  if t != none {
                    let txt = if is-child-active { strong(t) } else { t }
                    text(size: text-size * 0.85, if child.loc != none { link(child.loc, txt) } else { txt })
                  }
                }
                
                let dots-cell = if child.at("subsections", default: none) != none {
                  let groups = child.subsections.map(ss => {
                    render-dot-group(ss.slides).join(h(marker-size * 0.8))
                  })
                  let sep = box(baseline: marker-size * 0.2, text(fill: final-inactive-color, weight: "bold", size: text-size * 0.8, [|]))
                  groups.join(h(marker-size * 0.5) + sep + h(marker-size * 0.5))
                } else {
                  render-dot-group(child.slides).join(h(marker-size * 0.8))
                }

                if show-level2-titles {
                  rows.push(align(horizon, title-cell))
                  rows.push(align(horizon, dots-cell))
                } else {
                  rows.push(align(eval(dots-align), dots-cell))
                }
              }
              
              if show-level2-titles {
                grid(columns: (auto, auto), column-gutter: 0.8em, row-gutter: line-spacing * 0.7, ..rows)
              } else {
                stack(dir: ttb, spacing: line-spacing * 0.7, ..rows)
              }
            }).filter(e => e != none))
          )
        }
        items.push(root-content)
      }

      grid(
        columns: (auto,) * items.len(),
        column-gutter: gap,
        ..items
      )
    }

    block(
      width: width,
      fill: final-fill,
      inset: inset,
      outset: (x: outset-x),
      radius: radius,
      align(eval(align-mode), content-body)
    )
  }
}
