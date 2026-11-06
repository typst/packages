// Proficiency bonus can be either found in `initiative` directly in body (very rare) or computed, if possible, by the CR.
// For CR config see `challenge-rating.typ`
// If needed I could write cr-processing so that it can return a list of str (e.g. ("3", "4")) and this processing can do the rest, e.g. make a set (remove duplicates) and add the correct bonus.

#import "../../external.typ": transl, get
#import "../process/enum.typ"
#import "../utils.typ"

#let challenge-to-proficiency(body) = {
  assert(enum.xp-proficiency.keys().contains(body), message: "Invalid challenge rating: " + str(body))

  return [#enum.xp-proficiency.at(body)]
}

#let process-proficiency(body) = {
  if not body.keys().contains("cr") { return }
  if body.cr == none { return }

  let cr = none
  if type(body.cr) == str or type(body.cr) == int {
    cr = body.cr
  }else if type(body.cr) == dictionary {
    cr = body.cr.cr
  }

  return (proc: challenge-to-proficiency(cr), amount: 1)
}