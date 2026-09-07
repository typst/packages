// # List of figures. Lista de ilustrações.
// NBR 14724:2024 4.2.1.9

#import "../../components/heading.typ": not_start_on_new_page
#import "../../components/list_of_figures.typ": include_list_of_figures
#import "../../components/page.typ": not_number_page, should_consider_only_odd_pages

#let include_list_of_figures_page() = context {
  not_number_page(
    not_start_on_new_page()[
      #page()[
        #include_list_of_figures()
      ]

      #if not should_consider_only_odd_pages.get() {
        pagebreak(weak: true, to: "odd")
      }
    ],
  )
}
