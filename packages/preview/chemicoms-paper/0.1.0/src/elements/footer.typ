#import "@preview/chic-hdr:0.4.0": *

#let footer-render(parity: false, args) = {
  let footer-internal-content = (
    counter(page).display(),
    h(0.75em),[|],h(1em),
    text( size: 8pt, args.citation ),
  )
  if not parity {footer-internal-content = footer-internal-content.rev()}
  align(if parity {left} else {right}, footer-internal-content.join() )
}

#let odd-even-page(content-odd: [], content-even: []) = {
  locate( loc => {if calc.even(loc.page()) [#content-even] else [#content-odd]})
}

#let footer(args) = odd-even-page(
  content-odd: footer-render(parity: false, args),
  content-even: footer-render(parity: true, args)
)