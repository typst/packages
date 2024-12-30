// SPDX-FileCopyrightText: 2024 Olivier Charvin <git@olivier.pfad.fr>
//
// SPDX-License-Identifier: EUPL-1.2+

#let autobreak(content) = {
  layout(size => {
    let neededHeight = measure(block(width: size.width,content)).height
    if neededHeight <= size.height {
      // needs less than one page: make it non-breakable
      return block(breakable: false, content)
    }
    // needs more than 1 page

    let isOdd = calc.odd(here().page())
    // Below: hack needed to prevent lack of convergence
    // I think that otherwise the here().page() above refers to the next page when colbreak is called
    hide(place()[.])

    if isOdd {
      // new page to prevent page turning
      colbreak()
      content
    } else {
      // spread it over the current page and the next (facing) page
      content
    }
  })
}
