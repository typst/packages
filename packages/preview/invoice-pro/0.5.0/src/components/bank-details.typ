#import "../loom-wrapper.typ": loom, managed-motif
#import "../utils/types.typ"
#import "../utils/coercion.typ"
#import "../utils/bic.typ": normalize-bic
#import "../utils/iban.typ": format-iban, iban-valid, normalize-iban
#import "../logic/epc.typ"
#import "../logic/payment-reference.typ": resolve-remittance
#import "../logic/document-type.typ": sender-pays
#import "../logic/payment-means.typ": (
  of-context, report-problems, transfer-requested,
)
#import "../logic/currency.typ": currency-code

// What the root context holds for a sender or recipient without a name.
#let _is-missing(value) = (
  value in (none, "", [])
    or (
      type(value) == str
        and (value.starts-with("#sender.") or value.starts-with("#recipient."))
    )
)

/// Defines and renders the bank account information for payments.
///
/// The payment reference is resolved in this order: the `reference` or `text`
/// argument, the invoice's `payment-reference`, the `invoice-nr`. The resolved
/// value is printed, encoded in the EPC-QR code and written to the ZUGFeRD XML
/// (BT-83).
///
/// -> content
#let bank-details(
  /// The name of the account holder. Defaults to the name of the `payee` of
  /// the invoice (not on a credit note, which refunds the buyer), else the
  /// sender's name on one line, as in the e-invoice (BT-59, BT-27), or the
  /// recipient's on a credit note or a self-billed invoice, which the sender
  /// pays. A name given here is also the account name of the e-invoice
  /// (BT-85).
  /// -> auto | none | string
  name: auto,

  /// The name of the banking institution.
  /// -> none | string
  bank: none,

  /// The International Bank Account Number (IBAN), with or without spaces.
  /// Required: a missing or invalid IBAN (structure or check digits) stops
  /// the compilation, unless an e-invoice reports its problems in the
  /// document (`zugferd-errors: "report"`).
  /// -> none | string
  iban: none,

  /// The Bank Identifier Code (BIC/SWIFT). If omitted or `none`, the BIC is not displayed in the bank details block.
  /// -> none | string
  bic: none,

  /// The structured payment reference to be used by the customer.
  /// If `auto`, falls back to the invoice's `payment-reference` (as
  /// unstructured text) and then to the `invoice-nr`. `none` omits it.
  /// -> auto | none | string
  reference: auto,

  /// The unstructured payment reference text to be used by the customer.
  /// Takes precedence over the invoice's `payment-reference` and `invoice-nr`.
  /// -> none | string
  text: none,

  /// The specific amount to be paid. If `auto`, it uses the document total.
  /// -> auto | none | decimal | float | int
  payment-amount: auto,

  /// Whether to display the reference field in the output.
  /// -> bool
  show-reference: true,

  /// Optional custom text to label the account holder field.
  /// -> auto
  account-holder-text: auto,

  /// Configuration for a payment QR code (e.g., EPC-QR). By default, the
  /// code is shown only when the amount is paid by credit transfer: not
  /// with a `direct-debit` or a `card-payment`, and not on a `paid` invoice.
  /// -> dictionary
  qr-code: (:),
) = {
  types.require(name, "bank-details::name", none, auto, str)
  types.require(bank, "bank-details::bank", none, str)
  types.require(iban, "bank-details::iban", none, str)
  types.require(bic, "bank-details::bic", none, str)

  types.require(reference, "bank-details::reference", none, auto, str)
  types.require(text, "bank-details::text", none, str)
  types.require(
    payment-amount,
    "bank-details::payment-amount",
    none,
    auto,
    types.decimal-like,
  )

  types.require(show-reference, "bank-details::show-reference", bool)

  assert(
    (reference == auto or reference == none) or text == none,
    message: "Cannot specify both 'reference' and 'text'. Use one or the other.",
  )

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

      let remittance = resolve-remittance(
        ctx,
        reference: reference,
        text: text,
      )
      put("reference", remittance.reference)
      put("text", remittance.text)

      nest("theme", {
        ensure("bank-details", (..) => panic(
          "theme::bank-details is not provided",
        ))
      })

      nest("global", {
        nest("total", {
          ensure("gross", 0)
        })
      })
    }),
    measure: (ctx, _) => {
      // The root context collects the payment means of the body; inside the
      // line items, the bank details would be printed but not stated.
      let _ = loom.guards.assert-not-inside(ctx, "line-items")
      // The IBAN is checked here, independently of the theme, so that an
      // invalid one never ends up on an invoice unnoticed.
      let electronic-iban = normalize-iban(iban)
      let valid-iban = iban-valid(electronic-iban)
      // With an e-invoice and `zugferd-errors: "report"`, problems are shown
      // in the document instead of stopping the compilation.
      let report = report-problems(ctx)
      if not valid-iban and not report {
        panic(
          if electronic-iban == "" {
            "bank-details: the IBAN is missing. Set `iban` on `bank-details`."
          } else {
            (
              "bank-details: the IBAN \""
                + format-iban(electronic-iban)
                + "\" is not valid (wrong check digits or format). Check it for typos."
            )
          },
        )
      }

      // On a credit note or a self-billed invoice, the sender pays the
      // amount to the recipient, so the bank details are the recipient's
      // account, and the recipient scans no EPC-QR code.
      let document = ctx.at("document-type", default: none)
      let recipient-account = sender-pays(document)

      // The account holder: the explicit `name`, else the name on one line
      // of whom the amount is paid to: the payee (BG-10, e.g. a factoring
      // company that receives the payment instead of the seller) of what
      // the buyer pays, also on a self-billed invoice, but not of a credit
      // note, which refunds the buyer; else the sender (as in the e-invoice,
      // BT-27), or the recipient for the recipient's account.
      let credit = (
        type(document) == dictionary and document.at("credit", default: false)
      )
      let holder = ctx.sender.name
      if name == auto {
        let payee = ctx.at("payee", default: none)
        let payee-name = if type(payee) == dictionary and not credit {
          payee.at("name", default: none)
        }
        if not _is-missing(payee-name) {
          holder = if type(payee-name) == array {
            payee-name.join(", ")
          } else { payee-name }
        } else {
          let party = if recipient-account { ctx.recipient } else {
            ctx.sender
          }
          if recipient-account { holder = party.name }
          let inline = party.at("name-inline", default: none)
          if not _is-missing(inline) { holder = inline }
        }
      }

      let electronic-bic = normalize-bic(bic)
      let amount = if payment-amount == auto {
        ctx.global.total.at("due", default: ctx.global.total.gross)
      } else {
        payment-amount
      }

      // The EPC-QR code is only generated when it is shown. SEPA credit
      // transfers are in euro, so it is shown for invoices in EUR only. It
      // asks the buyer to transfer the amount, so by default it is left out
      // when the amount is collected otherwise or paid already, and on the
      // recipient's account.
      let qr-display = qr-code.at(
        "display",
        default: not recipient-account and transfer-requested(of-context(ctx)),
      )
      let epc-code = if qr-display and currency-code(ctx.locale) == "EUR" {
        epc.qr-code(
          holder,
          electronic-iban,
          bic: electronic-bic,
          reference: ctx.reference,
          text: ctx.text,
          amount: amount,
        )
      } else {
        (payload: none, problems: ())
      }

      // The view of the theme layout (`theme.bank-details`), with every value
      // ready to print, so the layout only draws (see "Data for Custom
      // Layouts" in docs/docs/api-reference/theme.md):
      // - `sender`: `name` (the account holder), `bank`, `iban` and `bic` in
      //   electronic format (`""` if not given) and `iban-valid`, which is
      //   only `false` with `report-problems`.
      // - `qr-code`: `size` and `display` as given, and the EPC-QR code as
      //   its `payload` (see `epc.qr-code`; `none` if no code is generated)
      //   or the `problems` that prevent it (only with `report-problems`,
      //   otherwise `draw` stops; the layout shows a placeholder).
      // - `reference` or `text` (the resolved payment reference),
      //   `show-reference`, `report-problems` and `payment-amount`.
      let data = (
        sender: (
          name: holder,
          bank: bank,
          iban: electronic-iban,
          iban-valid: valid-iban,
          bic: electronic-bic,
        ),

        qr-code: (
          size: qr-code.at("size", default: 5em),
          display: qr-display,
          payload: epc-code.payload,
          problems: epc-code.problems,
        ),

        reference: ctx.reference,
        text: ctx.text,
        show-reference: show-reference,
        report-problems: report,
        payment-amount: amount,
      )

      // Expose IBAN/BIC/reference as a public signal so root can embed them in ZUGFeRD XML.
      // The account name (BT-85) only if it is given: the default holder is
      // the payee or the seller, whom the e-invoice names already (BT-59,
      // BT-27).
      let public = (
        iban: iban,
        bic: bic,
        account-name: if name not in (auto, "") { name },
        reference: ctx.reference,
        text: ctx.text,
        payment-amount: data.payment-amount,
      )

      (public, data)
    },
    draw: (ctx, _, view, ..) => {
      // An EPC-QR code that cannot be generated stops the compilation, unless
      // an e-invoice reports its problems in the document, where the theme
      // shows a placeholder naming them. It stops while drawing, not while
      // measuring, so that the errors of components drawn before the bank
      // details are reported first.
      let problems = view.qr-code.problems
      if problems.len() > 0 and not view.report-problems {
        panic(
          "bank-details: the EPC-QR code cannot be generated: "
            + problems.map(problem => problem.message).join("; ")
            + ". Hide it with `qr-code: (display: false)` on `bank-details` if it is not needed.",
        )
      }
      (ctx.theme.bank-details)(ctx, view)
    },
    none,
  )
}
