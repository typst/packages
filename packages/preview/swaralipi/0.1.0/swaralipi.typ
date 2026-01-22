
#let apply(fn, x, def) = if x == none { def } else { fn(x) }
#let apply_empty(fn, x, def) = if x == () { def } else { fn(x) }
#let id(x) = x
#let count(s, x) = s.matches(x).len()
#let prefill(x, n, v) = (..range(n).map(i => v), x).flatten().slice(-n)
#let postfill(x, n, v) = (x, (..range(n).map(i => v),)).flatten().slice(0, n)

#let all_parts(phrase, pattern) = {
  let parts = ()
  let last = 0
  for match in phrase.matches(pattern) {
    if last < match.start {
      parts.push(("m": none, "u": phrase.slice(last, match.start)))
    }
    parts.push(("m": match, "u": none))
    last = match.end
  }
  if last < phrase.len() {
    parts.push(("m": none, "u": phrase.slice(last)))
  }
  parts
}



#let low_octave = box(baseline: -0.7em, circle(radius: 0.8pt, fill: black))
#let up_octave = move(dy: 0.75em, circle(radius: 0.8pt, fill: black))

#let ubar = box(baseline: -7pt, fill: red, width: 1em, height: 0.5pt);
#let tbar = move(dy: 0.6em, line(start: (0% + 0em, 0% + 0em), length: 0.5em, angle: 90deg, stroke: 0.5pt));

#let komal(v) = math.attach(
  math.limits(v),
  b: ubar,
  t: hide(tbar),
);
#let tivra(v) = math.attach(
  math.limits(v),
  b: hide(ubar),
  t: tbar,
);
#let suddha(v) = math.attach(
  math.limits(v),
  b: hide(ubar),
  t: hide(tbar),
);
#let low(x) = math.attach(math.limits(x), b: low_octave, t: hide(up_octave))
#let up(x) = math.attach(math.limits(x), b: hide(low_octave), t: up_octave)
#let middle(x) = math.attach(math.limits(x), b: hide(low_octave), t: hide(up_octave))
#let kan(x) = math.script(math.attach(math.limits(""), t: x))

#let SA = suddha(math.upright("S"))
#let RE = suddha(math.upright("R"))
#let GA = suddha(math.upright("G"))
#let MA = suddha(math.upright("M"))
#let PA = suddha(math.upright("P"))
#let DA = suddha(math.upright("D"))
#let NI = suddha(math.upright("N"))

#let KM = tivra(math.upright("M"))

#let KR = komal(math.upright("R"))
#let KG = komal(math.upright("G"))
#let KD = komal(math.upright("D"))
//#let KN = math.underline(math.upright("N"))
#let KN = komal(math.upright("N"))

#let notes_map = (
  "S": SA,
  "R": RE,
  "G": GA,
  "m": MA,
  "M": KM,
  "P": PA,
  "D": DA,
  "N": NI,
  "r": KR,
  "g": KG,
  "d": KD,
  "n": KN,
  "-": "-",
)

#let maxSwar = (up(KM), RE).join()
#let meend(x) = math.overparen(x)
#let krintan(x) = math.overbracket(x)
#let beat(x, count) = if count > 1 { math.underparen(x) } else { math.attach(math.limits(x), b: hide(sym.dash.wave)) }
//dha , dhin, na, te, re, ke, kat=ta,dhi, ga, di, ghe, ne, thun, tin
#let Dha = math.upright("Dha")
#let Dhin = math.upright("Dhin")
#let Din = math.upright("Din")
#let Ge = math.upright("Ge")
#let Tin = math.upright("Tin")
#let Ti = math.upright("Ti")
#let Ta = math.upright("Ta")
#let Na = math.upright("Na")
#let Kit = math.upright("Kit")
#let Kat = math.upright("Kat")
#let Tita = math.upright("Tita")
#let Kata = math.upright("Kata")
#let Gadi = math.upright("Gadi")
#let Gina = math.upright("Gina")
#let Dhage = math.upright("Dhage")
#let Tirkit = math.upright("Tirkit")
#let Tu = math.upright("Tu")
#let Ka = math.upright("Ka")
#let Dhi = math.upright("Dhi")
#let Ga = math.upright("Ga")

