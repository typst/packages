#import "@preview/touying:0.6.1": *
#import "colors.typ" as muw_colors

// MedUni Wien logos with transparent backgrounds
#let muw-logo-dunkelblau(..args) = image("./assets/muw_dunkelblau.svg", ..args)
#let muw-logo-white(..args) = image("./assets/muw_white.svg", ..args)

// Rounded corner box utility
#let muw-box(radius: 11%, fill: rgb(216, 243, 239, 100%), ..args) = box(
    radius: (top-left: radius, bottom-right: radius), 
    clip: true, 
    fill: fill,
    ..args
)


// Custom footer function with proper logo selection
#let muw-footer(
  footer-title: [Presentation title/topic OR Presenter's name],
  orga: [Organisational unit],
  show-date: true,
  page-numbering-fn: (current, total) => [#current / #total],
  page-numbering-start: 2,
  footer-text-font: "lucida sans",
) = context {
  let page-fill = page.fill
  let is-dark-bg = page-fill == muw_colors.colors.dunkelblau
  
  // Footer background: white for dark slides, dunkelblau for light slides
  let footer-bg = if is-dark-bg { white } else { muw_colors.colors.dunkelblau }
  // Footer text: dunkelblau for white footer, white for dunkelblau footer
  let footer-text-color = if is-dark-bg { muw_colors.colors.dunkelblau } else { white }

  set text(font: footer-text-font, fill: footer-text-color)

  let current-margin = 3.3mm
  
  place(bottom, dx: -current-margin)[
    #box(
      fill: footer-bg,
      height: 15mm,
      width: 100% + 2 * current-margin
    )[
      #set align(center + horizon)
      
      #grid(
        columns: (3fr, 2fr, 1fr),
        align: (left, left, right),
        column-gutter: 1fr,
        
        // Empty box
        box(fill: none, stroke:none),
        
        // Title and organization
        box[
          #stack(
            dir: ttb, 
            spacing: 2mm,
            text(size: 7pt, weight: "regular", footer-title),
            text(size: 7pt, weight: "bold", orga)
          )
        ],
        
        // Page number and date
        if here().page() >= page-numbering-start {
          box(inset: (x: 9mm))[
            #stack(
              dir: ttb, 
              spacing: 2mm,
              if show-date {
                text(size: 7pt, weight: "regular")[#datetime.today().display("[day]. [month repr:short] [year]")]
              },
              text(size: 7pt, weight: "regular")[
                #page-numbering-fn(
                  counter(page).at(here()).first(), 
                  counter(page).final().first()
                )
              ]
            )
          ]
        }
      )
    ]
  ]

    place(bottom, dx: 4 * current-margin)[
    #box(
      fill: none,
      height: 15mm,
      width: 100% + 2 * current-margin
    )[
      #set align(center + horizon)
      
      #grid(
        columns: (2fr, 2fr, 1fr),
        align: (left, left, right),
        column-gutter: 1fr,
        
        // Logo selection based on footer background
        box(inset: (x: 0mm))[        
          #if is-dark-bg {
            // White footer gets dunkelblau logo
            muw-logo-dunkelblau(height: 10mm)
          } else {
            // Dunkelblau footer gets white logo
            muw-logo-white(height: 10mm)
          }
        ],
        
        // Title and organization
        box(inset: (x: 0mm), fill: none, stroke:none),
        
        // Page number and date
        if here().page() > 1 {
          box(inset: (x: 9mm), fill: none, stroke:none)
        }
      )
    ]
  ]
}

// Title slide with a darkblue background 
#let title-slide-dunkelblau(..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  
  let body = {
    set align(left + horizon)
    set page(fill: muw_colors.colors.dunkelblau)
    set text(fill: muw_colors.colors.white, font: "georgia")
    set par(justify: true, leading: 0.5em, spacing: 1em)
    if info.title != none {
      block(
        inset: (left: 0.5em, bottom: 1em),
        text(size: 50pt, weight: "regular", fill: muw_colors.colors.white, hyphenate: false, info.title)
      )
    }

    if info.author != none {
      block(
        inset:(left: 0.5em),
        text(size: 20pt, fill: muw_colors.colors.white, weight: "regular", info.author),
      )
    }
    if info.institution != none {
      block(
        inset:(left: 0.5em),
        text(size: 20pt, fill: muw_colors.colors.white, weight: "regular", info.institution)
      )
    }
    if info.date != none {
      block(
        inset:(left: 0.5em),
        utils.display-info-date(self)
      )
    }
  }
  touying-slide(self: self, body)
})


