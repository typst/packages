// # Dedication. Dedicatória.
// NBR 14724:2024 4.2.1.4, NBR 14724:2024 5.2.4

#import "../../components/heading.typ": not_start_on_new_page
#import "../../components/page.typ": not_number_page, should_consider_only_odd_pages

#let include_dedication_page(
  body,
) = context {
  not_number_page(
    not_start_on_new_page()[
      #page()[
        // Dedication should not have title or numbering.
        // Dedication should start from the middle of the page to the right, and aligned to the bottom.
        #align(end + bottom)[
          #box(width: 50%)[
            #set align(start)
            #body
          ]
        ]
      ]

      #if not should_consider_only_odd_pages.get() {
        pagebreak(weak: true, to: "odd")
      }
    ],
  )
}
