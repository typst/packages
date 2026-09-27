#import "../loom-wrapper.typ": content-motif
#import "../utils/types.typ"

#let _to-content(val) = {
  if val == none {
    none
  } else if type(val) == content {
    val
  } else {
    [#val]
  }
}

/// A draw-only motif that queries and displays dynamic values from the Loom context (`ctx`).
///
/// Can be invoked with path segments, e.g.:
/// - `#dynamic("locale", "region", "code")`
/// - `#dynamic("sender", "name")`
/// - `#dynamic("recipient", "city-name")`
/// - `#dynamic("invoice-nr")`
/// - `#dynamic("due-date")`
/// - `#dynamic("order-nr")`
/// - `#dynamic("bank", "iban")`
/// - `#dynamic(ctx => [Custom: #ctx.sender.name])`
///
/// -> content
#let dynamic(
  /// The path segments in `ctx` (e.g. `"sender", "name"`), or a query function `ctx => content`.
  /// -> ..str | function
  ..path,

  /// Fallback content or string to render if the path is not found or evaluates to `none`.
  /// -> any
  default: none,

  /// Custom formatting function `(val) => content`, or `auto` to apply contextual formatting (e.g. for dates).
  /// -> auto | function
  format: auto,
) = {
  content-motif(
    draw: (ctx, body) => {
      let pos = path.pos()
      if pos.len() == 0 {
        return _to-content(default)
      }

      // 1. If first positional argument is a closure `ctx => content`
      if type(pos.first()) == function {
        let fn = pos.first()
        let res = fn(ctx)
        if res == none { res = default }
        return _to-content(res)
      }

      // 2. Flatten and normalize path keys
      let keys = ()
      for p in pos {
        if type(p) == array {
          for sub in p { keys.push(str(sub)) }
        } else if type(p) == str and p.contains(".") {
          for sub in p.split(".") { keys.push(sub) }
        } else {
          keys.push(str(p))
        }
      }

      // 3. Smart resolution with fallbacks for top-level shortcuts
      let val = none
      if keys.len() == 1 {
        let key = keys.first()
        if key == "invoice-nr" {
          val = ctx.at("invoice-nr", default: none)
        } else if key == "invoice-date" or key == "date" {
          val = ctx.at("invoice-date", default: none)
        } else if key == "due-date" {
          val = ctx.at("due-date", default: none)
          if (
            val == none and "payment-goal" in ctx and ctx.payment-goal != none
          ) {
            if ctx.payment-goal.at("date", default: none) != none {
              val = ctx.payment-goal.date
            } else if (
              ctx.payment-goal.at("days", default: none) != none
                and type(ctx.at("invoice-date", default: none)) == datetime
            ) {
              val = ctx.invoice-date + duration(days: ctx.payment-goal.days)
            }
          }
        } else if key == "customer-nr" or key == "customer-id" {
          val = ctx.at(
            "customer-nr",
            default: ctx.recipient.at(
              "customer-nr",
              default: ctx.recipient.at(
                "id",
                default: ctx.recipient.at("customer-id", default: none),
              ),
            ),
          )
        } else if key == "order-nr" or key == "po-nr" {
          val = ctx.at(
            "order-nr",
            default: ctx.recipient.at(
              "order-nr",
              default: ctx.at(
                "po-nr",
                default: ctx.recipient.at("po-nr", default: none),
              ),
            ),
          )
        } else if key == "order-date" {
          val = ctx.at(
            "order-date",
            default: ctx.recipient.at("order-date", default: none),
          )
        } else if key == "project" {
          val = ctx.at(
            "project",
            default: ctx.recipient.at("project", default: none),
          )
        } else if key == "contract-nr" {
          val = ctx.at(
            "contract-nr",
            default: ctx.recipient.at("contract-nr", default: none),
          )
        } else if key == "quote-nr" {
          val = ctx.at(
            "quote-nr",
            default: ctx.recipient.at("quote-nr", default: none),
          )
        } else if key == "delivery-note-nr" {
          val = ctx.at(
            "delivery-note-nr",
            default: ctx.recipient.at("delivery-note-nr", default: none),
          )
        } else if key == "preceding-invoice-nr" {
          val = ctx.at(
            "preceding-invoice-nr",
            default: ctx.at("original-invoice-nr", default: none),
          )
        } else if key == "payment-reference" {
          val = ctx.at(
            "payment-reference",
            default: ctx.at(
              "reference",
              default: ctx.at("invoice-nr", default: none),
            ),
          )
        } else if key == "buyer-reference" or key == "leitweg-id" {
          val = ctx.at(
            "buyer-reference",
            default: ctx.recipient.at(
              "buyer-reference",
              default: ctx.recipient.at("leitweg-id", default: none),
            ),
          )
        } else if key == "subject" {
          val = ctx.at("subject", default: none)
        } else if key == "tax-nr" {
          val = ctx.sender.at("tax-nr", default: none)
        } else if key == "vat-id" {
          val = ctx.sender.at("vat-id", default: none)
        } else if key == "iban" {
          val = ctx
            .at(
              "bank",
              default: (:),
            )
            .at(
              "iban",
              default: ctx
                .sender
                .at("bank", default: (:))
                .at(
                  "iban",
                  default: none,
                ),
            )
        } else if key == "bic" {
          val = ctx
            .at(
              "bank",
              default: (:),
            )
            .at(
              "bic",
              default: ctx
                .sender
                .at("bank", default: (:))
                .at(
                  "bic",
                  default: none,
                ),
            )
        } else if key in ctx {
          val = ctx.at(key)
        }
      } else {
        // Standard path traversal
        val = ctx
        for k in keys {
          if type(val) == dictionary and k in val {
            val = val.at(k)
          } else {
            val = none
            break
          }
        }

        // Additional smart fallbacks for nested lookups
        if val == none {
          if (
            keys == ("locale", "region", "code")
              or keys == ("locale", "region")
              or keys == ("region", "code")
          ) {
            val = ctx
              .locale
              .at(
                "meta",
                default: (:),
              )
              .at(
                "region",
                default: ctx
                  .locale
                  .at("region", default: (:))
                  .at(
                    "meta",
                    default: (:),
                  )
                  .at("region", default: none),
              )
          } else if (
            keys == ("locale", "lang")
              or keys == ("locale", "language")
              or keys == ("lang",)
          ) {
            val = ctx.locale.at(
              "lang",
              default: ctx
                .locale
                .at("meta", default: (:))
                .at(
                  "lang",
                  default: none,
                ),
            )
          } else if keys == ("bank", "iban") {
            val = ctx
              .at(
                "bank",
                default: (:),
              )
              .at(
                "iban",
                default: ctx
                  .sender
                  .at("bank", default: (:))
                  .at(
                    "iban",
                    default: none,
                  ),
              )
          } else if keys == ("bank", "bic") {
            val = ctx
              .at(
                "bank",
                default: (:),
              )
              .at(
                "bic",
                default: ctx
                  .sender
                  .at("bank", default: (:))
                  .at(
                    "bic",
                    default: none,
                  ),
              )
          } else if keys == ("total", "gross") or keys == ("total", "net") {
            let field = keys.at(1)
            val = ctx
              .at(
                "global",
                default: (:),
              )
              .at(
                "formated-total",
                default: (:),
              )
              .at(field, default: none)
          }
        }
      }

      let res = if val == none { default } else { val }
      if res == none { return none }

      // 4. Custom formatting
      if format != auto {
        if type(format) == function {
          return _to-content(format(res))
        }
      }

      // 5. Default formatting based on type
      if type(res) == datetime {
        if (
          "locale" in ctx
            and "format" in ctx.locale
            and "date" in ctx.locale.format
        ) {
          _to-content((ctx.locale.format.date)(res))
        } else {
          _to-content(res.display())
        }
      } else if type(res) == array {
        _to-content(
          res.map(x => if type(x) == content { x } else { [#x] }).join(", "),
        )
      } else {
        _to-content(res)
      }
    },
    body: none,
  )
}
