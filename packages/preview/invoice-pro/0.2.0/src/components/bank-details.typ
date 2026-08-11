#import "../loom-wrapper.typ": loom, managed-motif
#import "../utils/types.typ"
#import "../utils/coercion.typ"

/// Defines and renders the bank account information for payments.
///
/// -> content
#let bank-details(
  /// The name of the account holder. Defaults to the sender's name.
  /// -> auto | none | string
  name: auto,

  /// The name of the banking institution.
  /// -> none | string
  bank: none,

  /// The International Bank Account Number (IBAN).
  /// -> none | string
  iban: none,

  /// The Bank Identifier Code (BIC/SWIFT).
  /// -> none | string
  bic: none,

  /// The payment reference to be used by the customer.
  /// -> auto | none | string
  reference: auto,

  /// The specific amount to be paid. If `auto`, it uses the document total.
  /// -> auto | none | decimal | float | int
  payment-amount: auto,

  /// Whether to display the reference field in the output.
  /// -> bool
  show-reference: true,

  /// Optional custom text to label the account holder field.
  /// -> auto
  account-holder-text: auto,

  /// Configuration for a payment QR code (e.g., EPC-QR).
  /// -> dictionary
  qr-code: (:),
) = {
  types.require(name, "bank-details::name", none, auto, str)
  types.require(bank, "bank-details::bank", none, str)
  types.require(iban, "bank-details::iban", none, str)
  types.require(bic, "bank-details::bic", none, str)

  types.require(reference, "bank-details::reference", none, auto, str)
  types.require(
    payment-amount,
    "bank-details::payment-amount",
    none,
    auto,
    types.decimal-like,
  )

  types.require(show-reference, "bank-details::show-reference", bool)

  if name == none { name = "" }
  if iban == none { iban = "" }
  if bank == none { bank = "" }
  if bic == none { bic = "" }
  if payment-amount == none { payment-amount = 0 }
  if payment-amount != auto {
    payment-amount = coercion.to-decimal(payment-amount)
  }

  managed-motif(
    "bank-details",
    scope: ctx => loom.mutator.batch(ctx, {
      import loom.mutator: *

      derive("sender", "name", name, default: "")
      derive("reference", reference)

      nest("theme", {
        ensure("bank-details", (..) => [Bank Details])
      })

      nest("global", {
        nest("total", {
          ensure("gross", 0)
        })
      })
    }),
    measure: (ctx, _) => {
      let data = (
        sender: (
          name: ctx.sender.name,
          bank: bank,
          iban: iban,
          bic: bic,
        ),

        qr-code: (
          size: qr-code.at("size", default: 5em),
          display: qr-code.at("display", default: true),
        ),

        reference: ctx.reference,
        show-reference: show-reference,
        payment-amount: if payment-amount == auto {
          ctx.global.total.gross
        } else {
          payment-amount
        },
      )

      (none, data)
    },
    draw: (ctx, _, view, ..) => (ctx.theme.bank-details)(ctx, view),
    none,
  )
}
