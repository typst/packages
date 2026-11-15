/**
 * running_jobs is an array of the following structure:
  (
    task_id: task_id,
    task: (
      o: int,
      c: int,
      d: int,
      t: int,
    ),
    release: t,
    deadline: t + task.d,
    remaining_computation: task.c,
  )
**/

// Index-based priority (sorted by task-id)
#let priority_assignement(running_jobs, t) = {
  return running_jobs.sorted(key: it => it.task_id)
}

// Index-based priority (sorted by task-id)
#let reversed_priority_assignement(running_jobs, t) = {
  return running_jobs.sorted(key: it => it.task_id).rev()
}

// Rate-Monotonic scheduler (FTP)
#let rm(running_jobs, t) = {
  return running_jobs.sorted(key: it => it.task.t)
}

// Deadline-Monotonic scheduler (FTP)
#let dm(running_jobs, t) = {
  return running_jobs.sorted(key: it => it.task.d)
}

// Earliest Deadline First scheduler (FJP)
#let edf(running_jobs, t) = {
  return running_jobs.sorted(key: it => it.deadline)
}

// Least Laxity First scheduler (DP)
#let llf(running_jobs, t) = {
  running_jobs
    // first sort by task id (the ties are resolved by taking the
    // task with the lowest index)
    .sorted(key: job => {
      job.task_id
    })
    // then sort by smallest laxity
    .sorted(key: job => {
      job.deadline - t - (job.remaining_computation)
    })
}
