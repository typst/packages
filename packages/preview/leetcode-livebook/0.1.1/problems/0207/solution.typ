#import "../../helpers.typ": *

#let solution(numCourses, prerequisites) = {
  // Build adjacency list
  let adj = range(numCourses).map(_ => ())
  for prereq in prerequisites {
    let (course, prereq-course) = prereq
    adj.at(prereq-course).push(course)
  }

  // 0 = unvisited, 1 = visiting, 2 = visited
  let state = range(numCourses).map(_ => 0)

  // DFS to detect cycle
  let has-cycle = false

  let dfs(node, state) = {
    if state.at(node) == 1 {
      // Currently visiting - cycle detected
      return (true, state)
    }
    if state.at(node) == 2 {
      // Already processed
      return (false, state)
    }

    // Mark as visiting
    state.at(node) = 1

    for neighbor in adj.at(node) {
      let (cycle, new-state) = dfs(neighbor, state)
      state = new-state
      if cycle {
        return (true, state)
      }
    }

    // Mark as visited
    state.at(node) = 2
    (false, state)
  }

  for i in range(numCourses) {
    let (cycle, new-state) = dfs(i, state)
    state = new-state
    if cycle {
      return false
    }
  }

  true
}
