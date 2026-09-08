#import "/src/config.typ": sp_config

#let _dialogue_counter = counter("_screen_scripted_dialogue")
#let _dialogue_cue_gap = 1.2em - 8pt
#let _dialogue_more_gap = 0.5em

#let _dialogue_header_counter() = {
  counter(
    "_screen_scripted_dialogue_header:"
      + str(_dialogue_counter.get().first())
  )
}

#let _dialogue_footer_counter() = {
  counter(
    "_screen_scripted_dialogue_footer:"
      + str(_dialogue_counter.get().first())
  )
}

#let _dialogue_continuation_style(body) = {
  show table: it => _dialogue_counter.step() + it
  body
}

#let _dialogue_continuation_marker = context {
  let config = sp_config.get()
  return "(" + config.cont-str + ")"
}

#let _dialogue_text(value) = {
  if type(value) == str {
    value
  } else if type(value) != content {
    str(value)
  } else if value.has("text") {
    value.text
  } else if value.has("children") {
    value.children
      .map(_dialogue_text)
      .join("")
  } else if value.has("child") {
    _dialogue_text(value.child)
  } else if value.has("body") {
    _dialogue_text(value.body)
  } else if value == [ ] {
    " "
  } else {
    ""
  }
}

#let _dialogue_without_terminal_parenthetical(value) = {
  value
    .replace(
      regex("\\s*\\([^()]*\\)\\s*$"),
      "",
    )
    .trim()
}


#let _is_parenthetical(it) = {
  if it.func() != text {
    false
  } else {
    let value = it.text.trim()
    value.starts-with("(") and value.ends-with(")")
  }
}

#let _format_dialogue_body(body) = {
  if body.has("children") {
    for child in body.children {
      if _is_parenthetical(child) {
        h(1in)
        child
      } else {
        child
      }
    }
  } else if _is_parenthetical(body) {
    body
  } else {
    body
  }
}

#let _format_dialogue_cue(cue) = {
  align(left)[
    #move(
      dx: 1.5in,
      box(cue),
    )
  ]
}

#let _dialogue_initial_cue(cue) = {
  block(
    width: 100%,
    sticky: true,
    above: 0pt,
    below: 0pt,
  )[
    #pad(
      bottom: _dialogue_cue_gap,
      _format_dialogue_cue(cue),
    )
  ]
}

#let _dialogue_continuation_header(cue) = {
  table.header(
    repeat: true,

    table.cell(
      inset: 0pt,
      stroke: none,

      context {
        let header_counter = _dialogue_header_counter()

        // The step is inserted at this position in layout.
        header_counter.step()

        // Counter updates inside this context aren't visible to get()
        // immediately, hence the + 1.
        let occurrence = 1 + header_counter.get().first()

        if occurrence == 1 {
          none
        } else {
          pad(
            bottom: _dialogue_cue_gap,
            _format_dialogue_cue(cue),
          )
        }
      },
    ),
  )
}

#let _dialogue_continuation_footer() = {
  table.footer(
    repeat: true,

    table.cell(
      inset: 0pt,
      stroke: none,

      context {
        let footer_counter = _dialogue_footer_counter()

        footer_counter.step()

        let occurrence = 1 + footer_counter.get().first()
        let occurrence_count = footer_counter.final().first()

        let more = pad(
          top: _dialogue_more_gap,
          align(center)[
            (MORE)
          ],
        )

        if occurrence < occurrence_count {
          more
        } else {
          hide(more)
        }
      },
    ),
  )
}

#let dialogue(
  name,
  ext: "",
  cont: false,
  body,
) = {
  set par(leading: 4pt)
  
  let full_name = upper(
    _dialogue_text(name).trim()
  )
  let continuation_name = (
    _dialogue_without_terminal_parenthetical(full_name)
  )
  let ext_trimmed = upper(
    _dialogue_text(ext).trim()
  )
  let ext_suffix = if ext_trimmed != "" {
    " (" + ext_trimmed + ")"
  } else {
    ""
  }
  let first_cue = full_name + ext_suffix
  
  if cont {
    first_cue = (
      continuation_name
      + ext_suffix
      + " "
      + _dialogue_continuation_marker
    )
  }

  let continued_cue = (
    continuation_name
    + ext_suffix
    + " "
    + _dialogue_continuation_marker
  )

  _dialogue_continuation_style(
    align(center)[
      #block(
        width: 3.5in,
        breakable: true,
        below: -4pt,
      )[
        #_dialogue_initial_cue(first_cue)
        
        // Dialogue that may be breakable
        #table(
          columns: (100%,),
          inset: 0pt,
          _dialogue_continuation_header(
            continued_cue,
          ),
          table.cell(
            inset: 0pt,
            breakable: true,
            align: left,
            stroke: none,
          )[
            #_format_dialogue_body(body)
          ],

          // (MORE) on all non-final fragments.
          _dialogue_continuation_footer(),
        )
      ]
    ]
  )
}
