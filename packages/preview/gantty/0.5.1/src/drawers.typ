#import "sidebar.typ": default-sidebar-drawer
#import "field.typ": default-field-drawer
#import "header.typ": default-headers-drawer
#import "dividers.typ": default-dividers-drawer
#import "task.typ": default-tasks-drawer
#import "dependencies.typ": default-dependencies-drawer
#import "milestones.typ": default-milestones-drawer

/// The default set of drawers for a Gantt chart.
#let default-drawer = (
  sidebar: default-sidebar-drawer,
  field: default-field-drawer,
  headers: default-headers-drawer,
  dividers: default-dividers-drawer,
  tasks: default-tasks-drawer,
  dependencies: default-dependencies-drawer,
  milestones: default-milestones-drawer,
)
