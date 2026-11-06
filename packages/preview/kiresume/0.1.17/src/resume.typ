#import "section.typ": section

/// A utility function to get a value from a dictionary or return a default value.
/// 
/// -> bool
#let value-or-default(
  /// -> dictionary
  dict,
  /// -> str
  key,
  /// -> any
  default,
) = {
  if (key in dict) and (dict.at(key) != none) and (dict.at(key) != "") {
    return dict.at(key)
  }
  return default
}

/// The main function to create a resume. 
/// 
/// -> content
#let resume(
  /// -> str
  candidate-name: "",
  /// -> str
  job-title: "",
  /// -> array
  links: (),
  /// -> array
  sections: (),
  /// -> dictionary
  style: (:),
) = {
  let header-color = value-or-default(style, "header-color", color.black.to-hex())
  let divider-color = value-or-default(style, "divider-color", color.black.to-hex())
  let link-color = value-or-default(style, "link-color", color.navy.to-hex())
  let font = value-or-default(style, "font", "Nimbus Sans")

  set document(author: candidate-name, title: [#candidate-name $dash.em$ #job-title])
  set text(font: font, ligatures: false, size: 9pt, slashed-zero: true)
  set line(length: 100%, stroke: 1pt + rgb(divider-color))
  set page(paper: "a4", margin: 0.75in)
  show heading: it => [ #set text(fill: rgb(header-color)); #it ]
  show link: it => [ #set text(fill: rgb(link-color)); #underline(it) ]

  align(center)[
    = #candidate-name $dash.em$ #job-title
    #(
      links
        .map(it => if ("destination" in it) {
          link(it.destination)[#it.display]
        } else {
          it.display
        })
        .join(" | ")
    )
  ]

  for sect in sections {
    section(..sect)
  }
}
