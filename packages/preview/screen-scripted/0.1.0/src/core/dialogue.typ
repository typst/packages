#import "/src/config.typ": sp_config
#import "/src/util.typ": _format_dialogue_body, _is_parenthetical

#let dialogue(name, ext: "", cont: false, body) = context {
  let config = sp_config.get()

  let cue = if type(name) == content {
    upper(name.text.trim())
  } else {
    upper(name.trim())
  }

  let ext_trimmed = upper(ext.trim())

  if ext != "" {
    cue += " (" + ext_trimmed + ")"
  }

  if cont {
    cue += " ("+ config.cont-str +")"
  }

  align(center)[
    #block(width: 3.5in)[
      #align(left)[
        #move(
          dx: 1.5in,
          box(cue),
        )
      ]

      #let pre_cue_pg = counter(page).at(here()).first()
      #v(-4pt)

      #align(left)[
        #_format_dialogue_body(body)
      ]
    ]
  ]
}

#let dual-dialogue(d1, d2) = {
  columns(2, gutter: 2in)[
    #d1 #colbreak() #d2
  ]
}

#let montage(desc, body) = context {
  let config = sp_config.get()
  
  let desc_trimmed = upper(desc.text.trim())
  let dash = if config.slug-dashes == "double" {
    "--" 
  } else {
    "-"
  }

  [
    MONTAGE #dash #desc_trimmed \
    #body \
    END MONTAGE
  ]
}
