#import "@preview/touying:0.5.3": utils, components

#import "colour.typ": colour



#let get-current-section-number() = (
  context {
    let selector = selector(heading.where(level: 1)).before(here())
    let level = counter(selector)
    let headings = query(selector)

    if headings.len() == 0 {
      return
    }

    let heading = headings.last()

    return level.get(heading.numbering)
  }
)



#let calculate-progress-ratios(variant, callback) = (
  context {
    // --- `near` calculations
    let PREVIOUS = (
      query(selector(heading.where(level: 2)).before(here(), inclusive: false)).len()
      + query(selector(heading.where(level: 1)).before(here())).len()
    )

    let CURRENT = (
      query(selector(heading.where(level: 2)).after(here()).before(selector(heading.where(level: 1)).after(here()))).len()
    )

    // High level stats
    let total-sections = query(selector(heading.where(level: 1))).len()
    let current-heading = utils.current-heading(level: 1)
    
    // Determine if this is the last section
    let heading-selector = selector(heading.where(level: 1)).before(here())
    let level = counter(heading-selector)
    let headings = query(heading-selector)
    if headings.len() == 0 { return 0 }
    let current-section-number = level.get().first()

    let is-last-section = total-sections == current-section-number

    // Calculate remaining slides
    let number-of-slides-in-current-section = (
      query(selector(heading.where(level: 2)).after(here()).before(selector(heading.where(level: 1)).after(here()))).len()
    )

    let NEXT = if is-last-section { 
        0 
    } else {
        utils.last-slide-counter.final().first() - (utils.slide-counter.get().first() + number-of-slides-in-current-section)
    }

    let TOTAL = utils.last-slide-counter.final().first()



    // --- `exact` calculations
    let current-section-start = utils.current-heading(level: 1).location()

    let historic-section-slides = (
      query(selector(heading.where(level: 2)).before(current-section-start, inclusive: false)).len()
      + query(selector(heading.where(level: 1)).before(here(), inclusive: false)).len()
      - 1
    )

    let slides-covered-in-current-section = (
      query(selector(heading.where(level: 2)).after(current-section-start).before(here(), inclusive: false)).len()
    )

    let slides-remaining-in-current-section = (
      query(selector(heading.where(level: 2)).after(here()).before(selector(heading.where(level: 1)).after(here()))).len()
    )

    let future-section-slides = if is-last-section { 
      0
    } else {
      (
        query(selector(heading.where(level: 2)).after(here()).after(selector(heading.where(level: 1)).after(here()))).len()
        + query(selector(heading.where(level: 1)).after(here())).len()
        + 1
      )
    }

    let exact-total = (
      historic-section-slides
      + slides-covered-in-current-section
      + slides-remaining-in-current-section
      + future-section-slides
    )
    

    let ratios = (
      broad: (
        calc.min(1.0, utils.slide-counter.get().first() / utils.last-slide-counter.final().first()),
        calc.min(1.0, 1 - utils.slide-counter.get().first() / utils.last-slide-counter.final().first())
      ),
      near: (
        PREVIOUS / TOTAL,
        CURRENT / TOTAL,
        NEXT / TOTAL,
      ),
      exact: (
        historic-section-slides / exact-total,
        slides-covered-in-current-section / exact-total,
        slides-remaining-in-current-section / exact-total,
        future-section-slides / exact-total,
      )
    )

    callback(ratios.at(variant))
  }
)



#let lineal-progress-bar(variant: str, height: 2pt, ratios: array) = calculate-progress-ratios(variant, ratios => {
  let mapping = (
    broad: grid(
      columns: ratios.map(r => r * 100%),
      rows: height,
      components.cell(fill: colour.primary),
      components.cell(fill: colour.primary-light),
    ),
    near: grid(
      columns: ratios.map(r => r * 100%),
      rows: height,
      components.cell(fill: colour.primary),
      components.cell(fill: colour.primary-light),
      components.cell(fill: black.transparentize(60%)),
    ),
    exact: grid(
      columns: ratios.map(r => r * 100%),
      rows: height,
      components.cell(fill: black.transparentize(60%)),
      components.cell(fill: colour.primary),
      components.cell(fill: colour.primary-light),
      components.cell(fill: black.transparentize(80%)),
    ),
  )

  mapping.at(variant, default: mapping.broad)
})
