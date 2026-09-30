#import "question.typ": QUESTION_MC, QUESTION_TF, QUESTION_SA, QUESTION_WRITTEN

#let validate-question(q, mode: "strict") = {
  if type(q) != dictionary { panic("sang-math: question must be a dictionary") }
  let id = q.at("id", default: none)
  let label = if id == none { "unnamed question" } else { "question " + str(id) }
  let fail(message) = panic("sang-math: " + label + ": " + message)
  if not ("strict", "legacy-compatible").contains(mode) {
    fail("validation mode must be strict or legacy-compatible")
  }
  let kind = q.at("kind", default: none)
  if not (QUESTION_MC, QUESTION_TF, QUESTION_SA, QUESTION_WRITTEN).contains(kind) {
    fail("unsupported kind " + repr(kind))
  }
  if mode == "legacy-compatible" { return q }
  if q.at("prompt", default: none) == none { fail("prompt is required") }
  let choices = q.at("choices", default: ())
  if type(choices) != array { fail("choices must be an array") }
  if type(q.at("metadata", default: (:))) != dictionary { fail("metadata must be a dictionary") }
  let tags = q.at("tags", default: ())
  if type(tags) != array or tags.any(tag => type(tag) != str) { fail("tags must be an array of strings") }
  let points = q.at("points", default: none)
  if points != none and (type(points) != int and type(points) != float or points < 0) {
    fail("points must be a non-negative number")
  }
  let difficulty = q.at("difficulty", default: none)
  if difficulty != none and (type(difficulty) != int or difficulty < 1 or difficulty > 5) {
    fail("difficulty must be an integer from 1 to 5")
  }
  let estimated-time = q.at("estimated-time", default: none)
  if estimated-time != none and (type(estimated-time) != int or estimated-time < 0) {
    fail("estimated-time must be a non-negative number of seconds")
  }
  let answer = q.at("answer", default: none)
  if type(answer) == dictionary and answer.at("kind", default: none) == "numeric" {
    if not (int, float).contains(type(answer.at("value", default: none))) {
      fail("numeric answer value must be a number")
    }
    let tolerance = answer.at("tolerance", default: none)
    if tolerance != none and (not (int, float).contains(type(tolerance)) or tolerance < 0) {
      fail("numeric answer tolerance must be non-negative")
    }
  }
  if (QUESTION_MC, QUESTION_TF).contains(kind) {
    if choices.len() == 0 { fail("choices cannot be empty") }
    for item in choices {
      if type(item) != dictionary or not "content" in item or type(item.at("correct", default: false)) != bool {
        fail("each choice needs content and a boolean correct flag")
      }
      if type(item.at("metadata", default: (:))) != dictionary { fail("choice metadata must be a dictionary") }
    }
  }
  if kind == QUESTION_MC {
    if choices.len() > 6 { fail("mcq currently supports at most six choices") }
    let correct-count = choices.filter(item => item.correct).len()
    if correct-count > 1 { fail("mcq has more than one correct choice") }
    let ans = q.at("answer", default: none)
    if correct-count == 0 and not (type(ans) == dictionary and ans.at("kind", default: none) == "choice") {
      fail("mcq needs one correct choice or a typed choice answer")
    }
    if type(ans) == dictionary and ans.at("kind", default: none) == "choice" {
      let index = ans.at("value", default: none)
      if type(index) != int or index < 1 or index > choices.len() {
        fail("answer index " + str(index) + " is invalid because this question has " + str(choices.len()) + " choices")
      }
      if correct-count == 1 and not choices.at(index - 1).correct {
        fail("answer index conflicts with the marked correct choice")
      }
    }
  }
  if kind == QUESTION_TF {
    if choices.len() > 6 { fail("true-false currently supports at most six statements") }
    let ans = q.at("answer", default: none)
    if type(ans) == array and (ans.len() != choices.len() or ans.any(value => type(value) != bool)) {
      fail("true-false answer must contain one boolean per statement")
    }
    if type(ans) == array and choices.any(item => item.correct) and choices.enumerate().any(((i, item)) => item.correct != ans.at(i)) {
      fail("true-false answer conflicts with marked statements")
    }
  }
  q
}
