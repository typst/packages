/// pc-letter: A simple template for personal correspondence.

#import "locals.typ"

/// Deep merge two dictionaries
/// 
/// Returns a dictionary containing all the keys and subkeys (recursively)
/// contained in either dictionary `a` or dictionary `b`. Where a key exists
/// in both, the value of dictionary `b` is used.
/// 
/// -> dictionary
#let _deep-merge-dicts(
  /// The dictionary onto which dictionary `b` shall be merged
  /// -> dictionary
  a,
  /// The dictionary which shall be merged onto dictioary `a`
  /// -> dictionary
  b
) = {
  let result = a
  for (key, value) in b {
    if key in a and type(value) == dictionary {
        result.insert(key, _deep-merge-dicts(a.at(key), value))
    } else {
      result.insert(key, value)
    }
  }
  return result
}

/// The default style settings for the template
#let _default-style = (
  locale: (
    lang: "en",
    region: "GB",
  ),
  medium: "print",
  text: (
    font: ("Minion Pro", "Gentium", "Libertinus Serif", "Vollkorn", "Times New Roman"),
    size: (
      normal: 11pt,
      small: 10pt,
      tiny: 8pt,
    ),
    fill: (
      headline: rgb("#800022"),
      faded: black.lighten(20%),
    )
  ),
  alignment: (
    address-field: auto,
    date-field: auto,
    headings: auto,
    reference-field: auto,
    valediction: auto,
  ),
  page: (
    fill: auto,
  ),
  date: (
    format: auto,
  ),
  components: (
    place-name: (
      display: auto,
      pattern: "[place-name],"
    ),
    return-address-field: (
      display: auto,
    )
  ),
)

/// The default author settings for the template
#let _default-author = (
  name: "Author's Name",
  address: none,
  phone: none,
  email: none,
  web: none,
)

