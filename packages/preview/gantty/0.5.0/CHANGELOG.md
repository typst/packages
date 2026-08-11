# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.5.0]

### Added

- Task dependencies under the `dependencies` field.
- Drawers API to allow complete customization of various parts of the Gantt
  chart. This decision was made because there are many different ways of drawing
  dependencies (and, in fairness, many other parts of the Gantt chart) and
  because it will integrate better with show/set rules when they are available
  for custom elements.
- The `drawers.default-drawer` dictionary containing the default drawer
- An `x` field to intervals, tasks, milestones, and dependencies: to facilitate
  adding custom descriptions for custom drawers.
- Expose the following functions under the `util` namespace: `EPSILON`, `rects-intersect`,
  `content-if-fits`, `task-anchor`, `task-anchor-line`, `task-anchor-sidebar`,
  `id-level`, `styles-for-level`, `styles-for-id`, `foreach-task`, `task-start`,
  `task-end`, `gantt-range`, `date-ratio`, `date-x-coord`, and `date-coord`.
- Ability to provide a function to change how the sidebar items are styled.
- Hide a milestone's date with `milestone.show-date`.

### Changed

- The `taskgroups` key is now `tasks`
- The `tasks` key is now `subtasks`. All tasks can have subtasks.
- Tasks are now drawn with rectangles, not lines.

### Fixed

- Poor normalization of the `today` milestone

### Removed

- The `style` key.
- The `viewport-snap` key. Specify a `start` and `end` date instead.
- Nameless tasks.
- The `show-today` and `today-localized` keys. These should be configured on the
  milestone drawer instead.

## [0.4.0]

### Added

- The `intervals` field to task to allow for specifying multiple intervals in
  which as task is valid.
- You can now manually specify interviews for a taskgroup

### Changed

- `form-well` is now called `normalize-gantt`
- The `normalize-gantt` function now parses all datetimes as well.
- Update `cetz`

### Fixed

- Certain properties on `block` and `baseline` causing messed up gridlines

## [0.3.0]

### Added

- The `today-localized` field to change the translation of "Today".
- Documented the package.
- The `create-header`, `create-custom-year-header`, `create-custom-month-header`,
  `create-custom-day-header`, and `create-custom-week-header`.
- The ability for anonymous taskgroups

## [0.2.1]

### Fixed

- Days overrunning the header.

## [0.2.0] - 2025-03-06

### Added

- Support for custom start end and dates.

### Fixed

- A floating point precision error causing milestones to fail to resolve.
- A typo in the documentation.
