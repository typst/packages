/// this config file is for Chinese documents, using Barlow, Noto Sans CJK SC, Noto Serif CJK SC, IBM Plex Mono fonts, STIX Two Math for math, and Zapf Dingbats for symbols
#let _lang = "zh"
#let _appendix_numbering = "A.1"
#let _title_font = ((name: "Barlow", covers: "latin-in-cjk"), "Noto Sans CJK SC")
#let _sans_font = ((name: "Barlow", covers: "latin-in-cjk"), "Noto Sans CJK SC")
#let _serif_font = ("Noto Serif CJK SC", "Noto Color Emoji")
#let _caption_font = "Noto Serif CJK SC"
#let _subheading_font = "Noto Serif CJK SC"
#let _math_text_opts = (font: (.._serif_font, "STIX Two Math"), features: ("ss02", "ss03"))
#let _mono_font = "IBM Plex Mono"
#let _symbol_font = "Zapf Dingbats"
#let _draft = "草稿"
#let _date_format = "[year]年[month]月[day]日"
#let _main_size = 11pt
#let _lineskip = 0.75em
#let _envskip = 1.2em
#let _parskip = _lineskip //1.2em
#let _eq_spacing = 1em
#let _figure_spacing = 1.5em
#let _title_size = 20pt
#let _heading1_size = 24pt
#let _heading2_size = 1.35 * _main_size
#let _heading3_size = 1.2 * _main_size
#let _page_top_margin = 20mm + _main_size
#let _page_bottom_margin = 2cm
#let _page_num_size = 15pt
#let _page_margin = 15mm
#let _page_margin_sep = 8mm
#let _page_margin_note_width = 40mm
#let _chap_top_margin = 100mm
// for the "book" weights of NCM font
#let _default_weight = 400
#let _subheading_size = 13pt
#let _two_sided = true

#let i18n = (
  chapter: "章",
  section: "节",
  appendix: "附录",
  proof: (name: "证明：", supplement: "证明"),
  proposition: "命题",
  example: "例",
  definition: "定义",
  bibliography: "参考文献",
  index: "索引",
  equation: "公式",
  toc: "目录",
)

#let _color_palette = (
  accent: rgb(189, 28, 62),
  accent-light: rgb(252, 245, 245),
  // accent: rgb(85, 117, 137),
  // accent-light: rgb(246, 248, 249),
  grey: rgb(100, 100, 100),
  grey-light: rgb(224, 228, 228),
)
#let _qed_symbol = text(font: _math_text_opts.font)[$qed$]
