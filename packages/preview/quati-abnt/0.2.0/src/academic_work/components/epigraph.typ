// # Epigraph. Epígrafe.
// NBR 14724:2024 4.2.1.6

#import "../../common/components/quote.typ": format_quote

// NBR 14724:2024 4.2.1.6, NBR 14724:2024 5.2.4, NBR 14724:2024 5.5
#let include_epigraph(
  indent: true,
  smaller_text: true,
  body,
) = context {
  show quote: it => format_quote(
    indent: indent,
    smaller_text: smaller_text,
  )[#it]
  body
}
