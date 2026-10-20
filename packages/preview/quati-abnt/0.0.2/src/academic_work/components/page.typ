// # Page. Página.

#import "../../common/style/style.typ": font_family_serif, font_size_for_smaller_text

#let should_number_this_page = state("quati_abnt_should_number_this_page", true)
#let should_count_this_page = state("quati_abnt_should_count_this_page", true)

#let consider_only_odd_pages = state("quati_abnt_consider_only_odd_pages", true)

#let quantity_of_counted_pages = state("quati_abnt_quantity_of_counted_pages", 0)

#let not_number_page(
  body,
) = {
  should_number_this_page.update(false)
  body
  should_number_this_page.update(true)
}

#let not_count_page(
  body,
) = {
  should_count_this_page.update(false)
  body
  should_count_this_page.update(true)
}

#let format_header(should_number_pages) = context {
  // Regress page counter if this page should not be counted
  let actual_page_number = here().page()
  let page_number_to_display = quantity_of_counted_pages.get()

  if should_count_this_page.get() {
    page_number_to_display += 1
    quantity_of_counted_pages.update(n => n + 1)
  } else {
    counter(page).update(n => n - 1)
  }

  // NBR 14724:2024 5.3
  // Numbering should be on the right for odd pages and on the left for even pages.
  let alignment = if consider_only_odd_pages.get() {
    end
  } else {
    if calc.rem(actual_page_number, 2) == 1 {
      end
    } else {
      start
    }
  }

  if should_number_pages {
    // Display page number in the header
    if should_number_this_page.get() {
      align(alignment)[
        #text(
          font: font_family_serif,
          size: font_size_for_smaller_text,
        )[
          #page_number_to_display
        ]
      ]
    }
  }
}
