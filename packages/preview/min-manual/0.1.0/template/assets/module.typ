/**
 * = Quick Start
 * 
 * ```typm 
 * // Minimal initialization example, like:
 * #import "@preview/module:0.4.2": feature
 * #show: feature.with(
 *   name: "Do Something",
 *   when: datetime.today(),
 * )
 * ```
 *
 * = Description
 * 
 * To create this manual, the `doc-comments.typ` file reads the `assets/module.typ`
 * source code and gather documentation from special
 * comments there; then _min-manual_ handles everything and generates this
 * document from those comments.
 * 
 * 
 * 
 * #lorem(100)
 * 
 * = Options
 * These are all the options avalilable and its respetive default values, if any:
 * 
 * // Extract the #feature function from this source code file
 * :feature: show `typm`
 * 
 * ```typm #show: feature.with()``` -> content
 * Explanation of what is this structure, what it does, and how to set it.
 * 
 * ```typm #set feature()``` -> nothing
 * Explanation of what is this structure, what it does, and how to set it.
 * 
 * ```typm #feature()``` -> content
 * Explanation of what is this structure, what it does, and how to set it.
**/
#let feature(
    // Those doc-comments below document each argument of #feature:
  name: none, 
    /** <- string | content | none <required>
      * Explanation of what is this argument, what it does, and how to set it. **/
  text: none,
    /** <- string | content | none
      * Explanation of what is this argument, what it does, and how to set it. **/
  when: datetime.today(),
    /** <- datetime
      * Explanation of what is this argument, what it does, and how to set it. **/
  notify: true,
    /** <- boolean
      * Explanation of what is this argument, what it does, and how to set it. **/
  body,
    /// <- content | string
) = {

  /**
   * = Code Explanation
   * 
   * #lorem(50)
   * // You can insert standard Typst comments inside doc-comments!
  **/
  
  // Standard comments, like this one, are not treated as doc-comments.
}

/**
 * = Dependencies
 *
 * Requires the #univ("example") Typst package. To setup the project you will
 * need the #pip("fictional") Python module, or the #crate("nonexistent") crate.
 * If this package does not work, just go back to LaTeX and use
 * #pkg("alternative", "https://ctan.org/pkg/") instead, or delve into Regex and
 * one-liners with the #pkg("OG::Solution", "https://metacpan.org/pod/") Perl
 * module.
**/

This example file mimics a Typst module with embedded doc-comments, used by
_min-manual_ to generate documentation. If you are compiling this file, you can
see there's no doc-comments appearing here in the final document; that's because
Tyspt considers them to be regular comments.

Please, compile `doc-comments.typ` instead to see how the doc-comments contained in the
source code looks in a manual.


/**
 * = Copyright
 * 
 * Copyright #sym.copyright #datetime.today().year() MANUAL AUTHOR. \
 * This manual is licensed under MIT. \
 * The manual source code is free software:
 * you are free to change and redistribute it.  There is NO WARRANTY, to the extent
 * permitted by law.
**/

/// The logo was obtained from #link("https://flaticon.com")[Flaticon] website.
