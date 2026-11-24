#import "/src/config.typ": sp_config
#import "/src/util.typ": _translate_shorthand

#let slugline(intext, location, time) = context {
  let config = sp_config.get()

  let intext_trimmed = _translate_shorthand(upper(intext.text.trim()))
  if config.check-strict {
    assert(
      intext_trimmed in ("INT", "EXT", "INT.", "EXT."),
      message: "Parameter 'intext' must be either: 'INT', 'INT.', 'EXT', 'EXT.' (case-insensitive)",
    )
  }
  intext_trimmed = intext_trimmed.replace(".", "")

  let time_trimmed = _translate_shorthand(upper(time.text.trim()))
  if config.check-strict {
    assert(
      time_trimmed in (
        "DAY",
        "NIGHT",
        "CONTINUOUS",
        "SAME",
        "DAWN",
        "DUSK",
        "LATER",
      ),
      message: "Parameter 'time' must be either: 'DAY', 'NIGHT', 'DAWN', 'DUSK', 'LATER', 'CONTINUOUS', 'SAME' (case-insensitive)",
    )
  }

  let dash = if config.slug-dashes == "double" {
    "--" 
  } else {
    "-"
  }

  let location_trimmed = upper(location.text.trim())
  let sl = [
    #intext_trimmed. #location_trimmed #dash #time_trimmed
  ]
  
  if config.bold-slugs {
    sl = strong(sl)
  }

  [
    #v(2pt)
    #sl
  ]
}

#let minislug(location) = context {
  let config = sp_config.get()
  
  let location-trimmed = upper(location.text.trim())
  let heading = [#location-trimmed]

  if config.bold-slugs {
    heading = strong(heading)
  }

  [ #heading ]
}

#let timeshift(title, slug: none, body) = context {
  let config = sp_config.get()
  let title-trimmed = upper(title.text.trim())
  
  let dash = if config.slug-dashes == "double" {
    "--" 
  } else {
    "-"
  }
  
  let heading = if slug == none {
    [#title-trimmed]
  } else {
    [#title-trimmed #dash #slug]
  }

  let end_text = [END #title]
  if config.bold-slugs {
    heading = strong(heading)
    end_text = strong(end_text)
  }

  [
    #heading \
    #body \
    #end_text \
  ]
}
