// pdfpc metadata export for SAPIANS decks.
//
// Portions adapted from touying (MIT, © touying contributors) and inspired by
// minideck/polylux — touying's `src/pdfpc.typ` is itself adapted from
// polylux's `utils/pdfpc.typ` by Andreas Kröpelin.
//
// Every page drops four `<pdfpc>` markers (NewSlide, Idx, Overlay,
// LogicalSlide) plus one `Note` marker per speaker note. `pdfpc-file` collects
// them into the `pdfpcFormat: 2` document that pdfpc reads next to the PDF:
//
//   bash scripts/export_pdfpc.sh deck.typ   # -> deck.pdfpc

#import "dynamic.typ": _subslide, logical-slide

/// Emit a speaker note for the page it appears on. Every slide family also
/// takes a `note:` argument, which calls this for you.
/// -> content
#let speaker-note(
  /// The note. A raw block is unwrapped and trimmed, so a fenced markdown
  /// block can carry the note verbatim. -> str | raw
  note,
) = {
  let text = if type(note) == str {
    note
  } else if type(note) == content and note.func() == raw {
    note.text.trim()
  } else {
    panic("a speaker note must be a string or a raw block, got: " + repr(note))
  }
  [#metadata((t: "Note", v: text))<pdfpc>]
}

/// Mark the current slide as the last one of the presentation proper; pdfpc
/// treats the slides after it as backup material.
#let end-slide = [#metadata((t: "EndSlide"))<pdfpc>]

/// Mark the current slide as pdfpc's "saved" slide.
#let save-slide = [#metadata((t: "SaveSlide"))<pdfpc>]

/// Hide the current slide in pdfpc's overview.
#let hidden-slide = [#metadata((t: "HiddenSlide"))<pdfpc>]

/// Document-wide pdfpc configuration. Call it before the first slide.
///
/// ```typ
/// #pdfpc-config(duration-minutes: 30, last-minutes: 5)
/// ```
///
/// -> content
#let pdfpc-config(
  /// Length of the talk in minutes. -> none | int
  duration-minutes: none,

  /// Wall-clock start time, `HH:MM` when given as a string.
  /// -> none | str | datetime
  start-time: none,

  /// Wall-clock end time, `HH:MM` when given as a string.
  /// -> none | str | datetime
  end-time: none,

  /// How many minutes before the end the timer turns red. -> none | int
  last-minutes: none,

  /// Font size of pdfpc's notes pane. -> none | int | float
  note-font-size: none,

  /// Render the notes as plain text instead of markdown. -> bool
  disable-markdown: false,
) = {
  let time-config(value, name, tag) = {
    let value = if type(value) == datetime {
      value.display("[hour padding:zero repr:24]:[minute padding:zero]")
    } else if type(value) == str {
      value
    } else {
      panic(name + " must be a datetime or a string in HH:MM format")
    }
    [#metadata((t: tag, v: value))<pdfpc>]
  }

  if duration-minutes != none {
    [#metadata((t: "Duration", v: duration-minutes))<pdfpc>]
  }
  if start-time != none { time-config(start-time, "start-time", "StartTime") }
  if end-time != none { time-config(end-time, "end-time", "EndTime") }
  if last-minutes != none {
    [#metadata((t: "LastMinutes", v: last-minutes))<pdfpc>]
  }
  if note-font-size != none {
    [#metadata((t: "NoteFontSize", v: note-font-size))<pdfpc>]
  }
  [#metadata((t: "DisableMarkdown", v: disable-markdown))<pdfpc>]
}

/// The per-page markers. Emitted by `slide()` inside the page, so that
/// `here().page()` is the physical page the markers belong to.
/// -> content
#let pdfpc-page-markers(
  /// Speaker note for this page. -> none | str | raw
  note: none,
) = context {
  [#metadata((t: "NewSlide"))<pdfpc>]
  [#metadata((t: "Idx", v: here().page() - 1))<pdfpc>]
  [#metadata((t: "Overlay", v: _subslide.get() - 1))<pdfpc>]
  [#metadata((
    t: "LogicalSlide",
    v: calc.max(1, logical-slide.get().first()),
  ))<pdfpc>]
  if note != none { speaker-note(note) }
}

/// Collect every `<pdfpc>` marker into the `pdfpcFormat: 2` document and
/// publish it as `<pdfpc-file>`. Installed once by the slide engine.
/// -> content
#let pdfpc-file(
  /// The location the collector runs at, i.e. `here()`. -> location
  loc,
) = {
  let arr = query(<pdfpc>).map(it => it.value)
  let (config, ..slides) = arr.split((t: "NewSlide"))
  let pdfpc = (pdfpcFormat: 2, disableMarkdown: false)
  let camel(name) = lower(name.at(0)) + name.slice(1)

  for item in config {
    pdfpc.insert(camel(item.t), item.v)
  }

  let pages = ()
  for slide in slides {
    let entry = (
      idx: 0,
      label: "1",
      overlay: 0,
      forcedOverlay: false,
      hidden: false,
    )
    for item in slide {
      if item.t == "Idx" {
        entry.idx = item.v
      } else if item.t == "LogicalSlide" {
        entry.label = str(item.v)
      } else if item.t == "Overlay" {
        entry.overlay = item.v
        entry.forcedOverlay = item.v > 0
      } else if item.t == "HiddenSlide" {
        entry.hidden = true
      } else if item.t == "SaveSlide" {
        if "savedSlide" not in pdfpc { pdfpc.savedSlide = int(entry.label) - 1 }
      } else if item.t == "EndSlide" {
        if "endSlide" not in pdfpc { pdfpc.endSlide = int(entry.label) - 1 }
      } else if item.t == "Note" {
        entry.note = if "note" in entry { entry.note + "\n\n" + item.v } else {
          item.v
        }
      } else {
        pdfpc.insert(camel(item.t), item.v)
      }
    }
    pages.push(entry)
  }
  pdfpc.insert("pages", pages)
  [#metadata(pdfpc)<pdfpc-file>]
}
