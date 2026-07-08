/// Displaying package information and the page's dimensions

#let tschich-help = context {
  align(center)[ #box(stroke: (0.5pt + black), inset: 0.75em)[
    #text(size: 8em/11)[#sym.chevron.l *tschich v.0.2.0* #sym.chevron.r --- To set up the margins use:] \
    #box(stroke: (0.25pt + black), inset: 0.5em)[
      `#set page(margin: tschich(a, b))`] #v(1em, weak: true)
    $a = #page.width.mm()$ mm #h(2em) $b = #page.height.mm()$ mm #v(1.5em, weak: true) 
    #text(size: 8em/11)[For advanced usage see the \u{261E} #link("https://raw.githubusercontent.com/switchlex/tschich/refs/heads/main/docs/manual.pdf")[manual].]]]}


/// Canons for computing margins

  // Medieval Ideal Canon
  #let tschich-old(a, b, p) = {
    let c = eval(str(
      2 * a.mm() - (4 * calc.pow(a.mm(), 3)) / (calc.pow(a.mm(), 2) + calc.pow(b.mm(), 2))) + "mm")
    return (
      "inside": p * (b - b/a * c),
      "top": p * (b - b/a * c),
      "outside": a - c,
      "bottom": b - b/a * c,
      "x": a, "y": b)}

  // Division with variable proportion
  #let tschich-var(a, b, p) = {
    if p >= 1/3 {panic("p must be smaller than 1/3")}
    else {return (
      "inside": p * a,
      "top": p * b,
      "outside": 2 * p * a,
      "bottom": 2 * p * b,
      "x": a, "y": b)}}

  // Nine Part Division (Standard)
    #let tschich(a, b) = tschich-var(a, b, 1/9)


/// Centering the type area

#let tschich-mid(f) = {
  let m = 1/2 * (f.at("inside") + f.at("outside"))
  return (
      "inside": m,
      "top": f.at("top"),
      "outside": m,
      "bottom": f.at("bottom"),
      "x": f.at("x"), "y": f.at("y"))}
      
      
/// Computing the type area's dimensions

#let tschich-dim(f) = {
  return (
    "width": f.at("x") - f.at("inside") - f.at("outside"),
    "height": f.at("y") - f.at("top") - f.at("bottom"))}


/// Displaying an estimate of the optimal font size

#let tschich-font(f) = context{
  let avg-letter-width = calc.round(
    measure(text(size: 10pt)[abcdefghijklmnopqrstuvwxyz]).width / 26 / 10pt, digits: 3)
  let space-width = calc.round(
    (measure(text(size: 10pt)[m m]).width - measure(text(size: 10pt)[mm]).width) / 10pt, digits: 2)
  align(center)[ #box(stroke: (0.5pt + black), inset: 0.75em)[
    #text(size: 8em/11)[#sym.chevron.l *tschich v.0.2.0* #sym.chevron.r --- The optimal font size \ for the current settings is estimated to be:] #v(1em, weak: true)
    \~ $#calc.round(tschich-dim(f).width.pt() / (avg-letter-width * 50 + space-width * 9), digits: 1)$ pt #v(1.5em, weak: true) 
    #text(size: 8em/11)[For detailed information see the \u{261E} #link("https://raw.githubusercontent.com/switchlex/tschich/refs/heads/main/docs/manual.pdf")[manual].]]]}