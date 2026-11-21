#import "@zandies/rt-sched:0.0.1": *
#let taskset = (
  (c: 1, d: 5, t: 5),
  (c: 2, d: 4, t: 4),
)
// #{
//   config.colors = (gray.lighten(50%),)
// }
#let a = {
  let taskset = (
    (c: 1, d: 5, t: 5),
    (c: 2, d: 4, t: 4),
  )

  { config.colors = (red.lighten(40%), green.lighten(40%)) }

  plot(from: 0, to: 20, tasks: taskset, scheduler: scheduler.rm, config: config)

  // $tau_2 succ tau_1 "(Rate Monotonic)"$
  // plot(
  //   from: 0,
  //   to: 20,
  //   tasks: taskset,
  //   scheduler: scheduler.rm,
  //   config: config,
  //   display-idle: true,
  // )
}
#context {
  let (width: wi, height: he) = measure(a)
  set page(width: wi + 30pt, height: he + 30pt, margin: (x: 0pt, y: 0pt))
  align(horizon + center, box(align(left, a)))
}
