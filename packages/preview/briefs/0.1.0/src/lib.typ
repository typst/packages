// MIT License
//
// Copyright (c) 2025 Tobias Enderle
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#let localization = (
  "de": (
    page-number: (i, t) => [Seite #i von #t],
    date-format: "[day].[month].[year]",
  ),
  "en": (
    page-number: (i, t) => [Page #i of #t],
    date-format: "[month repr:long] [day padding:none], [year]",
  ),
)
#let localization-fallback = (
  page-number: (i, t) => [#i / #t],
  date-format: auto,
)
#let localized() = localization.at(text.lang, default: localization-fallback)

// https://stackoverflow.com/a/78185552
#let get-margin(..sides) = {
  let m = if type(page.margin) == relative or page.margin == auto {
    page.margin
  } else {
    page.margin.at(sides.pos().find(s => s in page.margin))
  }
  if m == auto {
    // https://typst.app/docs/reference/layout/page/#parameters-margin
    return calc.min(page.width, page.height) * 2.5 / 21
  }
  return m
}
#let top-margin() = get-margin("top")
#let left-margin() = get-margin("left", "inside")

#let mark(y, len) = place(
  top + left,
  dx: 5mm,
  dy: y,
  line(length: len, stroke: 0.25pt)
)
#let content-box(x, y, width, height, framed: false, content) = context place(
  top + left,
  dx: x - left-margin(),
  dy: y - top-margin(),
  box(width: width, height: height, stroke: if framed { 0.25pt }, content)
)

#let letter(
  /// Sender's name and address. This address is shown in the address box with
  /// font size `sender-font-size` and concatenated with separator
  /// `sender-separator`. If `information` is `auto`, this address is also
  /// shown at the top of the information box.
  /// -> array of content
  sender: (),
  /// Font size of the sender's name and address in the address box.
  /// -> length
  sender-font-size: 8pt,
  /// Separator between sender's address parts in address box.
  /// -> content
  sender-separator: ", ",
  /// The recipient's name and address. Add line breaks manually.
  /// -> content
  recipient: [],
  /// Content of the information box. If this is `auto`, the sender, location,
  /// and date are shown as a default.
  /// -> auto | content
  information: auto,
  /// Absolute position and size of the information box: (x, y, width, height).
  /// -> array of length
  information-box: (125mm, 25mm, 75mm, 65mm),
  /// The date (only used, if `information` is `auto`). If this is
  /// `auto`, the current date is shown. If `auto` or a value of type `datetime`
  /// is provided, the date will be formatted with `date-format`.
  /// -> auto | datetime | content
  date: auto,
  /// The date format which is applied if `date` is `auto` or of type
  /// `datetime`. If `date-format` is a string, it is directly passed to Typst's
  /// `datetime.display()` function. If `date-format` is `auto` and `text.lang`
  /// is `"de"`, the format `[day].[month].[year]` is used. If a different
  /// language is set, `auto` is passed to `datetime.display()`.
  /// -> auto | str
  date-format: auto,
  /// The location (only used, if `information` is `auto`).
  /// -> none | content
  location: none,
  /// The separator between location and date
  /// -> content
  location-date-separator: ", ",
  /// The subject
  /// -> none | content
  subject: none,
  /// Whether folding marks are shown
  /// -> bool
  folding-marks: true,
  /// Whether a hole punch mark is shown
  /// -> bool
  hole-punch-mark: true,
  /// Content for the page background. The folding marks and the hole punch mark
  /// are placed on the page's background. If you want to add additional content
  /// to the background, provide it here.
  /// -> content
  background: [],
  /// Whether address box and information box are framed. This is mainly for
  /// debugging.
  /// -> bool
  show-boxes: false,
  /// Additional arguments for Typst's `page()` function.<br>
  /// Default arguments are:<br>
  /// `margin: (left: 25mm, rest: 20mm)`<br>
  /// `number-align: bottom + right`<br>
  /// `numbering: (i, t) => text(10pt, context (localized().page-number)(i, t))`<br>
  /// However, those values can be overwritten.
  /// -> any
  ..page-args,
  /// The letter content
  /// -> content
  body
) = {
  let default-page-args = arguments(
    margin: (left: 25mm, rest: 20mm),
    number-align: bottom + right,
    numbering: (i, t) => text(10pt, context (localized().page-number)(i, t))
  )
  set page(
    ..(default-page-args + page-args),
    background: {
      if folding-marks {
        mark(105mm, 5mm)
        mark(210mm, 5mm)
      }
      if hole-punch-mark { mark(148.5mm, 7mm) }
      background
    },
  )

  content-box(
    25mm,
    50mm,
    80mm,
    12.7mm,
    framed: show-boxes,
    text(sender-font-size, sender.join(sender-separator))
  )
  content-box(25mm, 50mm + 12.7mm, 80mm, 27.3mm, framed: show-boxes, recipient)
  content-box(
    ..information-box,
    framed: show-boxes,
    if information == auto {
      if date == auto { date = datetime.today() }
      if type(date) == datetime {
        date = context date.display(
          if date-format == auto {
            localized().date-format
          } else { date-format }
        )
      }
      sender.join("\n")
      v(1fr)
      (location, date).filter(x => x != none).join(location-date-separator)
    } else { information }
  )

  context v(110mm - top-margin())
  if subject != none {
    subject
    v(1cm)
  }
  body
}
