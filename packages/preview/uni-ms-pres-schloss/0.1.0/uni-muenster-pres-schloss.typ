#import "@preview/polylux:0.4.0": *
#import "@preview/polylux:0.4.0": slide as s
#import "@preview/ez-today:2.1.0"
#import "math-utils.typ": *

// States for basic Data
#let title-state = state("title", [])
#let author-state = state("author", [])
#let date-state = state("date", [])

// Main colors
#let lapis = rgb("#00578A")       // Dark Blue
#let cyan = rgb("#009DD1")        // Light Blue
#let dark-grey = rgb("#333F48")   // Dark jet soft Grey (Used for e.g. text)

// Additional official colors (Mostly unused)
#let violet = rgb("#AF0078")
#let grey-blue = rgb("#006E89")   // Not colorblind friendly with main colors
#let turquoise = rgb("#008E96")   // Not colorblind friendly with main colors
#let light-green = rgb("#B1C800") // Apple Green

// These colors aren't part of the official theme
// However they should play very nice with the main colors (including colorblind friendly contrasts)
#let green = rgb("#7AB51D")       // A pastel green (Can be used with the official green without colorblind collision)
#let orange = rgb("#D28901")      // Medium Orange
#let red = rgb("#D14200")         // A pastel red
// Different steps of grey
#let light-grey = rgb("#f2f2f2")  // Lighter grey
#let medium-grey = rgb("#ccc")    // Somewhat light grey (Can collide with apple green)
#let grey = rgb("#a6a6a6")        // Just grey

#let x-margin = 1.2cm


// https://forum.typst.app/t/how-to-auto-size-text-and-images/1290/3
#let fill-height-with-text(
  min: 1em, 
  max: 5em, 
  eps: 0.1em, 
  it) = layout(size => {
    let fits(text-size, it) = {
      measure(width: size.width, { set text(text-size); it }).height <= size.height
    }
  
    if not fits(min, it) { panic("Content doesn't fit even at minimum text size") }
  
    let (a, b) = (min, max)
    while b - a > eps {
      let new = 0.5 * (a + b)
      if fits(new, it) {
        a = new
      } else {
        b = new
      }
    }
  
    set text(a)
    it
  }
)


