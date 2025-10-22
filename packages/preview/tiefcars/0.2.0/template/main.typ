
#import "@preview/tiefcars:0.2.0": single-page-layout, tiefcars

/* === Set up lcars with your theme === */
#show: tiefcars.with(theme: "tng")

/* === Enable the default layout === */
#show: single-page-layout.with(
  /* === The title of the document, fancyful and amazing */
  title: [TiefCARS],
  subtitle-text: [
    /* === Text displayed in the top part under the title */
    The best way to imitate an LCARS interface with Typst (as it's, as far as I know,
    the only way currently)

    Current features:
    - One page
    - Headaches
    - Easy start
  ],
)

/* === Change the below text to your liking! === */

Welcome to *TiefCARS*, the worst way to format your documents to look like
a futuristic Screen!

Build your own magic stuff with TiefCARS, now for free at
#link("https://github.com/Tiefseetauchner/TiefCARS")! Make your own documents
now!

(Version 0.2.0, less buggy but still)
