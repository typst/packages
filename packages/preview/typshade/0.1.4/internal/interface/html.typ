// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

/// Target-aware table rendering for PDF and HTML export.

#let _table-style = "border-collapse:collapse;border:1px solid #c8c8c8;margin:0.35em 0;"
#let _header-cell-style = "border:1px solid #c8c8c8;padding:0.25em 0.45em;text-align:left;vertical-align:top;font-weight:600;background:#f7f7f7;"
#let _cell-style = "border:1px solid #c8c8c8;padding:0.25em 0.45em;text-align:left;vertical-align:top;"

/// Render tabular data appropriately for the active output target.
///
/// - pdf-table (content): Typst table used for paged output.
/// - headers (array): Header cells for the semantic HTML table.
/// - rows (array): Body rows for the semantic HTML table.
/// -> content
#let target-table(pdf-table, headers, rows) = context if target() == "html" {
  html.elem("table", attrs: (class: "typshade-data-table", style: _table-style))[
    #html.elem("thead")[
      #html.elem("tr")[
        #for cell in headers {
          html.elem("th", attrs: (style: _header-cell-style))[#cell]
        }
      ]
    ]
    #html.elem("tbody")[
      #for row in rows {
        html.elem("tr")[
          #for cell in row {
            html.elem("td", attrs: (style: _cell-style))[#cell]
          }
        ]
      }
    ]
  ]
} else {
  pdf-table
}
