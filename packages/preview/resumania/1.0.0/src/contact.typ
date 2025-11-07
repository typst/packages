// These are the Resumania data structures and functions for organizing and
// creating contact information blocks.
//
// Here is a usage example:
// ```typst
// #let phone-number = phone("+0 (123) 555-0100")
// #let portfolio = url-link(
//   name: "Portfolio",
//   "example.com/johndoe",
//   "https://example.com",
// )
//
// // Make a custom contact entry.
// #let greeting = contact(
//   "Howdy",
//   "John",
//   show-value: who => emph(who),
// )
//
// #show-section(contact-section(phone-number, portfolio, greeting))
// ```
// -----------------------------------------------------------------------------

#import "debug.typ": *
#import "section.typ": *
#import "util.typ": *

#import "style.typ"

// The separator between contact entries in the contact section. This can be
// freely changed by updating the state. For example, to separate by just a
// space it can be set to `h(1em)`.
#let contact-separator = state("resumania:contact:contact-separator", [ | ])

// Create an arbitrary contact entry.
//
// This is meant to be a "base" for creating specific kinds of contacts, such as
// a phone number or email address (which are both provided as part of this
// module).
//
// = Parameters
// - `name`: `str` | `content`
//     The name of the contact, which will be displayed next to the contact.
// - `value`: `any`
//     The value of the contact, which is specific to the kind of contact being
//     created and must be compatible with the `show-value` parameter.
// - `show-value`: `function`
//     A function which takes the `value` and returns `content` to be displayed
//     next to `name`.
//
// Note that if `name` is `none`, it will not be shown.
#let contact(name, value, show-value: text) = {
  (name: name, value: value, show-value: show-value)
}

// Turn a contact entry into content.
#let show-contact(contact) = {
  let (name, value, show-value) = contact

  if show-value != none {
    value = show-value(value)
  }

  if name != none {
    [#style.section(name): ]
  }

  value
}

// Create a location contact entry.
//
// Most commonly this would be city and state (or equivalent), but may be any
// `content`.
//
// The argument `name` optionally specifies what the location is, for example
// `[Location]` or `[Hometown]`.
#let location(loc, name: none) = {
  contact(name, loc)
}

// Create a phone number contact entry.
//
// There is no enforcement on the format or type for the number so long as it
// can be appended to a string (for the link). When shown using `show-contact`,
// a `"tel:"` link will be added to the resulting content.
//
// The argument `name` optionally specifies a name for the phone number, for
// example `[Personal]`, `[Work]`, or `[Cell].
#let phone(number, name: none) = {
  contact(
    name,
    number,
    show-value: number => link("tel:" + number),
  )
}

// Create an email contact entry.
//
// There is no enforcement on the format or type for the email so long as it can
// be appended to a string (for the link). When using `show-contact`, a
// `"mailto:"` link will be added to the resulting content.
//
// The `name` argument optionally specifies a name for the email, such as
// `[Personal]`, `[Work]`, or `[Email], for example.
#let email(email, name: none) = {
  contact(
    name,
    email,
    show-value: email => link("mailto:" + email),
  )
}

// Create a generic contact entry with an embedded link.
//
// `name` and `value` are directly passed to `contact` and should follow those
// conventions, and `dest` must be able to be passed to `link` (e.g. a string
// URL).
#let url-link(value, dest, name: none) = {
  contact(
    name,
    value,
    show-value: value => link(dest, value),
  )
}

// Create a section of multiple contact entries (created from `contact` or the
// other common "sub-types" (e.g. `phone`, `email`, etc.).
//
// When inserted into the document, the contact entries are inserted in the
// order they were given, with the separator specified in `contact-separator`
// between them (except at line breaks, where no separator is used).
#let contact-section(..contacts) = {
  return section(
    none,
    none,
    show-section: (contacts) => {
      let body = join-with-linebreaks(
        contacts.items.map(show-contact),
        separator: context contact-separator.get(),
      )
      align(center, debug-block(body))
    },
    ..contacts,
  )
}
