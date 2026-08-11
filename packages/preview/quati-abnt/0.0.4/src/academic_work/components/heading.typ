// # Headings. Títulos.

#import "../../common/components/heading.typ": format_heading as format_heading_from_common
#import "./page.typ": should_consider_only_odd_pages

#let should_start_on_new_page = state(
  "should_start_on_new_page",
  true,
)

#let not_start_on_new_page(
  body,
) = {
  should_start_on_new_page.update(false)
  body
  should_start_on_new_page.update(true)
}

#let format_heading(
  should_use_larger_text_to_highlight: false,
  body,
) = context {
  // NBR 14724:2024 5.2.2.

  // Level 1 headings should start on a new page.
  if body.level == 1 {
    if should_start_on_new_page.get() {
      // If considering odd/even pages, sections should start on odd pages
      if not should_consider_only_odd_pages.get() {
        pagebreak(weak: true, to: "odd")
      }
      pagebreak(weak: true)
    }
  }

  format_heading_from_common(
    should_use_larger_text_to_highlight: should_use_larger_text_to_highlight,
    body,
  )
}
