// # Font family. Família tipográfica.

#import "../style.typ": base_font_size, font_family_math, font_family_mono, font_family_sans, font_family_serif


#let font_family_for_common_text_state = state("quati_abnt_font_family_for_common_text", font_family_serif)
#let font_family_for_highlighted_text_state = state("quati_abnt_font_family_for_highlighted_text", font_family_sans)
#let font_family_for_math_text_state = state("quati_abnt_font_family_for_math_text", font_family_math)
#let font_family_for_monospaced_text_state = state("quati_abnt_font_family_for_monospaced_text", font_family_mono)

#let base_font_size_state = state("quati_abnt_base_font_size", none)
