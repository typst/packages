// The page header: `basics` and the header preferences mapped onto
// `_page-header`, the contact bar's entries from `data/contacts.typ`.
// Not one of the column sections in `data/sections.typ`: `alta()`
// renders it above the grid. `_read-cv` has checked the fields it
// reads.

#import "../internal/util/fields.typ": _field
#import "../internal/data/contacts.typ": _contact-rows, _linked-contacts
#import "../internal/primitives.typ": _fact-line, _photo
#import "../internal/components/header.typ": _page-header

// `basics.image`, or `none` when there's nothing to frame: a `path`
// can't be empty, and an empty `str` / `bytes` counts as absent.
#let _header-image(image-src) = if (
  type(image-src) == path or (image-src != none and image-src.len() > 0)
) { image-src }

// `auto` reads `basics.url`, which `_read-cv` has checked is set.
#let _resolve-qr-url(qr-code, basics) = if qr-code == auto {
  basics.url
} else { qr-code }

#let _header(cv, (labels, prefs, ..)) = {
  let basics = cv.basics
  let image = _header-image(basics.at("image", default: none))
  _page-header(
    name: basics.name,
    tagline: _field(basics, "label"),
    objective: _field(cv, "objective"),
    contacts: _contact-rows(
      _linked-contacts(
        basics,
        prefs,
        location-alt: labels.location,
        join-location: _fact-line,
      ),
    ),
    text-align: prefs.header-text-align,
    uppercase: prefs.uppercase-name,
    // `alt` is the person's name: language-neutral, so no label key.
    photo: if image != none {
      _photo(image, prefs.photo-size, basics.name, shape: prefs.photo-shape)
    },
    photo-position: prefs.photo-position,
    qr-url: _resolve-qr-url(prefs.qr-code, basics),
  )
}
