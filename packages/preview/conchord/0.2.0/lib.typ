#import "tabs/tabs.typ"
#import "tabs/tabs.typ": canvas, draw

#let render-chord(hold, open, muted, fret-number, name,
  barre: 0, barre-shift: 0, shadow-barre: 0, string-number: 6,
  scale-length: 1pt, 
  colors: (:), number-to-left: false) = {
  /// IMPORTANT: for the convinience there all strings are numbered FROM THE TOP (e.g. A will be 1)
  /// hold: array of coords of positions held; string first, then shift"
  /// open: array of numbers of opened strings
  /// muted: array of numbers for muted
  /// fret-number: the starting fret
  /// barre: length of barre if present; ZERO means NO
  /// barre-shift: shift of the barre; usually no, but there are exceptions
  /// shadow-barre: length of semi-visible upper part of barre (default 0) 
  /// string-number: number of strings of the instrument, default is 6
  /// colors: dictionary with colors for image
  /// - grid: color of grid, default is `gray.darken(20%)`
  /// - open: color of circles for open strings, default is `black`
  /// - muted: color of crosses for muted strings, default is `black`
  /// - hold: color of held positions, default is #5d6eaf
  /// - barre: color of main barre part, default is #5d6eaf
  /// - shadow-barre: color of "unnecessary" barre part, default is #5d6eaf.lighten(30%)
  /// colors and other properties of fret and chord name you can specify using show rules for text and raw (fret is `raw`) 
  /// outputs canvas with height=80 * scale-length 
  /// and width=((string-number + 1)*10 + 5) * scale-length
  
  assert.eq(type(name), str)
  assert.eq(type(hold), array)
  assert.eq(type(open), array)
  assert.eq(type(muted), array)

  let default-blue = rgb("5d6eaf");

  let right-end = (string-number)*10 - 4; // the end of bar from the right
  let width = calc.max(string-number*10 + 5, name.len()*5.5 + 5);
  
  return canvas(length: scale-length, {
    import draw: *
    stroke(colors.at("muted", default: black) + 1*scale-length)

    line((0, 0), (0, 0)) // always include zero

    for n in muted { // Draw muted strings
      line((n*10 + 1.1, -2), (rel: (7, -7)))
      line((rel: (-7, 0)), (rel: (7, 7)))
    }

    stroke(colors.at("open", default: black) + 1*scale-length)

    for n in open{ // Draw open strings
      circle((5 + n*10, -5), radius: 3.5)
    }

    stroke(colors.at("grid", default: gray.darken(20%)) + scale-length)
    grid((5, -63), (string-number*10 - 5, -13), step: 10, name: "grid")

    for p in hold {
      assert(p.at(1) < 6, message: "Unable to render chord. Held position (" + repr(p) + ") is too far away.")
      circle((p.at(0)*10 + 5, -8 - p.at(1) * 10), radius: 3, fill: colors.at("hold", default: default-blue), stroke: none)
    }

    if barre > 0 {
      let barre-col = colors.at("barre", default: default-blue)
      stroke(barre-col + 5*scale-length)
      fill(barre-col)
      line((right-end, -17.9 - barre-shift*10), (rel: (if shadow-barre > 0{6} else{8} - barre*10, 0)), name: "barre")
      circle("barre.start", radius: 2.5, stroke: none)

      if shadow-barre > 0 {
        let sh-col = colors.at("shadow-barre", default: default-blue.lighten(30%))
        fill(sh-col)
        stroke(sh-col + 5*scale-length)
        line("barre.end", (rel: (2-shadow-barre*10, 0)), name: "shadow-barre")
        circle("shadow-barre.end", radius: 2.5, stroke: none)
      }
      else{
        circle("barre.end", radius: 2.5, stroke: none)
      }
    }

    // Add fret number text
    if fret-number > 0 {
      if number-to-left {
        content((0, -17), [
          #set text(size: 13*scale-length)
          #raw(str(fret-number))
        ], anchor: "east")

      }
      else {
        content("grid.north-east", [
          #set text(size: 13*scale-length)
          #v(7*scale-length)
          #h(5*scale-length)
          #raw(str(fret-number))
        ], anchor: "west")
      }
    }

    // Add "empty" point for the same
    // width with and without fret numbers
    line((string-number*10 + 12, -75), (string-number*10 + 12, -75))
    
    let l = name.len()
    let font-size = if (l < 8){13}
      else if l==8 {12}
      else if l==9 {11}
      else if l==10 {10}
      else {9};

    let middle-anchor = (right-end - 6.0*l) > 0;
    
    content("grid.south", [
      #set text(size: font-size*scale-length, baseline: scale-length*3)
      #name
      ], anchor: "north")
  })
}

