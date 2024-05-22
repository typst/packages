// states
#let default_row_height = state("bf-row-height", 2.5em);
#let default_header_font_size = state("bf-header-font-size", 9pt);
#let default_field_font_size = state("bf-field-font-size", auto);
#let default_note_font_size = state("bf-note-font-size", auto);
#let default_header_background = state("bf-header-bg", none);
#let default_header_border = state("bf-header-border", none);

// function to use with show rule
#let bf-config(
  row_height: 2.5em,
  field_font_size: auto,
  note_font_size: auto,
  header_font_size: 9pt,
  header_background: none,
  header_border: none,
  content
  ) = {
  default_row_height.update(row_height);
  default_header_font_size.update(header_font_size)
  default_field_font_size.update(field_font_size)
  default_note_font_size.update(note_font_size)
  default_header_background.update(header_background)
  default_header_border.update(header_border)
  content
}


#let get-default-row-height() = {
  default_row_height.get()
}

#let get-default-header-font-size() = {
  default_header_font_size.get()
}

#let get-default-field-font-size() = {
  default_field_font_size.get()
}

#let get-default-note-font-size() = {
  default_note_font_size.get()
}

#let get-default-header-background() = {
  default_header_background.get()
}

#let get-default-header-border() = {
  default_header_border.get()
}