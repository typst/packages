// # Errata. Errata.
// NBR 14724:2024 4.2.1.2

#import "../../components/heading.typ": not_start_on_new_page
#import "../../components/page.typ": consider_only_odd_pages, not_number_page

#let include_errata_page(
  body,
) = context {
  not_number_page(
    not_start_on_new_page()[
      #page()[
        #heading(
          numbering: none,
          outlined: false,
        )[
          Errata
        ]
        #body
      ]

      #if not consider_only_odd_pages.get() {
        pagebreak(weak: true, to: "odd")
      }
    ],
  )
}
