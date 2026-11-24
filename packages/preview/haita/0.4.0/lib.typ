/// This function defines a chapter in the output
/// ```
/// #chapter("doc/lib.typ")
/// ```
/// -> chapter
#let chapter(
  /// The path to the chapter. When `content` is left blank
  /// the function would automatically look into the current directory
  /// and fetch the content if there is a file at the path ending in `.typ`
  /// -> str
  path,
  /// The content of the chapter.
  /// -> auto | content
  content: auto,
  /// Subchapters
  /// -> any | chapter
  children: (),
  /// Whether if this chapter is numbered
  /// -> bool
  numbered: true,
  /// Extra arguments passed to the renderer
  /// -> any
  ..args,
) = {
  let path = if type(path) == array { path } else { path.split("/").filter(it => it.len() > 0) }
  (
    kind: "chapter",
    path: path,
    content: if content == auto {
      include "/" + path.join("/") + ".typ"
    } else {
      content
    },
    numbered: numbered,
    children: children,
    ..args.named(),
  )
}

// https://github.com/typst/typst/issues/2196#issuecomment-1728135476
#let to-string(
  it,
) = {
  if type(it) == str {
    it
  } else if type(it) != content {
    str(it)
  } else if it.has("text") {
    it.text
  } else if it.has("children") {
    it.children.map(to-string).join()
  } else if it.has("body") {
    to-string(it.body)
  } else if it == [ ] {
    " "
  }
}

#let normalize-base-url(base-url) = {
  if base-url == none { return none }
  let base-url = base-url.trim("/", at: end, repeat: true)
  if base-url.len() == 0 { none } else { base-url }
}

#let normalize-tree(tree) = {
  assert(type(tree) == array, message: "The tree argument must be an array. Maybe you forgot a comma?")
  tree.map(it => {
    if type(it) != dictionary or "kind" not in it {
      it = (
        kind: "other",
        content: it,
      )
    }
    let path-str = none
    if "path" in it {
      path-str = it.path.join("/")
      it.insert("page-label", label("page:/" + path-str))
    }
    if it.kind == "chapter" {
      let chapter-heading-state = state(path-str + " chapter state", ())
      let chapter-title-state = state(path-str + " title state", none)
      it.content = {
        show heading.where(level: 1, outlined: true): head => {
          if "label" in head.fields() {
            chapter-heading-state.update(arr => (..arr, head.label))
            head
          } else {
            let heading-text = lower(to-string(head).replace(" ", "-"))
            let lb = label(path-str + "__HAITA_INTERNAL__" + heading-text)
            [#metadata((
                id: heading-text,
                body: head.body,
              )) #lb]
            chapter-heading-state.update(arr => (..arr, lb))
            head
          }
        }
        show title: title => {
          chapter-title-state.update(state => title.body)
          title
        }
        it.content
      }
      it.insert("title", chapter-title-state.final())
      it.insert("headings", chapter-heading-state.final())
    }
    if "children" in it {
      it = (..it, children: normalize-tree(it.children))
    }
    it
  })
}

#import "new-hamber.typ"

/// The entrypoint of the entire documentation.
/// -> content
#let book(
  /// The title of the documentation.
  /// -> str
  title: "",
  /// The description of the documentation.
  /// -> str
  description: "",
  /// The URL the documentation is deployed at, including the subfolder when you
  /// are not deploying to the root of a site. Examples include
  /// `https://<username>.github.io/<project name>` for GitHub Pages and
  /// `https://<project name>.pages.dev` for Cloudflare Pages.
  ///
  /// This setting is optional: it is only used to build the absolute URLs
  /// that SEO metadata requires (the canonical link, Open Graph and Twitter cards).
  /// -> none | str
  base-url: none,
  /// The authors of the documentation. It should be an array of strings.
  /// -> array
  authors: (),
  /// The language of the documentation
  /// -> str
  lang: "en",
  /// Which HTML renderer to use. By default it uses _New Hamber_'s html renderer.
  /// -> function
  html-renderer: new-hamber.html-renderer,
  /// Which paged (PDF, PNG, SVG) renderer to use. By default it uses
  /// _New Hamber_'s paged renderer.
  /// -> function
  paged-renderer: new-hamber.paged-renderer,
  /// Whether to enable the debug mode or not. Debug mode outputs a tree of the current document at `/__debug_tree.html`
  /// -> bool
  debug: false,
  /// The content of your documentation.
  /// -> array
  tree: (),
) = context {
  let base-url = normalize-base-url(base-url)
  assert(type(authors) == array, message: "Authors must be an array of strings.")
  let normalized = normalize-tree(tree)
  // Bundle export will not output PDF until https://github.com/typst/typst/issues/7998 is resolved
  if target() in ("paged",) {
    paged-renderer(
      normalized,
      title: title,
      description: description,
      authors: authors,
      lang: lang,
    )
  }
  if target() in ("bundle",) {
    // debug for testing the tree
    if debug { document("/__debug_tree.html", [#normalized]) }
    html-renderer(
      normalized,
      title: title,
      description: description,
      base-url: base-url,
      authors: authors,
      lang: lang,
    )
  }
  if target() == "html" {
    panic({
      "You must use the bundle target."
      " You are seeing this error either because you put `book` inside a #document in when using bundle format"
      " or you set the format to be HTML."
      " You must use the bundle target and you should not place book inside a #document."
    })
  }
}

/// Minimal page summary renderer.
/// Use it like this. Always use it with the `.with` syntax:
/// ```typ
/// #book(
///   html-renderer: new-hamber.html-renderer.with(
///     summary-image-renderer: lib.minimal-summary-image-renderer.with(
///       image-content: it => [...] // your content here
///       // Don't complete any other fields
///     )
///   )
/// )
/// ```
#let minimal-summary-image-renderer(
  /// The chapter that would be feeded into the renderer.
  /// #highlight[Usually this is internal to the renderer, and should not be completed.]
  /// -> chapter
  chapter,
  /// The base URL of your site, taken from `book`'s `base-url`.
  /// #highlight[Usually this is internal to the renderer, and should not be completed.]
  /// When it is `none` the image is referenced relative to the page instead of
  /// by an absolute URL.
  /// -> none | str
  base-url: none,
  /// The width of the image in pixels. For the default PPI it is 1pt -> 1px.
  /// -> int
  width-px: 1200,
  /// The height of the image in pixels. For the default PPI it is 1pt -> 1px.
  /// -> int
  height-px: 630,
  /// The PPI of the image in pixels. If you change the PPI via the `--ppi` when
  /// compiling you must also change this value.
  /// -> int
  ppi: 144,
  /// The content of the summary image.
  /// -> function
  image-content: chapter => none,
) = {
  let image-path = "/" + chapter.path.join("/") + "_summary.png"
  let image-url = if base-url == none { chapter.path.last() + "_summary.png" } else { base-url + image-path }
  (
    document: document(
      image-path,
      page(
        width: width-px / ppi * 1in,
        height: height-px / ppi * 1in,
        image-content(chapter),
      ),
    ),
    og-properties: {
      html.elem("meta", attrs: (property: "og:image", content: image-url))
      html.elem("meta", attrs: (property: "og:image:type", content: "image/png"))
      html.elem("meta", attrs: (property: "og:image:width", content: str(width-px)))
      html.elem("meta", attrs: (property: "og:image:height", content: str(height-px)))
      html.meta(name: "twitter:card", content: "summary_large_image")
      html.meta(name: "twitter:image", content: image-url)
    },
  )
}
