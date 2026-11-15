// Checks of the identifier inputs of the parties at the input boundary of
// `invoice`, for every invoice: an identifier that produces no text would
// otherwise be left out of the printed invoice and of the e-invoice without
// notice.

#import "../utils/text.typ": plain-text

/// The keys of each party that take an identifier: a text, a dictionary
/// `(scheme: .., id: ..)` or an identifier of the `id` module.
#let identifier-keys = (
  sender: ("id", "global-id", "legal-id", "electronic-address"),
  recipient: (
    "id",
    "global-id",
    "legal-id",
    "electronic-address",
    "leitweg-id",
    "buyer-reference",
  ),
  delivery-address: ("id", "location-id", "global-id"),
  payee: ("id", "global-id", "legal-id"),
)

// Whether a dictionary is an identifier of the `id` module, whose problems
// (e.g. an empty or a wrong identifier) the e-invoice reports (IP-ID-01).
#let _is-typed(value) = "kind" in value and "problems" in value

/// Stops the compilation for an identifier of `party` (the input `field`,
/// e.g. `"sender"`, with the keys `keys`) that produces no text:
///
/// - a function, e.g. the constructor `id.siret` given without calling it;
/// - a dictionary whose `id` is missing or empty, e.g. `(scheme: "0002")`.
///   An electronic address without `id` counts as not given and is derived
///   instead, and an identifier of the `id` module reports its problems in
///   the e-invoice.
///
/// -> none
#let check-identifiers(party, field, keys) = {
  if type(party) != dictionary { return }
  for key in keys {
    let value = party.at(key, default: none)
    let path = field + "." + key
    if type(value) == function {
      assert(
        false,
        message: "`"
          + path
          + "` is the function `"
          + repr(value)
          + "`, not an identifier: call it with the identifier, e.g. `"
          + key
          + ": id."
          + repr(value)
          + "(\"..\")` for a constructor of the `id` module.",
      )
    }
    if (
      type(value) == dictionary
        and key != "electronic-address"
        and not _is-typed(value)
        and plain-text(value.at("id", default: none)) == ""
    ) {
      assert(
        false,
        message: "`"
          + path
          + "` has no identifier: its `id` is missing or empty in "
          + repr(value)
          + ". Give the identifier as `id`, e.g. `"
          + key
          + ": (scheme: \"0088\", id: \"4000001123452\")`, or leave out `"
          + key
          + "`.",
      )
    }
  }
}
