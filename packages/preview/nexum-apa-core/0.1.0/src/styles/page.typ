// Page geometry and page-number header.
#let with-page(
  body,
  paper: "us-letter",
  margin: 1in,
  page-numbers: true,
) = {
  set page(
    paper: paper,
    margin: margin,
    header: if page-numbers {
      context align(right)[#counter(page).display("1")]
    } else {
      none
    },
    header-ascent: 50%,
  )
  body
}
