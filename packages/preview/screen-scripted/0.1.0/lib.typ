#import "/src/core/slugs.typ": (
  slugline,
  minislug,
)
#import "/src/core/dialogue.typ": (
  dialogue as _d, dual-dialogue,
  montage,
)
#import "/src/core/transition.typ": transition

#import "/src/experimental/dialogue_experimental.typ": dialogue as _d_exp

#import "/src/config.typ": (
  sp_config as _sp_config,
  default_config as _default_config,
  _validate_user_config,
)
#import "/src/util.typ": character

#let dialogue(..args) = context {
  let config = _sp_config.get()

  if config.dialogue-cont {
    _d_exp(..args)
  } else {
    _d(..args)
  }
}

#let scripted(
  title: "",
  authors: (),
  date: datetime.today(),
  version: "",
  info: [],
  config: (:),
  body,
) = {
  set text(
    font: ("Courier Prime", "DejaVu Sans Mono"),
    size: 12pt,
  )
  set page(paper: "us-letter", numbering: none)
  set par(leading: 4pt, spacing: 8pt)

  // Merge template and user config
  _validate_user_config(config)
  let merged_config = _default_config() + config
  assert(
    merged_config.slug-dashes == "single" or merged_config.slug-dashes == "double",
    message: "Only 'single' or 'double' are accepted values"
  )
  _sp_config.update(merged_config)

  // Title page
  align(center + horizon)[
    #underline(title) 
    #v(32pt)
    
    Written by \
    #if type(authors) == array {
      [ #authors.join(", ") \ ]
    } else if type(authors) == str {
      [ #authors \ ]
    }
    #v(12pt)
    
    #date.display("[month repr:long] [day padding:none], [year]") \
    #if version != "" {
      [ Version #version ]
    }
  ]
  align(bottom)[
    #info  
  ] 

  // Document contents
  pagebreak()
  counter(page).update(1)
  set page(
    numbering: (current, ..) => {
      if current > 1 {
        numbering("1.", current)
      }
    },
    number-align: top + right,
    margin: (
      top: 1in, bottom: 1in, left: 1.5in, right: 1.1in
    )
  )  
  
  [ #body ]
}

// Shorthand function calls
#let d(..args) = { dialogue(..args) }
#let sl(..args) = { slugline(..args) }
#let ms(..args) = { minislug(..args) }
#let t(..args) = { transition(..args) }
