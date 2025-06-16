// one function to set the display of an RFC word
#let __rfc-keyword(body)        = emph(upper(body))
#let __rfc-keyword-quoted(body) = emph(upper(["#body"]))

// a function (macro-like) for each of the possible RFC words
#let must            = __rfc-keyword("must")
#let must-quoted     = __rfc-keyword-quoted("must")
#let must-not        = __rfc-keyword("must not")
#let required        = __rfc-keyword("required")
#let shall           = __rfc-keyword("shall")
#let shall-not       = __rfc-keyword("shall not")
#let should          = __rfc-keyword("should")
#let should-not      = __rfc-keyword("should not")
#let recommended     = __rfc-keyword("recommended")
#let not-recommended = __rfc-keyword("not recommended")
#let may             = __rfc-keyword("may")
#let optional        = __rfc-keyword("optional")

// quoted versions, so quotation marks get included in the emph()
#let must-quoted            = __rfc-keyword-quoted("must")
#let must-not-quoted        = __rfc-keyword-quoted("must not")
#let required-quoted        = __rfc-keyword-quoted("required")
#let shall-quoted           = __rfc-keyword-quoted("shall")
#let shall-not-quoted       = __rfc-keyword-quoted("shall not")
#let should-quoted          = __rfc-keyword-quoted("should")
#let should-not-quoted      = __rfc-keyword-quoted("should not")
#let recommended-quoted     = __rfc-keyword-quoted("recommended")
#let not-recommended-quoted = __rfc-keyword-quoted("not recommended")
#let may-quoted             = __rfc-keyword-quoted("may")
#let optional-quoted        = __rfc-keyword-quoted("optional")

// links to the relevant BCP and RFCs
#let bcp14-name   = "BCP 14"
#let bcp14-url    = "https://www.rfc-editor.org/bcp/bcp14"
#let bcp14        = link(bcp14-url, bcp14-name)

#let rfc2119-name = "RFC2119"
#let rfc2119-url  = "https://www.rfc-editor.org/rfc/rfc2119"
#let rfc2119      = link(rfc2119-url, rfc2119-name)

#let rfc8174-name = "RFC8174"
#let rfc8174-url  = "https://www.rfc-editor.org/rfc/rfc8174"
#let rfc8174      = link(rfc8174-url, rfc8174-name)

// the boilerplate you should include when using RFC words:
//
// Authors who follow these guidelines should incorporate this phrase near
// the beginning of their document:
#let rfc-keyword-boilerplate = [
  The key words #must-quoted, #must-not-quoted, #required-quoted, #shall-quoted,
  #shall-not-quoted, #should-quoted, #should-not-quoted, #recommended-quoted,
  #not-recommended-quoted, #may-quoted, and #optional-quoted in this document
  are to be interpreted as described in #bcp14 [#rfc2119] [#rfc8174] when, and
  only when, they appear in all capitals, as shown here.
]

// definitions for each of the words

#let rfc-keyword-must-definition = terms.item(
  must,
  [
    This word, or the terms #required-quoted or #shall-quoted, mean that the definition
    is an absolute requirement of the specification.
  ]
)

#let rfc-keyword-must-not-definition = terms.item(
  must-not,
  [
    This phrase, or the phrase #shall-not-quoted, mean that the definition is an
    absolute prohibition of the specification.
  ]
)

#let rfc-keyword-should-definition = terms.item(
  should,
  [
    This word, or the adjective #recommended-quoted, mean that there may exist valid
    reasons in particular circumstances to ignore a particular item, but the full
    implications must be understood and carefully weighed before choosing a
    different course.
  ]
)

#let rfc-keyword-should-not-definition = terms.item(
  should-not,
  [
    This phrase, or the phrase #not-recommended-quoted mean that there may exist
    valid reasons in particular circumstances when the particular behavior is
    acceptable or even useful, but the full implications should be understood and
    the case carefully weighed before implementing any behavior described with
    this label.
  ]
)

#let rfc-keyword-may-definition = terms.item(
  may,
  [
    This word, or the adjective "#optional", mean that an item is truly
    optional. One vendor may choose to include the item because a particular
    marketplace requires it or because the vendor feels that it enhances the
    product while another vendor may omit the same item. An implementation which
    does not include a particular option #must be prepared to interoperate with
    another implementation which does include the option, though perhaps with
    reduced functionality. In the same vein an implementation which does include a
    particular option #must be prepared to interoperate with another
    implementation which does not include the option (except, of course, for the
    feature the option provides.)
  ]
)

// and all definitions in a single term list
#let rfc-keyword-definitions = [
  #rfc-keyword-must-definition
  #rfc-keyword-must-not-definition
  #rfc-keyword-should-definition
  #rfc-keyword-should-not-definition
  #rfc-keyword-may-definition
]
