// lib.typ - Main entry point for the scorify package (WASM-backed)
//
// Parsing, layout, and rendering command generation are performed by a Rust
// core compiled to WebAssembly. The Typst frontend serializes user-facing
// parameters to JSON, calls the WASM plugin, and embeds the returned SVG systems
// as vector images.

#let scorify-wasm = plugin("scorify_wasm.wasm")

// Named color presets exported for Typst-side score configuration and
// string interpolation in inline music color wrappers.
#let red = "#ff0000"
#let orange = "#ffa500"
#let yellow = "#ffcf00"
#let green = "#00ff00"
#let blue = "#0000ff"
#let sky-blue = "#4e9fe5"
#let purple = "#9d0055"
#let gold = "#d4af37"
#let white = "#ffffff"
#let black = "#000000"
#let silver = "#c0c0c0"
#let platinum = "#e5e4e2"
#let bronze = "#cd7f32"
#let copper = "#b87333"
#let charcoal = "#36454f"
#let navy = "#0a2a66"

#let preset-colors = (
  "red": red,
  "orange": orange,
  "yellow": yellow,
  "green": green,
  "blue": blue,
  "skyblue": sky-blue,
  "purple": purple,
  "gold": gold,
  "white": white,
  "black": black,
  "silver": silver,
  "platinum": platinum,
  "bronze": bronze,
  "copper": copper,
  "charcoal": charcoal,
  "navy": navy,
)

#let resolve-preset-color(value) = {
  if type(value) != str {
    value
  } else {
    let key = if value == "sky blue" or value == "sky-blue" or value == "sky_blue" {
      "skyblue"
    } else {
      value
    }
    preset-colors.at(key, default: value)
  }
}

#let normalize-color(value) = {
  if value == none {
    none
  } else if type(value) == str {
    resolve-preset-color(value)
  } else {
    let css = repr(rgb(value))
    if css.starts-with("rgb(\"") and css.ends-with("\")") {
      css.slice(5, css.len() - 2)
    } else {
      css
    }
  }
}

#let typst-color(value) = {
  if value == none {
    none
  } else if type(value) == str {
    rgb(resolve-preset-color(value))
  } else {
    value
  }
}

// Header (standard Typst content, outside the SVG systems)

#let render-header(
  title: none,
  subtitle: none,
  composer: none,
  arranger: none,
  lyricist: none,
  color: none,
) = {
  if title == none and composer == none { return }
  let fill = typst-color(color)
  block(width: 100%, {
    if title != none {
      if fill != none {
        align(center, text(size: 18pt, weight: "bold", fill: fill, title))
      } else {
        align(center, text(size: 18pt, weight: "bold", title))
      }
    }
    if subtitle != none {
      if fill != none {
        align(center, text(size: 12pt, style: "italic", fill: fill, subtitle))
      } else {
        align(center, text(size: 12pt, style: "italic", subtitle))
      }
    }
    v(2pt)
    if composer != none or arranger != none or lyricist != none {
      grid(
        columns: (1fr, 1fr),
        {
          if lyricist != none {
            if fill != none {
              align(left, text(size: 10pt, fill: fill, "Text: " + lyricist))
            } else {
              align(left, text(size: 10pt, "Text: " + lyricist))
            }
          }
        },
        {
          if composer != none {
            if fill != none {
              align(right, text(size: 10pt, fill: fill, composer))
            } else {
              align(right, text(size: 10pt, composer))
            }
          }
          if arranger != none {
            if fill != none {
              align(right, text(size: 9pt, style: "italic", fill: fill, "arr. " + arranger))
            } else {
              align(right, text(size: 9pt, style: "italic", "arr. " + arranger))
            }
          }
        },
      )
    }
    v(6pt)
  })
}

