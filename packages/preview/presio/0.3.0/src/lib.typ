// presio: attach speaker notes and embedded media to PDF slides for presio.xyz

#let _mime-for-ext(ext) = if ext == "gif" {
  "image/gif"
} else if ext == "mp4" {
  "video/mp4"
} else if ext == "webm" {
  "video/webm"
} else if ext == "html" or ext == "htm" {
  "text/html"
} else {
  "application/octet-stream"
}

// Anchored at the scheme so the id is only picked up when YouTube is the
// actual host — an unanchored pattern also matches a YouTube link that merely
// appears inside some other site's query string. `(?:[A-Za-z0-9-]+\.)*` covers
// `www.`, `m.`, and a bare host.
#let _youtube-id(url) = {
  let m = url.match(
    regex(
      "^https?://(?:[A-Za-z0-9-]+\.)*(?:youtube(?:-nocookie)?\.com/(?:watch\?(?:[^ ]*&)?v=|embed/|shorts/|live/)|youtu\.be/)([A-Za-z0-9_-]{11})",
    ),
  )
  if m != none { m.captures.first() } else { none }
}

#let _vimeo-id(url) = {
  let m = url.match(
    regex(
      "^https?://(?:[A-Za-z0-9-]+\.)*vimeo\.com/(?:video/|channels/[^/]+/|groups/[^/]+/videos/)?(\d+)",
    ),
  )
  if m != none { m.captures.first() } else { none }
}

// A path's text as Typst prints it: root-absolute and normalised
// ("/figures/demo.gif"). Typst 0.15 doesn't expose path → string directly.
#let _path-str(p) = {
  let m = repr(p).match(regex("^path\\(\"(.+)\"\\)$"))
  if m != none { m.captures.first() } else { none }
}

// `to` as a URL relative to the folder `from` (a file) is in; both are
// root-absolute, as `_path-str` gives them.
#let _relative(from, to) = {
  let a = from.split("/").slice(0, -1)
  let b = to.split("/")
  let i = 0
  while i < a.len() and i < b.len() - 1 and a.at(i) == b.at(i) { i += 1 }
  (("..",) * (a.len() - i) + b.slice(i)).join("/")
}

#let _b64-chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".clusters()

// Base64 of `data` (bytes). Typst has no encoder of its own; this one does
// roughly half a megabyte a second.
#let _b64(data) = array(data).chunks(3).map(c => {
  let v = c.at(0) * 65536 + c.at(1, default: 0) * 256 + c.at(2, default: 0)
  let s = _b64-chars.at(calc.div-euclid(v, 262144)) + _b64-chars.at(calc.rem(calc.div-euclid(v, 4096), 64))
  s += if c.len() > 1 { _b64-chars.at(calc.rem(calc.div-euclid(v, 64), 64)) } else { "=" }
  s += if c.len() > 2 { _b64-chars.at(calc.rem(v, 64)) } else { "=" }
  s
}).join(default: "")

// Asset files an HTML animation's bundle carries as text; the rest go in
// base64.
#let _text-exts = ("html", "htm", "js", "mjs", "css", "json", "svg", "txt", "csv", "xml", "glsl", "frag", "vert")

// An HTML animation's assets as `(rel, src)` pairs: `rel` is the URL the page
// uses for the file (relative to the page), `src` the file. `assets` is an
// array of paths (each made relative to `entry`) or a dictionary from URL to
// path.
#let _assets(entry, assets) = {
  let pairs = if type(assets) == dictionary {
    assets.pairs().map(((rel, src)) => (rel: rel, src: src))
  } else {
    assets.map(src => (rel: none, src: src))
  }
  pairs.map(a => {
    assert(type(a.src) == path, message: "presio.media: each of `assets` must be a path, as `path(\"anim/app.js\")`")
    let rel = if a.rel != none { a.rel } else { _relative(_path-str(entry), _path-str(a.src)) }
    (rel: rel, src: a.src)
  })
}

