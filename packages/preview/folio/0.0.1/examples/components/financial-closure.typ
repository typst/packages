#import "@preview/folio:0.0.1": financial-closure, folio-init

#show: body => folio-init(
  data: (
    closure: (
      financial_closure: (
        final_cost: 48000.0,
        budget_baseline: 50000.0,
        variance: -2000.0,
        variance_explanation: "Lower vendor costs",
        outstanding_invoices: "None",
      ),
    ),
  ),
  body,
)

#financial-closure("closure.financial_closure")

This is a demonstration of the `financial-closure` component.