/// Render a complete music score.
///
/// This is the primary entry point for the scorify library.
///
/// Parameters:
/// - staves: array of staff dictionaries, each with:
///     - clef: "treble", "bass", "alto", "tenor", "treble-8a", etc.
///     - music: music string (see syntax reference)
///     - label: optional staff label
///     - instrument-name: optional full name shown on the first system
///     - instrument-name-cont: optional abbreviated name shown on later systems
///     - instrument-name-shared: true to center the previous staff's name across both staves
///     - barline-group-start/end: connect measure lines across this adjacent staff range
///     - bracket-start/end: connect adjacent staves with a straight bracket
///     - brace-start/end: connect adjacent staves with a grand-staff brace
/// - key: key signature string ("C", "G", "D", "Bb", "f#", etc.)
/// - time: time signature string ("4/4", "3/4", "6/8", "C"/"common", "C|"/"cut")
/// - title: piece title
/// - subtitle: subtitle
/// - composer: composer name
/// - arranger: arranger name
/// - lyricist: lyricist name
/// - staff-group: "none", "grand", "bracket", "separate"
/// - staff-size: staff space distance (default 1.75mm)
/// - system-spacing: vertical space between systems
/// - staff-spacing: vertical space between staves within a system
/// - music-font: SMuFL font family (defaults to Leland)
/// - tuplet-style: `"bracket"` or `"number"` (defaults to `"bracket"`)
/// - width: explicit width or auto
/// - measure-numbers: "system", "every", "none"
/// - measures-per-line: if set, force this many measures per system line
#let score(
  staves: (),
  lyrics: (),
  chords: (),
  key: "C",
  time: none,
  tempo: none,
  title: none,
  subtitle: none,
  composer: none,
  arranger: none,
  lyricist: none,
  copyright: none,
  staff-group: "none",
  staff-size: 1.75mm,
  system-spacing: 12mm,
  staff-spacing: 8mm,
  lyric-line-spacing: none,
  color: none,
  music-font: "Leland",
  music-font-metadata: none,
  tuplet-style: "bracket",
  width: auto,
  measure-numbers: "system",
  relative-octave: false,
  measures-per-line: none,
) = {
  if staves.len() == 0 { return }

  // Alternate fonts are resolved through Typst so missing font-path setup still
  // produces a CLI warning. Default Leland is rendered from the WASM bundle.
  if music-font != "Leland" {
    box(width: 0pt, height: 0pt, hide(text(font: music-font, size: 0.1pt, "\u{E050}")))
  }

  render-header(
    title: title,
    subtitle: subtitle,
    composer: composer,
    arranger: arranger,
    lyricist: lyricist,
    color: color,
  )

  let render-inner(avail-width-mm) = {
    let input = (
      staves: staves.map(s => (
        clef: s.at("clef", default: none),
        music: s.at("music", default: ""),
        label: s.at("label", default: none),
        instrument_name: s.at("instrument-name", default: none),
        instrument_name_cont: s.at("instrument-name-cont", default: none),
        instrument_name_shared: s.at("instrument-name-shared", default: false),
        fingering_position: s.at("fingering-position", default: "above"),
        color: normalize-color(s.at("color", default: none)),
        barline_group_start: s.at("barline-group-start", default: s.at("connect-start", default: false)),
        barline_group_end: s.at("barline-group-end", default: s.at("connect-end", default: false)),
        bracket_start: s.at("bracket-start", default: false),
        bracket_end: s.at("bracket-end", default: false),
        brace_start: s.at("brace-start", default: false),
        brace_end: s.at("brace-end", default: false),
      )),
      key: key,
      time: time,
      title: none,
      subtitle: none,
      composer: none,
      arranger: none,
      lyricist: none,
      staff_group: staff-group,
      staff_size_mm: staff-size / 1mm,
      width_mm: avail-width-mm,
      staff_spacing_mm: staff-spacing / 1mm,
      system_spacing_mm: system-spacing / 1mm,
      measures_per_line: measures-per-line,
      measure_numbers: measure-numbers,
      music_font: music-font,
      color: normalize-color(color),
      tuplet_style: tuplet-style,
    )

    let result-bytes = scorify-wasm.render_score(bytes(json.encode(input)))
    let result = json(result-bytes)

    for system in result.systems {
      block(image(bytes(system.svg), format: "svg"))
      v(system-spacing)
    }
  }

  if width == auto {
    layout(size => {
      render-inner(size.width / 1mm)
    })
  } else {
    render-inner(width / 1mm)
  }
}

/// Quick single-staff melody rendering.
///
/// A convenience wrapper around `score()` for simple melodies.
#let melody(
  music: "",
  key: "C",
  time: none,
  clef: none,
  title: none,
  composer: none,
  staff-size: 1.75mm,
  system-spacing: 12mm,
  lyric-line-spacing: none,
  color: none,
  music-font: "Leland",
  music-font-metadata: none,
  tuplet-style: "bracket",
  width: auto,
  measures-per-line: none,
  instrument-name: none,
  instrument-name-cont: none,
) = {
  score(
    staves: ((clef: clef, music: music, instrument-name: instrument-name, instrument-name-cont: instrument-name-cont),),
    key: key,
    time: time,
    title: title,
    composer: composer,
    staff-size: staff-size,
    system-spacing: system-spacing,
    lyric-line-spacing: lyric-line-spacing,
    color: color,
    music-font: music-font,
    music-font-metadata: music-font-metadata,
    tuplet-style: tuplet-style,
    width: width,
    measures-per-line: measures-per-line,
  )
}

/// Chord chart rendering (not yet implemented).
#let chord-chart(
  chords: "",
  key: "C",
  time: "4/4",
  title: none,
  width: auto,
) = {
  // Stub - not yet implemented
}