/// Template initiator function
/// 
/// This function should be called at the start of a document. It returns
/// a dictionary of functions and variables, best thought of as a
/// "pseudo-module". To access these, you must store the returned dictionary
/// in a variable.
/// 
/// To activate the template styling, the call to `init` should be followed by
/// a show rule referring to the returned variable `letter-style`.
/// 
/// *Minimal working example:*
/// ```typ
/// #letter = pc-letter.init(author: (name: "Sherlock Holmes"))
/// 
/// #show: letter.letter-style
/// ```
/// 
/// -> dictionary
#let init(
  /// The letter author's details
  /// 
  /// This should be a dictionary minimally containing the key `name`. The keys
  /// `phone`, `email`, and `web` are optional.
  /// 
  /// -> dictionary
  author: _default-author,
  /// The letter's title (if any)
  /// 
  /// Can be used to (optionally) specify a title for the letter, e.g. the
  /// subject line. This will only be added to the output metadata and not
  /// appear in the letter itself, but may be useful for indexing and searching
  /// digital documents later.
  /// 
  /// -> str | none
  title: none,
  /// The letter's date
  /// 
  /// Can be used to optionally specify the date for the letter. If set to
  /// `auto` (the default), today's date will be used.
  /// 
  /// -> datetime | auto
  date: auto,
  /// The place of the letter's authorship
  /// 
  /// Can be used to optionally specify a place name (usually the place where
  /// the letter itself was written) to show alongside the letter's date, as is
  /// customary in many regions. If set to `none` (the default), no place name
  /// will be shown.
  /// 
  /// Note that, even if specified, whether a place name is displayed or not
  /// depends on the letter's `style.locale` values, as it is by default only
  /// displayed in languages/regions where it is customary to do so. To
  /// overwrite whether the place name is shown, set
  /// `style.components.place-name.display` to `true`.
  /// 
  /// -> str | none
  place-name: none,
  /// Custom styling options for the letter
  /// 
  /// Can be used to configure custom styling options for the letter. Most
  /// commonly you will only want to pass a dictionary with a locale (e.g.
  /// `(locale: (lang: "es", region: "MX"))` for _Spanish (Mexico)_ --
  /// note that the default is _English (United Kingdom)_). The
  /// default styling, of not overwritten here, will adjust to sensible
  /// defaults depending on the `locale` specified.
  /// 
  /// Possible keys:
  /// / `locale.lang`: The (main) language of the letter, e.g. `"en"`, `"es"`.
  ///   Default: `"en"`.
  /// / `locale.region`: The regional variant of the (main) language of the
  ///   letter, e.g. `"AT"`, `"MX"`. Default: `"GB"`.
  /// / `medium`: Whether the letter is meant to be printed out or digital only.
  ///   The digital-only version may be set slightly differently and with a
  ///   light off-white background colour to be more pleasant for reading on
  ///   digital devices. If you either intend to print the letter or expect that
  ///   your recipient will print it out, then you should choose `"print"`.
  ///   One of `"print" | "digital"`. Default: `"print"`.
  /// / `text.font`: The typeface that should be used for the letter. Note that
  ///   the template has been designed with _serif_ fonts and expects the
  ///   chosen font to suppor true smallcaps, though it might well work with the
  ///   sans-serif font of your choice. By default, the first available font
  ///   from the list _Minion Pro_, _Gentium_, _Libertinus Serif_, _Vollkorn_,
  ///   or _Times New Roman_ is used.
  /// / `text.size.normal`: The font-size to be used for normal text.
  ///   Default: `11pt`.
  /// / `text.size.small`: The font-size to be used for text intended to be
  ///   slightly smaller than normal text. Default: `10pt`.
  /// / `text.size.tiny`: The smallest font-size used by the template.
  ///   Default: `8pt`.
  /// / `text.fill.headline`: The colour to be used for the author's name on the
  ///   letterhead. Default: `rgb("#800022")` (a deep burgundy).
  /// / `text.fill.faded`: The colour to be used for text and other elements
  ///   (e.g. some lines) that should appear slightly less prominent compared
  ///   to the main text/elements of the letter. Default: `black.lighten(20%)`.
  /// / `alignment.address-field`: Whether to align the address field `left` or
  ///   `right`. If set to `auto`, the alignment is determined based on the
  ///   specified `locale`. Default: `auto`.
  /// / `alignment.date-field`: The horizontal (`left`, `center`, `right`)
  ///   and vertical (`top`, `bottom`, `horizon` -- where `horizon` means
  ///   'just above the first falzmarke') alignment of the date field. If set to
  ///   `auto`, the alignment is determined based on the specified `locale`.
  ///   Default: `auto`.
  /// / `alignment.headings`: Whether to align 1st and 2nd level headings flush
  ///   `left`, `center`-ed, or `right`. If set to `auto`, the alignment is
  ///   determined based on the specified `locale`. Default: `auto`.
  /// / `alignment.reference-field`: The horzontal (`left`, `right`) and
  ///   vertical (`top`, `bottom`, `horizon` -- -- where `horizon` means
  ///   'just above the first falzmarke') alignment of the reference-field (if
  ///   used). If set to `auto`, the alignment is determined based on the
  ///   specified `locale`. Default: `auto`.
  /// / `alignment.valediction`: Whether to align the valediction (and possibly
  ///   the list of cc-recipients and appendices) flush `left` or indented to
  ///   `right` (starting at about the center of the page). If set to `auto`,
  ///   the alignment is determined based on the specified `locale`. Default:
  ///   `auto`.
  /// / `page.fill`: A background fill colour for the letter's page(s). If set
  ///   to `auto`, the value will be determined based on the `medium` of the
  ///   letter (off-white for `"digital"`, pure white otherwise).
  ///   Default: `auto`.
  /// / `date.format`: A Typst date-format string (e.g.
  ///   `"[year]-[month pad:zero]-[day pad:zero]"`) or `auto`. If set to `auto`,
  ///   the template attempts to supply an appropriate date format for the
  ///   specified `locale`. Default: `auto`.
  /// / `components.place-name.display`: Whether to display the place name
  ///   alongside the letter's date or not (`true` or `false`). Note that even
  ///   if set to `true`, a place name is only shown if it was supplied as an
  ///   argument to `init`. If set to `auto`, whether to display the place name
  ///   or not is determined based on the specified `locale`. Default: `auto`.
  /// / `components.place-name.format`: A string pattern to format the place name,
  ///   where `"[place-name]"` will be replaced with the place name. If set to
  ///   `auto`, the format will be determined based on the specified `locale`.
  ///   Default: `auto`.
  /// / `components.return-address-field.display`: Whether to displat the
  ///   return address field immediately above the recipient's address or not
  ///   (`true` or `false`). If set to `auto`, whether to display the return
  ///   address field is determined based on the specified `locale`.
  ///   Default: `auto`.
  /// 
  ///  -> dictionary
  style: (:)
) = {

  // --- Configuration-independent functions --- //

  /// Format a phone number
  /// 
  /// Formats a phone number (spaces set at 1/4em) and wraps it in a `tel:`
  /// link.
  /// 
  /// -> content
  let phone-number(
    /// The phone number
    /// 
    /// -> str
    number
  ) = [
    #set text(spacing: 0.125em)
    #link("tel:" + number)
  ]

  /// Format an email address
  /// 
  /// Formats an email address and wraps it in a `mailto:` link.
  /// 
  /// -> content
  let email-address(
    /// The email address
    /// 
    /// -> str
    email
  ) = link("mailto:" + email)

  /// Formats a web address
  /// 
  /// Formats a web address and wraps it in a link element.
  /// 
  /// -> content
  let web-address(
    /// The destination address
    /// 
    /// Should be a valid URL.
    /// 
    /// -> str
    dest,
    /// Whether to display the link's schema
    /// 
    /// If set to `false`, the initial schema (e.g. `https://`) will be dropped
    /// from the link text (but of course still be included in the linked
    /// destination URL).
    /// 
    /// -> bool
    include-schema: true
  ) = {
    let body = dest
    if include-schema == false {
      body = dest.replace(regex("\A[a-zA-Z]*://"), "")
    }
    link(dest, body)
  }
  
  /// Set text as spaced true small caps
  /// 
  /// This will set its content as true small caps with capital letters
  /// converted to small caps, letter spacing of 1/16th em and word spacing of
  /// 1/2 em.
  /// 
  /// Note that this relies on the font supporting true small caps and capital
  /// to small caps conversion (font features `smcp` and `c2sc`, respectively).
  /// 
  /// -> content
  let spaced-smallcaps(content) = [
    #set text(tracking: 0.0625em, spacing: 0.5em, features: (smcp: 1, c2sc: 1))
    #content
  ]

  /// Set a thin horizontal space of 1/4em width
  /// 
  /// -> content
  let thin-space() = h(0.125em, weak: true)

  /// Set a horizontal en-space (1/2em width)
  /// 
  /// -> content
  let en-space() = h(0.5em, weak: true)


  // --- Prepare template configuration --- //

  // Prepare author details
  author = _deep-merge-dicts(_default-author, author)
  // Prepare letter style settings
  let tmp-style = _deep-merge-dicts(_default-style, style)
  let tmp-locale = tmp-style.locale.lang + "-" + tmp-style.locale.region
  if tmp-locale in locals.default-styles {
    tmp-style = _deep-merge-dicts(_default-style, locals.default-styles.at(tmp-locale))
  } else if tmp-style.locale.lang in locals.default-styles {
    tmp-style = _deep-merge-dicts(_default-style, locals.default-styles.at(tmp-style.locale.lang))
  } else {
    // If no matching locale is found even at just the lang level, assume "en"
    tmp-style = _deep-merge-dicts(_default-style, locals.default-styles.at("en"))
  }
  style = _deep-merge-dicts(tmp-style, style)
  if style.page.fill == auto {
    if style.medium == "digital" {
      style.page.fill = rgb("#faf9f0")
    } else {
      style.page.fill = none
    }
  }
  // Prepare letter date
  if date == auto {
    date = datetime.today()
  }
  /// Prepare letter's author address
  let _prepare-author-address(author-address) = {
    if author-address == none or type(author-address) == array and author-address.len() == 0 {
      none
    } else if type(author-address) == str {
      author-address
    } else if type(author-address) == array {
      author.address.join(" " + sym.bullet + " ")
    } else {
      panic("Invalid format for `author.address`.")
    }
  }
  let _prepared-author-address = _prepare-author-address(author.address)
  /// Prepare letter author's contact details
  let _prepare-author-contact-details(author-data) = {
    let parts = ()
    if "phone" in author-data and author-data.phone != none {
      parts.push(phone-number(author-data.phone))
    }
    if "email" in author-data and author-data.email != none {
      parts.push(email-address(author-data.email))
    }
    if "web" in author-data and author-data.web != none {
      parts.push(web-address(author-data.web, include-schema: false))
    }
    if parts.len() == 0 {
      none
    } else if parts.len() == 2 {
      parts.join(" " + sym.bullet + " ")
    } else {
      parts.join(" " + sym.bullet + " ", last: linebreak())
    }
  }
  let _prepared-author-contact-details = _prepare-author-contact-details(author)

  // The page dimensions (currently hard-coded for A4 paper)
  let _page-dimensions = (
    height: 297mm,
    width: 210mm,
  )

  // The page margins (currently only fitting for A4 paper)
  let _page-margins = (
    left: 25mm,
    right: 25mm,
    top: 27mm + 10mm,
    bottom: 30mm
  )


  // --- Configuration-dependent functions --- //

  /// Add falzmarken to the left margin of a page
  /// 
  /// Adds three falzmarken to the left margin of the page, two falzmarken of
  /// 1em length which indicate the points at which to fold the paper to fit it
  /// into a DL envelope (windowed or windowless) or a C6 envelope (windowless),
  /// and a third 1/2em falzmark at the vertical center of the page to align a
  /// hole punch or use as a folding mark for a C5 envelope (windowed or
  /// windowless).
  /// 
  /// Falzmarken are usually only added to the very first page of a letter, and
  /// a call to the `falzmarken` function will place the falzmarken only on
  /// the current page.
  /// 
  /// -> content
  let falzmarken() = {
    place(
      top + left,
      dx: -_page-margins.left,
      dy: ((_page-dimensions.height - (105mm * 2)) - _page-margins.top),
      line(stroke: 0.2mm + style.text.fill.faded, length: 2em)
    )
    place(
      top + left,
      dx: -_page-margins.left + 1em,
      dy: ((_page-dimensions.height / 2) - _page-margins.top),
      line(stroke: 0.2mm + style.text.fill.faded, length: 1em)
    )
    place(
      top + left,
      dx: -_page-margins.left,
      dy: ((_page-dimensions.height - 105mm) - _page-margins.top),
      line(stroke: 0.2mm + style.text.fill.faded, length: 2em)
    )
  }

  /// Sets the recipient's address
  /// 
  /// This will set the address field showing the recipient's address, and
  /// optionally above it a return address for the letter's author.
  /// 
  /// -> content
  let address-field(
    /// The recipient's address
    /// 
    /// Should be no more than 9 lines long. Address lines should normally be
    /// broken by simple linebreaks, not paragraph breaks.
    /// 
    /// -> content | str
    recipient-address,
    /// Content for the return address field
    /// 
    /// If specified, overwrites the content for the return address field
    /// shown immediately above the recipient's address, provided the letter's
    /// `locale` and `style` settings are such that the return address is
    /// displayed.
    /// 
    /// If set to `auto`, the return address is shown as the author's name
    /// and address, separated by bullet points.
    /// 
    /// -> content | str | auto
    return-address-field: auto
  ) = [
    #if return-address-field == auto {
      return-address-field = [
        #set text(size: style.text.size.tiny)
        #set align(left + bottom)
        #if _prepared-author-address != none [
          #author.name #sym.bullet #_prepared-author-address
        ] else [
          #author.name
        ]
      ]
    }
    #let recipient-field = [
        #set par(first-line-indent: 0em)
        #set text(size: style.text.size.small)
        #recipient-address
    ]
    #context {
      let x-offset = 0mm
      if style.alignment.address-field == right {
        x-offset = _page-dimensions.width - _page-margins.left - _page-margins.right - 2mm
        if (style.components.return-address-field.display 
            and measure(return-address-field).width > measure(recipient-field).width) {
          x-offset -= measure(return-address-field).width
        } else {
          x-offset -= measure(recipient-field).width
        }
      }
      if style.components.return-address-field.display {
        place(
          top + left,
          dx: x-offset,
          dy: (0mm - 10mm),
          rect(
            height: 17.7mm,
            width: 90mm,
            stroke: none,
            [
              #return-address-field
              #context place(
                bottom + left,
                dx: -2mm,
                dy: 1.5mm,
                line(
                  stroke: 0.2mm,
                  length: measure(return-address-field).width + 4mm
                )
              )
            ]
          )
        )
      }
      place(
        top + left,
        dx: x-offset,
        dy: (17.7mm - 10mm),
        rect(
          height: 27.3mm,
          width: 90mm,
          stroke: none,
          recipient-field
        )
      )
    }
  ]

  /// Sets an optional reference number
  /// 
  /// This field can be used to set a reference number, such as one may be asked
  /// to quote on correspondence in a business, legal, or civil matter.
  /// 
  /// -> content
  let reference-field(
    /// The reference number to quote
    /// 
    /// -> str
    reference,
    /// The text that precedes the reference number
    /// 
    /// By default this will be something like "Ref:" or "Reference:" in the
    /// language of the letter, and will be determined automatically by the
    /// template based on the specified `locale`. However, the `supplement`
    /// argument can be used to customise/overwrite this text.
    /// 
    /// -> content | str
    supplement: locals.get-strings(style.locale).reference
  ) = [
    #let field-alignment = top + style.alignment.reference-field.x
    #let y-offset = 0mm
    #if style.alignment.reference-field.y == horizon {
      y-offset = -10mm
    } else if style.alignment.reference-field.y == top {
      y-offset = -55mm
    }
    #place(
      field-alignment,
      dx: 0mm,
      dy: 65mm - 10mm + y-offset,
      [#supplement #en-space() #reference]
    )
  ]

  let _header = [
    #set align(center)
    #text(
      weight: 500,
      size: 1.125em,
      fill: style.text.fill.headline,
      spaced-smallcaps[#author.name]
    )\
    #set text(size: style.text.size.small, fill: style.text.fill.faded)
    #if _prepared-author-address != none {
      _prepared-author-address
      linebreak()
    }
    #if _prepare-author-contact-details != none {
      _prepared-author-contact-details
    }
  ]

  /// Style function for the document's body
  /// 
  /// Use this with a `show` rule, e.g. ````typ #show: letter.letter-style```.
  /// This will apply all the layout and formatting rules of the template as
  /// they were configured with the `init` call beforehand.
  /// 
  /// -> content
  let letter-style(
    /// The document's body
    /// 
    /// -> content
    body
  ) = [
    #set document(
      author: author.name,
      title: title,
      date: date,
    )
    #set page(
      paper: "a4",
      margin: _page-margins,
      header: rect(width: 100%, height: 100%, stroke: none, _header),
      header-ascent: 12mm,
      footer: context { rect(width: 100%, stroke: none, height: 100%, [
        #set align(right)
        #set text(size: style.text.size.small)
        #if counter(page).final().at(0) > 1 {
          locals.get-strings(style.locale).page-xy
            .replace("[X]", str(counter(page).get().at(0)))
            .replace("[Y]", str(counter(page).final().at(0)))
        }
      ]) },
      footer-descent: 10mm,
      fill: style.page.fill,
    )
    #set text(
      size: style.text.size.normal,
      font: style.text.font,
      lang: style.locale.lang,
      region: style.locale.region,
      discretionary-ligatures: false,
      features: (onum: 1),
    )
    #set par(first-line-indent: 2em)
    #show heading: set align(style.alignment.headings)
    #show heading: set block(above: 1.25em, below: 1.25em)
    #show heading.where(level: 1): set text(size: style.text.size.normal, weight: "bold")
    #show heading.where(level: 2): set text(size: style.text.size.normal, weight: "regular", style: "italic")
    #let date-y-offset = 0mm
    #if style.alignment.date-field.y == top {
      date-y-offset = -55mm
    } else if style.alignment.date-field.y == horizon {
      date-y-offset = -10mm
    }
    #if style.alignment.date-field.x == none {
      style.alignment.date-field.x = right
    }
    #place(
      top + style.alignment.date-field.x,
      dx: 0mm,
      dy: 65mm - 10mm + date-y-offset,
      [
        #if style.components.place-name.display and place-name != none [
          #style.components.place-name.pattern.replace("[place-name]", place-name)
        ]
        #locals.localise-date(date, style.date.format, style.locale)
      ]
    )
    #v(31.46mm + 45mm - 10mm)
    #body
  ]

  /// Set a valediction at the end of a letter
  /// 
  /// Use this to add a valediction ("formal closing") at the end of a letter,
  /// e.g. "Yours sincerely," or "Yours faithfully",.
  /// 
  /// Using the `valediction` function instead of just a plain text paragraph
  /// ensures that the valediction is spaced and formatted appropriately for the
  /// chosen letter `locale` and style.
  /// 
  /// -> content
  let valediction(
    /// The valediction text
    /// 
    /// For example `"Yours sincerely,"` or `"Yours faithfully,"`. Note that
    /// no punctuation is added, so if you want a comma, colon, or similar you
    /// have to include this in the provided text.
    /// 
    /// -> content | str
    valediction,
    /// An optional signature
    /// 
    /// This can be used to include a signature, e.g. an image you have prepared
    /// or text in a "handwriting" font.
    /// If set to `none`, a vertical space of 3em height is provided instead
    /// for the author to manually sign the letter.
    /// 
    /// -> content
    signature: none,
    /// The author's name
    /// 
    /// This can be used to overwrite the author's name below the signature. If
    /// set to `auto` (the default), the letter author's full name is printed,
    /// if set to `none` then no name is printed at all. If a string or content
    /// is passed, that is printed below the signature space instead.
    /// 
    /// -> auto | none | content | str
    name: auto
  ) = [
    #if name == auto {
      name = author.name
    }
    #let _inset = 0mm
    #if style.alignment.valediction == right {
      _inset = (left: (_page-dimensions.width / 2) - _page-margins.left - _page-margins.right)
    }
    #set par(first-line-indent: 0em)
    #block(above: 3em, inset: _inset, breakable: false)[
      #valediction
      #if signature != none {
        block(signature)
      } else {
        v(3em)
      }
      #name
    ]
  ]

  /// Sets a carbon-copy field at the end of a letter
  /// 
  /// This can be used to tell the recipient(s) that copies of the letter have
  /// been sent to further addressees. The `cc-field` is customarily set after
  /// the `valediction`.
  /// 
  /// How the cc-recipients are set depends on their number: 2 or fewer are
  /// set as a single line of text, separated by comma. 3 or more are set
  /// as a bullet-point list.
  /// 
  /// -> content
  let cc-field(
    /// The carbon-copy recipients
    /// 
    /// -> content | str
    ..recipients
  ) = [
    #let _inset = 0mm
    #if style.alignment.valediction == right {
      _inset = (left: (_page-dimensions.width / 2) - _page-margins.left - _page-margins.right)
    }
    #set par(first-line-indent: 0em)
    #block(inset: _inset, breakable: false)[
      #stack(dir: ltr, spacing: 0.5em)[
        #text(style: "italic", locals.get-strings(style.locale).carbon-copy)
      ][
        #if recipients.pos().len() < 3 {
          recipients.pos().join(", ")
        } else {
          recipients.pos().join(",\n")
        }
      ]
    ]
  ]

  /// Sets en enclosed/attached field at the end of the letter
  /// 
  /// This field can be used to tell the recipients about further documents
  /// that have been enclodes/attached to the letter.
  /// 
  /// How the encloded document descriptions are set depends on their number:
  /// a single enclosed document is given without a bullet point, while 2 or
  /// more are set enclosed documents are set as a bullet-point list.
  /// 
  /// -> content
  let enclosed-field(
    /// Descriptions of the enclosed documents
    /// 
    /// -> content | str
    ..enclosures
  ) = [
    #let _inset = 0mm
    #if style.alignment.valediction == right {
      _inset = (left: (_page-dimensions.width / 2) - _page-margins.left - _page-margins.right)
    }
    #set par(first-line-indent: 0em)
    #block(inset: _inset, breakable: false)[
      #if enclosures.pos().len() < 2 {
        stack(dir: ltr, spacing: 0.5em)[
          #text(style: "italic", locals.get-strings(style.locale).enclosed-sg)
        ][
          #enclosures.pos().at(0)
        ]
      } else {
        stack(dir: ltr, spacing: 0.5em)[
          #text(style: "italic", locals.get-strings(style.locale).enclosed-pl)
        ][
          #for enclosure in enclosures.pos() {
            [- #enclosure]
          }
        ]

      }
      
    ]
  ]

  return (
    style: style,
    spaced-smallcaps: spaced-smallcaps,
    thin-space: thin-space,
    en-space: en-space,
    phone-number: phone-number,
    email-address: email-address,
    web-address: web-address,
    falzmarken: falzmarken,
    address-field: address-field,
    reference-field: reference-field,
    letter-style: letter-style,
    valediction: valediction,
    cc-field: cc-field,
    enclosed-field: enclosed-field,
  )
}
