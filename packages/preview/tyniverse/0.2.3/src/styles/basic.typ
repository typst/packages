#import "../utils/font.typ": set-font

/// Patch typst's bullet list
/// Usage:
/// ```typ
/// show list.item: patch-list-item
/// ```
///
/// - it (content): list.item
/// -> content
#let patch-list-item(it) = {
  // The generated terms is not tight
  // So setting `par.spacing` is to set the result lists' spacing
  let spacing = if list.spacing != auto {
    list.spacing
  } else if enum.tight {
    par.leading
  } else {
    par.spacing
  }
  set par(spacing: spacing)

  let current-marker = if type(list.marker) == array {
    list.marker.at(0)
  } else {
    list.marker
  }

  context {
    let hanging-indent = measure(current-marker).width + terms.separator.amount
    set terms(hanging-indent: hanging-indent)
    if type(list.marker) == array {
      terms.item(
        current-marker,
        {
          // set the value of list.marker in a loop
          set list(marker: list.marker.slice(1) + (list.marker.at(0),))
          it.body
        },
      )
    } else {
      terms.item(current-marker, it.body)
    }
  }
}


#let counting-symbols = "1aAiI一壹あいアイא가ㄱ*"
#let consume-regex = regex("[^" + counting-symbols + "]*[" + counting-symbols + "][^" + counting-symbols + "]*")

/// Patch typst's numbered list
/// Usage:
/// ```typ
/// show enum.item: patch-enum-item
/// ```
///
/// - it (content): list.item
/// -> content
#let patch-enum-item(it) = {
  if it.number == none {
    return it
  }
  // The generated terms is not tight
  // So setting `par.spacing` is to set the result enums' spacing
  let spacing = if enum.spacing != auto {
    enum.spacing
  } else if enum.tight {
    par.leading
  } else {
    par.spacing
  }
  set par(spacing: spacing)


  let new-numbering = if type(enum.numbering) == function or enum.full {
    numbering.with(enum.numbering, it.number)
  } else {
    enum.numbering.trim(consume-regex, at: start, repeat: false)
  }
  let current-number = numbering(enum.numbering, it.number)
  context {
    let hanging-indent = measure(current-number).width + terms.separator.amount

    set terms(hanging-indent: hanging-indent)

    terms.item(
      strong(delta: -300, numbering(enum.numbering, it.number)),
      {
        if new-numbering != "" {
          set enum(numbering: new-numbering)
          it.body
        } else {
          it.body
        }
      },
    )
  }
}

#let identical-mapping = it => it

/// Basic typesetting
///
/// - title (str): title
/// - authors (str | array<str>): list of authors
/// - lang (str): language identifier used in `set text(lang: lang)`
/// - use-patch (bool | (list?: bool, enum?: bool)):
///   whether to use the patch for list and/or enum, default enabled when ignored
/// - body (content): content
/// -> content
#let typesetting(
  title: "Document Title",
  authors: "Fr4nk1in",
  lang: "en",
  use-patch: true,
  body,
) = {
  // document
  set document(title: title, author: authors)
  // font
  show: set-font.with(lang: lang)
  // paragraph
  set par(linebreaks: "optimized", justify: true)
  show raw.where(block: true): set par(linebreaks: "simple", justify: false)
  // heading
  show heading: strong

  let patches = (
    list: identical-mapping,
    enum: identical-mapping,
  )

  if type(use-patch) == bool {
    if use-patch {
      patches = (
        list: patch-list-item,
        enum: patch-enum-item,
      )
    }
  } else if type(use-patch) == dictionary {
    patches = (
      list: if use-patch.at("list", true) { patch-list-item } else { identical-mapping },
      enum: if use-patch.at("enum", true) { patch-enum-item } else { identical-mapping },
    )
  } else {
    assert(
      false,
      message: "Invalid value for `use-patch`, expected bool or (list?: bool, enum?: bool)",
    )
  }

  show list.item: patches.list
  show enum.item: patches.enum

  body
}


