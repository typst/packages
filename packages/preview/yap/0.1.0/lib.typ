#let vidata = plugin("vidata.wasm") // source: https://github.com/snlxnet/vidata

#let fs-enabled = state("yap-enable-fs", false)
#let use-local() = fs-enabled.update((_current) => true)

/// Speaker notes for the current page.
/// Intended for presentations.
/// Show up on the left in the viewer.
#let notes(
  /// The text of the note.
  /// You can only use
  /// regular text, *bold*, _italic_,
  /// #link("https://snlx.net/yaptyp", underline[links]),
  /// - lists
  /// 1. and other lists
  ///
  /// -> content
  body
) = {
  let to-html(it) = {
    if type(it) == str {
      it
    } else if type(it) != content {
      str(it)
    } else if it.func() == parbreak {
      "</p><p>"
    } else if it.has("text") {
      it.text
    } else if it.has("children") {
      it.children.map(to-html).join()
    } else if it.has("body") {
      let wrapper = if it.func() == strong {
        ("<strong>", "</strong>")
      } else if it.func() == emph {
        ("<em>", "<em>")
      } else if it.func() == heading {
        let level = str(it.depth)
        ("#"*level+" ", "\n")
      } else if it.func() == link {
        ("<a href=\""+it.dest+"\">", "</a>")
      } else if it.func() == list.item {
        ("<ul><li>", "</li></ul>")
      } else if it.func() == enum.item {
        ("<ol><li>", "</li></ol>")
      } else {
        ("", )
      }
      wrapper.first() + to-html(it.body) + wrapper.last()
    } else if it == [ ] {
      " "
    }
  }

  let url = "note://<p>" + to-html(body).replace("</ul> <ul>", "").replace("</ol> <ol>", "") + "</p>"
  place(top + left)[#box(width: 0mm, height: 0mm, fill: none, stroke: none)#label(url)]
}

/// A video.
///
/// You can use it as though it is an image,
/// wrapping it in boxes, figures, etc.
///
/// -> content
#let video(
  /// A path to a video file.
  /// Only tested with .mp4, but may work with other formats.
  ///
  /// -> path
  source,
  /// The ratio between the top and left sides of the video.
  ///
  /// Examples: landscape `"16/9"`, landscape `"4/3"`,
  /// portrait `"9/16"`, square `"1/1"`, in pixels `"640/480"`,
  /// as a decimal fraction `"1.333"`.
  ///
  /// Default: `"16/9"` or taken from the actual file if you've called `#use-local()`
  ///
  /// -> str
  aspect-ratio: "16/9",
  /// The width of the video.
  ///
  /// -> auto | relative
  width: auto,
  /// The height of the video.
  ///
  /// -> auto | relative
  height: auto,
) = context {
  let vertical = none

  let placeholder = ```xml
    <svg viewBox="0 0 WIDTH HEIGHT" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:h5="http://www.w3.org/1999/xhtml">
    </svg>
  ```.text

  // Auto aspect ratio
  if (not source.contains("://")) and fs-enabled.get() and source.ends-with(".mp4") {
    let metadata = vidata.from(read(source, encoding: none))
    let video = eval(str(metadata)).find(track => track.type == "Video")
    vertical = video.height > video.width

    placeholder = placeholder.replace("WIDTH", str(video.width)).replace("HEIGHT", str(video.height))
  }

  // Manual aspect ratio
  {
    let width = float(eval(aspect-ratio))
    let height = 1.0
    if vertical == none {
      vertical = height > width
    }
    placeholder = placeholder
      .replace("WIDTH", str(width*1000))
      .replace("HEIGHT", str(height*1000))
  }

  // Build the placeholder image
  placeholder = image(
    bytes(placeholder),
    format: "svg",
  )

  [#box(fill: rgb("12345678"), width: width, align(center+horizon, placeholder))#label("vid://" + source)]
}

/// An external image.
/// Typst's default `#image`'s
/// are embedded into the SVG, resulting in large file sizes, which
/// can be a problem if used in a website.
/// YapTyp's `#img` loads them separately.
#let img(
  /// -> path
  source,
  /// -> auto | relative
  width: auto,
  /// -> auto | relative
  height: auto,
  /// "cover" or "contain"
  /// -> str
  fit: "cover",
) = [#box(fill: rgb("12345678"), hide(image(source, width: width, height: height, fit: fit)))#label("img-" + fit + "://" + source)]

