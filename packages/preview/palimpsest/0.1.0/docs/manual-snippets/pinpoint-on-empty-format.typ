#import "@preview/palimpsest:0.1.0": *

#set page(width: 16.6cm, height: auto, margin: 12pt)
#set text(size: 10.5pt)
#set-revisions(require-exchange: false)

No anchor `<r9-9>` exists anywhere in this document.

Default `on-empty:` warns: #pinpoint(<r9-9>)

#pinpoint(<r9-9>, on-empty: none) shows nothing instead when given `on-empty: none`.

#pinpoint(<r9-9>, on-empty: [not found in this round]) shows custom content instead, given as `on-empty:`.

#passage(<r2-1>)[A change #add[on this page].]

Default wording: #pinpoint(<r2-1>)

Custom `format:`: #pinpoint(<r2-1>, format: (pages, has-marks) => [(see line 1 of p. #pages.first())])
