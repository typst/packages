/// Generate the numbering pattern of first-level headings for package numbly
/// 
/// -> str
#let pattern-heading-first-level(
  /// Language of the thesis
  ///
  /// -> "en" | "zh" | "pt"
  lang: "en",
  /// Supplementary of the heading
  /// 
  /// -> content
  supplement: [Chapter],
) = {
  if supplement == [Chapter] {
    if lang == "zh" {
      "第{1:一}章"
    } else if lang == "pt" {
      "Capítulo {1}"
    } else {
      "Chapter {1}"
    }
  } else if supplement == [Appendix] {
    if lang == "zh" {
      "附录{1:A}"
    } else if lang == "pt" {
      "Apêndice {1:A}"
    } else {
      "Appendix {1:A}"
    }
  }
}