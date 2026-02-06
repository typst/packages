/*
 * SPDX-FileCopyrightText: 2025 Stefano Volpe <foxy@teapot.ovh>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

// Styles the content adding Agda to the available grammars for syntax
// highlighting.
#let init-color-my-agda(body) = context {
  // The syntaxes previously available in the current context
  let syntaxes-old = raw.syntaxes
  // The type of the variable storing the syntaxes previously available
  let syntaxes-old-type = type(syntaxes-old)
  // The syntaxes to be added
  let syntaxes-new = ("Agda.sublime-syntax",)
  // The syntaxes that will be available after the operation
  let syntaxes-merged = (
    (
      if syntaxes-old-type == str { (syntaxes-old,) } else if syntaxes-old-type
        == array { syntaxes-old } else {
        panic(
          "unmet assumption: raw.syntaxes' type is "
            + syntaxes-old-type
            + ", but should be string or array",
        )
      }
    )
      + syntaxes-new
  )
  set raw(syntaxes: syntaxes-merged)
  body
}
