#import "@preview/thyme:0.1.0": *

#show: webpage.with(
  title: [Contact],
  description: "Direct email and OpenPGP fingerprint.",
  modified: datetime(year: 2026, month: 10, day: 28),
)

= Contact

#tr(
  en: [Reach out directly by electronic mail or verify signatures against `/pgp.txt`.],
  de: [Direkter Kontakt per E-Mail oder Signaturprüfung über `/pgp.txt`.],
)

// `html.elem` comes from Typst itself, so no helper is needed for markup that plain
// Typst content cannot express.
#html.elem("ul", {
  html.elem("li", {
    [Email: ] + link("mailto:ada@example.org")[`ada@example.org`]
  })
  html.elem("li", { [OpenPGP: ] + link("../pgp.txt")[`pgp.txt`] })
})
