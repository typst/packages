# presio

Attach **speaker notes** and **embedded media** (GIF / MP4 / WebM) to PDF slides
so they can be presented with the [presio.xyz](https://presio.xyz) viewer.

`presio` is framework-agnostic — it works with [polylux](https://typst.app/universe/package/polylux),
[touying](https://typst.app/universe/package/touying), or plain Typst pages. It
only contributes two functions; layout and slide flow are up to your existing
template.

## Install

```typ
#import "@preview/presio:0.2.2": media, speaker-notes
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
`youtube.com/shorts/…`, `youtube-nocookie.com/embed/…`) and Vimeo
(`vimeo.com/<id>`, `player.vimeo.com/video/<id>`) are detected automatically and
emitted with `kind: "youtube"` / `kind: "vimeo"` plus an extracted `video_id`
the viewer can use to build an iframe embed.

```typ
#media("https://www.youtube.com/watch?v=dQw4w9WgXcQ", width: 60%, aspect-ratio: 16/9)
#media("https://vimeo.com/76979871", width: 60%, aspect-ratio: 16/9)
```

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

## Supported media types

The MIME is sniffed from the extension of the source path's filename (file mode) or the URL (URL mode):

| Extension | MIME         |
| --------- | ------------ |
| `.gif`    | `image/gif`  |
| `.mp4`    | `video/mp4`  |
| `.webm`   | `video/webm` |

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
| Plain Typst | [`examples/plain/example.typ`](https://github.com/benedict-armstrong/presio-typst-package/blob/v0.2.0/examples/plain/example.typ)     | [`example.pdf`](https://github.com/benedict-armstrong/presio-typst-package/blob/v0.2.0/examples/plain/example.pdf)   |
| polylux     | [`examples/polylux/example.typ`](https://github.com/benedict-armstrong/presio-typst-package/blob/v0.2.0/examples/polylux/example.typ) | [`example.pdf`](https://github.com/benedict-armstrong/presio-typst-package/blob/v0.2.0/examples/polylux/example.pdf) |
| touying     | [`examples/touying/example.typ`](https://github.com/benedict-armstrong/presio-typst-package/blob/v0.2.0/examples/touying/example.typ) | [`example.pdf`](https://github.com/benedict-armstrong/presio-typst-package/blob/v0.2.0/examples/touying/example.pdf) |

Rebuild with `typst compile --root . examples/<framework>/example.typ examples/<framework>/example.pdf` from the repo root. The `--root .` flag is required so the file-`path` sandbox can resolve `demo.gif`.

## License

MIT — see [LICENSE](LICENSE).
