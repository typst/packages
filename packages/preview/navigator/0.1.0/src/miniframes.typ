/// Extraction of the presentation structure.
/// Returns a dictionary with sections, each containing subsections, each containing logical slides.
#let get-structure(slide-selector: auto, filter-selector: none) = {
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
  let sorted-headings = headings.sorted(key: h => (h.location().page(), h.location().position().y))
  
  for h in sorted-headings {
    if h.level == 1 {
      current-section = (
        title: h.body,
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
  structure,
  current-slide-num,
  fill: black,
  text-color: white,
  text-size: 10pt,
  font: none,
  active-color: white,
  inactive-color: gray,
  marker-shape: "circle",
  marker-size: 4pt,
  style: "grid", 
  align-mode: "left",
  dots-align: "left",
  show-level1-titles: true,
  show-level2-titles: true,
  show-numbering: false,
  numbering-format: "1.1",
  gap: 1.5em,
  line-spacing: 4pt,
  inset: (x: 1em, y: 0.5em),
  width: 100%,
  outset-x: 0pt, 
  radius: 0pt,
  navigation-pos: "bottom", // "top" (dots above titles) or "bottom" (dots below titles)
) = {
  let marker(is-active, is-future) = {
    let color = if is-active { active-color } else if is-future { inactive-color } else { active-color.transparentize(40%) }
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
      let is-active = s.number == current-slide-num
      let is-future = s.number > current-slide-num
      let m = marker(is-active, is-future)
      if s.loc != none { link(s.loc, m) } else { m }
    })
  }
  
  let fmt-title(item) = {
    let t = item.title
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

  let content = {
    set text(fill: text-color, size: text-size)
    set par(leading: 0.8em)
    if font != none { set text(font: font) }
    
    let items = ()
    for root in structure {
      let is-root-active = root.subsections.any(sub => {
        if sub.at("slides", default: none) != none {
          return sub.slides.any(s => s.number == current-slide-num)
        } else if sub.at("subsections", default: none) != none {
          return sub.subsections.any(ss => ss.slides.any(s => s.number == current-slide-num))
        }
        false
      })
      
      let title-part = if show-level1-titles and root.title != none {
        let t = fmt-title(root)
        let title-text = if is-root-active { strong(t) } else { t }
        let title-link = if root.loc != none { link(root.loc, title-text) } else { title-text }
        align(eval(dots-align), title-link)
      }

      let dots-part = if style == "compact" {
        let all-slides = ()
        for sub in root.subsections {
          if sub.at("slides", default: none) != none { all-slides += sub.slides }
          else if sub.at("subsections", default: none) != none {
            for ss in sub.subsections { all-slides += ss.slides }
          }
        }
        align(eval(dots-align), stack(dir: ltr, spacing: marker-size * 0.8, ..render-dot-group(all-slides)))
      }

      let root-content = if style == "compact" {
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
                child.slides.any(s => s.number == current-slide-num)
              } else {
                child.subsections.any(ss => ss.slides.any(s => s.number == current-slide-num))
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
                let sep = box(baseline: marker-size * 0.2, text(fill: inactive-color, weight: "bold", size: text-size * 0.8, [|]))
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
    fill: fill,
    inset: inset,
    outset: (x: outset-x),
    radius: radius,
    align(eval(align-mode), content)
  )
}
