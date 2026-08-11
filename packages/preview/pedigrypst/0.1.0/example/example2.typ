#import "@preview/pedigrypst:0.1.0" as pedigrypst: pedigree

#set page(height: auto, width: 4in)

I'm my own grandpa!

// Tree from https://en.wikipedia.org/wiki/File:Im_my_own_grandpa_family_tree.svg

#pedigree(length: 2cm, generation-labels: false, {
  import pedigrypst: *
  duplicate(1, "i3-2", bezier: -1.5)
  individual(1, 2, "female", label: [Widow])
  individual(1, 3, "male", label: none)
  individual(2, 1, "male", label: [Son])
  individual(2, 2, "female", label: [Stepdaughter])
  individual(2, 3, "male", label: [Father])
  individual(2, 4, "female", label: none)
  individual(3, 1, "male", label: [Stepgrandson])
  individual(3, 2, "male", label: [Narrator])

  union("d1", "i1-2")
  union("i1-2", "i1-3")
  union("i2-2", "i2-3")
  union("i2-3", "i2-4")

  children("u1", "i2-1")
  children("u2", "i2-2")
  children("u3", "i3-1")
  children("u4", "i3-2")
})
