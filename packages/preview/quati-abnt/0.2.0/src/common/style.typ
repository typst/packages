// # Style. Estilo.

// ## Paper size. Tamanho do papel.
// NBR 14724:2024 5.1.
#let paper_size = "a4"

// ## Margins. Margens.
// NBR 14724:2024 5.1.
#let margin_top = 3.0cm
#let margin_bottom = 2.0cm
#let margin_start = 3.0cm
#let margin_end = 2.0cm

// ## Ident. Recuo.
// NBR 6024:2012.
#let indentation_for_paragraphs = 1.25cm
#let indentation_for_subparagraphs = indentation_for_paragraphs

// ## Font family. Família tipográfica.
#let font_family_sans = "Liberation Sans"
#let font_family_serif = "Liberation Serif"
#let font_family_mono = "Liberation Mono"
#let font_family_math = "New Computer Modern Math"
#let font_family_math_text = "New Computer Modern"

// ## Font size. Tamanho da fonte.
// NBR 14724:2024 5.1, NBR 6022:2018 6.1.
#let base_font_size = 12pt
//
#let font_size_for_larger_text = 1.083333em
#let font_size_for_common_text = 1em
// Smaller text must be used for: quotations with more than 3 lines, footnotes, page numbering, cataloging-in-publication, references and information of figures and tables.
#let font_size_for_smaller_text = 0.916667em

// ## Spacing. Espaçamento.
// NBR 14724:2024 5.2, NBR 6022:2018 6.1.
//
// ### Multipliers. Multiplicadores.
#let spacing_of_one = 1.0 / 2
#let spacing_of_one_and_a_half = 1.5 / 2
//
// ### Common text. Texto comum.
// Spacing of 1.5 must be used for common text.
#let spacing_for_larger_text = font_size_for_larger_text * spacing_of_one_and_a_half
#let spacing_for_common_text = font_size_for_common_text * spacing_of_one_and_a_half
//
// ### Smaller text. Texto menor.
// Spacing of 1 must be used for: quotations with more than 3 lines, footnotes, nature, references and information of figures and tables. We interpret that nature should also use this leading.
#let simple_spacing_for_smaller_text = font_size_for_smaller_text * spacing_of_one

// ## Leading. Entrelinha.
// NBR 14724:2024 5.2.
//
// ### Multipliers. Multiplicadores.
#let leading_of_one = spacing_of_one
#let leading_of_one_and_a_half = spacing_of_one_and_a_half
//
// ### Common text. Texto comum.
// Leading of 1.5 must be used for common text.
#let leading_for_larger_text = font_size_for_larger_text * leading_of_one_and_a_half
#let leading_for_common_text = font_size_for_common_text * leading_of_one_and_a_half
//
// ### Smaller text. Texto menor.
// Leading of 1 must be used for: quotations with more than 3 lines, footnotes, nature, references and information of figures and tables. We interpret that nature should also use this leading.
#let simple_leading_for_smaller_text = font_size_for_smaller_text * leading_of_one


// ## Figures. Figuras.
#let spacing_around_figure = spacing_for_common_text
