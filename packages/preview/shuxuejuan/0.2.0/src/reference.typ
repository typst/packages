#import "question.typ": *

#let sxj-ref-to-question(
  ref-style: auto,
  counter-with-acc-to-nums: auto,
  it,
) = {
  let counter-here = counter-question.get()
  // Note: use `query` as a workaround because currently
  //   `counter-question.at(it.target)` can't get the actual counter.
  let counter-there = query(
    selector(<sxj-label-question>).after(it.target),
  )
    .first()
    .value
    .counter-question
  let ct-here = counter-here.slice(2, counter-here.at(1) * 2 + 2)
  let ct-there = counter-there.slice(2, counter-there.at(1) * 2 + 2)
  if ct-here.len() < ct-there.len() {
    ct-here += (0,) * (ct-there.len() - ct-here.len())
  } else {
    ct-there += (0,) * (ct-here.len() - ct-there.len())
  }

  let ref-style = if ref-style == auto { env-get("ref-style") } else { ref-style }
  let counter-with-acc-to-nums = if counter-with-acc-to-nums == auto {
    env-get("fn-number")
  } else { counter-with-acc-to-nums }
  let nums = sxj-numbering-numbers(counter-with-acc-to-nums(counter-there))

  let body = if ref-style == 0 {
    let idx-diff = ct-here
      .chunks(2, exact: true)
      .zip(ct-there.chunks(2, exact: true))
      .position(((idx-here, idx-there)) => idx-here != idx-there)
    let idx-diff = if idx-diff in (none, nums.len()) { -1 } else { idx-diff }
    nums.slice(idx-diff).join()
  } else if type(ref-style) == int and ref-style > 0 {
    let len = calc.min(ref-style, nums.len())
    nums.slice(-len).join()
  } else {
    nums.join()
  }
  link(it.target, body)
}
