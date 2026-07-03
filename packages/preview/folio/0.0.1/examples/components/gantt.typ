#import "@preview/folio:0.0.1": folio-init, gantt

#show: body => folio-init(
  data: (
    baselines: (
      schedule: (
        gantt: (
          start: "2026-01-01",
          end: "2026-02-15",
          tasks: (
            (
              name: "Phase 1: Research",
              subtasks: (
                (
                  id: "T1",
                  name: "User Interviews",
                  start: "2026-01-01",
                  end: "2026-01-15",
                ),
                (
                  id: "T2",
                  name: "Market Analysis",
                  start: "2026-01-10",
                  end: "2026-01-25",
                ),
              ),
            ),
            (
              name: "Phase 2: Design",
              subtasks: (
                (
                  id: "T3",
                  name: "Wireframing",
                  start: "2026-01-25",
                  end: "2026-02-05",
                ),
                (
                  id: "T4",
                  name: "Prototyping",
                  start: "2026-02-01",
                  end: "2026-02-15",
                ),
              ),
            ),
          ),
          milestones: (
            (name: "Research Complete", date: "2026-01-25", show-date: true),
            (name: "Design Freeze", date: "2026-02-15", show-date: true),
          ),
        ),
      ),
    ),
  ),
  body,
)

#gantt("baselines.schedule.gantt")

This is a demonstration of the `gantt` component using the enhanced visual rendering mode (via `gantty`). It automatically switches to this mode when a dictionary with `start`, `end`, and `tasks` is provided instead of a flat array.
