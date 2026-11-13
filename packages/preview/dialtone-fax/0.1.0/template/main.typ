#import "@preview/dialtone-fax:0.1.0": fax

// Change "us-letter" to "a4" for A4 paper.
#show: fax.with(
  paper: "us-letter",
  to: [County Records Office],
  to-fax: [+1 202 555 0143],
  from: [Your name],
  from-fax: [+1 202 555 0188],
  subject: [Records request],
)

Dear records clerk,

Please find attached my request for a certified copy of the record described below. The signed
authorisation is on page 2.

#table(
  columns: (auto, 1fr),
  [Record], [Certificate of formation],
  [Reference], [2026-0412],
  [Copies], [1],
)

You can reach me at the fax number above or by phone during business hours.

Sincerely,

Your name

#pagebreak()

= Authorisation

I authorise the release of the record named on page 1 to the sender of this fax.

#v(36pt)
#line(length: 60%)
Signature and date