// The frame document of an HTML animation: the bundle (entry page + assets)
// and the runtime that loads it and owns its clock. Byte for byte what
// Presio's media plugin builds (client/plugins/media/bundle.ts), so the
// animation behaves the same in both.
#let _html-srcdoc(entry, assets, options) = {
  let files = ("index.html": (text: read(entry)))
  for a in assets {
    let ext = lower(a.rel.split("?").first().split(".").last())
    files.insert(a.rel, if ext in _text-exts { (text: read(a.src)) } else { (b64: _b64(read(a.src, encoding: none))) })
  }
  // "<" only appears inside JSON strings; escaped, it can't close the
  // <script> the bundle sits in.
  let bundle = json.encode((entry: "index.html", files: files, options: options), pretty: false).replace("<", "\\u003c")
  (
    "<!doctype html><html><head><meta charset=\"utf-8\">"
      + "<script type=\"application/json\" id=\"presio-bundle\">"
      + bundle
      + "</script><script>"
      + read("html-runtime.js")
      + "</script></head></html>"
  )
}

// A Typst length or ratio as CSS, or `fallback` for auto / anything else.
#let _css-size(v, fallback) = if type(v) == ratio {
  str(v / 1%) + "%"
} else if type(v) == length {
  str(v.pt()) + "pt"
} else { fallback }

// What a `media` source is: its kind (file / html / url / youtube / vimeo),
// the id and MIME type the sidecar carries, and its extension.
#let _classify(source, name) = {
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
    let p = _path-str(source)
    if p != none { p.split("/").last() } else { "media" }
  } else { source }
  let ref-name = if name != none { name } else { derived-name }

  let yt-id = if is-url { _youtube-id(source) } else { none }
  let vimeo-id = if is-url and yt-id == none { _vimeo-id(source) } else { none }
  let ext-source = ref-name.split("?").first().split("#").first()
  let ext = lower(ext-source.split(".").last())
  let kind = if is-path {
    if ext == "html" or ext == "htm" { "html" } else { "file" }
  } else if yt-id != none {
    "youtube"
  } else if vimeo-id != none {
    "vimeo"
  } else {
    "url"
  }
  let mime = if kind == "youtube" or kind == "vimeo" {
    "text/html"
  } else {
    _mime-for-ext(ext)
  }
  (
    is-path: is-path,
    is-url: is-url,
    ref-name: ref-name,
    kind: kind,
    ext: ext,
    mime: mime,
    yt-id: yt-id,
    vimeo-id: vimeo-id,
    safe-id: ref-name.replace(regex("[^A-Za-z0-9]"), "_"),
  )
}

// `media` in HTML export: the media itself, as an element of the page.
#let _media-html(
  source,
  name: none,
  width: auto,
  height: auto,
  autoplay: true,
  loop: true,
  placeholder: auto,
  aspect-ratio: none,
  assets: (),
  controls: true,
  interactive: true,
  duration: none,
) = {
  let c = _classify(source, name)
  let w = _css-size(width, "100%")
  let h = if type(height) == length {
    "height:" + str(height.pt()) + "pt"
  } else {
    "aspect-ratio:" + str(if aspect-ratio != none { float(aspect-ratio) } else { 16 / 9 })
  }
  let style = "display:block;border:0;max-width:100%;width:" + w + ";" + h
  let bool-attrs(..pairs) = pairs.named().pairs().filter(((k, v)) => v).map(((k, v)) => (k, "")).to-dict()
  if c.kind == "html" {
    let options = (
      autoplay: autoplay,
      loop: loop,
      controls: controls,
      interactive: interactive,
    )
    if duration != none { options.insert("duration", duration) }
    html.elem("iframe", attrs: (
      srcdoc: _html-srcdoc(source, _assets(source, assets), options),
      sandbox: "allow-scripts",
      allow: "autoplay",
      title: c.ref-name,
      style: style,
    ))
  } else if c.kind == "youtube" or c.kind == "vimeo" {
    let src = if c.kind == "youtube" {
      "https://www.youtube-nocookie.com/embed/" + c.yt-id
    } else {
      "https://player.vimeo.com/video/" + c.vimeo-id
    }
    html.elem("iframe", attrs: (
      src: src,
      title: c.ref-name,
      allow: "autoplay; encrypted-media; fullscreen; picture-in-picture",
      allowfullscreen: "",
      style: style,
    ))
  } else if c.mime.starts-with("video/") {
    let src = if c.is-path { "data:" + c.mime + ";base64," + _b64(read(source, encoding: none)) } else { source }
    html.elem("video", attrs: (
      src: src,
      style: style + ";object-fit:cover",
      ..bool-attrs(controls: true, muted: true, playsinline: true, autoplay: autoplay, loop: loop),
    ))
  } else if c.is-url {
    html.elem("img", attrs: (src: source, alt: "", style: style + ";object-fit:cover"))
  } else if placeholder != auto and placeholder != none {
    placeholder
  } else {
    image(source, width: if type(width) in (ratio, length) { width } else { auto }, alt: c.ref-name)
  }
}

