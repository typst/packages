#import "utils.typ": *
/// This function constructs the the frontmatter of the thesis.
/// -> content
#let maketitle(
  /// The Thesis Title is set here.
  /// -> content | string
  title: [],
  /// The type of thesis. Bachelor-, Masters- or another kind of thesis.
  /// -> content | string
  thesis-type: none,
  /// An array of authors. For each author, you can specify a name,
  /// matriculation number, email. The attributes can be modified via the `fields` and `field-prefixes` arguments.
  /// -> array
  authors: none,
  /// Displays the date if it is not none.
  /// -> content | string
  date: datetime.today().display("[day] [month repr:long] [year]"),
  /// Sets the prefix that is shown before the date.
  /// -> content | string
  date-prefix: "Datum:",
  /// Defines the fields/keys, that the authors need to have, inorder to be diyplayed.
  /// -> array
  fields: ("email", "matrnr"),
  /// Sets the prefixes, that are shown before their actual value, which is taken from the authors dictionary.
  /// -> array
  field-prefixes: ("", "Matr.Nr.: "),
  /// If true writes the title and the first authors name to the pdfs metadata.
  /// -> bool
  metadata: true,
  /// Set the font of the title.
  /// -> string
  title-font: title-font,
  /// Size of the heading
  /// -> length
  large-size: large-size,
  /// Size of the authors text.
  /// -> length
  font-size: normal-size,
  /// Sets the hyphenation of the title. Is ideal for long titles.
  /// -> auto | bool
  title-hypenation: auto,
) = {
  if metadata {
    set document(title: title, author: authors.at(0).at("name"))
  }
  let repr-thesis-type = text(thesis-type, weight: "light")
  let repr-thesis-title = text(
    title,
    weight: "bold",
    hyphenate: title-hypenation,
  )

  authors = authors.map(_parse-author.with(
    fields: fields,
    field-prefixes: field-prefixes,
  ))
  let cols = if authors.len() <= 3 { (1fr,) * authors.len() } else {
    (1fr,) * 3
  }

  align(center, {
    set text(font: title-font, size: large-size)
    v(50pt, weak: false)
    repr-thesis-type
    v(25pt, weak: true)
    repr-thesis-title
    v(25pt, weak: true)

    set text(size: font-size)
    grid(
      columns: cols, align: center,
      ..authors,
    )
    if date != none {
      align(center)[#date-prefix #date]
    }
  })
}

/// This function constructs the abstract, which is supposed to come directly after the frontmatter.
/// -> content
#let abstract(
  content,
  /// The font, which is only used for the heading of the abstract paragraph.
  /// -> string
  font: title-font,
  /// The title which the abstract paragraph should have.
  /// -> content | string
  title: [Kurzfassung],
) = {
  // English abstract
  v(50pt, weak: true)
  set text(small-size)
  show: pad.with(x: 1cm)
  align(center, text(font: font, strong(title)))
  v(6pt, weak: true)
  content
}

/// This function will help you to provide a long caption to a figure,
/// but a short caption to the outline.
///
/// Example usage:
/// ```typ
/// #figure(
///   rect(),
///   caption: shortcap("Short caption", "Long caption"),
/// )
/// ```
///
/// -> content
#let shortcap(
  /// The short caption of the figure.
  /// -> string | content
  short,
  /// The long caption of the figure.
  /// -> string | content
  long,
) = context if outlined.get() { short } else { long }


/// This function is a wrapper of the `outline` function and allows for an easy
/// way to create the table of figures.
///
/// Example usage:
/// ```typ
/// #fig-outline()
/// ```
/// -> content
#let fig-outline(
  /// The title of the table of figures.
  /// -> string | content
  title: "List of Figures",
  /// The Target of the table of figures.
  /// -> label | selector | location | function
  target: figure.where(kind: image),
  /// Additional optional arguments to the outline function.
  ..args,
) = outline(target: target, title: title, ..args)

/// This function is a wrapper of the `outline` function and allows for an easy
/// way to create the list of tables.
///
/// Example usage:
/// ```typ
/// #tab-outline()
/// ```
/// -> content
#let tab-outline(
  /// The title of the table of figures.
  /// -> string | content
  title: "List of Tables",
  /// The Target of the table of figures.
  /// -> label | selector | location | function
  target: figure.where(kind: table),
  /// Additional optional arguments to the outline function.
  ..args,
) = outline(target: target, title: title, ..args)

/// This function is a dictionary that contains the configuration
/// for an Author. Any attributes can be added to the dictionary.
/// The default attributes are `name`, `email`, and `matrnr` and are needed for the default `maketitle` function. But these can be modified or extended, via the fields and field-prefixes arguments.
/// -> dict
#let Author(
  /// The name of the author. (mandatory)
  /// -> string
  name,
  /// The email address of the author.
  /// -> string
  email: none,
  /// The matriculation number of the author.
  /// -> string
  matrnr: none,
  /// Additional attributes
  /// -> dict
  attrs: none,
) = ( 
  name: name,
  email: email,
  matrnr: matrnr,
  ..attrs,
)
