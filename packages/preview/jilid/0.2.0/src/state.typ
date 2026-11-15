// The state that the rules, pages and footer read.

// The parts of a document.
// A typo such as `sections.mian` fails.
#let sections = (cover: "cover", front: "front", main: "main", back: "back")
#let section = state("jilid-section", sections.front)

// The text from `set-footer-text`.
// none uses `footer.left`.
#let footer-text = state("jilid-footer-text", none)

#let page-format(cfg, sec) = {
  if (
    sec == sections.main
      or (sec == sections.back and cfg.numbering.back == "body")
  ) {
    "1"
  } else {
    cfg.numbering.front
  }
}

// The page number at `loc` as text, as the footer shows it, such as "iv".
#let page-label(cfg, loc) = numbering(
  page-format(cfg, section.at(loc)),
  counter(page).at(loc).first(),
)
