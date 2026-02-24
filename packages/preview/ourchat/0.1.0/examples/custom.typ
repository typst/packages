#import "../src/lib.typ" as oc: default-profile

#set page(width: auto, height: auto, margin: 1em, fill: none)

#oc.chat(
  theme: "dark",
  oc.message(left, name: [AAA], profile: default-profile)[
    *strong* _emph_
  ],
  oc.message(right, name: [bbb], profile: default-profile)[
    $lambda f. (lambda x. f (x x)) (lambda x. f (x x))$
  ],
  oc.message(left, name: [wasd], profile: default-profile)[
    #rect(width: 1em, height: 1em, fill: blue)
  ],
  oc.plain(right, name: [qwer], profile: default-profile)[
    #rect(width: 3em, height: 4em, fill: blue)
  ],
  oc.plain(left, name: [qwer], profile: default-profile)[
    #rect(width: 5em, height: 4em, fill: orange)
  ],
)
