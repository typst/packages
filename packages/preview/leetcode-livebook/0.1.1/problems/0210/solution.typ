#import "../../helpers.typ": *

#let solution(numCourses, prerequisites) = {
  // Build adjacency list and in-degree array
  let adj = range(numCourses).map(_ => ())
  let in-degree = fill(0, numCourses)

  for prereq in prerequisites {
    let (course, prereq-course) = prereq
    adj.at(prereq-course).push(course)
    in-degree.at(course) += 1
  }

  // Kahn's algorithm: start with nodes with in-degree 0
  let queue = ()
  for i in range(numCourses) {
    if in-degree.at(i) == 0 {
      queue.push(i)
    }
  }

  let result = ()
  let qh = 0

  while qh < queue.len() {
    let node = queue.at(qh)
    qh += 1
    result.push(node)

    for neighbor in adj.at(node) {
      in-degree.at(neighbor) -= 1
      if in-degree.at(neighbor) == 0 {
        queue.push(neighbor)
      }
    }
  }

  // If we processed all courses, return result; otherwise cycle exists
  if result.len() == numCourses {
    result
  } else {
    ()
  }
}