// Title slide with a white background 
#let title-slide-white(..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  
  let body = {
    set align(left + horizon)
    set page(fill: muw_colors.colors.white)
    set text(fill: muw_colors.colors.dunkelblau, font: "georgia")
    set par(justify: true, leading: 0.5em, spacing: 1em)
    if info.title != none {
      block(
        inset: (left: 0.5em, bottom: 1em),
        text(size: 50pt, weight: "regular", fill: muw_colors.colors.dunkelblau, hyphenate: false, info.title)
      )
    }

    if info.author != none {
      block(
        inset:(left: 0.5em),
        text(size: 20pt, fill: muw_colors.colors.dunkelblau, weight: "regular", info.author),
      )
    }
    if info.institution != none {
      block(
        inset:(left: 0.5em),
        text(size: 20pt, fill: muw_colors.colors.dunkelblau, weight: "regular", info.institution)
      )
    }
    if info.date != none {
      block(
        inset:(left: 0.5em),
        utils.display-info-date(self)
      )
    }
  }
  touying-slide(self: self, body)
})


// New section slide
#let new-section-slide(self: none, body) = touying-slide-wrapper(self => {
  let slide-content = {
      set align(left + horizon)
      set page(fill: muw_colors.colors.white)
      set par(justify: true, spacing: 1em, first-line-indent: 0pt)
      block(
        inset: (left: 0.5em, top: 8em),
        text(size: 42pt, weight: "regular", font: "georgia", fill: muw_colors.colors.dunkelblau, utils.display-current-heading(level: 1))
      )
      if body != none and body != [] {
        block(
          inset: (left: 0.5em),
          text(size: 20pt, weight: "regular", font: "georgia", fill: muw_colors.colors.dunkelblau, body)
        )
      }
  }
  touying-slide(self: self, slide-content)
})

// Focus slide with white background for attention
#let focus-slide-white(title, subtitle) = touying-slide-wrapper(self => {
  let slide-content = {
      set align(left + horizon)
      set page(fill: muw_colors.colors.white)
      set par(justify: true, spacing: 1em, first-line-indent: 0pt)
      block(
        inset: (left: 0.5em, top: 8em),
        text(size: 42pt, weight: "regular", font: "georgia", fill: muw_colors.colors.dunkelblau, title)
      )
      if subtitle != none and subtitle != [] {
        block(
          inset: (left: 0.5em),
          text(size: 20pt, weight: "regular", font: "georgia", fill: muw_colors.colors.dunkelblau, subtitle)
        )
      }
  }
  touying-slide(self: self, slide-content)
})

// Focus slide with green background for attention
// Note: This green background color is not defined in colors.typ
#let focus-slide-green(title, subtitle) = touying-slide-wrapper(self => {
  let slide-content = {
      set align(left + horizon)
      set page(fill: self.colors.bg-green)
      set par(justify: true, spacing: 1em, first-line-indent: 0pt)
      block(
        inset: (left: 0.5em, top: 8em),
        text(size: 42pt, weight: "regular", font: "georgia", fill: muw_colors.colors.dunkelblau, title)
      )
      if subtitle != none and subtitle != [] {
        block(
          inset: (left: 0.5em),
          text(size: 20pt, weight: "regular", font: "georgia", fill: muw_colors.colors.dunkelblau, subtitle)
        )
      }
  }
  touying-slide(self: self, slide-content)
})

// Focus slide with coral background for attention
// Note: This coral background color is not defined in colors.typ
#let focus-slide-coral(title, subtitle) = touying-slide-wrapper(self => {
  let slide-content = {
      set align(left + horizon)
      set page(fill: self.colors.ppt-coral)
      set par(justify: true, spacing: 1em, first-line-indent: 0pt)
      block(
        inset: (left: 0.5em, top: 8em),
        text(size: 42pt, weight: "regular", font: "georgia", fill: muw_colors.colors.dunkelblau, title)
      )
      if subtitle != none and subtitle != [] {
        block(
          inset: (left: 0.5em),
          text(size: 20pt, weight: "regular", fill: muw_colors.colors.dunkelblau, subtitle)
        )
      }
  }
  touying-slide(self: self, slide-content)
})


