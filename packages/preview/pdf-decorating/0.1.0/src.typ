/* The Code Style of source code:
+ two spaces indent
+ kebab-case names
+ type/value convert: `-to-`, `2`, type(other-type)
+ python-like concise: `)]}` will not fill lines */

#let detail(f, x) = {
  x
  show f: y => (y,)
  x}

#let dec2hex(num) = {
  let digits = "0123456789abcdef"
  let hex = ""
  let rem = 0
  while true {
    rem = calc.rem(num, 16)
    hex = digits.at(rem) + hex
    num = calc.quo(num, 16)
    if num < 16 {
      hex = digits.at(num) + hex
      break}}
  return hex}

#let string(content) = {
  if content == none {""}
  else if type(content) == str {content}
  else if type(content) == array {content.map(string).join(", ")}
  else if content.has("text") {content.text}
  else if content.has("children") {
    if content.children.len() == 0 {""}
    else {content.children.map(string).join("")}}
  else if content.has("child") {string(content.child)}
  else if content.has("body") {string(string(content.body))}
  else if content == [] {""}
  else if content == [ ] {" "}
  else if content.func() == ref {"_ref_"}
  else {let offending = content; ""}}

#let embed-font(compose) = {
  set text(font:("Libertinus Serif", "New Computer Modern",
  "New Computer Modern Math", "DejaVu Sans Mono"))
  compose}

#let cm-link(compose) = {
  show link: x => text(blue, underline(x))
  compose}

#let cm-ref(compose) = {
  show ref: x => text(blue, underline(x))
  compose}

#let cm-quote(compose) = {
  set quote(block:true)
  show quote: x => rect(
    width:100%, stroke: (left: 0.5em + luma(240)),
    x)
  compose}

#let cm-raw(compose) = {
  show raw.where(block:false): box.with(
    inset:(x:3pt,y:0pt), outset:(y:3pt), radius:2pt,
    fill:luma(240),)
  show raw.where(block:true): x => {
    block(inset:6pt, radius:2pt,
    fill:luma(240),
    x)}
  compose}

#let common-mark(compose) = {
  show: embed-font.with()
  show: cm-link.with()
  show: cm-ref.with()
  show: cm-quote.with()
  show: cm-raw.with()
  compose}

#let gm-heading(compose) = {
  show ref: x => {
    if x.supplement != auto {
      link(x.target, x.supplement)}
    else if x.element.supplement != auto {
      link(x.target, x.element.supplement)}
    else {x}}
  show heading: x => {
    let id = lower(string(x).replace(
      regex("[^\w\d\s]"), "").trim().replace(" ", "-"))
    return [
      #rect(
        height:1em, width:100%, inset:0pt,
        stroke:(bottom:0.5pt+luma(220)),
        x.body)
      #v(-2em)
      #figure(kind:heading, supplement:x.body,
        numbering: (..nums) => numbering("1.", ..counter(heading).get()))[]
      #label(id)
      #v(1em)]}
  compose}

#let gm-table(compose) = {
  show table.cell.where(y:0): strong
  set table(
    align: (x,y) => (
      if y == 0 {center}
      else {left+horizon}),
    fill: (_,y) => if y>0 and calc.rem(y,2) == 0 {luma(250)},
    stroke: 0.5pt + luma(220))
  compose}

#let gm-task-list(compose) = {
  let f(c, n) = {
    text(c, size:1.5em, font:"DejaVu Sans Mono", str.from-unicode(n))}
  show regex("(\[\s\])|(\[\])"): f(blue, 0x2610)
  show regex("\[x\]"): f(green, 0x2611)
  show regex("[\u{2022}\u{2023}\u{2013}]"): set text(baseline:0.35em)
  show regex("[0-9]\."): set text(baseline:0.45em)
  compose}

#let github-markup(compose) = {
  show: common-mark.with()
  show: gm-heading.with()
  show: gm-table.with()
  show: gm-task-list.with()
  compose}

#let gm-alert(id, compose) = {
  let colr = (blue, olive, purple, orange, red)
  let syml = (0x2693, 0x2615, 0x2691, 0x26a0, 0x26a1).map(str.from-unicode)
  let kind = "Note Tip Important Warning Caution".split()
  if id not in range(0,5) {id = 0}
  let (c, s, k) = (colr.at(id), syml.at(id), kind.at(id))
  rect(stroke:(left: 0.2em + c))[
    #text(c, size:1.6em, font:"DejaVu Sans Mono", s)
    #text(c, k)\
    #compose]}

#let gm-alert-diy(c:green, s:emoji.parrot, k:"Do-It-Yourself", compose) = {
  rect(stroke:(left: 0.2em + c))[
    #text(c, s)
    #text(c, k)\
    #compose]}

#let gm-color-dot(c, m:"hex") = {
  box(rect(fill:luma(240))[
    #if m == "rgb" [
      rgb#[#c.components(alpha:false).map(i => int(i*2.55/1%))].text
    ] else if m == "hsl" [hsl#[#c.components(alpha:false)].text
    ] else [#c.to-hex()]
    #box(circle(radius:0.3em, fill:c))])}
