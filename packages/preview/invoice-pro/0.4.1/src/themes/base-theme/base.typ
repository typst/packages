#import "line-items.typ": *
#import "bank-details.typ": render-bank-details
#import "payment-goal.typ": render-payment-goal
#import "signature.typ": render-signature

#import "../../loom-wrapper.typ": eval-content

#let base-theme(
  /// Document Root Styling.
  /// -> (ctx, content) => content
  document: (ctx, body) => body,
  /// Header that will be evaluted by the weave loop and then by appled to the
  /// document. Can include motifs/active items.
  /// -> content
  header: none,
  /// Footer that will be evaluted by the weave loop and then by appled to the
  /// document. Can include motifs/active items.
  /// -> content
  footer: none,
  /// Layout of the aggregated line item data.
  /// -> (ctx, dictionary, content) => content
  line-items: render-line-items,
  /// Layout of the bank-details the customer should send the payment to.
  /// -> (ctx, dictionary) => content
  bank-details: render-bank-details,
  /// Layout of the payment-goal. Time until payment is due.
  /// -> (ctx, dictionary) => content
  payment-goal: render-payment-goal,
  /// Layout of the signature.
  /// -> (ctx, dictionary) => content
  signature: render-signature,
) = {
  (
    document: (ctx, body) => {
      if header != none and header != [] {
        set page(header: eval-content(ctx, header))
      }
      if footer != none and footer != [] {
        set page(footer: eval-content(ctx, footer))
      }
      document(ctx, body)
    },
    header: header,
    footer: footer,
    line-items: line-items,
    bank-details: bank-details,
    payment-goal: payment-goal,
    signature: signature,
  )
}
