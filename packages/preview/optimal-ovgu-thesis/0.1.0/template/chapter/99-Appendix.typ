#counter(heading).update(0)
#set heading(numbering: (..nums) => {
  let vals = nums.pos()
  let value = "ABCDEFGHIJ".at(vals.at(0) - 1)
  if vals.len() == 1 {
    return "Appendix " + value
  } else {
    return value + "." + nums.pos().slice(1).map(str).join(".")
  }
})

=

== Lorem <appendix_lorem>
