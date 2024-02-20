#import "main.typ" as cvss;

```typ
#cvss.parse("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:H")
```
#block(
  breakable: false,
  inset: 0.5em,
  stroke: 1pt + black,
  radius: 0.25em,
  width: 100%,
  fill: gray.lighten(50%),
  [#cvss.parse("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:H")]
)
```typ
#cvss.score("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:H")
```
#block(
  breakable: false,
  inset: 0.5em,
  stroke: 1pt + black,
  radius: 0.25em,
  width: 100%,
  fill: gray.lighten(50%),
  [#cvss.score("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:H")]
)
```typ
#cvss.severity("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:H")
```
#block(
  breakable: false,
  inset: 0.5em,
  stroke: 1pt + black,
  radius: 0.25em,
  width: 100%,
  fill: gray.lighten(50%),
  [#cvss.severity("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:H")]
)
```typ
#cvss.metrics("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:H")
```
#block(
  breakable: false,
  inset: 0.5em,
  stroke: 1pt + black,
  radius: 0.25em,
  width: 100%,
  fill: gray.lighten(50%),
  [#cvss.metrics("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:H")]
)
```typ
#cvss.verify("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:H")
#cvss.verify("CVS  S:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:H")
```
#block(
  breakable: false,
  inset: 0.5em,
  stroke: 1pt + black,
  radius: 0.25em,
  width: 100%,
  fill: gray.lighten(50%),
  [#cvss.verify("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:H") \
  #cvss.verify("CVS  S:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:H")]
)
```typ
#cvss.NONE
#cvss.LOW
#cvss.MEDIUM
#cvss.HIGH
#cvss.CRITICAL
#cvss.re
```
#block(
  breakable: false,
  inset: 0.5em,
  stroke: 1pt + black,
  radius: 0.25em,
  width: 100%,
  fill: gray.lighten(50%),
  [
    #cvss.NONE \
    #cvss.LOW \ 
    #cvss.MEDIUM \
    #cvss.HIGH \
    #cvss.CRITICAL \
    #cvss.re
  ]
)
