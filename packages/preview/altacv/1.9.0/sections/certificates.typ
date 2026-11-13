// Certificates: the date at the title's right edge, then the issuer
// and credential ID on one line, so several certs stay short.

#import "../internal/util/dates.typ": _date-span
#import "../internal/util/fields.typ": _field
#import "../internal/components/entry.typ": _entry
#import "../internal/primitives.typ": _divider-space
#import "../internal/components/frame.typ": _section

// No `open-end`: a cert without `expiry-date` doesn't expire, so it
// never reads "Present".
#let _certificates(certs, (labels, format-date, ..)) = _section(
  labels.certificates,
  certs,
  cert => _entry(
    labels,
    title: cert.name,
    url: _field(cert, "url"),
    org: _field(cert, "issuer"),
    details: (_field(cert, "credential-id"),),
    period: _date-span(
      _field(cert, "date"),
      _field(cert, "expiry-date"),
      format-date,
    ),
    summary: _field(cert, "summary"),
  ),
  // Short, uniform rows: the spacing without the rule.
  separator: _divider-space(),
)