// `media` in PDF export: the placeholder, plus the sidecar (and file) presio
// reads to play it.
#let _media-pdf(
  source,
  name: none,
  width: auto,
  height: auto,
  autoplay: true,
  loop: true,
  placeholder: auto,
  aspect-ratio: none,
  assets: (),
  sync: "presenter",
  controls: true,
  interactive: true,
  duration: none,
  poster-at: none,
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
    let c = _classify(source, name)
    let (is-path, ref-name, kind, ext, mime, yt-id, vimeo-id, safe-id) = (
      c.is-path,
      c.ref-name,
      c.kind,
      c.ext,
      c.mime,
      c.yt-id,
      c.vimeo-id,
      c.safe-id,
    )
    assert(
      kind == "html" or assets.len() == 0,
      message: "presio.media: `assets` only applies to an HTML animation (a path to an .html file)",
    )
    let html-assets = if kind == "html" { _assets(source, assets) } else { () }

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
    // The position of the *context element* is where the media call appears
    // in the flow, not where the block is finally laid out: an enclosing
    // `align(center)` (or any alignment / placement) moves the block but not
    // the context element, so `here().position()` reports the un-aligned
    // origin. Drop an out-of-flow anchor at the block's own top-left corner
    // and read its position back through introspection instead.
    // The anchor carries the resolved size too, so the whole geometry that
    // goes into the sidecar is observable from a test via `query`.
    let src-key = if is-path { repr(source) } else { source }
    let anchor = [#metadata((id: safe-id, src: src-key, kind: kind, mime: mime, w: w, h: h)) <_presio-media-anchor>]
    let same-id = query(<_presio-media-anchor>).filter(el => el.value.id == safe-id)

    let anchors = same-id.filter(el => el.location().page() == page-num)
    let pos = if anchors.len() > 0 {
      anchors.first().location().position()
    } else {
      here().position()
    }

    let media-filename = if kind == "file" or kind == "html" {
      "media-" + safe-id + "." + ext
    } else { none }
    // An animation's assets, numbered so two paths that normalise alike
    // still get their own attachment.
    let asset-files = html-assets
      .enumerate()
      .map(((i, a)) => (
        path: a.rel,
        filename: "media-asset-" + safe-id + "-" + str(i + 1) + "-" + a.rel.replace(regex("[^A-Za-z0-9.]"), "_"),
        src: a.src,
      ))

    // The binary is attached once for the whole document, on the lowest page
    // that references it — the name has no page in it, so re-attaching per
    // slide is a hard "attached twice" error. That bites whenever one file is
    // reused (a logo on every slide) and, notably, whenever file media sits in
    // a touying overlay group: `#pause` repeats it across subslide pages.
    // `same-src` is empty on the pre-introspection pass, when attaching would
    // duplicate; the later passes settle on exactly one attach.
    //
    // Keyed on (id, source) rather than id alone: two *different* sources can
    // normalise to one `safe-id` (`a-b.gif` and `a_b.gif` both give
    // `a_b_gif`), and those must still each attach under that name so Typst
    // raises "attached twice" — a loud collision beats silently serving one
    // file in place of the other. The fix at the call site is `name:`.
    let same-src = same-id.filter(el => el.value.src == src-key)
    if media-filename != none and same-src.len() > 0 and page-num == calc.min(..same-src.map(el => el.location().page())) {
      pdf.attach(
        media-filename,
        read(source, encoding: none),
        mime-type: mime,
        description: "Media: " + ref-name,
      )
      for a in asset-files {
        pdf.attach(
          a.filename,
          read(a.src, encoding: none),
          description: "Media asset: " + ref-name + " / " + a.path,
        )
      }
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
    } else if kind == "html" {
      let extra = (
        filename: media-filename,
        sync: sync,
        controls: controls,
        interactive: interactive,
      )
      if asset-files.len() > 0 { extra.insert("assets", asset-files.map(a => (path: a.path, filename: a.filename))) }
      if duration != none { extra.insert("duration", duration) }
      if poster-at != none { extra.insert("poster_at", poster-at) }
      meta + extra
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
      {
        place(top + left, anchor)
        if resolved-placeholder != none {
          resolved-placeholder
        } else {
          align(center + horizon, text(fill: white)[▶ #ref-name])
        }
      },
    )
  })
)

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
//
// HTML animations: a path to an `.html` file is played as an animation — the
// page runs in a sandboxed frame on a clock presio plays, pauses and seeks,
// and keeps in time on every screen. Options that only apply to them:
//   - `assets`: the files the page loads (scripts, stylesheets, images,
//     data). An array of paths, each reached from the page by its path
//     relative to the page (`path("anim/js/app.js")` next to
//     `anim/index.html` is `js/app.js`), or a dictionary from the URL the
//     page uses to the path. Each is attached to the PDF.
//   - `sync`: "presenter" (default): viewers follow the presenter.
//     "independent": each viewer plays it themselves. The presenter can
//     switch between the two while presenting.
//   - `controls`: viewers playing it themselves get play / pause, restart and
//     a scrubber (when the length is known). Default true; the presenter
//     always has them. In HTML export: whether the page shows them.
//   - `interactive`: clicks, drags and hovers reach the page. Default true.
//     What the presenter changes reaches viewers following (and everyone on
//     "Sync"): form fields by themselves, other state when the page calls
//     `presio.sync({ get, set })`.
//   - `duration`: its length in seconds, for the scrubber and looping.
//     Without it, it's measured from its CSS animations when those are all
//     it runs; otherwise it plays open-ended.
//   - `poster-at`: the moment, in seconds, Presio shows as its preview (in
//     thumbnails, the next-slide view and a PDF downloaded from Presio).
//     Default: near the end, or 2 s in when it has no set length. The PDF
//     itself shows `placeholder`.
//
// Exported to HTML (`typst compile --features html --format html`), media
// becomes the real thing on the page: the animation in a sandboxed <iframe>
// (with its controls), a <video>, an image, or a YouTube / Vimeo embed.
#let media(
  source,
  name: none,
  width: auto,
  height: auto,
  autoplay: true,
  loop: true,
  placeholder: auto,
  aspect-ratio: none,
  assets: (),
  sync: "presenter",
  controls: true,
  interactive: true,
  duration: none,
  poster-at: none,
) = context {
  assert(
    sync in ("presenter", "independent"),
    message: "presio.media: `sync` must be \"presenter\" or \"independent\"",
  )
  assert(
    duration == none or (type(duration) in (int, float) and duration > 0),
    message: "presio.media: `duration` must be a number of seconds > 0",
  )
  assert(
    poster-at == none or (type(poster-at) in (int, float) and poster-at >= 0),
    message: "presio.media: `poster-at` must be a number of seconds >= 0",
  )
  if target() == "html" {
    _media-html(
      source,
      name: name,
      width: width,
      height: height,
      autoplay: autoplay,
      loop: loop,
      placeholder: placeholder,
      aspect-ratio: aspect-ratio,
      assets: assets,
      controls: controls,
      interactive: interactive,
      duration: duration,
    )
  } else {
    _media-pdf(
      source,
      name: name,
      width: width,
      height: height,
      autoplay: autoplay,
      loop: loop,
      placeholder: placeholder,
      aspect-ratio: aspect-ratio,
      assets: assets,
      sync: sync,
      controls: controls,
      interactive: interactive,
      duration: duration,
      poster-at: poster-at,
    )
  }
}

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
