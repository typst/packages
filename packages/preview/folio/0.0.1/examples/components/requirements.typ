#import "@preview/folio:0.0.1": folio-init, requirements

#show: body => folio-init(
  data: (
    baselines: (
      requirements: (
        (
          id: "REQ-01",
          description: "Standard Workstation",
          category: "Hardware",
          priority: "high",
          qty: 5,
          unit: "units",
          unit_cost: 2000,
        ),
        (
          id: "REQ-02",
          description: "Color Printer",
          category: "Hardware",
          priority: "medium",
          qty: 1,
          unit: "units",
          unit_cost: 500,
        ),
        (
          id: "REQ-03",
          description: "Design Suite",
          category: "Software",
          priority: "high",
          qty: 5,
          unit: "licenses",
          unit_cost: 800,
        ),
      ),
    ),
  ),
  body,
)

#requirements("baselines.requirements")

This is a demonstration of the `requirements` component with category grouping and subtotals.