#let taals = (
  "tintal": (
    ("+", Dha, Dhin, Dhin, Dha),
    ("2", Dha, Dhin, Dhin, Dha),
    ("0", Dha, Tin, Tin, Ta),
    ("3", Ta, Dhin, Dhin, Dha),
  ),
  "dadra": (("+", Dha, Dhin, Na), ("0", Dha, Ti, Na)),
  "ektal": (
    ("+", Dhin, Dhin),
    ("0", Dhage, Tirkit),
    ("2", Tu, Na),
    ("0", Kat, Ta),
    ("3", Dhage, Tirkit),
    ("4", Dhin, Na),
  ),
  "ektal3": (
    ("+", Dha, Dhi, Na),
    ("2", Na, Ti, Na),
    ("0", Kat, Tita, Dhin),
    ("3", Tita, Dhin, Tita),
  ),
  "kaharba": (("+", Dha, Ge, Na, Ti), ("0", Na, Ka, Dhin, Na)),
  "chautal": (("+", Dha, Dha), ("0", Dhin, Ta), ("2", Kit, Dha), ("0", Dhin, Ta), ("3", Tita, Kata), ("4", Gadi, Gina)),
  "rupak": (("+", Tin, Tin, Na), ("2", Dhin, Na), ("3", Dhin, Na)),
  "jhaptal": (("+", Dhin, Na), ("2", Dhin, Dhin, Na), ("0", Tin, Na), ("3", Dhin, Dhin, Na)),
  "dipchandi": (("+", Dha, Dhin, "-"), ("2", Dha, Ge, Tin, "-"), ("0", Ta, Tin, "-"), ("3", Dha, Ge, Dhin, "-")),
  "tivra": (("+", Dha, Dhin, Ta), ("2", Tita, Kata), ("3", Gadi, Gina)),
  "dhamar": (("+", Ka, Dhi, Ta, Dhi, Ta), ("2", Dha, "-"), ("0", Ga, Ti, Ta), ("3", Ti, Ta, Ta, "-")),
  "sultal": (("+", Dha, Dha), ("0", Din, Ta), ("2", Kit, Dha), ("3", Tita, Kata), ("0", Gadi, Gina)),
  "adachautal": (
    ("+", Dhin, Tirkit),
    ("2", Dhin, Na),
    ("0", Tu, Na),
    ("3", Kat, Ta),
    ("0", Tirkit, Dhin),
    ("4", Na, Dhin),
    ("0", Dhin, Na),
  ),
)

#let beats_count(t) = t.map(b => b.len() - 1).sum()
#let bibhag_count(taal) = taal.len()
#let bibhag_positions(taal, repeat: 1) = {
  let single = range(taal.len() + 1).map(i => taal.slice(0, i).map(s => s.len() - 1).sum(default: 0))
  let b_count = beats_count(taal)
  range(repeat).map(r => single.slice(0, -1).map(p => r * b_count + p)).flatten() + (repeat * b_count,)
}
#let all_beats(cycles) = {
  let beats = ()
  for cycle in cycles {
    for bibhag in cycle {
      beats += bibhag
    }
  }
  beats
}

#let extract_opts(s) = {
  let m = s.match(regex("\[(.*?)\]"))
  if m == none { return (s, (:)) }
  let opts = (:)
  for part in m.captures.at(0).split(",") {
    let kv = part.split(":")
    if kv.len() == 2 { opts.insert(kv.at(0).trim(), kv.at(1).trim()) }
  }
  (s.replace(m.text, ""), opts)
}


#let note_patterns = regex("(\\{[^}]+\\})?(S|R|r|G|g|m|M|P|d|D|N|n|-)(\\.{0,2})(\\'{0,2})");
#let section_patterns = regex("\\[(.*?)\\]|\\{(.*?)\\}|\\((.*?)\\)|([^\\[\\{\\(\\]\\}\\)]+)");
#let render_note(note) = {
  if note.text != none {
    note.text
  } else {
    let render_swara(base, octave) = {
      let n = notes_map.at(base, default: math.upright(base))
      if octave > 0 { up(n) } else if octave < 0 { low(n) } else { middle(n) }
    }

    let base_rendered = render_swara(note.base, note.octave)

    if note.at("kan", default: none) != none {
      kan(render_swara(note.kan.base, note.kan.octave)) + base_rendered
    } else {
      base_rendered
    }
  }
}
#let note_count(b) = b.filter(n => n.text == none).len()

