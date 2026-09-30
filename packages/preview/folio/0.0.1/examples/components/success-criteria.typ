#import "@preview/folio:0.0.1": folio-init, success-criteria

#show: body => folio-init(
  data: (
    initiation: (
      objectives: (
        (id: "OBJ-1", description: "Demo Objective", priority: "high"),
      ),
      success_criteria: (
        (
          id: "SC-1",
          type: "project",
          criterion: "Demo Criterion",
          measurement: "Test",
          target: "Success",
          objective_id: "OBJ-1",
        ),
      ),
    ),
  ),
  body,
)

#success-criteria("initiation.success_criteria")

This is a demonstration of the `success-criteria` component. It includes a cross-reference to an objective.
