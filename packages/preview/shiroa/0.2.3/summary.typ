
#import "utils.typ": _store-content
#import "meta-and-state.typ": book-meta-state
#import "supports-link.typ": link2page, cross-link-path-label

/// Show template in #link("https://myriad-dreamin.github.io/shiroa/format/book.html")[book.typ]
///
/// Example:
/// ```typ
/// #show book
/// ```
#let book(content) = {
  [#metadata(toml("typst.toml")) <shiroa-internal-package-meta>]

  // #let sidebar-gen(node) = {
  //   node
  // }
  // #sidebar-gen(converted)
  // #get-book-meta()
  content
}

/// Book metadata in #link("https://myriad-dreamin.github.io/shiroa/format/book.html")[book.typ]
///
/// - title (str): The title of the book.
/// - authors (array | str): The author(s) of the book.
/// - description (str): A description for the book, which is added as meta information in the html <head> of each page.
/// - repository (str): The github repository for the book.
/// - repository-edit (str): The github repository editing template for the book.
///   Example: `https://github.com/Me/Book/edit/main/path/to/book/{path}`
/// - language: The main language of the book, which is used as a language attribute
///   `<html lang="en">` for example.
///   Example: `en`, `zh`, `fr`, etc.
/// - summary: Content summary of the book. Please see #link("https://myriad-dreamin.github.io/shiroa/format/book-meta.html#label-summary%20%20(required)%20content")[Book Metadata's Summary Field] for details.
#let book-meta(
  title: "",
  description: "",
  repository: "",
  repository-edit: "",
  authors: (), // array of string
  language: "", // default "en"
  summary: none,
) = [
  #let raw-meta = (
    kind: "book",
    title: title,
    description: description,
    repository: repository,
    repository_edit: repository-edit,
    authors: authors,
    language: language,
    summary: summary,
  );

  #let meta = {
    import "summary-internal.typ"
    let meta = summary-internal._convert-summary(metadata(raw-meta))
    meta.at("summary") = summary-internal._numbering-sections(meta.at("summary"))
    meta
  }

  #book-meta-state.update(meta)
  #metadata(meta) <shiroa-book-meta>
  #metadata(raw-meta) <shiroa-raw-book-meta>
]

/// Build metadata in #link("https://myriad-dreamin.github.io/shiroa/format/book.html")[book.typ]
///
/// - dest-dir: The directory to put the rendered book in. By default this is `book/` in the book's root directory. This can overridden with the `--dest-dir` CLI option.
#let build-meta(
  dest-dir: "",
) = [
  #let meta = (
    "dest-dir": dest-dir,
  )

  #metadata(meta) <shiroa-build-meta>
]

/// Represents a chapter in the book
/// link: path relative (from summary.typ) to the chapter
/// title: title of the chapter
/// section: manually specify the section number of the chapter
///
/// Example:
/// ```typ
/// #chapter("chapter1.typ")["Chapter 1"]
/// #chapter("chapter2.typ", section: "1.2")["Chapter 1.2"]
/// ```
#let chapter(link, title, section: auto) = metadata((
  kind: "chapter",
  link: link,
  section: section,
  title: _store-content(title),
))

/// Represents a prefix/suffix chapter in the book
///
/// Example:
/// ```typ
/// #prefix-chapter("chapter-pre.typ")["Title of Prefix Chapter"]
/// #prefix-chapter("chapter-pre2.typ")["Title of Prefix Chapter 2"]
/// // other chapters
/// #suffix-chapter("chapter-suf.typ")["Title of Suffix Chapter"]
/// ```
#let prefix-chapter(link, title) = chapter(link, title, section: none)

/// Represents a prefix/suffix chapter in the book
///
/// Example:
/// ```typ
/// #prefix-chapter("chapter-pre.typ")["Title of Prefix Chapter"]
/// #prefix-chapter("chapter-pre2.typ")["Title of Prefix Chapter 2"]
/// // other chapters
/// #suffix-chapter("chapter-suf.typ")["Title of Suffix Chapter"]
/// ```
#let suffix-chapter = prefix-chapter

/// Represents a divider in the summary sidebar
#let divider = metadata((
  kind: "divider",
))

#let external-book(spec: none) = {
  place(
    hide[
      #spec
    ],
  )
}

#let visit-summary(x, visit) = {
  if x.at("kind") == "chapter" {
    let v = none

    let link = x.at("link")
    if link != none {
      let chapter-content = visit.at("inc")(link)

      if chapter-content.children.len() > 0 {
        let t = chapter-content.children.at(0)
        if t.func() == [].func() and t.children.len() == 0 {
          chapter-content = chapter-content.children.slice(1).sum()
        }
      }

      if "children" in chapter-content.fields() and chapter-content.children.len() > 0 {
        let t = chapter-content.children.at(0)
        if t.func() == parbreak {
          chapter-content = chapter-content.children.slice(1).sum()
        }
      }

      show: it => {
        let abs-link = cross-link-path-label("/" + link)
        context {
          let page-num = here().page()
          link2page.update(it => {
            it.insert(abs-link, page-num)
            it
          })
        }

        it
      }

      visit.at("chapter")(chapter-content)
    }

    if "sub" in x {
      x.sub.map(it => visit-summary(it, visit)).sum()
    }
  } else if x.at("kind") == "part" {
    // todo: more than plain text
    visit.at("part")(x.at("title").at("content"))
  } else {
    // repr(x)
  }
}
