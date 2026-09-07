// # Glossary. Glossário.
// NBR 14724:2024 4.2.3.2

#import "../../../common/components/glossary.typ": include_glossary
#import "../../components/heading.typ": not_start_on_new_page
#import "../../components/page.typ": should_consider_only_odd_pages

#let include_glossary_page(
  disable_back_references: true,
  invisible: false,
  print_gloss: none,
  title: "Glossário",
  outlined: true,
  entries,
) = context {
  let arguments = (
    disable_back_references: disable_back_references,
    invisible: invisible,
    print_gloss: print_gloss,
    title: title,
    outlined: outlined,
  )

  // If the glossary must not be printed, no page will be crated for it
  if (invisible == true) {
    include_glossary(
      ..arguments,
      entries,
    )
  } else {
    not_start_on_new_page()[
      #page()[
        #include_glossary(
          ..arguments,
          entries,
        )
      ]

      #if not should_consider_only_odd_pages.get() {
        pagebreak(weak: true, to: "odd")
      }
    ]
  }
}
