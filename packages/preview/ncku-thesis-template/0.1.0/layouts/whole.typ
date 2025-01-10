/*
 * NOTE: this is the global settings which applys to the whole documents
 * NOTE: includes cover, abstract, acknowledge, mainmatter, reference and appendix
 *
 * @param main_lang: the main language to writting the thesis/dissertation
 * @param doc: contents of the following documents which the show rule apply to
 */
#let whole(
  main_lang: (en: true, zh_tw: false),
  doc,
) = {
  // check the lang type setting
  assert(
    (
      (main_lang.at("en") and (not main_lang.at("zh_tw")))
        or (main_lang.at("zh_tw") and (not main_lang.at("en")))
    ), // XOR logic
    message: "You should chose only one main language type!",
  )

  // apply the the whole thesis/dissertation
  set page(paper: "a4")

  // set the fonts of whole document
  set text(
    // NOTE: "Times New Roman" as main english font
    // NOTE: "TW-MOE-Std-Kai" as main zh-tw font
    font: ("Times New Roman", "TW-MOE-Std-Kai"),
    lang: if main_lang.at("zh_tw") { "zh" } else { "en" },
    region: if main_lang.at("zh_tw") { "tw" } else { none },
  )

  // make objects with "invisible" lebel be hidden
  show label("invisible"): it => { }

  // display the content
  doc
}
