#let is-task-synchronous(task) = {
  if (task.keys().contains("o") and task.at("o") > 0) { return false }
  return true
}

#let is-task-asynchronous(task) = {
  return not is-task-synchronous(task)
}

#let is-synchronous(tasks) = {
  for task in tasks { if (task.keys().contains("o")) { if task.o != 0 { return false } } }
  return true
}

#let is-implicit(tasks) = {
  for task in tasks { if task.d != task.t { return false } }
  return true
}

#let is-constrained(tasks) = {
  for task in tasks { if task.d > task.t { return false } }
  return true
}

#let is-arbitrary(tasks) = {
  return not is-constrained(tasks)
}

#let utilization(tasks) = {
  tasks.map(task => task.c / task.t).sum()
}

#let hyperperiod(tasks) = {
  let res = tasks.first().t
  for (i, task) in tasks.enumerate() {
    if (i != 0) {
      res = calc.lcm(res, task.t)
    }
  }
  res
}
