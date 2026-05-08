// Fixture: partial-data.typ
// Some sections populated, others missing. Audit should show gaps.
// Tests graceful degradation: some phases render, others are omitted.
#import "@preview/folio:0.0.1": project-doc

#show: project-doc(
  data: (
    project: (
      name: "Partial Data Project",
      description: "Only initiation and basic planning populated.",
    ),
    initiation: (
      pitch: "A project with incomplete data to test graceful degradation.",
      business_case: "Validates that folio handles partial schemas correctly.",
      objectives: (
        (
          id: "OBJ-1",
          description: "Demonstrate partial rendering",
          priority: "high",
        ),
        (
          id: "OBJ-2",
          description: "Verify audit catches gaps",
          priority: "neutral",
        ),
      ),
    ),
    baselines: (
      scope: (
        in_scope: ("Partial data handling", "Audit coverage"),
        out_of_scope: ("Full data rendering",),
      ),
      schedule: (
        milestones: (
          (
            id: "M1",
            date: "2026-06-01",
            title: "Partial Test Complete",
            status: "Pending",
          ),
        ),
      ),
    ),
    governance: (
      team: (
        (role: "Tester", name: "Jane Doe", email: "jane@test.dev"),
      ),
    ),
    // NOTE: No execution, registers, or closure sections — audit should flag these.
  ),
  config: (
    audit: true,
    toc: true,
  ),
)
