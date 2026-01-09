#import "languages.typ": get-terms

#let abstract-page(
  body,
  keywords: none,
) = context {
  if body == none and document.description == none { return }

  set document(keywords: keywords) if keywords != none
  set document(description: body)

  heading(level: 1, get-terms(text.lang, text.script).Abstract, outlined: false)

  par(first-line-indent: 0in, body)

  if keywords == none and document.keywords == () {
    pagebreak(weak: true)
    return
  }

  let the-keywords = if document.keywords != () and keywords == none {
    document.keywords
  } else {
    keywords
  }


  if type(the-keywords) == array {
    emph[#get-terms(text.lang, text.script).Keywords: ]
    the-keywords.map(it => it).join(", ")
  } else if type(the-keywords) == str or type(the-keywords) == std.content {
    emph[#get-terms(text.lang, text.script).Keywords:]
    the-keywords
  } else {
    panic("Invalid keyword type: ", type(the-keywords))
  }

  pagebreak(weak: true)
}

