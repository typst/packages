#import "@preview/folio:0.0.1": benefits-review, folio-init

#show: body => folio-init(
  data: (
    closure: (
      benefits_review: (
        (
          objective_id: "OBJ-1",
          claimed: "Demo Benefit",
          actual: "Observed Benefit",
          variance: "0%",
        ),
      ),
    ),
    initiation: (
      objectives: ((id: "OBJ-1", description: "Demo Objective"),),
    ),
  ),
  body,
)

#benefits-review("closure.benefits_review")

This is a demonstration of the `benefits-review` component, linking to an objective.
