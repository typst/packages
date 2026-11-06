/*
  File: search.typ
  Author: neuralpain
  Date Modified: 2025-01-11

  Description: Search logic for Pigmentpedia.
*/

#import "private.typ": *
#import "pigments.typ": *

/// Search logic for `pigmentpedia`.
///
/// - key (str): Your search string.
/// - pgmt-scope (dictionary): The pigment list to search within.
/// - upper-level (dictionary, none): The parent list.
/// - upper-level-name (str, none): The name of the parent list.
/// - current-level (dictionary, none): The current list.
/// - current-level-name (str, none): The name of the current list.
/// - is-hex (bool): Decides whether or not user is searching with HEX values.
/// -> content
#let pgmt-search(
  key,
  pgmt-scope,
  current-level: none,
  current-level-name: none,
  upper-level: none,
  upper-level-name: none,
  is-hex: false,
) = {
  key = key.replace(" ", "-")

  // whether or not the name of the current group being
  // searched is displayed after finding a match
  let current-level-breadcrumbs-displayed = false

  // if `none`, search is on the top-most level of the list
  if current-level == none { current-level = pgmt-scope }

  // formatting for pigments being displayed
  let display-pgmt-block(name, color) = {
    block(
      ..colorbox-block-properties,
      stroke: 2pt + color,
      [
        #rect(..colorbox, fill: color)
        #name #h(1fr) #raw(upper(color.to-hex()))
      ],
    )
  }

  // pigment name formatting
  let output-caps = false
  let output-hyphen = false

  for (name, color) in current-level {
    if name == "output" {
      output-caps = color.caps
      output-hyphen = color.hyphen
      continue
    }
    if type(color) == "dictionary" {
      // if the current "color" position is of type `dictionary`,
      // do a recursive search to find more matches
      pgmt-search(
        key,
        pgmt-scope,
        upper-level: current-level,
        upper-level-name: current-level-name,
        current-level: color,
        current-level-name: name,
        is-hex: is-hex,
      )
    } else {
      let c = if is-hex { color.to-hex() } else { name }
      if lower(key) in lower(c) {
        // display the breadcrumbs for a specific level
        // only once if there is a match on that level.
        if not current-level-breadcrumbs-displayed {
          if current-level != upper-level and upper-level != none and upper-level-name != none {
            line(..group-divider-line)
            pigment(grey, [#upper-level-name $->$ #current-level-name])
          } else {
            line(..group-divider-line)
            pigment(grey, [#current-level-name])
          }
          current-level-breadcrumbs-displayed = true
        }

        display-pgmt-block(format-pigment-name(name, output-caps, output-hyphen), color)
      }
    }
  }
}

/// Search for pigments in `pigmentpedia`.
///
/// - key (str): Partial name or HEX value to search for.
/// - scope (dictionary): Pigment group to search within.
/// - bg (color): The color of the page background. This is
///   used to choose a contrast color for the text based on
///   the background color.
/// -> content
#let find-pigment(key, scope: none, bg: white) = {
  // searching through `pigmentpedia` on `scope` will break the search.
  if scope == pigmentpedia {
    // perform a standard search and exit the function.
    find-pigment(key)
    return
  }

  if type(scope) == "color" {
    pgmt-error.scope-is-color
    return
  }

  if scope != none and type(scope) != "dictionary" {
    pgmt-error.not-a-pgmt-group
    return
  }

  if type(bg) != "color" {
    pgmt-error.bg-not-a-color
    return
  }

  pgmt-page-setup(
    bg: bg,
    {
      v(0cm) // small padding from the header

      align(center)[
        #pigment(
          get-contrast-color(bg),
          [
            #if key.len() == 0 or key == " " or key == "#" {
              [🔍 Find the perfect pigment...]
              return // don't attempt search
            } else if key.len() != 1 and "#" in key {
              let valid-hex = true

              // local scope copy of `key`
              let _key = key.trim("#")

              // Value is reset for every input, If `key` is
              // too large, its value will remain `none`,
              // having skipped the validation check
              let invalid-hex-symbol = none

              // verify the HEX string length is within bounds
              if _key.len() > 6 {
                valid-hex = false
              } else {
                for i in _key {
                  if lower(i) not in "0123456789abcdef" {
                    valid-hex = false
                    invalid-hex-symbol = i
                    break
                  }
                }
              }

              if valid-hex {
                [🔍 Showing results for "`#`#raw(_key)" #get-pgmt-group-name(l: "in", scope, bg: bg)]
              } else if invalid-hex-symbol != none {
                pigment(red)[`Sorry, "`#raw(invalid-hex-symbol)`" is not a valid HEX symbol.`]
              } else {
                pigment(red)[`Too long! "`#raw(key)`" is not a valid HEX code.`]
              }
            } else {
              [🔍 Showing results for "#key" #get-pgmt-group-name(l: "in", scope, bg: bg)]
            }
          ],
        )
      ]

      if type(scope) != "dictionary" {
        for (pgmt-list-name, pgmt-list) in pigmentpedia {
          if key != "#" and "#" in key {
            pgmt-search(key.trim("#"), pgmt-list, current-level-name: pgmt-list-name, is-hex: true)
          } else {
            pgmt-search(key, pgmt-list, current-level-name: pgmt-list-name)
          }
        }
      } else {
        if key != "#" and "#" in key {
          pgmt-search(key.trim("#"), scope, is-hex: true)
        } else {
          pgmt-search(key, scope)
        }
      }
    },
  )
}
