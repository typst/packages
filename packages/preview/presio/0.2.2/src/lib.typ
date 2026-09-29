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
//   - a `path` (constructed with `path("figures/demo.gif")` at the call
//     site): a local file. The bytes are read and attached to the PDF.
//     For image formats (png, jpg, gif, svg, webp) the in-slide preview
//     defaults to `image(source)`; video files (mp4, webm) get a dark
//     block unless an explicit `placeholder` is given.
//   - a string starting with "http://" or "https://": a URL. Nothing is
//     attached to the PDF; the viewer fetches the URL at presentation
//     time. YouTube and Vimeo URLs are detected automatically.
//
// `name` is normally derived from the path's filename. Pass it
// explicitly to override the attachment filename / MIME sniffing.
//
// `placeholder`:
//   - `auto` (default): for local image files, use `image(source)`;
//     for videos and URLs, draw a dark block.
//   - `none`: force a dark block.
//   - any `content`: rendered as the preview.
//
// Videos play muted (no audio).
#let media(
  source,
  name: none,
  width: auto,
  height: auto,
  autoplay: true,
  loop: true,
  placeholder: auto,
  aspect-ratio: none,
) = (
  layout(container => context {
    // Use the physical page (`here().page()`), not the logical page counter.
    // Under touying, `counter(page)` returns the same value for every
    // subslide of an overlay group, so content that appears on multiple
    // subslides would collide on a single attachment name (and Typst errors
    // on a duplicate attachment). `here().page()` advances per physical page,
    // matching how the presio viewer flips through the PDF — and matching
    // what `speaker-notes` already uses. (In polylux the two agree.)
    let page-num = here().page()
    let is-path = type(source) == path
    let is-url = (
      type(source) == str
        and (
          source.starts-with("http://") or source.starts-with("https://")
        )
    )
    assert(
      is-path or is-url,
      message: "presio.media: `source` must be a path or a http(s) URL string",
    )

    let derived-name = if is-path {
      // Typst 0.15 doesn't expose path → string directly; parse repr().
      let m = repr(source).match(regex("^path\\(\"(.+)\"\\)$"))
      if m != none { m.captures.first().split("/").last() } else { "media" }
    } else { source }
    let ref-name = if name != none { name } else { derived-name }

    let yt-id = if is-url { _youtube-id(source) } else { none }
    let vimeo-id = if is-url and yt-id == none { _vimeo-id(source) } else { none }
    let kind = if is-path {
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

    // `image()` can't decode video files, so the auto-preview only applies
    // to extensions Typst can actually render; videos fall back to the
    // dark block (pass an explicit `placeholder` for a poster frame).
    let image-exts = ("png", "jpg", "jpeg", "gif", "svg", "svgz", "webp")
    let resolved-placeholder = if placeholder == auto {
      if is-path and ext in image-exts { image(source) } else { none }
    } else { placeholder }

    let w = if width == auto {
      if resolved-placeholder != none {
        let natural = measure(resolved-placeholder)
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
    } else if resolved-placeholder != none {
      let natural = measure(resolved-placeholder)
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
        read(source, encoding: none),
        mime-type: mime,
        description: "Media: " + ref-name,
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
      fill: if resolved-placeholder == none { rgb("#222") } else { none },
      radius: 6pt,
      clip: true,
      if resolved-placeholder != none {
        resolved-placeholder
      } else {
        align(center + horizon, text(fill: white)[▶ #ref-name])
      },
    )
  })
)

#let _presio-notes-counter = counter("_presio-notes-call")

// Attach speaker notes to the current slide as a JSON sidecar
// (`notes-slide-<N>.json`) consumed by the presio viewer.
//
// Multiple calls on the same slide are concatenated into a single
// attachment whose `notes` field is a list, in source order. Dedup is
// counter-based — each call stamps its sequence number into the
// metadata and only the call with the max number on a slide emits the
// `pdf.attach`. (y-position dedup collides when calls are stacked
// back-to-back with no separator content.)
#let speaker-notes(notes) = {
  _presio-notes-counter.step()
  context {
    let n = _presio-notes-counter.get().first()
    [#metadata((notes: notes, n: n)) <_presio-notes>]
    let pg = here().page()
    let on-slide = query(<_presio-notes>).filter(el => el.location().page() == pg)
    // `on-slide` is empty during early introspection passes (before
    // metadata is observed). Skip emission until our own metadata is
    // visible — by then `max-n` reflects the final state.
    if on-slide.len() > 0 and n == calc.max(..on-slide.map(el => el.value.n)) {
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
