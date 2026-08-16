#import "@preview/folio:0.0.1": card, project-doc

#let pricing-annex(data-path) = context {
  heading(level: 2)[Pricing Annex]
  card[
    This section is a custom injection demonstrating folio's extensibility.
    The pricing details below are pulled from `#data-path`.
  ]
  [Detailed pricing table would go here.]
}

#let rfp-data = (
  project: (
    name: "Enterprise ERP Migration",
    description: "RFP Response for Global Logistics Corp",
  ),
  initiation: (
    pitch: "Transition legacy SAP instances to a unified cloud-native platform.",
    business_case: "Estimated 25% reduction in TCO and 15% increase in throughput.",
  ),
  baselines: (
    financials: (
      budget: (
        (description: "Phase 1: Discovery", amount: 250000),
        (description: "Phase 2: Migration", amount: 1250000),
      ),
    ),
  ),
  custom: (
    pricing: (
      tier: "Enterprise",
      valid_until: "2026-12-31",
    ),
  ),
)

#show: project-doc(
  data: rfp-data,
  config: (
    extra-sections: (
      (
        id: "pricing-annex",
        phase: "custom",
        after: "budget",
        data-path: "custom.pricing",
        render: pricing-annex,
      ),
    ),
  ),
)
