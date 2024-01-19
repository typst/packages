#import "@preview/scrutinize:0.1.0": grading, question, questions
// #import "@local/scrutinize:0.1.0": grading, question, questions
// #import "../src/lib.typ" as scrutinize: grading, question, questions

// you usually want to alias this, as you'll need it often
#import question: q

// make the PDF reproducible to ease version control
#set document(date: none)

#set table(stroke: 0.5pt)

// let's show the available points to the right of each
// question's title and give the grader a space to put points
#show heading: it => {
  // here, we need to access the current question's metadata
  question.current(q => [#it.body #h(1fr) / #q.points])
}

// for grading, we need to consider all questions
#question.all(qs => [
  #let total = grading.total-points(qs)
  // the total-points function can also accept a filter function
  #let hard = grading.total-points(qs, filter: q => q.points >= 5)

  // create a grading key
  #let grades = grading.grades([bad], total * 2/4, [okay], total * 3/4, [good])

  // adjust the key to you individual needs. Here
  // - for the lowest grade, the upper limit is exclusive, we render as "< limit"
  // - for the second lowest grade, both limits are inclusive, we render as "limit - limit"
  // - for the other grades, lower limit is exclusive, upper inclusive, we render as "limit - limit"
  //   for exclusivity, we add half a point to the limit and for the highest grade we use total points
  #let grades = grades.enumerate().map(((i, grade)) => {
    let (body, lower-limit, upper-limit) = grade
    if lower-limit == none {
      (body: body, range: [< #upper-limit P.])
    } else if i == 1 {
      (body: body, range: [#(lower-limit) - #upper-limit P.])
    } else if upper-limit != none {
      (body: body, range: [#(lower-limit + 0.5) - #upper-limit P.])
    } else {
      (body: body, range: [#(lower-limit + 0.5) - #total P.])
    }
  })

  // render a table with the points
  #table(
    columns: (auto, ..(1fr,) * grades.len()),
    align: (col, row) =>
      if col == 0 { left + horizon }
      else { center + horizon },

    [Points],
    ..grades.map(g => g.range),

    [Grade],
    ..grades.map(g => g.body),
  )

  Points from hard questions: #hard
])

#locate(loc => {
  let qs = question.all(loc)
  // note that `qs` is an array, not a content!
  // but eventually, `locate()` will convert to content
  [The first question is worth #qs.first().points points!]
})

// the q function adds metadata to a question
#q(points: 6)[
  = Hard Question

  #lorem(20)
]

#v(1fr)

#question.current(q => [This question is worth #q.points points.])

#locate(loc => {
  let points = question.current(loc).points
  // note that `points` is an integer, not a content!
  let points-with-extra = points + 1
  // but eventually, `locate()` will convert to content
  [I may award up to #points-with-extra points for great answers!]
})

#q(points: 2)[
  = Question

  #lorem(20)
]

#v(1fr)
