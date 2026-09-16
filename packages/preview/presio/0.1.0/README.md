# presio

Attach **speaker notes** and **embedded media** (GIF / MP4 / WebM) to PDF slides
so they can be presented with the [presio.xyz](https://presio.xyz) viewer.

`presio` is framework-agnostic — it works with [polylux](https://typst.app/universe/package/polylux),
[touying](https://typst.app/universe/package/touying), or plain Typst pages. It
only contributes two functions; layout and slide flow are up to your existing
template.

## Install

```typ
#import "@preview/presio:0.1.0": media, speaker-notes
```

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

Because of how Typst resolves file paths inside packages, the caller is
responsible for `read`-ing the media bytes:

```typ
#media(
  read("figures/demo.gif", encoding: none),
  name: "demo.gif",
  placeholder: image("figures/demo.gif"),
  width: 60%,
)
```

The binary is embedded in the PDF via `pdf.attach` and a placement descriptor
JSON is written alongside it. `placeholder` is optional `content` shown in the
slide itself (Typst can render GIFs via `image(...)` — for MP4/WebM use a still
image or omit `placeholder` to get a dark block).

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

| Parameter      | Default | Notes                                                                                                  |
| -------------- | ------- | ------------------------------------------------------------------------------------------------------ |
| `source`       | —       | Either `bytes` (from `read(..., encoding: none)`) or a `http(s)://` URL string                         |
| `name`         | `none`  | Required when `source` is bytes. Used as the PDF attachment filename and to sniff the MIME type.       |
| `placeholder`  | `none`  | Optional `content` rendered as the in-slide preview (e.g. `image(...)`)                                |
| `width`        | `auto`  | Length, ratio of the container width, or `auto` (natural width of `placeholder`, else container width) |
| `height`       | `auto`  | Length, ratio, or `auto` (derived from `placeholder` / `aspect-ratio` / 16:9)                          |
| `aspect-ratio` | `none`  | Width/height ratio, e.g. `16/9`                                                                        |
| `autoplay`     | `true`  | Forwarded to the viewer                                                                                |
| `loop`         | `true`  | Forwarded to the viewer                                                                                |

## Supported media types

The MIME is sniffed from the extension of `name` (bytes mode) or the URL (URL mode):

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

## License

MIT — see [LICENSE](LICENSE).