#let generate-chord(tabs, name: "", string-number: 6, force-barre: 0, use-shadow-barre: true, scale-length: 1pt, colors: (:), number-to-left: false) = {
  /// generates image with really simple rules
  /// tab: ARRAY of six elements (not a string);
  /// "x" (mute) and numbers are accepted
  /// name: name of chord
  /// string-number: total number of strings instrument has
  /// force-barre: 0 → standart algorithm, 1 → force add barre, -1 → force avoid barre
  /// inside the same fret (default no)

  assert(tabs.len() == string-number, message: "expected " + str(string-number) + " frets, found " + str(tabs.len()))

  let muted = ();
  let open = ();
  let hold = ();
  let min-fret = 100;
  let min-counter = 1; // counts number of holds at minimal fret (many → use barre)
  let min-fret-first-string = -1; // saves the first (from the bases) string that reaches min-fret
  let max-fret = 0; // counts the max fret to move the start
  let fret-number = 0;
  let barre = 0;
  let shadow-barre = 0; // part of barre that is not obligatory to hold

  for i in range(tabs.len()){
    if (tabs.at(i) == "x"){
      muted.push(i);
    }
    else if (tabs.at(i) == 0){
      open.push(i);
    }
    else{
      assert(type(tabs.at(i)) == int, message: "Passed fret " + repr(tabs.at(i)) + " that is not \"x\" or number")
      hold.push((i, tabs.at(i)))

      if (tabs.at(i) < min-fret or (min-counter == 0 and tabs.at(i) == min-fret)){
        min-fret = tabs.at(i);
        min-counter = 1;
        min-fret-first-string = i;
      }
      else if (tabs.at(i) == min-fret){
        min-counter += 1;
      }
      max-fret = calc.max(max-fret, tabs.at(i))
    }
  }

  // Want to use barre if possible, but need to check…

  if (force-barre == 1 // ignore everything, just use it!
    or hold.len() >= 4 // barre could be better than four random positions
    and min-counter >= 2 // barre will "close" at least two fingers
    and (open.len() == 0 or calc.max(..open) < min-fret-first-string) // whether there are no opens inside barre
    and (force-barre != -1) // No force avoid
    ){

    // Can use barre there
    barre = string-number - min-fret-first-string;
    if use-shadow-barre{
      shadow-barre = string-number - (if(open.len() > 0){calc.min(..open)}else{-1}) - 1 - barre;
    }
    
    hold = hold.map(h => (h.at(0), h.at(1) - (min-fret - 1)))
    hold = hold.filter(pos=>(pos.at(1)>1 or pos.at(0) < min-fret-first-string));
    fret-number = min-fret;
    if (fret-number == 1){
      fret-number = 0 // Ignore number if barre on the first fret
    }
  }
  else if (max-fret > 4 and hold.len() > 0){
    hold = hold.map(h => (h.at(0), h.at(1) - (min-fret - 1)))
    fret-number = min-fret;
  }

  return render-chord(hold, open, muted, fret-number, name, barre: barre, barre-shift: 0, shadow-barre: shadow-barre, string-number: string-number, colors: colors, scale-length: scale-length, number-to-left: number-to-left)
}


#let parse-tabstring(string-tab) = {
  let to-int-or-ignore(s) = {
    s = s.trim()
    if s.matches(regex("^\d+$")).len() != 0 {int(s)} else {s}
  }
  // Remove spaces if present
  string-tab = string-tab.replace(regex("/[ \t]/"), "");

  let tabs = if (string-tab.find(",") != none){
    string-tab.split(",").map(to-int-or-ignore);
  }
  else{
    string-tab.codepoints().map(to-int-or-ignore)
  }

  let last = tabs.last();
  let force-barre = if last == "*" {-1}
    else if last == "!" {1}
    else {0};

  if (force-barre != 0){
    tabs.pop();
  }

  return (tabs, force-barre)
}


#let new-chordgen(string-number: 6, use-shadow-barre: true, scale-length: 1pt, colors: (:), number-to-left: false) = {
  (tabstring, name: " ") => {
    let (tabs, force-barre) = parse-tabstring(tabstring)
    generate-chord(tabs, name: name, string-number: string-number, force-barre: force-barre, use-shadow-barre: use-shadow-barre, scale-length: scale-length, colors: colors, number-to-left: number-to-left)
  }
}


#let overchord(body, align: start, height: 1em, width: -0.25em) = box(place(align, body), height: 1em + height, width: width)