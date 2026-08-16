// presio: attach speaker notes and embedded media to PDF slides for presio.xyz

#let _mime-for-ext(ext) = if ext == "gif" {
  "image/gif"
} else if ext == "mp4" {
  "video/mp4"
} else if ext == "webm" {
  "video/webm"
} else {
  "application/octet-stream"
}

#let _youtube-id(url) = {
  let m = url.match(
    regex(
      "(?:youtube\.com/watch\?(?:[^ ]*&)?v=|youtu\.be/|youtube(?:-nocookie)?\.com/embed/|youtube\.com/shorts/)([A-Za-z0-9_-]{11})",
    ),
  )
  if m != none { m.captures.first() } else { none }
}

#let _vimeo-id(url) = {
  let m = url.match(regex("vimeo\.com/(?:video/|channels/[^/]+/|groups/[^/]+/videos/)?(\d+)"))
  if m != none { m.captures.first() } else { none }
}

// Embed a gif / mp4 / webm to be played by the presio viewer.
//
// `source` is one of:
//   - bytes: the binary contents of a local file, typically produced by
//     `read("path/to/file.ext", encoding: none)` at the call site.
//     When `source` is bytes, `name` is REQUIRED — it is used as the
//     PDF attachment filename and to sniff the MIME type.
//   - a string starting with "http://" or "https://": a URL. Nothing is
//     attached to the PDF; the viewer fetches the URL at presentation
//     time.
//
// `placeholder` is optional `content` rendered in the slide where the
// media will appear (e.g. `image("figures/demo.gif")`). If omitted, a
// dark block is drawn.
//
// Videos play muted (no audio).
#let media(
  source,
  name: none,
  width: auto,
  height: auto,
  autoplay: true,
  loop: true,
  placeholder: none,
  aspect-ratio: none,
) = (
  layout(container => context {
    let page-num = counter(page).get().first()
    let is-url = (
      type(source) == str
        and (
          source.starts-with("http://") or source.starts-with("https://")
        )
    )

    let ref-name = if is-url { source } else {
      assert(
        name != none,
        message: "presio.media: `name` is required when `source` is bytes",
      )
      name
    }
    let yt-id = if is-url { _youtube-id(source) } else { none }
    let vimeo-id = if is-url and yt-id == none { _vimeo-id(source) } else { none }
    let kind = if not is-url {
      "file"
    } else if yt-id != none {
      "youtube"
    } else if vimeo-id != none {
      "vimeo"
    } else {
      "url"
    }

    let safe-id = ref-name.replace(regex("[^A-Za-z0-9]"), "_")
    let ext-source = ref-name.split("?").first().split("#").first()
    let ext = lower(ext-source.split(".").last())
    let mime = if kind == "youtube" or kind == "vimeo" {
      "text/html"
    } else {
      _mime-for-ext(ext)
    }

    let w = if width == auto {
      if placeholder != none {
        let natural = measure(placeholder)
        if natural.width > 0pt { natural.width } else { container.width }
      } else {
        container.width
      }
    } else if type(width) == ratio {
      container.width * width
    } else {
      width
    }
    let h = if height != auto {
      if type(height) == ratio { container.height * height } else { height }
    } else if aspect-ratio != none {
      w / aspect-ratio
    } else if placeholder != none {
      let natural = measure(placeholder)
      if natural.width > 0pt {
        w * (natural.height / natural.width)
      } else {
        w * 9 / 16
      }
    } else {
      w * 9 / 16
    }
    let pos = here().position()

    let media-filename = if kind == "file" {
      "media-" + safe-id + "." + ext
    } else { none }

    if kind == "file" {
      pdf.attach(
        media-filename,
        source,
        mime-type: mime,
        description: "Media: " + name,
      )
    }

    let meta = (
      kind: kind,
      slide: page-num,
      id: safe-id,
      mime: mime,
      x_pt: pos.x.pt(),
      y_pt: pos.y.pt(),
      w_pt: w.pt(),
      h_pt: h.pt(),
      autoplay: autoplay,
      loop: loop,
    )
    let meta-with-source = if kind == "file" {
      meta + (filename: media-filename)
    } else if kind == "youtube" {
      meta + (url: source, video_id: yt-id)
    } else if kind == "vimeo" {
      meta + (url: source, video_id: vimeo-id)
    } else {
      meta + (url: source)
    }
    pdf.attach(
      "media-slide-" + str(page-num) + "-" + safe-id + ".json",
      bytes(json.encode(meta-with-source)),
      mime-type: "application/json",
      description: "Media placement for slide " + str(page-num),
    )

    block(
      width: w,
      height: h,
      fill: if placeholder == none { rgb("#222") } else { none },
      radius: 6pt,
      clip: true,
      if placeholder != none {
        placeholder
      } else {
        align(center + horizon, text(fill: white)[▶ #ref-name])
      },
    )
  })
)

// Attach speaker notes to the current slide as a JSON sidecar
// (`notes-slide-<N>.json`) consumed by the presio viewer.
//
// Multiple calls on the same slide are concatenated into a single
// attachment whose `notes` field is a list, in source order.
#let speaker-notes(notes) = {
  [#metadata((notes: notes)) <_presio-notes>]
  context {
    let here-loc = here()
    let pg = here-loc.page()
    let on-slide = query(<_presio-notes>).filter(el => el.location().page() == pg)
    // Only the context that follows the LAST metadata on this slide emits
    // the pdf.attach, so we emit exactly one attachment per slide.
    let last-meta-y = on-slide.last().location().position().y
    if here-loc.position().y >= last-meta-y {
      let all-notes = on-slide.map(el => el.value.notes)
      pdf.attach(
        "notes-slide-" + str(pg) + ".json",
        bytes(json.encode((slide: str(pg), notes: all-notes))),
        mime-type: "application/json",
        description: "Speaker notes for slide " + str(pg),
      )
    }
  }
}
