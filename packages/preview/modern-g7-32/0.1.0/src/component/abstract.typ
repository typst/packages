#import "headings.typ": structural-heading-titles

#let get-count(kind) = {
  assert(kind in (page, image, table, ref, "annex"), message: "Невозможно определить количество этих элементов")
  let target-counter = none
  let caption = none
  if kind == page { 
    target-counter = counter(page)
    caption = "с."
  } else if kind == "annex" {
    target-counter = counter("annex")
    caption = "прил."
  } else if kind == ref {
    caption = "ист."
  } else if kind == image {
    target-counter = counter("image")
    caption = "рис."
  } else if kind == table {
    target-counter = counter("table")
    caption = "табл."
  }
  
  let count = 0
  if kind == cite {
    count = target-counter.final().dedup().len()
  } else if kind == ref {
    count = query(selector(ref)).filter(it => it.element == none).map(it => it.target).dedup().len()
  } else {
    count = target-counter.final().first()
  }

  if count != 0 {
    repr(count) + " " + caption
  }
}

#let abstract(..keywords, body) = {
  [
    #heading(structural-heading-titles.abstract, outlined: false) <abstract>

    #context {
      let counts = (get-count(page), get-count(image), get-count(table), get-count(ref), get-count("annex"))
      counts = counts.filter(it => it != none)
      [Отчёт #counts.join(", ")]
    }

    #{
      set par(first-line-indent: 0pt)
      upper(keywords.pos().join(", "))
    }
  
    #text(body)
  ]
}