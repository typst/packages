# presio

Attach **speaker notes**, **embedded media** (GIF / MP4 / WebM, YouTube /
Vimeo) and **HTML animations** to PDF slides so they can be presented with the
[presio.xyz](https://presio.xyz) viewer.

`presio` is framework-agnostic — it works with [polylux](https://typst.app/universe/package/polylux),
[touying](https://typst.app/universe/package/touying), or plain Typst pages. It
only contributes two functions; layout and slide flow are up to your existing
template.

[![Present the Touying demo](https://img.shields.io/badge/Present%20the%20Touying%20demo-7C3AED)](https://presio.xyz/present?from=https://github.com/benedict-armstrong/presio-typst-package/blob/v0.3.0/examples/touying/example.pdf)
[![Present the polylux demo](https://img.shields.io/badge/Present%20the%20polylux%20demo-7C3AED)](https://presio.xyz/present?from=https://github.com/benedict-armstrong/presio-typst-package/blob/v0.3.0/examples/polylux/example.pdf)
[![Present the HTML animation demo](https://img.shields.io/badge/Present%20the%20HTML%20animation%20demo-7C3AED)](https://presio.xyz/present?from=https://github.com/benedict-armstrong/presio-typst-package/blob/v0.3.0/examples/html-animation/example.pdf)
[![Present the workshop demo](https://img.shields.io/badge/Present%20the%20workshop%20demo-7C3AED)](https://presio.xyz/present?from=https://github.com/benedict-armstrong/presio-typst-package/blob/v0.3.0/examples/workshop/example.pdf)
[![Present the plain demo](https://img.shields.io/badge/Present%20the%20plain%20demo-7C3AED)](https://presio.xyz/present?from=https://github.com/benedict-armstrong/presio-typst-package/blob/v0.3.0/examples/plain/example.pdf)

## Install

```typ
#import "@preview/presio:0.3.0": media, speaker-notes
```

Requires Typst 0.15 or newer (for the file `path` type). Users on Typst
0.13–0.14 can pin to `@preview/presio:0.1.0`, which has a slightly more
verbose bytes-based API.

## Usage

### Speaker notes

```typ
= Introduction

Hello world.

#speaker-notes[
  Remember to mention the funding agency before the next slide.
]
```

A JSON sidecar `notes-slide-<N>.json` is attached to the PDF. Multiple
`speaker-notes[…]` calls on the same slide are concatenated into a single
attachment, in source order.

### Embedded media (local file)

```typ
#media(path("figures/demo.gif"), width: 60%)
```

`path("…")` is Typst 0.15's file-path type — it resolves relative to the
file that constructed it, so the package can `read()` and `image()` the
target on the caller's behalf. The bytes are embedded in the PDF via
`pdf.attach` and a placement descriptor JSON is written alongside it.

By default the in-slide preview is `image(source)`. For MP4 / WebM
(which Typst can't render directly) pass an explicit `placeholder:
image("poster.png")`, or `placeholder: none` to get a dark block.

### Embedded media (URL)

```typ
#media(
  "https://upload.wikimedia.org/wikipedia/commons/2/2c/Rotating_earth_%28large%29.gif",
  width: 40%,
  aspect-ratio: 1,
)
```

Nothing is attached to the PDF; the viewer fetches the URL at presentation time.

### YouTube / Vimeo

URLs from YouTube (`youtube.com/watch?v=…`, `youtu.be/…`, `youtube.com/embed/…`,
`youtube.com/shorts/…`, `youtube.com/live/…`, `youtube-nocookie.com/embed/…`,
and any subdomain such as `m.youtube.com`) and Vimeo (`vimeo.com/<id>`,
`vimeo.com/video/<id>`, `player.vimeo.com/video/<id>`,
`vimeo.com/channels/<channel>/<id>`, `vimeo.com/groups/<group>/videos/<id>`)
are detected automatically and emitted with `kind: "youtube"` / `kind: "vimeo"` plus an extracted `video_id`
the viewer can use to build an iframe embed.

```typ
#media("https://www.youtube.com/watch?v=dQw4w9WgXcQ", width: 60%, aspect-ratio: 16/9)
#media("https://vimeo.com/76979871", width: 60%, aspect-ratio: 16/9)
```

### HTML animations

Point `media` at an `.html` file and it's played as an animation: presio runs
the page in a sandboxed frame, on a clock it plays, pauses, seeks and keeps in
time on every screen — `requestAnimationFrame`, timers, CSS and Web
Animations, SVG animations and `<video>` all follow it. List the files the
page loads in `assets`; each is attached to the PDF and reached by the page at
its path relative to the page.

```typ
#media(
  path("orbit/index.html"),
  assets: (path("orbit/js/main.js"), path("orbit/js/planets.js"), path("orbit/css/style.css")),
  width: 70%,
  aspect-ratio: 16/9,
)
```

Relative URLs work wherever the page uses them: in `src` / `href`, in CSS
`url()` and `@import`, in ES module imports, and in `fetch`, XHR and `src`
set from script. Absolute URLs (a library from a CDN) load from the network
as usual. To give an asset a different URL than its path, pass a dictionary:
`assets: ("lib/d3.js": path("vendor/d3.v7.min.js"))`.

By default viewers follow the presenter. `sync: "independent"` hands the
animation to each viewer instead, with its own controls (play / pause,
restart, a scrubber when the length is known) and its own clicks and drags.
The presenter can switch between the two at any time from the animation's
controls.

```typ
#media(path("explorer.html"), sync: "independent", duration: 12, width: 80%)
```

What the presenter changes on the page reaches viewers following them, and
every viewer when the presenter presses **Sync**. Form fields (sliders,
checkboxes, selects, text) come along by themselves. Anything else, the page
hands over with `presio.sync`. `get` returns JSON-able data, and Presio asks for
it a few times a second. `set` receives a copy of the presenter's data:

```js
if (window.presio) presio.sync({
  get: () => ({ points }),
  set: (s) => { points = s.points; },
});
```

Keep it small (it has to fit in 15 KB). The state also survives seeking back,
but not a restart.

Presio previews the animation where it can't run it: slide thumbnails, the
next-slide view, and PDFs downloaded from Presio show a frame from near its
end (2 s in when it has no set length). Pick another with `poster-at:`
seconds. The PDF Typst writes shows `placeholder`, as for other media.

The page is sandboxed: its scripts run, but on an opaque origin, with no
access to presio, the deck or the viewer's storage (so `localStorage` and
cookies are unavailable inside it).

### HTML export

Compiled with Typst's (experimental) HTML export,
`typst compile --features html --format html deck.typ`, `media` puts the real
thing on the page: an HTML animation in a sandboxed `<iframe>` — the same
runtime as in presio, so it plays the same, with its controls unless
`controls: false` — a `<video>`, an image, or a YouTube / Vimeo embed.
Local video files are inlined as base64, which takes the compiler about two
seconds per megabyte. Note that Typst's HTML export leaves out anything inside
`align`, so wrap media in `align` only for PDF output.

## `media` parameters

| Parameter      | Default | Notes                                                                                                       |
| -------------- | ------- | ----------------------------------------------------------------------------------------------------------- |
| `source`       | —       | Either a `path` (from `path("…")`) or a `http(s)://` URL string                                             |
| `name`         | `none`  | Override for the attachment filename / MIME sniff. Auto-derived from the path's filename when omitted.      |
| `placeholder`  | `auto`  | `auto` → `image(source)` for files, dark block for URLs. `none` → force dark block. Any `content` → use it. |
| `width`        | `auto`  | Length, ratio of the container width, or `auto` (natural width of `placeholder`, else container width)      |
| `height`       | `auto`  | Length, ratio, or `auto` (derived from `placeholder` / `aspect-ratio` / 16:9)                               |
| `aspect-ratio` | `none`  | Width/height ratio, e.g. `16/9`                                                                             |
| `autoplay`     | `true`  | Forwarded to the viewer                                                                                     |
| `loop`         | `true`  | Forwarded to the viewer                                                                                     |
| `assets`       | `()`    | HTML animations: the files the page loads. An array of paths, or a dictionary from the URL the page uses to a path. |
| `sync`         | `"presenter"` | HTML animations: `"presenter"` (viewers follow) or `"independent"` (each viewer plays it). Switchable live. |
| `controls`     | `true`  | HTML animations: controls for viewers playing it themselves, and in HTML export. The presenter always has them. |
| `interactive`  | `true`  | HTML animations: clicks, drags and hovers reach the page.                                                   |
| `duration`     | `none`  | HTML animations: length in seconds, for the scrubber and looping. Measured from CSS animations when omitted and those are all it runs. |
| `poster-at`    | `none`  | HTML animations: the moment (seconds) Presio uses as its preview in thumbnails, the next-slide view and PDFs downloaded from Presio. Defaults to near the end, or 2 s in when open-ended. |

## Supported media types

The MIME is sniffed from the extension of the source path's filename (file mode) or the URL (URL mode):

| Extension | MIME         |
| --------- | ------------ |
| `.gif`    | `image/gif`  |
| `.mp4`    | `video/mp4`  |
| `.webm`   | `video/webm` |
| `.html`   | `text/html` (an HTML animation) |

## Sidecar JSON schemas

**`notes-slide-<N>.json`** — `notes` is always an array (one entry per
`speaker-notes` call on that slide, in source order):

```json
{ "slide": "3", "notes": [ "<typst content>", "<typst content>" ] }
```

**`media-slide-<N>-<id>.json`**

Common fields: `kind`, `slide`, `id`, `mime`, `x_pt`, `y_pt`, `w_pt`, `h_pt`,
`autoplay`, `loop`. The remaining fields depend on `kind`:

| `kind`    | Extra fields                     |
| --------- | -------------------------------- |
| `file`    | `filename` (PDF attachment name) |
| `url`     | `url` (direct media URL)         |
| `youtube` | `url`, `video_id`                |
| `vimeo`   | `url`, `video_id`                |
| `html`    | `filename` (the page), `sync`, `controls`, `interactive`, and when given `assets` (`[{ "path", "filename" }]`, one attachment each), `duration` and `poster_at` |

```json
{
  "kind": "file",
  "slide": 3,
  "id": "demo_gif",
  "mime": "image/gif",
  "x_pt": 72.0, "y_pt": 120.0, "w_pt": 432.0, "h_pt": 243.0,
  "autoplay": true,
  "loop": true,
  "filename": "media-demo_gif.gif"
}
```

## Examples

A complete deck for each supported workflow lives under `examples/`. Each
folder is self-contained (its own `demo.gif`) and is compiled to PDF
alongside the source.

| Framework   | Source                                                                                                                                | Compiled PDF                                                                                                         |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| Plain Typst | [`examples/plain/example.typ`](https://github.com/benedict-armstrong/presio-typst-package/blob/v0.3.0/examples/plain/example.typ)     | [`example.pdf`](https://github.com/benedict-armstrong/presio-typst-package/blob/v0.3.0/examples/plain/example.pdf)   |
| polylux     | [`examples/polylux/example.typ`](https://github.com/benedict-armstrong/presio-typst-package/blob/v0.3.0/examples/polylux/example.typ) | [`example.pdf`](https://github.com/benedict-armstrong/presio-typst-package/blob/v0.3.0/examples/polylux/example.pdf) |
| HTML animations | [`examples/html-animation/example.typ`](https://github.com/benedict-armstrong/presio-typst-package/blob/v0.3.0/examples/html-animation/example.typ) | [`example.pdf`](https://github.com/benedict-armstrong/presio-typst-package/blob/v0.3.0/examples/html-animation/example.pdf) |
| Workshop (touying, viewers drive) | [`examples/workshop/example.typ`](https://github.com/benedict-armstrong/presio-typst-package/blob/v0.3.0/examples/workshop/example.typ) | [`example.pdf`](https://github.com/benedict-armstrong/presio-typst-package/blob/v0.3.0/examples/workshop/example.pdf) |
| touying     | [`examples/touying/example.typ`](https://github.com/benedict-armstrong/presio-typst-package/blob/v0.3.0/examples/touying/example.typ) | [`example.pdf`](https://github.com/benedict-armstrong/presio-typst-package/blob/v0.3.0/examples/touying/example.pdf) |

Rebuild with `typst compile --root . examples/<framework>/example.typ examples/<framework>/example.pdf` from the repo root. The `--root .` flag is required so the file-`path` sandbox can resolve `demo.gif`.

## License

MIT — see [LICENSE](LICENSE).
