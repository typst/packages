// states
#let __default_row_height = state("bf-row-height", 2.5em);
#let __default_header_font_size = state("bf-header-font-size", 9pt);

// function to use with show rule
#let bf-config(
  row_height: 2.5em,
  header_font_size: 9pt,
  content
  ) = {
  __default_row_height.update(row_height);
  __default_header_font_size.update(header_font_size)
  content
}


#let _get_row_height(loc) = {
  __default_row_height.at(loc)
}

#let _get_header_font_size(loc) = {
  __default_header_font_size.at(loc)
}