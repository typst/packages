#import "@preview/folio:0.0.1": budget, folio-init

#show: body => folio-init(
  data: (
    baselines: (
      financials: (
        budget: (
          line_items: (
            (
              id: "B1",
              description: "Design Software",
              category: "Software",
              qty: 2,
              unit: "licenses",
              unit_cost: 500,
            ),
            (
              id: "B2",
              description: "Workstations",
              category: "Hardware",
              qty: 3,
              unit: "units",
              unit_cost: 2500,
            ),
            (
              id: "B3",
              description: "Initial Setup",
              category: "Services",
              qty: 1,
              unit: "lump sum",
              unit_cost: 1500,
            ),
          ),
          extra_costs: (
            (description: "Contingency (10%)", percentage: 0.1),
            (description: "Fixed Buffer", cost: 1000),
          ),
        ),
      ),
    ),
  ),
  body,
)

#budget("baselines.financials.budget")

This is a demonstration of the `budget` component using the enhanced rich data mode. It supports category grouping, quantity/unit-cost breakdown, and both absolute and percentage-based extra costs.
