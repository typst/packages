// `theme.custom`: the public face of the patch DSL (README §2.4). Only the
// documented helpers are re-exported; the implementation in
// theming/custom.typ also sees internal helpers (emit, clean-auto, ..) that
// must not become API. tests/polish/exports.typ pins this list.
#import "../theming/custom.typ": (
  area, bank-details, brand, checks, colors, continuation, envelopes, fonts,
  from-data, items-table, line-items, logo, marks, page, page-number, part,
  proof, radii, replace, reset, row, sizes, spacing, stationery, strokes, title,
  totals, weights, wrap,
)
