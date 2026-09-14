/*
  File: hfdisplay.typ
  Author: neuralpain
  Date Modified: 2025-12-10

  Description: Handle header-footer display.
*/

#import "hfdata.typ": hfdata
#import "util.typ": mod

#let hfdisplay(hf, pg, flex) = {
  if counter(page).final().last() > 1 {
    // -------------------------------------------------------------- First Page
    if counter(page).get().at(0) == pg.first {
      if hf.first-page != none {
        let hf = hf // copy from outside the current context
        if type(hf.first-page) == array {
          if hf.first-page.at(0) == "" or hf.first-page.at(0) == none {
            hf.first-page.at(0) = hf.content.at(0)
          }
          if hf.first-page.at(1) == "" or hf.first-page.at(1) == none {
            hf.first-page.at(1) = hf.content.at(1)
          }
          if hf.first-page.at(2) == "" or hf.first-page.at(2) == none {
            hf.first-page.at(2) = hf.content.at(2)
          }
          hfdata(hf.first-page, hf.alignment-first-page, flex)
        } else {
          hfdata(hf.first-page, hf.alignment, flex)
        }
      } else {
        if hf.odd-page != none {
          hfdata(hf.odd-page, hf.alignment, flex)
        } else {
          // Display normally
          hfdata(hf.content, hf.alignment, flex)
        }
      }
    }
    // --------------------------------------------------------------- Last Page
    if counter(page).get().at(0) == pg.last {
      if hf.last-page != none {
        let hf = hf // copy from outside the current context
        if type(hf.last-page) == array {
          if hf.last-page.at(0) == "" or hf.last-page.at(0) == none {
            hf.last-page.at(0) = hf.content.at(0)
          }
          if hf.last-page.at(1) == "" or hf.last-page.at(1) == none {
            hf.last-page.at(1) = hf.content.at(1)
          }
          if hf.last-page.at(2) == "" or hf.last-page.at(2) == none {
            hf.last-page.at(2) = hf.content.at(2)
          }
          hfdata(hf.last-page, hf.alignment-last-page, flex)
        } else {
          hfdata(hf.last-page, hf.alignment, flex)
        }
      } else {
        if mod(pg.last) == pg.even and hf.even-page != none {
          hfdata(hf.even-page, hf.alignment, flex)
        } else if mod(pg.last) == pg.odd and hf.odd-page != none {
          hfdata(hf.odd-page, hf.alignment, flex)
        } else {
          // Display normally
          hfdata(hf.content, hf.alignment, flex)
        }
      }
    }
    // ------------------------------------------------------------ Middle Pages
    if counter(page).get().at(0) != pg.first and counter(page).get().at(0) != pg.last {
      if mod(counter(page).get().at(0)) == pg.even and hf.even-page != none {
        hfdata(hf.even-page, hf.alignment, flex)
      } else if mod(counter(page).get().at(0)) == pg.odd and hf.odd-page != none {
        hfdata(hf.odd-page, hf.alignment, flex)
      } else {
        // Display normally
        hfdata(hf.content, hf.alignment, flex)
      }
    }
  } else {
    // ------------------------------------------------------------- Single Page
    // Display normally
    hfdata(hf.content, hf.alignment, flex)
  }
}
