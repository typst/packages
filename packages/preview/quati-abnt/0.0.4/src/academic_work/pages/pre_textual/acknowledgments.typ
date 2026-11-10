// # Acknowledgments. Agradecimentos.
// NBR 14724:2024 4.2.1.6

#import "../../components/heading.typ": not_start_on_new_page
#import "../../components/page.typ": not_number_page, should_consider_only_odd_pages

#let include_acknowledgments_page(
  body,
) = context {
  not_number_page(
    not_start_on_new_page()[
      #page()[
        #heading(
          numbering: none,
          outlined: false,
        )[
          Agradecimentos
        ]
        #body
      ]

      #if not should_consider_only_odd_pages.get() {
        pagebreak(weak: true, to: "odd")
      }
    ],
  )
}
