#import "@preview/one-liner:0.3.0": fit-to-width

#let spell-sheet(
/* * * HEADER * * */
  spellcasting-class: none,
  spellcasting-ability: none,
  spell-save-dc: none,
  spell-attack-bonus: none,
  
/* * * SPELLS * * */
  cantrips: (),
  lvl1-spells: (),
  lvl2-spells: (),
  lvl3-spells: (),
  lvl4-spells: (),
  lvl5-spells: (),
  lvl6-spells: (),
  lvl7-spells: (),
  lvl8-spells: (),
  lvl9-spells: (),

/* * * SPELL SLOTS * * */
  slots-total: array,
  slots-expended: array,

/* * * for rendering * * */
  settings: (
    language: "en", // only changes built-in lang features, no changes are made to the sheet text
    printer-mono: false, // true for black outlines, false for colored
    spell-rainbows: false, // changes the paper rules to rainbow gradients
    body-font: "Vollkorn"
  ),
  body: none
) = {
  set text(lang: settings.at("language", default: "en"), size:14pt, font: settings.at("body-font", default: "Vollkorn"))
  set page(
    paper: "us-letter",
    margin: (x: 0%, y: 0%, top: 0%, bottom: 0%)
  )

  body = {
  /* * * HEADER * * */
  set text(size:23pt)
  place(
    top + center,
    dx: 10.3pt,
    dy: 63.5pt,
    block(
      height: 3cm,
      width: 2.3cm,
      fit-to-width(spellcasting-ability, max-text-size: 21pt)
    )
  )
  place(
    top + center,
    dx: 111pt,
    dy: 60pt,
    [#spell-save-dc]
  )
  place(
    top + center,
    dx: 214.6pt,
    dy: 60pt,
    if type(spell-attack-bonus) == int {
      "+" + [#spell-attack-bonus]
    } else { 
      [#spell-attack-bonus]
    }
  )

  /* * * SPELLS * * */
  set text(size:11pt)

  // Set string to append at the end of files names when getting graphics
  let svg-color
  if settings.at("printer-mono", default: false) {
    svg-color = "-mono.svg"
  } else {
    svg-color = "-col.svg"
  }

  // Set stroke to use for all spell underlines
  let spell-stroke = 0.4pt + black.lighten(40%)
  if settings.at("spell-rainbows", default: false) {
    spell-stroke = 1pt + gradient.linear(..color.map.rainbow)
  }

  // Initialize starting position for placings
  let spell-x-counter = 32pt
  let spell-y-counter = 137.8pt

  // Print numbers of total and expended spell slots of a specific level at a specific xy-offset
  if type(slots-total) != array {
    slots-total = (slots-total,)
  }
  if type(slots-expended) != array {
    slots-expended = (slots-expended,)
  }

  let slot-printer(lvl, xcounter, ycounter) = {
    if slots-total.len() >= lvl and slots-total.at(lvl -1) != 0 {
      place(
        center,
        dx: xcounter - 266.3pt,
        dy: 10pt + ycounter,
        text([#slots-total.at(lvl -1)], size: 19pt)
      )
    }
    if slots-expended.len() >= lvl and slots-expended.at(lvl -1) != 0 {
      place(
        top + left,
        dx: xcounter + 74pt,
        dy: ycounter + 12pt,
        text(for i in range(slots-expended.at(lvl -1)) {[I]}, size:20pt,tracking: 2pt)
      )
    }
  }

  // Flip entries in an array of lenght 2
  let array-flipper(arr) = {
    return (arr.at(1), arr.at(0))
  }

  // Print Cantrips
  if type(cantrips) == str {
    cantrips = (cantrips,)
  }
  if cantrips.len() > 0 {
    place(
      top + left,
      dx: spell-x-counter - 0.97pt,
      dy: spell-y-counter,
      image("/outlines/spell-header-cantrips"+svg-color)
    )
    spell-y-counter += 37.12pt // size of header
    spell-y-counter += 9.68pt // space between header and first line
    for i in cantrips {
      place(
        top + left,
        dx: spell-x-counter,
        dy: spell-y-counter,
        line(start: (0pt, 0pt), length: 171.5pt, stroke: spell-stroke)
      )
      place(
        top + left,
        dx: spell-x-counter + 10pt,
        dy: spell-y-counter - 10pt,
        [#i]
      )
      if spell-y-counter >= 742pt {
        spell-x-counter += 189pt
        spell-y-counter = 137.8pt
      }
      spell-y-counter += 14pt
    }
    if spell-y-counter >= 151.9pt {
      spell-y-counter -= 10pt // space between last line and divider
      place(
        top + left,
        dx: spell-x-counter - 10.2pt,
        dy: spell-y-counter,
        image("/outlines/spell-divider.svg", width:190.4pt)
      )
      spell-y-counter += 6.66pt // size of divider
      spell-y-counter += 1.55pt // space between divider and header
    } else {
      spell-y-counter -= 14pt
    }
  }
  
  if type(lvl1-spells) == str or (type(lvl1-spells) == array and lvl1-spells.len() == 2 and (type(lvl1-spells.at(0)) == bool or type(lvl1-spells.at(1)) == bool)) {
    lvl1-spells = (lvl1-spells,)
  }
  if lvl1-spells.len() > 0 {
    if (spell-y-counter + 41pt) >= 750pt {
      spell-x-counter += 189pt
      spell-y-counter = 137.8pt
    }
    place(
      top + left,
      dx: spell-x-counter - 4.6pt,
      dy: spell-y-counter,
      image("/outlines/spell-header-lvl1"+svg-color)
    )
    slot-printer(1, spell-x-counter, spell-y-counter + 10.5pt)
    spell-y-counter += 47.89pt // size of header
    spell-y-counter += 13pt // space between header and first line
    for i in lvl1-spells {
      place(
        top + left,
        dx: spell-x-counter + 8.4pt,
        dy: spell-y-counter,
        line(start: (0pt, 0pt), length: 163.1pt, stroke: spell-stroke)
      )
      // Unify order of array entries
      if type(i) == array and type(i.at(0)) != bool {
        i = array-flipper(i)
      }
      place(
        top + left,
        dx: spell-x-counter + 0.35pt,
        dy: -6.2pt + spell-y-counter,
        if type(i) == array and i.at(0) {
          circle(radius: 3pt, stroke: 0.7pt + black, fill: black)
        } else {
          circle(radius: 3pt, stroke: 0.7pt + black)
        }
      )
      place(
        top + left,
        dx: spell-x-counter + 11pt,
        dy: spell-y-counter - 10pt,
        if type(i) == array {
          [#i.at(1)]
        } else {
          [#i] 
        }
      )
      if spell-y-counter >= 742pt {
        spell-x-counter += 189pt
        spell-y-counter = 137.8pt
      }
      spell-y-counter += 14pt
    }
    if spell-y-counter >= 151.9pt {
      spell-y-counter -= 11pt // space between last line and divider
      place(
        top + left,
        dx: spell-x-counter - 10.2pt,
        dy: spell-y-counter,
        image("/outlines/spell-divider.svg", width:190.4pt)
      )
      spell-y-counter += 6.66pt // size of divider
      spell-y-counter += 0.75pt // space between divider and header
    } else {
      spell-y-counter -= 14pt
    }
  }

  // combine the spell lists, so we can use a for loop
  let spells-above-1 = (lvl2-spells, lvl3-spells, lvl4-spells, lvl5-spells, lvl6-spells, lvl7-spells, lvl8-spells, lvl9-spells)

  for i in range(spells-above-1.len()) {
    if type(spells-above-1.at(i)) == str or (type(spells-above-1.at(i)) == array and spells-above-1.at(i).len() == 2 and (type(spells-above-1.at(i).at(0)) == bool or type(spells-above-1.at(i).at(1)) == bool)) {
      spells-above-1.at(i) = (spells-above-1.at(i),)
    }
    if spells-above-1.at(i).len() > 0 {
    if (spell-y-counter + 41pt) >= 750pt {
      spell-x-counter += 189pt
      spell-y-counter = 137.8pt
    }
    place(
      top + left,
      dx: spell-x-counter - 0.97pt,
      dy: spell-y-counter,
      image("/outlines/spell-header"+svg-color)
    )
    place(
      center,
      dx: spell-x-counter - 297.7pt,
      dy: 14.4pt + spell-y-counter, // 14.4pt is the space 
      text([#strong[#(i+2)]], size: 11pt, font: "Noto Sans")
    )
    slot-printer(i+1, spell-x-counter, spell-y-counter)
    spell-y-counter += 37.12pt // size of header
    spell-y-counter += 11pt // space between header and first line
    for i in spells-above-1.at(i) {
      place(
        top + left,
        dx: spell-x-counter + 8.4pt,
//        dy: 582.2pt + i*14pt,
        dy: spell-y-counter,
        line(start: (0pt, 0pt), length: 163.1pt, stroke: spell-stroke)
      )
      // Unify order of array entries
      if type(i) == array and type(i.at(0)) != bool {
        i = array-flipper(i)
      }
      place(
        top + left,
        dx: spell-x-counter + 0.35pt,
        dy: -6.2pt + spell-y-counter,
        if type(i) == array and i.at(0) {
          circle(radius: 3pt, stroke: 0.7pt + black, fill: black)
        } else {
          circle(radius: 3pt, stroke: 0.7pt + black)
        }
      )
      place(
        top + left,
        dx: spell-x-counter + 11pt,
        dy: spell-y-counter - 10pt,
        if type(i) == array {
          [#i.at(1)]
        } else {
          [#i] 
        }
      )
      if spell-y-counter >= 742pt {
        spell-x-counter += 189pt
        spell-y-counter = 137.8pt
      }
      spell-y-counter += 14pt
    }
    if spell-y-counter >= 151.9pt {
      spell-y-counter -= 11pt // space between last line and divider
      place(
        top + left,
        dx: spell-x-counter - 10.2pt,
        dy: spell-y-counter,
        image("/outlines/spell-divider.svg", width:190.4pt)
      )
      spell-y-counter += 6.66pt // size of divider
    } else {
      spell-y-counter -= 14pt
    }
  }
  }
  }
  // Place Background and all info added to body above
  if settings.at("printer-mono", default: false) {
    set page(
      background: image("/outlines/page-3-mono.svg", width: 100%)
    )
    place(
      top + left,
      dx: 50pt,
      dy: 68pt,
      block(
        height: 3cm,
        width: 7.3cm,
        fit-to-width(spellcasting-class, max-text-size: 23pt)
      )
    )
    body
  } else {
    set page(
      background: image("/outlines/page-3-col.svg", width: 100%)
    )
    place(
      top + left,
      dx: 50pt,
      dy: 68pt,
      block(
        height: 3cm,
        width: 7.3cm,
        fit-to-width(spellcasting-class, max-text-size: 23pt)
      )
    )
    body
  }
}
