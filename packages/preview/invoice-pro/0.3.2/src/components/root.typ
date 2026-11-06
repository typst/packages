#import "../loom-wrapper.typ": loom, managed-motif

/// The internal root container that wraps the invoice body.
/// It initializes the global context and provides the base document structure to the theme.
///
/// -> content
#let root(
  /// The content to be rendered within the document structure.
  /// -> content
  body,
) = {
  managed-motif(
    "root",
    scope: ctx => loom.mutator.batch(ctx, {
      import loom.mutator: *

      nest("sender", {
        ensure("name", "#sender.name")
        ensure("address", "#sender.address")
        ensure("city", "#sender.city")

        ensure("extra", ())
        update("extra", x => if type(x) == dictionary { x.pairs() } else { x })
      })

      nest("recipient", {
        ensure("name", "#recipient.name")
        ensure("address", "#recipient.address")
        ensure("city", "#recipient.city")

        ensure("extra", ())
        update("extra", x => if type(x) == dictionary { x.pairs() } else { x })
      })

      ensure("invoice-date", datetime.today())
      ensure("subject", "#subject")
      ensure("references", ())
      ensure("invoice-nr", "#invoice-nr")

      nest("locale", {
        ensure("lang", "de")
        nest("format", {
          ensure("date", (..) => panic("locale::format::date is not provided"))
        })
      })

      ensure("theme", "document", (.., body) => body)

      // Internally Calculated
      nest("global", {
        nest("total", {
          ensure("net", decimal(0))
          ensure("gross", decimal(0))
        })

        nest("formated-total", {
          ensure("net", "0")
          ensure("gross", "0")
        })
      })
    }),
    measure: (ctx, children) => {
      let all-line-itmes = loom.query.collect-signals(
        children,
        kind: "line-items",
      )
      assert(
        all-line-itmes.len() <= 1,
        message: "There can only be one `line-items` element in the document!",
      )
      let line-items = all-line-itmes.first(default: (:))

      let public = (
        total: line-items.at("total", default: (:)),
        formated-total: line-items.at("formated-total", default: (:)),
      )

      return (public, none)
    },
    draw: (ctx, _, _, body) => {
      set text(lang: ctx.locale.lang)
      (ctx.theme.document)(ctx, body)
    },
    body,
  )
}
