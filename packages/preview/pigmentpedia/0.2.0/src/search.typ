#import "pigments.typ": *
#import "private.typ": *

#let convert-space-to-hyphen(char_str) = {
  let cnv_str = ""
  for char in char_str {
    if char == " " {
      cnv_str += "-"
    } else {
      cnv_str += char
    }
  }
  cnv_str
}

/// Find pigments searched by partial HEX match
///
/// - group (): Pigment group
/// - key (): Pigment search string
/// - current-list (): Current subgroup
/// - previous-list (): Upper-level group
/// ->
#let find-pigment-by-hex(group, key, current-list, previous-list) = {
  let group-name-is-displayed = false
  for i in current-list {
    if (type(i.at(1)) == "color") {
      let name = i.at(0)
      let color = i.at(1)
      if lower(color.to-hex()).contains(lower(key)) {
        if (group-name-is-displayed != true) {
          // only show the name if it's a subgroup
          if previous-list != group {
            line(..group-divider-line)
            pigment(grey, [#group $->$ #previous-list])
            linebreak()
          } else {
            line(..group-divider-line)
            pigment(grey, [#group])
          }
          group-name-is-displayed = true
        }
        block(
          ..colorbox-block-properties,
          stroke: 2pt + color,
          [
            #rect(..colorbox, fill: color)
            #name #h(1fr) #raw(upper(color.to-hex()))
          ],
        )
      }
    } else {
      find-pigment-by-hex(group, key, i.at(1), i.at(0))
    }
  }
}

/// Find pigments searched by partial string match
///
/// - group (): Pigment group
/// - key (): Pigment search string
/// - current-list (): Current subgroup
/// - previous-list (): Upper-level group
/// ->
#let find-pigment-by-name(group, key, current-list, previous-list) = {
  let group-name-is-displayed = false
  key = convert-space-to-hyphen(key)
  for i in current-list {
    if (type(i.at(1)) == "color") {
      let name = i.at(0)
      let color = i.at(1)
      if lower(name).contains(lower(key)) {
        if (group-name-is-displayed != true) {
          // only show the name if it's a subgroup
          if previous-list != group {
            line(..group-divider-line)
            pigment(grey, [#group $->$ #previous-list])
            linebreak()
          } else {
            line(..group-divider-line)
            pigment(grey, [#group])
          }
          group-name-is-displayed = true
        }
        block(
          ..colorbox-block-properties,
          stroke: 2pt + color,
          [
            #rect(..colorbox, fill: color)
            #name #h(1fr) #raw(upper(color.to-hex()))
          ],
        )
      }
    } else {
      find-pigment-by-name(group, key, i.at(1), i.at(0))
    }
  }
}

/// Search pigments in pigmentpedia
///
/// - key (): Partial name or HEX value to search for
/// - scope (): Pigment group to search within. Does not work correctly.
/// ->
#let find-pigment(key, scope: none, sovr: false) = {
  set page(..pigmentpage)
  counter(page).update(1)
  set text(size: 16pt, black, font: "Libertinus Serif")
  set grid(gutter: 2em)

  if scope != none and not sovr {
    align(center + horizon)[
      #pigment(red)[
        #raw("Error: `scope` parameter is disabled.") \ \
        #raw("To enable searching through `scope`,") \
        #raw("toggle `sovr: true` and accept the risks.")
      ]
    ]
    return
  }

  align(center)[
    #pigment(
      grey,
      [
        #if key == "" or key == "#" {
          [🔍 Waiting for search query...]
        } else if key != "#" and key.contains("#") {
          let valid-hex = true

          if key.trim("#").len() > 6 {
            valid-hex = false
          } else {
            for i in key.trim("#") {
              for j in "0123456789abcdef" {
                if lower(i) == j {
                  // if the hex value is valid it will change to true
                  // if not then that value is not a valid hex code
                  valid-hex = true
                  break // break loop when match is found
                } else { valid-hex = false }
              }
              if not valid-hex { break }
            }
          }

          if valid-hex {
            [🔍 Showing results for "#raw(key)"]
          } else {
            pigment(red)[🔍 "#raw(key)" is not a valid #raw("HEX") code]
          }
        } else {
          [🔍 Showing results for "#key"]
        }
      ],
    )
  ]

  if key != "#" and key.contains("#") {
    for i in (if scope != none { scope } else { pigmentpedia }) {
      find-pigment-by-hex(
        i.at(0),
        key.trim("#"),
        if scope != none {
          scope
        } else {
          i.at(1)
        },
        i.at(0),
      )
    }
  } else if key != "" {
    for i in (if scope != none { scope } else { pigmentpedia }) {
      find-pigment-by-name(
        i.at(0),
        key,
        if scope != none {
          scope
        } else {
          i.at(1)
        },
        i.at(0),
      )
    }
  }
}
