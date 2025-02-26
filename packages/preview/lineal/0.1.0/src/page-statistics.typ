#import "@preview/touying:0.5.3": *

#let get-current-section-number() = (
  context {
    let heading-selector = selector(heading.where(level: 1)).before(here())
    let level = counter(heading-selector)
    let headings = query(heading-selector)
    if headings.len() == 0 { return 0 }
    let heading = headings.last()
    level.get().first()
  }
)

#let is-last-section() = {
  context {
    let total-sections = query(selector(heading.where(level: 1))).len()

    let selector = selector(heading.where(level: 1)).before(here())
    let level = counter(selector)
    let headings = query(selector)
    if headings.len() == 0 { return 0 }
    let heading = headings.last()
    let current-section-number = level.get().first()

    return total-sections == current-section-number
  }
}


#let page-stats = [
  #set text(size: 12pt)
  #context {
    let total-sections = query(selector(heading.where(level: 1))).len()
    [Total sections: #{total-sections}]
  }

  #context {
    let slide-count = utils.last-slide-number
    [Total number of slides: #{slide-count}]
  }

  #context {
    [Current section number: #{get-current-section-number()}]
  }

  #context {
    let page-number-of-current-section-start = utils.current-heading(level: 1).location().page()
    [Page number of start of current section: #{page-number-of-current-section-start}]
  }

  #v(1em)

  #context {
    let number-of-slides-in-previous-sections = (
      query(selector(heading.where(level: 2)).before(here(), inclusive: false)).len()
      // Exclude the current slide's title element
      - 2
      // Number of new section slides
      + query(selector(heading.where(level: 1)).before(here())).len()
    )
    [\# slides in previous sections: #{number-of-slides-in-previous-sections}]
  }

  #v(1em)

  #context {
    let number-of-slides-in-current-section = (
      query(selector(heading.where(level: 2)).after(here()).before(selector(heading.where(level: 1)).after(here()))).len()
      + 2
    )
    [\# slides in current section: #{number-of-slides-in-current-section}]
  }

  #v(1em)

  #context {
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

    let remaining-slide-count = if is-last-section { 
        0 
    } else {
        utils.last-slide-counter.final().first() - (utils.slide-counter.get().first() + number-of-slides-in-current-section)
    }
    
    [\# slides in next sections: #{remaining-slide-count}]
  }

  #v(1em)

  #context {
    let prev = (
      query(selector(heading.where(level: 2)).before(here(), inclusive: false)).len()
      // Exclude the current slide's title element
      - 2
      // Number of new section slides
      + query(selector(heading.where(level: 1)).before(here())).len()
    )

    let current = (
      query(selector(heading.where(level: 2)).after(here()).before(selector(heading.where(level: 1)).after(here()))).len()
      + 2
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

    let next = if is-last-section { 
        0 
    } else {
        utils.last-slide-counter.final().first() - (utils.slide-counter.get().first() + number-of-slides-in-current-section)
    }

    let total = prev + current + next

    // Array of proportions of slides in previous sections, current section, and next sections
    let pages = (
      calc.round(prev / total, digits: 2),
      calc.round(current / total, digits: 2),
      calc.round(next / total, digits: 2),
    )
    pages
  }

  #context {
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

    // Determine if this is the last section
    let total-sections = query(selector(heading.where(level: 1))).len()
    let heading-selector = selector(heading.where(level: 1)).before(here())
    let level = counter(heading-selector)
    let headings = query(heading-selector)
    if headings.len() == 0 { return 0 }
    let current-section-number = level.get().first()

    let is-last-section = total-sections == current-section-number

    let future-section-slides = if is-last-section { 
      0
    } else {
      (
        query(selector(heading.where(level: 2)).after(here()).after(selector(heading.where(level: 1)).after(here()))).len()
        + query(selector(heading.where(level: 1)).after(here())).len()
        + 1
      )
    }

    (
      historic-section-slides,
      slides-covered-in-current-section,
      slides-remaining-in-current-section,
      future-section-slides,

      historic-section-slides
      + slides-covered-in-current-section
      + slides-remaining-in-current-section
      + future-section-slides
    )
  }
]
