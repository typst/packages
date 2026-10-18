#import "line-items.typ": render-line-items
#import "bank-details.typ": render-bank-details
#import "payment-goal.typ": render-payment-goal
#import "signature.typ": render-signature

#let base-theme(
  /// Document Root Styling.
  /// -> (ctx, content) => content
  document: (ctx, body) => body,

  /// Header that will be evaluted by the weave loop and then by appled to the
  /// document. Can include motifs/active items.
  /// -> content
  header: [],
  /// Footer that will be evaluted by the weave loop and then by appled to the
  /// document. Can include motifs/active items.
  /// -> content
  footer: [],

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
    document: document,
    header: header,
    footer: footer,
    line-items: line-items,
    bank-details: bank-details,
    payment-goal: payment-goal,
    signature: signature,
  )
}
