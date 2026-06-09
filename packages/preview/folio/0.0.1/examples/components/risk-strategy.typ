#import "@preview/folio:0.0.1": folio-init, risk-strategy

#show: body => folio-init(
  data: (
    baselines: (
      risk_strategy: (
        approach: "Demo Approach",
        categories: ("Technical", "External"),
        scoring: "3x3",
        tolerance: "Low",
      ),
    ),
  ),
  body,
)

#risk-strategy("baselines.risk_strategy")

This is a demonstration of the `risk-strategy` component.
