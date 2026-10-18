// # List of tables. Lista de tabelas.
// NBR 14724:2024 4.2.1.10

#import "../../components/heading.typ": not_start_on_new_page
#import "../../components/list_of_tables.typ": include_list_of_tables
#import "../../components/page.typ": consider_only_odd_pages, not_number_page

#let include_list_of_tables_page() = context {
  not_number_page(
    not_start_on_new_page()[
      #page()[
        #include_list_of_tables()
      ]

      #if not consider_only_odd_pages.get() {
        pagebreak(weak: true, to: "odd")
      }
    ],
  )
}
