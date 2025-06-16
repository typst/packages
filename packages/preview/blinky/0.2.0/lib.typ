
#let link-bib-urls(link-fill: blue, content) = {
  // Typst converts URLs and DOIs into links -- get rid of the links and
  // restore the actual URLs and DOIs, otherwise the regexes don't match.
  show link: it => {
    if it.body.text == it.dest { // apply only to original link
      it.body
    } else if "https://doi.org/" + it.body.text == it.dest { // for DOI links
      it.body
    } else {
      it
    }
  }

  // Match the magic pattern for <<<url|||title>>> and replace by links.
  // These code snippets are by user Philipp on the Typst forum,
  // https://forum.typst.app/t/how-can-i-configure-linking-and-color-in-my-bibliography
  let link-magic = regex("<<<(.*)\|\|\|\s*(.*)>>>")
  show link-magic: it => {
    set text(fill: link-fill)
    link(..it.text.matches(link-magic).first().captures)
  }

  // Match the magic pattern for <_<url||title>_> and replace by
  // links styled in italics.
  let italic-link-magic = regex("<_<(.*)\|\|\|\s*(.*)>_>")
  show italic-link-magic: it => {
    set text(fill: link-fill)
    text(style: "italic")[#link(..it.text.matches(italic-link-magic).first().captures)]
  }

  content
}

