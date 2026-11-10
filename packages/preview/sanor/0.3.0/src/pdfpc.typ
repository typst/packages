/// imported from https://github.com/polylux-typ/polylux/blob/main/src/toolbox/pdfpc.typ 
/// Same as Polylux package 

/// Adds speaker notes to a slide, visible only in the presenter view. 
/// 
/// ```typst
/// #pdfpc.speaker-note[Remember to emphasize this point during the presentation]
/// ```
/// -> metadata
#let speaker-note(
  /// Speaker notes as a string or raw code block
  /// -> str | raw
  text
) = {
  let text = if type(text) == str {
    text
  } else if type(text) == content and text.func() == raw {
    text.text.trim()
  } else {
    panic("A note must either be a string or a raw block")
  }
  [ #metadata((t: "Note", v: text)) <pdfpc> ]
}

/// Mark the end of a slide
/// -> metadata
#let end-slide = [
  #metadata((t: "EndSlide")) <pdfpc>
]

/// Save the current slide state
/// -> metadata
#let save-slide = [
  #metadata((t: "SaveSlide")) <pdfpc>
]

/// Mark a slide as hidden from the presentation
/// -> metadata
#let hidden-slide = [
  #metadata((t: "HiddenSlide")) <pdfpc>
]

/// Configure presentation settings for pdfpc.
/// 
/// ```typst
/// #pdfpc.config(
///   duration-minutes: 30,
///   start-time: "14:00",
///   last-minutes: 5,
/// )
/// ```
#let config(
  /// Total presentation duration in minutes
  /// -> int
  duration-minutes: none,
  /// Presentation start time in HH:MM format
  /// -> str | datetime
  start-time: none,
  /// Presentation end time in HH:MM format
  /// -> str | datetime
  end-time: none,
  /// Highlight final N minutes with visual alert
  /// -> int
  last-minutes: none,
  /// Font size of the speaker note
  /// -> int
  note-font-size: none,
  /// Whether or not to disable rendering the notes as markdown
  /// -> bool
  disable-markdown: false,
  /// Default slide transition settings
  /// -> dictionary
  default-transition: none,
) = {
  if duration-minutes != none {
    [ #metadata((t: "Duration", v: duration-minutes)) <pdfpc> ]
  }

  let _time-config(time, msg-name, tag-name) = {
    let time = if type(time) == datetime {
      time.display("[hour padding:zero repr:24]:[minute padding:zero]")
    } else if type(time) == str {
      time
    } else {
      panic(msg-name + " must be either a datetime or a string in the HH:MM format.")
    }

    [ #metadata((t: tag-name, v: time)) <pdfpc> ]
  }

  if start-time != none {
    _time-config(start-time, "Start time", "StartTime")
  }

  if end-time != none {
    _time-config(end-time, "End time", "EndTime")
  }

  if last-minutes != none {
    [ #metadata((t: "LastMinutes", v: last-minutes)) <pdfpc> ]
  }

  if note-font-size != none {
    [ #metadata((t: "NoteFontSize", v: note-font-size)) <pdfpc> ]
  }

  [ #metadata((t: "DisableMarkdown", v: disable-markdown)) <pdfpc> ]

  if default-transition != none {
    let dir-to-angle(dir) = if dir == ltr {
      "0"
    } else if dir == rtl {
      "180"
    } else if dir == ttb {
      "90"
    } else if dir == btt {
      "270"
    } else {
      panic("angle must be a direction (ltr, rtl, ttb, or btt)")
    }

    let transition-str = (
      default-transition.at("type", default: "replace")
      + ":" +
      str(default-transition.at("duration-seconds", default: 1))
      + ":" +
      dir-to-angle(default-transition.at("angle", default: rtl))
      + ":" +
      default-transition.at("alignment", default: "horizontal")
      + ":" +
      default-transition.at("direction", default: "outward")
    )

    [ #metadata((t: "DefaultTransition", v: transition-str)) <pdfpc> ]
  }
}

// Touying and Polylux's Idea.
#let pdfpc-slide-markers(ctx) = context [
  #let i = ctx.subslide
  #metadata((t: "NewSlide")) <pdfpc>
  #metadata((t: "Idx", v: here().page() - 1)) <pdfpc>
  #metadata((t: "Overlay", v: i - 1)) <pdfpc>
  #metadata((t: "LogicalSlide", v: counter(page).get().first())) <pdfpc>
]