#let render_notes(notes) = notes.map(n => render_note(n)).join()
#let render_section(sec) = (
  apply_empty(render_notes, sec.base, ""),
  apply_empty(x => kan(render_notes(x)), sec.kan, ""),
  apply_empty(x => meend(render_notes(x)), sec.meend, ""),
  apply_empty(x => krintan(render_notes(x)), sec.krintan, ""),
).join("")
#let empty_beat = ("kan": (), "meend": (), "krintan": (), "base": ())

#let parse_kan_note(kan_str) = {
  if kan_str == none { return none }
  let inner = kan_str.slice(1, -1)
  let m = inner.match(note_patterns)
  if m != none {
    (
      "base": m.captures.at(1),
      "octave": count(m.captures.at(2), ".") * -1 + count(m.captures.at(3), "'") * 1,
    )
  } else {
    none
  }
}


#let render_beat(b, ubar, is_lyrics: false) = {
  if is_lyrics {
    return b.map(sec => sec.base.map(n => n.text).join()).join()
  }
  let total_count = b.map(sec => note_count(sec.base) + note_count(sec.meend) + note_count(sec.krintan)).sum(default: 0)
  let s = b.map(sec => render_section(sec)).join()
  if ubar { beat(s, total_count) } else { s }
}




#let make_note(note) = (
  "text": none,
  "kan": parse_kan_note(note.captures.at(0)),
  "base": note.captures.at(1),
  "octave": count(note.captures.at(2), ".") * -1 + count(note.captures.at(3), "'") * +1,
)
#let make_text(note) = ("text": note, "base": none, "octave": 0)

#let parse_notes(notes) = all_parts(notes, note_patterns).map(p => if p.m != none { make_note(p.m) } else {
  make_text(p.u)
})

#let parse_section(section) = (
  "krintan": apply(parse_notes, section.captures.at(0), ()),
  "kan": apply(parse_notes, section.captures.at(1), ()),
  "meend": apply(parse_notes, section.captures.at(2), ()),
  "base": apply(parse_notes, section.captures.at(3), ()),
)

#let parse_beats(beats) = beats.matches(section_patterns).map(m => parse_section(m))
#let parse_bibhag(bibhag, bits_count, is_lyrics: false) = {
  let parts = bibhag.matches(regex("([^\\[\\{\\(\\s]+|\\[[^\\]]*\\]|\\{[^\\}]*\\}|\\([^\\)]*\\))+")).map(m => m.text)
  if bits_count > 0 {
    if parts.len() > 0 and parts.at(0) == ">" {
      parts = prefill(parts.slice(1), bits_count, "")
    } else {
      parts = postfill(parts, bits_count, "")
    }
  }
  if is_lyrics {
    return parts.map(group => {
      let section = (
        "base": (("text": group, "base": none, "octave": 0),),
        "kan": (),
        "meend": (),
        "krintan": (),
      )
      (section,)
    })
  }
  parts.map(group => parse_beats(group))
}
#let parse_cycle(line, taal, ubar, is_lyrics: false) = (
  line
    .split("|")
    .enumerate()
    .map(iv => {
      let (i, v) = iv
      parse_bibhag(
        v.trim(),
        if taal == none { 0 } else { taal.at(calc.rem(i, taal.len())).len() - 1 },
        is_lyrics: is_lyrics,
      )
    })
)


#let hcell(val, visible) = if visible { (grid.cell(align: left + bottom, val),) } else { () }

