#import "../state.typ": footer-text, page-format, section, sections
#import "../utils.typ": styled

// If `numbering.position` is "top", chapter and appendix pages show the number at the top right.
// A page that opens a chapter keeps it at the bottom.
#let number-on-top(cfg, sec) = (
  cfg.numbering.position == "top"
    and sec in (sections.main, sections.back)
    and not query(heading.where(level: 1)).any(h => (
      h.location().page() == here().page()
    ))
)

#let page-number(cfg, sec) = text(size: cfg.typography.font-size, numbering(
  page-format(cfg, sec),
  counter(page).get().first(),
))

// Show the page number at the top right if `number-on-top` allows it.
#let page-header(cfg) = context {
  let sec = section.get()
  if cfg.footer.show-page-number and number-on-top(cfg, sec) {
    align(right, page-number(cfg, sec))
  }
}

// The built-in footer: the text above the page number.
// It gets the same data as a `footer.render` hook.
#let default-footer(f, it) = [
  #if it.left != none [
    #align(left, styled(f.text, it.left))
    #v(0.2em)
  ]
  #if it.number != none [
    #align(f.page-number-align, it.number)
  ]
]

#let page-footer(cfg) = context {
  let f = cfg.footer
  let sec = section.get()
  if sec == sections.cover or not f.enabled {
    return none
  }
  set par(first-line-indent: 0pt)

  let left-text = footer-text.get()
  let render = if f.render == auto { default-footer.with(f) } else { f.render }
  render((
    number: if f.show-page-number and not number-on-top(cfg, sec) {
      page-number(cfg, sec)
    },
    left: if left-text == none { f.left } else { left-text },
    part: sec,
  ))
}
