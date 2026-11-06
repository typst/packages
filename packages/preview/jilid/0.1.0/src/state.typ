// state for the rules, pages and footer.

// the parts of a document.
// a typo such as `sections.mian` fails.
#let sections = (cover: "cover", front: "front", main: "main", back: "back")
#let section = state("jilid-section", sections.front)

// page number style from the current `frontmatter(numbering: ..)`.
#let front-override = state("jilid-front-numbering", auto)

// text from `set-footer-text`.
// none uses `footer.left`.
#let footer-text = state("jilid-footer-text", none)

#let page-format(cfg, sec, override: auto) = {
  if (
    sec == sections.main
      or (sec == sections.back and cfg.numbering.back == "body")
  ) {
    "1"
  } else if override not in (auto, none) {
    override
  } else {
    cfg.numbering.front
  }
}

// the page number at `loc` as text, as the footer shows it.
#let page-label(cfg, loc) = numbering(
  page-format(cfg, section.at(loc), override: front-override.at(loc)),
  counter(page).at(loc).first(),
)