#let render_taal_header(taal, has_any_prefix, b_count, repeat: 1) = {
  let h_row = hcell("", has_any_prefix)
  let symbols = (
    h_row
      + range(repeat)
        .map(_ => taal.map(bibhag => {
          (grid.cell(align: center + bottom, [#bibhag.at(0)]),) + range(bibhag.len() - 2).map(_ => grid.cell(""))
        }))
        .flatten()
        .flatten()
  )
  let counts = (
    h_row
      + range(1, repeat * b_count + 1).map(i => {
        let val = calc.rem(i - 1, b_count) + 1
        grid.cell(align: center + bottom, text(size: 0.8em, str(val)))
      })
  )
  symbols + counts
}

#let parse_itemized_lines(code, taal, ubar) = {
  let lines = code.split("\n")
  while lines.len() > 0 and lines.at(0).trim() == "" { lines = lines.slice(1) }
  while lines.len() > 0 and lines.at(-1).trim() == "" { lines = lines.slice(0, -1) }

  let processed_lines = ()
  let plus_count = 0
  let has_any_prefix = false

  for line in lines {
    let prefix = ""
    let content = line.trim()
    let is_lyrics = false
    let is_separator = content.starts-with("---")
    let is_empty = content.len() == 0

    if not is_separator and not is_empty {
      if line.starts-with("+") {
        plus_count += 1
        prefix = [#plus_count.]
        content = line.slice(1).trim()
        has_any_prefix = true
      } else if line.starts-with("-") {
        prefix = [•]
        content = line.slice(1).trim()
        has_any_prefix = true
      } else if line.starts-with("#L") {
        content = line.slice(2).trim()
        is_lyrics = true
      }
    }

    processed_lines.push((
      "prefix": prefix,
      "is_lyrics": is_lyrics,
      "is_separator": is_separator,
      "is_empty": is_empty,
      "cycle": if is_separator or is_empty { () } else { parse_cycle(content, taal, ubar, is_lyrics: is_lyrics) },
    ))
  }
  (processed_lines, has_any_prefix)
}

#let render_composition(code, lang) = {
  let (code_str, o1) = extract_opts(str(code))
  let (lang_str, o2) = extract_opts(str(lang))
  let opts = (taal: "", matra: "true", wrapped: "true") + o1 + o2
  let ubar = opts.matra == "true"
  let taal = taals.at(opts.taal, default: none)
  let wrapped = opts.wrapped == "true"

  let (processed_lines, has_any_prefix) = parse_itemized_lines(code_str, taal, ubar)

  if taal == none {
    for pl in processed_lines {
      if pl.is_empty or pl.is_separator {
        [#linebreak()]
        continue
      }
      let pref = if pl.prefix != "" { [#pl.prefix ] } else { [] }
      let content = pl
        .cycle
        .map(bibhag => {
          bibhag.map(beat => render_beat(beat, ubar, is_lyrics: pl.is_lyrics)).join(" ")
        })
        .join(" | ")
      [#pref #content #linebreak()]
    }
  } else {
    let b_count = beats_count(taal)
    let beats_per_line = processed_lines.map(pl => if pl.is_separator or pl.is_empty { 0 } else {
      all_beats((pl.cycle,)).len()
    })
    let max_beats = beats_per_line.fold(0, calc.max)
    let max_cycles = int(calc.ceil(max_beats / b_count))
    let repeat = if wrapped { 1 } else { calc.max(1, max_cycles) }
    let total_beats = repeat * b_count

    let cols = if has_any_prefix { (auto,) + (1fr,) * total_beats } else { (1fr,) * total_beats }
    let header_rows = render_taal_header(taal, has_any_prefix, b_count, repeat: repeat)

    let row_counts = processed_lines.map(pl => {
      if pl.is_separator { return 0 }
      let beats = all_beats((pl.cycle,))
      if wrapped { return int(calc.max(1, calc.ceil(beats.len() / b_count))) }
      return 1
    })

    let hlines = processed_lines
      .enumerate()
      .filter(iv => iv.at(1).is_separator)
      .map(iv => {
        let y_pos = 2 + row_counts.slice(0, iv.at(0)).fold(0, (a, b) => a + b)
        if y_pos > 2 { grid.hline(y: y_pos) } else { () }
      })
      .flatten()

    grid(
      columns: cols, gutter: 2pt, fill: (x, y) => white, inset: (x, y) => (
        x: 5pt,
        y: if y < 2 { 5pt } else { 7pt },
      ), align: center + bottom,
      ..bibhag_positions(taal, repeat: repeat).map(p => grid.vline(x: int(has_any_prefix) + p)),
      ..header_rows,
      grid.hline(),
      ..hlines,
      ..processed_lines
        .filter(pl => not pl.is_separator)
        .map(pl => {
          if pl.is_empty { return hcell("", has_any_prefix) + range(total_beats).map(_ => grid.cell("")) }
          let beats = all_beats((pl.cycle,))
          let step = if wrapped { b_count } else { beats.len() }
          range(0, beats.len(), step: step)
            .enumerate()
            .map(ij => {
              let (i, j) = ij
              let row_beats = beats.slice(j, calc.min(j + step, beats.len()))
              let cells = row_beats.map(b => grid.cell(render_beat(b, ubar, is_lyrics: pl.is_lyrics)))
              (
                hcell(if i == 0 { pl.prefix } else { "" }, has_any_prefix)
                  + cells
                  + range(total_beats - cells.len()).map(_ => grid.cell(""))
              )
            })
            .flatten()
        })
        .flatten()
    )
  }
}
