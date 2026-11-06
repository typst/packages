// states
#let default-row-height = state("bf-row-height", 2.5em);
#let default-header-font-size = state("bf-header-font-size", 9pt);
#let default-field-font-size = state("bf-field-font-size", auto);
#let default-note-font-size = state("bf-note-font-size", auto);
#let default-header-background = state("bf-header-bg", none);
#let default-header-border = state("bf-header-border", none);

// function to use with show rule
#let bf-config(
  row-height: 2.5em,
  field-font-size: auto,
  note-font-size: auto,
  header-font-size: 9pt,
  header-background: none,
  header-border: none,
  content
  ) = {
  default-row-height.update(row-height);
  default-header-font-size.update(header-font-size)
  default-field-font-size.update(field-font-size)
  default-note-font-size.update(note-font-size)
  default-header-background.update(header-background)
  default-header-border.update(header-border)
  content
}


#let get-default-row-height() = {
  default-row-height.get()
}

#let get-default-header-font-size() = {
  default-header-font-size.get()
}

#let get-default-field-font-size() = {
  default-field-font-size.get()
}

#let get-default-note-font-size() = {
  default-note-font-size.get()
}

#let get-default-header-background() = {
  default-header-background.get()
}

#let get-default-header-border() = {
  default-header-border.get()
}
