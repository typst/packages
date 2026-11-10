// # Epigraph. Epígrafe.
// NBR 14724:2024 4.2.1.6

#import "../../components/epigraph.typ": include_epigraph
#import "../../components/heading.typ": not_start_on_new_page
#import "../../components/page.typ": consider_only_odd_pages, not_number_page

// NBR 14724:2024 4.2.1.6, NBR 14724:2024 5.2.4, NBR 14724:2024 5.5
// Epigraph on pre-textual elements can present a quote without following long quote formatting, as determined by NBR 14724:2024 4.2.1.6.
#let include_epigraph_page(
  indent: true,
  smaller_text: true,
  body,
) = context {
  not_number_page(
    not_start_on_new_page()[
      #page(
        // Epigraph should not have title or numbering.
        // Epigraph should be aligned to the bottom.
        align(bottom, {
          include_epigraph(
            indent: indent,
            smaller_text: smaller_text,
            body,
          )
        }),
      )

      #if not consider_only_odd_pages.get() {
        pagebreak(weak: true, to: "odd")
      }
    ],
  )
}