/// Template
///
/// - lang (str): language identifier used in `set text(lang: lang)`
/// - use-patch (bool | (list?: bool, enum?: bool)):
///   whether to use the patch for list and/or enum, default enabled when
///   ignored
/// - title (str | (str, content)):
///   document title and (optional) style-free content how the title displays
///   - If the content is provided, better not setting the font size and font
///     weight in the content, as this content will be used both in the title
///     and the header. The template would handle it for consistency
///   - If the content is not provided, the title will be just a text block
/// - author-infos (str | array[str] | array[dict[str, any]]):
///   list of authors, together with their information
///   - If a single string is provided, it is treated as the name of the only
///     author
///   - If an array of strings is provided, it is treated as the names of
///     authors
///   - If an array of dictionaries is provided, each dictionary should contain
///     the "name" key
/// - display-author-block (bool | function(dict[str, any]) -> content):
///   Whether or How to display an author block for a single author, default to
///   a simple text block displaying the name. The author blocks are placed
///   under the title as a up-to-3-column grid
/// - display-author-header (bool | function(array[dict[str, any]]) -> content):
///   Whether or How to display the author information in the header. For single
///   author, the default is to display the name of the author. For multiple
///   authors, the default is to not display the author information.
///   - For multiple authors, only when this is set to a valid function, the
///     author information will be displayed in the header, otherwise (even if
///     set to `true`), the author information will not be displayed in the
///     header
///   - Better not setting the font size in the content, the template would
///     handle the font size
///   - Better control the height of the content the same as the title content
///     with the same font size
/// - make-title (bool): whether to make the title, default to true
/// - make-header (bool): whether to make the header, default to true
/// - body (content): content
/// -> content
#let template(
  lang: "en",
  use-patch: true,
  title: ("Document Title", [Document Title]),
  author-infos: "Author",
  display-author-block: true,
  display-author-header: true,
  make-title: true,
  make-header: true,
  body,
) = {
  let title-str = if type(title) == str { title } else { title.at(0) }
  let title-content = if type(title) == str { text(title) } else { title.at(1) }

  let author-infos = if type(author-infos) == str {
    ((name: author-infos),)
  } else if type(author-infos) == array {
    if type(author-infos.at(0)) == str {
      author-infos.map(name => (name: name))
    } else {
      author-infos
    }
  }
  let authors = author-infos.map(info => info.name)

  let header = if type(display-author-header) == function {
    grid(
      columns: (auto, auto),
      column-gutter: 1fr,
      align: center + top,
      emph(title-content), display-author-header(author-infos),
    )
  } else if author-infos.len() > 1 or not display-author-header {
    align(center, emph(title-content))
  } else if display-author-header {
    grid(
      columns: (auto, auto),
      column-gutter: 1fr,
      align: center + top,
      emph(title-content), text(author-infos.at(0).name),
    )
  }

  show: typesetting.with(
    title: title-str,
    authors: authors,
    lang: lang,
    use-patch: use-patch,
  )

  set page(
    numbering: "1",
    number-align: center,
    header-ascent: 14pt,
    header: {
      context if make-header and counter(page).get().at(0) != 1 {
        set text(size: 8pt)
        header
      }
    },
  )

  // title
  if make-title {
    align(
      center,
      {
        strong(text(size: 1.75em, title-content))

        let display-author-block = if (
          type(display-author-block) == bool and display-author-block
        ) {
          info => text(info.name)
        } else {
          display-author-block
        }

        let reminder = calc.rem(author-infos.len(), 3)
        let fill = author-infos.len() - reminder

        if type(display-author-block) == function {
          if (fill > 0) {
            grid(
              columns: 3,
              column-gutter: 1em,
              row-gutter: 1em,
              align: center + bottom,
              ..author-infos.slice(0, count: fill).map(display-author-block),
            )
          }
          if (reminder > 0) {
            grid(
              columns: reminder,
              column-gutter: 1em,
              row-gutter: 1em,
              align: center + bottom,
              ..author-infos.slice(fill).map(display-author-block),
            )
          }
        }
      },
    )
  }

  body
}
