#let readme = [
= Term List as a Table

The _term list_<tl> is the following syntax in typst:

#table(columns: 2,
  [_Input_], [_Document Result_],
  ```typ / term: description```,
  [*term*~~description],
)

This package allows laying out the term list as a regular table. By default, the terms form the first column and the descriptions are in the second column, but it can also be transposed. As an extension, additional columns can be added.


== Example

#let example1 = ```typ
#import "@preview/tabbyterms:0.1.0" as tabbyterms: terms-table

#show: tabbyterms.style.default-styles
#terms-table[
  / Package: PACKAGENAME
  / Technology: Typst
  / Subject: General, Mathematics, Linguistics
  / Category: Layout, Components
]
```

#table(columns: 2,
  [_Input_], [_Document Result_],
  example1,
  eval(example1.text, mode: "markup"),
)

As an extension, additional columns can be added by using lists in the description:

#let example2 = ```typ
#import "@preview/tabbyterms:0.1.0" as tabbyterms: terms-table

#show: tabbyterms.style.default-styles
#terms-table[
  / Term: - Explanation
          - Assumptions
  / X: - Explanatory variables
       - Non-random
  / Y: - Y1, ..., Yn observations
       - Pairwise independent
  / β: - Model parameters
       - Non-random
]
```

#table(columns: 2,
  [_Input_], [_Document Result_],
  example2,
  eval(example2.text, mode: "markup"),
)


== Function Documentation and Manual

Please _see the manual_<manual> for more explanations, examples and function documentation.

== License

The package is distributed under the terms of the European Union Public License v1.2 or any later version, which is an OSI-approved weakly copyleft license. The License is distributed with the package.


#emoji.cat.smirk
]



// The following is a typlite style that enables this README to
// be exported to markdown while also supporting nested tables with
// code blocks inside the tables.

#let x-target = sys.inputs.at("x-target", default: "pdf")
#set document(date: none, title: "tabbyterms README") if x-target == "pdf"
#let show-if(cond, func) = body => if cond { func(body) } else { body }

#show <tl>: link.with("https://typst.app/docs/reference/model/terms/")
#show <manual>: link.with("docs/tabbyterms-manual.pdf")

#show: show-if(x-target == "md", doc => {
  let elemlabel = <_custom_elem>
  let iselem(it) = (
    it != none and it.func() == metadata and
      type(it.value) == dictionary and
      it.at("label", default: none) == elemlabel)
  let myelem(tag, body) = {
    [#metadata((tag: tag, body: body))#elemlabel]
  }

  let open(tag) = {"<"; tag; ">"}
  let close(tag) = {"</"; tag; ">"}
  let verbatim(src) = html.elem("m1verbatim", attrs: (src: src))

  show selector.and(metadata, elemlabel): it => {
    let tag = it.value.tag
    let body = it.value.body
    let newline = verbatim("\n")
    verbatim(open(tag))
    if not iselem(body) { newline }
    body
    if not iselem(body) { newline }
    verbatim(close(tag))
  }

  show table: it => {
    let columns = it.columns.len()
    myelem("table", {
      for row in it.children.chunks(columns) {
        myelem("tr", {
          row.map(cell => myelem("td", cell)).join()
        })
      }
    })
  }

  show raw.where(block: true): it => {
    verbatim("\n```" + it.lang + "\n" + it.text + "\n```\n")
  }

  show sym.space.nobreak: it => {
    verbatim("&nbsp;")
  }

  doc
})

#readme
