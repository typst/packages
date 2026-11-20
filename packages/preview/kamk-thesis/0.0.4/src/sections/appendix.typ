// Load the translations
#let lang-data = toml("../data/lang.toml")

#let render-appendices(language: "fi", items: ()) = {
  // If there are no appendices, skip rendering the section entirely
  if items.len() == 0 {
    return
  }

  let d = lang-data.at(language)

  // 1. Render the index of appendices. Label is needed for ToC special treatment.
  [
    #heading(level: 1, outlined: true, numbering: none)[#d.appendices_heading] <kamk-appendices>
  ]

  for (i, item) in items.enumerate() {
    block(below: 0.65em)[#d.appendix #(i + 1) #item.title]
  }

  // 2. Render each appendix dynamically
  for (i, item) in items.enumerate() {
    let num = i + 1
    let start-lbl = label("app-start-" + str(num))
    let end-lbl = label("app-end-" + str(num))

    pagebreak(weak: true)

    set page(
      numbering: none,
      header: context {
        let starts = query(start-lbl)
        let ends = query(end-lbl)

        // Ensure labels exist before attempting math
        if starts.len() > 0 and ends.len() > 0 {
          let current-page = here().page()
          let start-page = starts.first().location().page()
          let end-page = ends.last().location().page()

          // Calculate relative pages for "i/total"
          let rel-current = current-page - start-page + 1
          let rel-total = end-page - start-page + 1

          align(right)[#d.appendix #num #rel-current/#rel-total]
        }
      }
    )

    // Invisible metadata acts as a reliable anchor for the start label
    [#metadata("start")#start-lbl]

    heading(level: 1, outlined: false, numbering: none)[#d.appendix #num #item.title]

    item.content

    // Anchor the end label to the very end of the content to catch the final page
    [#metadata("end")#end-lbl]
  }
}