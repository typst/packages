#import "utils.typ": check-keys

#let check-committee-info(author-info) = {
  let expected-keys = ("chair", "first-evaluator", "second-evaluator")
  check-keys("check-author-info", expected-keys, author-info)
}

#let check-committee-info-thesis(author-info) = {
  let expected-keys = ("examiner", "supervisor")
  check-keys("check-author-info", expected-keys, author-info)
}