// Base-Theme
#let pres-theme(
  text-font: "Carlito",
  text-lang: "en",
  text-size: 20pt,
  code-font: "JetBrains Mono",
  author: [],
  title: [],
  date: [],
  progressbar: true,
  body,
) = {
  set text(
    font: (text-font, "Libertinus Serif"),
    lang: text-lang,
    size: text-size,
    fill: dark-grey,
  )
  set par(
    justify: true,
  )
  
  // Global styling for bullet lists (Itemize)
  set list(marker: (
    text(size: 29pt, fill: lapis, baseline: -6pt)[#sym.triangle.filled.r], // Level 1
    text(size: 29pt, fill: cyan, baseline: -6pt)[#sym.triangle.filled.r], // Level 2
  ))
  
  // Global styling for numbered lists (Enumerate)
  set enum(numbering: 
    n => text(fill: lapis, weight: "extrabold")[#n.], // Level 1: 1.
  )
  
  // Global font and default text color for all code
  show raw: set text(font: (code-font, "DejaVu Sans Mono"), fill: dark-grey)
  
  // Set Code theme
  set raw(theme: "assets/Code_Color.tmTheme")
  
  // Style the surrounding block
  show raw.where(block: true): it => {
    // Add Line Numbers natively
    show raw.line: it => {
      box(
        width: 1.5em, 
        // Using 'grey' for the line numbers so they don't distract from the code
        align(right, text(fill: grey, size: 0.85em)[#it.number])
      )
      h(1em) // Spacing between the number and the code
      it.body
    }
    
    block(
      // Using 'light-grey' for the background and 'medium-grey' for the border
      fill: light-grey,
      inset: 12pt,
      radius: 20pt,
      width: 100%,
      stroke: 1pt + medium-grey,
      it
    )
  }

  // Color links
  show link: it => {
    if type(it.dest) == str {
      // Styling for external URL links
      set text(cyan)
      show link: underline
      it
    } else {
      // Internal links
      set text(grey)
      it
    }
  }
  // Set Bib style
  show bibliography: set bibliography(title: none)
  show bibliography: it => {
    show heading: set text(lapis)
    show link: set text(cyan)
    show link: underline
    it
  }
  
  // Footnote Size
  show footnote.entry: set text(size: .75em)

  // Update parameter info
  context {
    title-state.update(title)
    author-state.update(author)
    date-state.update(date)
  }

  set page(
    margin: (top: 20%, bottom: 10%, left: x-margin, right: x-margin),
    header-ascent: 23%,
    paper: "presentation-16-9",
    header: context {
        // Query document for Level 1 headings BEFORE this spot
        let headings = query(selector(heading.where(level: 1)).before(here()))
        
        // Extract the last one
        // If we haven't passed any yet, fall back to the main title.
        let current-chapter = if headings.len() > 0 {
            headings.last().body
        } else {
            title-state.get()
        }
        
        // Left
        place(top + left, dy: 0.4cm, dx: 0.6cm-x-margin, align(center, {
          image("assets/Logo.svg", width: 6cm)
        }))
        // Right
        place(horizon + right, dx: x-margin - 0.6cm, align(center, {
          text(size: 1em, fill: grey)[#current-chapter]
        }))
    },
    footer: context {
      set text(
        size: 0.8em,
        fill: dark-grey
      )
      let current-array = counter("logical-slide").get()
      let total-array = counter("logical-slide").final()
      
      // Pull integer out
      let current = if current-array.len() > 0 { current-array.first() } else { 1 }
      let total = if total-array.len() > 0 { total-array.first() } else { 1 }
      
      // Calculate the progress ratio
      let ratio = if total == 0 { 0 } else { current / total }
      let ratio_plus_1 = if total == 0 { 0 } else if current == total { 1 } else { (current + 1) / total }
      
      // Progress Overlay (Cyan-Lapis)
      // Gradient from ratio to ratio + 1
      if progressbar {
        place(top, dx: -x-margin,
          line(stroke: 1pt + gradient.linear((lapis, 0%), (lapis, ratio * 100%), (grey, ratio_plus_1 * 100%), (grey, 100%)), length: (100% + 2*x-margin))
        )
      } else {
        place(top, dx: -x-margin,
          line(stroke: 1pt + lapis, length: (100% + 2*x-margin))
        )
      }
      
      
      // Left (Author)
      place(bottom + left, dy: -0.4cm, dx: 0.6cm-x-margin, align(center, {
        text()[#author-state.get()]
      }))
      
      // Right (Slide Numbers)
      place(bottom + right, dy: -0.4cm, dx: x-margin - 0.6cm, align(center, {
        text()[#current / #total]
      }))
    }
  )
  show heading: set text(size: 1.2cm, fill: lapis)
  show heading: set block(above: 25pt, below: 25pt)
  body
}

#let title-slide(
  author: none,
  date: none,
  title: none,
  subtitle: none,
  max-width: 90%,
) = {
  set page(margin: 0%, header: none, footer: none)
  let content = context {
    // Background Image & Blue Overlay
    place(top + left, image("assets/Schloss_Left.jpeg", width: 100%, height: 100%, fit: "cover"))
    place(top + left, rect(width: 100%, height: 100%, fill: lapis.transparentize(20%)))

    // The White Top Decorative Shape
    place(top + left, curve(
      fill: white,
      curve.move((0%, 0%)),
      curve.line((80%, 0%)),
      curve.line((0%, 30%)),
    ))
    
    // University Logo (top left)
    place(top + left, dx: 0.6cm, dy: 0.4cm, 
      image("assets/Logo.svg", width: 6cm)
    )

    // Main Title and Author (Center Left)
    place(left + horizon, dx: 0.6cm, dy: 1.2cm, block(width: max-width, {
      set text(fill: white)
      set par(justify: false)
      
      block(width:90%, height: 4cm)[
        // Apply the dynamic sizing function
        #fill-height-with-text(min: 2em, max: 4em)[
          #text(weight: "bold")[
            #if title == none { title-state.get() } else { title }
          ]
        ]
      ]
      
      v(1em) 
      
      // Author
      text(size: 1.8em)[
        #if author == none { author-state.get() } else { author }
      ]
    }))

    // Footer - Left (living.knowledge)
    place(bottom + left, dx: 0.6cm, dy: -0.4cm,
      context {
        if text.lang == "de" {
          image("assets/Claim_GER_Negativ.svg", height: 0.9em)
        } else {
          image("assets/Claim_ENG_Negativ.svg", height: 0.9em)
        } 
      }
    )

    // Footer - Right (Date & Conference)
    place(bottom + right, dx: -0.6cm, dy: -0.6cm, align(right, {
      set text(fill: white, size: 1.1em)
      
      // Date
      text(style: "italic")[
        #if date == none { date-state.get() } else { date }
      ]
      
      v(-0.5em)
      
      // Conference Name
      if subtitle != none { subtitle }
    }))
  }
  s(content)
  counter("logical-slide").update(0)
}

/// Base for the rest of the slides
#let slide(
  heading: none,
  show-section: true,
  block-height: none,
  body,
) = {
  // Main-Content of the slide starts here
  let content = {
    // HEADING ON SLIDE
    if heading != none {
      block(
        below: 25pt,
        text(size: 1.2cm, fill: lapis)[*#heading*]
      )
      block(
        width: 100%,
        height: if block-height == none { 85% } else { block-height },
      )[
        #body 
      ]
    } else {
      // NO HEADING ON SLIDE
      block(
          width: 100%,
          height: if block-height == none { 100% } else { block-height },
      )[
        #body
      ]
    }
  }
  //SLIDE
  s(content)
}

/// Slide to show an outline
#let outline-slide(
  heading: none,
  multipage: false,
  items-per-page: 8
) = {
  
  let head = context {
    if text.lang == "de" { "Gliederung" } else { "Outline" }
  }
  
  toolbox.all-sections((sections, current) => {
    // Process the colors for internal links
    let colored-sections = sections.map(sec => {
      if sec.func() == link {          
        let is-dark-grey = sec.body.func() == text and sec.body.fields().at("fill", default: none) == dark-grey
        if is-dark-grey { sec } else { link(sec.dest, text(fill: dark-grey)[#sec.body]) }
      } else {
        sec 
      }
    })

    // Squish (Single Slide)
    if multipage == false { 
      slide(heading: [#if heading == none [#head] else { heading }])[
        #block(height: 100%)[
          #fill-height-with-text(min: 0.5em, max: 1.2em)[
            #enum(
              ..colored-sections,
              tight: false,
              indent: 1em,
              body-indent: 1em,
              // spacing left automatic for dynamic resize!
            )
          ]
        ]
      ]
    }
    // Chunking (Multi Page)
    else {
      let chunks = ()
      let i = 0
      while i < colored-sections.len() {
        // Store dictionary containing BOTH the slice and its starting number
        chunks.push((
          start-num: i + 1, // If i is 7, the next slide starts at 8
          items: colored-sections.slice(i, calc.min(i + items-per-page, colored-sections.len()))
        ))
        i += items-per-page
      }
      
      // Spawn a brand new slide-base for every chunk
      for (i, chunk) in chunks.enumerate() {
        slide(heading: [#if heading == none [#head (#numbering("i", i + 1))] else { heading }])[
          #enum(
            ..chunk.items,           // Pass the array of items
            start: chunk.start-num,  // <-- The magic fix: tell Typst where to start counting
            tight: false,
            indent: 1em,
            body-indent: 1em,
            spacing: 1.2em,
          )
        ]
      }
    }
  })
}

/// Slide to show an outline point
#let header-slide(
  body,
) = {
  set page(margin: 0%, header: none, footer: none)
  // Register heading in polylux environment
  toolbox.register-section(body)
  
  let content = context {
    // Background Image & Darker Blue Overlay
    place(top + left, image("assets/Schloss_Right.jpeg", width: 100%, height: 100%, fit: "cover"))
    place(top + left, rect(width: 100%, height: 100%, fill: lapis.transparentize(20%)))

    // The White Decorative Shapes
    place(top + left, curve(
      fill: white,
      curve.move((100%, 100%)),
      curve.line((67%, 100%)),
      curve.line((100%, 60%)),
    ))

    place(top + left, curve(
      fill: white,
      curve.move((0%, 0%)),
      curve.line((100%, 0%)),
      curve.line((0%, 19%)),
    ))

    place(top + left, dx: 0.6cm, dy: 0.4cm, 
      image("assets/Logo.svg", width: 6cm)
    )

    // Make heading for chapter title usage
    place(hide(heading(level: 1, bookmarked: true)[#body]))

    // Section Heading Layout
    place(center + horizon, block(width: 85%, height: 50%)[
      #set text(fill: white)
      #set par(justify: false)
      #block(width: 100%, height: 60%)[
        #align(bottom)[
          #fill-height-with-text(min: 2.2em, max: 3.2em)[
            #text(weight: "bold")[#body]
          ]
        ]
      ]

      #v(1.5em)
      
      #line(stroke: 1pt + white, length: 50%)

      #v(0.5em)

      #block(width: 80%, height: 35%)[
        #align(top)[
          #fill-height-with-text(min: 0.5em, max: 2em)[
            #text(weight: 500)[#title-state.get()]
          ]
        ]
      ]
    ])

    place(bottom + left, dx: 0.6cm, dy: -0.4cm, align(center, {
      text(fill: white, size: 0.8em)[#author-state.get()]
    }))
    //Right
    place(bottom + right, dx: -0.6cm, dy: -0.4cm, align(center, {
      text(size: 0.8em)[#toolbox.slide-number / #toolbox.last-slide-number]
    }))
    
  }
  
  // Pass the built content to your template's slide wrapper
  s(content)
}
