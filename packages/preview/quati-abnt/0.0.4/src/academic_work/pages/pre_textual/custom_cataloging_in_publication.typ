// # Custom cataloging-in-publication. Ficha catalográfica customizada.
// NBR 14724:2024 4.2.1.1.2

#import "../../../common/util/font_family.typ": font_family_for_highlighted_text_state
#import "../../components/heading.typ": not_start_on_new_page
#import "../../components/page.typ": not_count_page, not_number_page, should_consider_only_odd_pages

#let include_custom_cataloging_in_publication(
  body,
) = context {
  set page(
    margin: 0cm,
  )
  set text(
    font: font_family_for_highlighted_text_state.get(),
  )
  not_number_page(
    not_start_on_new_page()[
      #if should_consider_only_odd_pages.get() {
        not_count_page(
          body,
        )
      } else {
        body
      }
    ],
  )
}
