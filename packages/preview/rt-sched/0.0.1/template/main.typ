#import "../src/lib.typ": *
#set page(margin: (x: 4em, y: 5em))

= Rate Monotonic (RM)

#let taskset = (
  (c: 2, d: 8, t: 8),
  (c: 3, d: 11, t: 11),
  (c: 5, d: 15, t: 15),
)

#print-taskset(taskset)

#let config = (
  task_height: 0.8cm,
  step_width: 2em,
  colors: (gray.lighten(80%),),
)

#plot(from: 0, to: 15, tasks: taskset, scheduler: scheduler.dm, config: config)

= Arbitrary deadline system

#let taskset = (
  (c: 52, d: 110, t: 100),
  (c: 52, d: 154, t: 140),
)

#print-taskset(taskset)

#let config = (
  task_height: 0.8cm,
  step_width: 0.28em,
  colors: (gray.lighten(80%),),
)

#plot(from: 0, to: 160, step: 50, tasks: taskset, scheduler: scheduler.dm, config: config)


= Asynchronous system

#let taskset = (
  (c: 7, d: 10, t: 10),
  (c: 1, d: 16, t: 16),
  (o: 4, c: 3, d: 15, t: 15),
)

#print-taskset(taskset)

#let config = (
  task_height: 0.8cm,
  step_width: 0.3em,
  colors: (gray.lighten(80%),),
)

#plot(from: 0, to: 150, step: 50, tasks: taskset, scheduler: scheduler.priority_assignement, config: config)


= Earliest Deadline First (EDF)

#let taskset = (
  (c: 2, d: 4, t: 4),
  (c: 3, d: 7, t: 7),
)

#print-taskset(taskset)

#let config = (
  task_height: 0.8cm,
  step_width: 1.5em,
  colors: (gray.lighten(80%),),
)

#plot(from: 0, to: 27, tasks: taskset, scheduler: scheduler.edf, config: config)


= Least Laxity First (LLF)

#let config = (
  task_height: 0.8cm,
  step_width: 2em,
  colors: (gray.lighten(80%),),
)

#let taskset = (
  (c: 4, d: 8, t: 10),
  (c: 5, d: 9, t: 10),
)
#print-taskset(taskset)

#plot(from: 0, to: 8, tasks: taskset, scheduler: scheduler.llf, config: config)
#plot(from: 0, to: 8, tasks: taskset, scheduler: scheduler.edf, config: config)