////////////////////////////////////////////////////////////////
// Standard slide function
#let slide(..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let body = args.pos().at(0, default: none)
  
  // Get title from heading or explicit parameter
  let title = args.named().at("title", default: auto)
  let subtitle = args.named().at("subtitle", default: auto)
  
  if title == auto {
    title = utils.display-current-heading(level: 2)
  }

  if title != auto and title != none {
    self.store.title = title
  }

  if subtitle == auto {
    subtitle = utils.display-current-heading(level: 3)
  }

  if subtitle != auto and subtitle != none {
    self.store.subtitle = subtitle
  }
 
  let slide-content = {
    // set align(left + top)
    set page(fill: muw_colors.colors.white)
    set text(fill: muw_colors.colors.black)
    set par(justify: true, spacing: 0.9em, leading: 0.9em, first-line-indent: 0pt)

    // Hide level 3 headings since they're used as subtitles
    show heading.where(level: 3): none
    
    // Display title
    if title != auto and title != none {
      block(
        inset: (left: 0.5em),
        text(size: 27pt, weight: "regular", font: "georgia", fill: muw_colors.colors.dunkelblau, title)
      )
    }
    
    // Display subtitle if available
    if subtitle != auto and subtitle != none {
      block(
        inset: (left: 0.5em),
        text(size: 20pt, weight: "regular", font: "georgia", fill: muw_colors.colors.hellblau, subtitle)
      )
    }
    
    set par(justify: true, 
            leading: 1.3em, 
            first-line-indent: 0pt)

    // Display slide content
    if body != none {
      set text(size: 17pt, weight: "regular", font: "lucida sans", fill: muw_colors.colors.black)
      block(
        inset: (top: 0.5em, left: 0.5em, right: 0.5em),
        body
      )
    }
  }

  touying-slide(self: self, slide-content)
})
////////////////////////////////////////////////////////////////

 
// Black slide for medical imaging
// Imaging slide with black background for medical images
#let imaging-slide(
  title: none,
  subtitle: none,
  picture: none,
  picture-width: 100pt,  // Changed to absolute value
  ..args
) = touying-slide-wrapper(self => {
  let body = args.pos().at(0, default: none)
  
  let slide-content = {
    set align(left + top)
    set page(fill: muw_colors.colors.black)
    set text(fill: muw_colors.colors.white)
    set par(justify: true, leading:0.9em, first-line-indent: 0pt)
    
    // Title
    if title != none {
      block(
        inset: (left: 0.5em),
        text(size: 27pt, weight: "regular", fill: muw_colors.colors.white, title)
      )
    }
    
    // Subtitle
    if subtitle != none {
      block(
        inset: (left: 0.5em),
        text(size: 20pt, weight: "regular", fill: muw_colors.colors.hellblau, subtitle)
      )
    }
    
    // Main content area with image and text side by side
    if picture != none or body != none {
      grid(
        columns: (picture-width, 1fr),  
        column-gutter: 1em,
        
        // Left column: Image
        if picture != none {
          set align(top + left)
          set image(width: 100%)
          picture
        } else {
          []
        },
        
        // Right column: Content
        if body != none {
          set par(justify: true, 
                  spacing: 1.3em, 
                  leading: 1.3em,
                  first-line-indent: 0pt)
          align(left + top)[
            #block(
              inset: (top: 1em, left: 0em, right: 0.5em),
              text(size: 17pt, weight: "regular", font: "lucida sans", fill: muw_colors.colors.white, body)
            )
          ]
        } else {
          []
        }
      )
    }
  }
  
  touying-slide(self: self, slide-content)
})


// Black slide for medical imaging
#let imaging-slide-black(
  bg-fill: black,
  font-fill: white,
  ..args,
  body
) = touying-slide-wrapper(self => {
  let self = utils.merge-dicts(
    self,
    config-page(fill: bg-fill),
  )
  set text(fill: font-fill)
  touying-slide(self: self, ..args, body)
})




// Define the MedUni Wien Touying theme
#let muw-theme(
  aspect-ratio: "16-9",
  footer-title: [Presentation title/topic OR Presenter's name],
  footer-orga: [Organisational unit],
  show-date: false,
  page-numbering-start: 2,
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (x: 2em, y: 2em, bottom: 2em),
      footer: muw-footer(
        footer-title: footer-title,
        orga: footer-orga,
        show-date: show-date,
        page-numbering-start: page-numbering-start,
      )
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      slide-level: 2,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(size: 20pt, lang: "en")
        set par(justify: true)
        show math.equation: set text(size: 20pt)
        // show strong: utils.alert-with-primary-color
        
        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: muw_colors.colors.dunkelblau,
      secondary: muw_colors.colors.hellblau,
      neutral-lightest: muw_colors.colors.white,
      neutral-darkest: muw_colors.colors.dunkelblau,
      bg-green: rgb(176, 230, 223, 100%),
      ppt-coral: rgb(253, 216, 201, 80%),
      box-green: rgb(216, 243, 239, 100%),
    ),
    ..args,
  )
  
  body
}

#let next-slide(body) = {
  pagebreak()
  body
}

// Export theme and utilities
#let muw-slides = muw-theme

