#import "@preview/cvssc:0.1.1"

#cvssc.get-version("CVSS:2.0/AV:L/AC:L/Au:N/C:C/I:C/A:C")

#cvssc.get-version("CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:N")

#cvssc.get-version("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:N")

#cvssc.get-version("CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:N/VI:N/VA:N/SC:N/SI:N/SA:N")

#cvssc.v2("CVSS:2.0/AV:L/AC:L/Au:N/C:C/I:C/A:C")

#cvssc.v3("CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:N")

#cvssc.v3("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:N")

#cvssc.v3((
  version: "3.1",
  metrics: (
    "AV": "N",
    "AC": "L",
    "PR": "N",
    "UI": "N",
    "S": "U",
    "C": "N",
    "I": "N",
    "A": "N"
  )
))

#cvssc.v4("CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:N/VI:N/VA:N/SC:N/SI:N/SA:N")

#cvssc.calc((
  version: "3.1",
  metrics: (
    "AV": "N",
    "AC": "L",
    "PR": "N",
    "UI": "N",
    "S": "U",
    "C": "N",
    "I": "N",
    "A": "N"
  )
))

#cvssc.calc("CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:N/VI:N/VA:N/SC:N/SI:N/SA:N")

#cvssc.str2vec("CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:N")

#cvssc.vec2str((version: "3.0", metrics: (:)))

#cvssc.kebab-case("helloWorld")

#cvssc.kebabify-keys(
  (
    "somethingElse": "else",
    "anotherThing": "thing"
  )
)