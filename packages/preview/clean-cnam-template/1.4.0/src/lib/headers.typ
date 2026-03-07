/**
 * Header management for the TYPST template
 *
 * @author Tom Planche
 * @license MIT
 */

/**
 * Build a main header with title and author.
 *
 * @param main-heading-content - The main heading content
 * @param author - The author name
 * @returns Header content with title and author
 */
#let build-main-header(main-heading-content, author) = {
  [
    #smallcaps(main-heading-content) #h(1fr) #emph(author)
    #line(length: 100%)
  ]
}

/**
 * Check if the secondary heading appears after the main heading in the document.
 *
 * @param secondary-heading - The secondary heading element
 * @param main-heading - The main heading element
 * @returns True if secondary heading is after main heading
 */
#let is-after(secondary-heading, main-heading) = {
  let sec-head-pos = secondary-heading.location().position()
  let main-head-pos = main-heading.location().position()
  if (sec-head-pos.at("page") > main-head-pos.at("page")) {
    return true
  }
  if (sec-head-pos.at("page") == main-head-pos.at("page")) {
    return sec-head-pos.at("y") > main-head-pos.at("y")
  }
  return false
}

/**
 * Generate the appropriate header based on the current page and heading context.
 *
 * @param author - The author name to display in headers
 * @param show-secondary-header - Whether to show secondary headers (with sub-heading)
 * @returns The appropriate header for the current page
 */
#let get-header(
    author: "Tom Planche",
    show-secondary-header: true,
) = {
  context {
    // if we are on the first and second pages, we don't have any header
    // so we return an empty header
    if (here().page() <= 2) {
      return []
    }

    // Find if there is a level 1 heading on the current page
    let next-main-heading = query(selector(heading).after(here())).find(head-it => {
     head-it.location().page() == here().page() and head-it.level == 1
    })

    if (next-main-heading != none) {
      return build-main-header(next-main-heading.body, author)
    }

    // Find the last previous level 1 heading -- at this point surely there's one :-)
    let last-main-heading = query(selector(heading).before(here())).filter(head-it => {
      head-it.level == 1
    }).last()

    // Find if the last level > 1 heading in previous pages
    let previous-secondary-heading-array = query(selector(heading).before(here())).filter(head-it => {
      head-it.level > 1
    })

    let last-secondary-heading = if (previous-secondary-heading-array.len() != 0) {
        previous-secondary-heading-array.last()
    } else {
        none
    }

    return build-main-header(last-main-heading.body, author)
  }
}
