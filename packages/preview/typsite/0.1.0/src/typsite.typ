#import "html-bindings.typ" as html
#import "util.typ": *

/// Creates an HTML document with a schema.
// `~>` means that will be processed by typsite

/// - name (str):
///     The name of the schema to be included in the HTML document. 
/// - body (content):
///     The main content of the HTML document, which will be applied to the handle-body function. 
/// - head (content):
///     Additional content to be placed inside the `<head>` tag of the HTML document.
/// - handle-body ((content) -> content):
///     A function that processes the body content before it is placed inside the HTML document.
///     The returned content will be placed inside the `<body>` tag of the HTML document. 
/// -> HTML document with a schema ~> HTML Page
#let schema(name, body, head, handle-body) = context {
  if target() != "html" {
    return body
  }
  html.tag("html")[
    #html.tag("head")[
      #html.tag("schema", name: str(name))[]
      #head
    ]
    #html.tag("body", handle-body(body))
  ]
}


// Rewrites
// `~>` means that will be processed by typsite

/// Creates a typsite-rewrite element in HTML.
///
/// - id (str): id specified in the `.typsite/rewrite/*.html` with `<rewrite pass="rewrite-id" />`
///     The identifier for the rewrite
/// - attrs (..):
///     Additional attributes to be applied to the rewrite. 
/// - content (content):
///     The content to be placed inside the rewrite element. 
/// -> typsite rewrite - (HTML element)
#let rewrite(id, ..attrs, content) = html.tag(
  "rewrite",
  id: id,
  ..attrs,
  content,
)

// Anchor & Goto
// `~>` means that will be processed by typsite

/// Creates an anchor definition in HTML.
/// 
/// - id (str):
///     The identifier for the anchor, which can be used to link to a specific section in the document.
/// -> anchor definition component ~> anchor definition element
#let anchor(id) = {
  box(html.tag("anchordef", id: str(id))[])
}

/// Creates an anchor goto in HTML.
/// 
/// - id (str):
///     The identifier for the anchor, which can be used to link to a specific section in the document.
/// - content (content):
///     The content to be placed inside the anchor goto element.
/// -> anchor goto component ~> anchor goto element
#let goto(id, content) = {
  box(html.tag("anchorgoto", id: str(id), content))
}


/// Creates an embed component in HTML.
///
/// - slug (str):
///     The slug of the embed, which is used to reference the embedded content. 
/// - open (bool): 
///     A boolean indicating whether the embed is open or closed.
/// - sidebar (str): "none" | "only-title" | "full"
///     The sidebar type for the embed, which can be "none", "only-title", or "full".
/// - heading-level (str): "child" | "peer" | exact heading level(1-6) or using heading like `== #embed("./example.typ")`
///     The level of the heading for the embed, which can be "child", "peer", or an exact heading level (1-6).
///     Or i.e., you can use a heading like `== #embed("./example.typ")` to set the heading level as `2`.
/// - attrs (..):
///     Additional attributes to be applied to the embed element. 
///     Values will be converted to string using `to-str` function.
///     You can use these attributes by `{key}` in the embed component config (.typsite/components/embed.html)
/// -> embed component ~> HTML embed article  (not a `<embed>` tag)
#let embed(slug, open: true, sidebar: "full", heading-level: "child", ..attrs) = context {
  if target() != "html" {
    return pdf.embed(slug)
  }
  if sidebar != "none" and sidebar != "full" and sidebar != "only-title" and sidebar != "only_title" {
    panic("Expect 'none' | 'full' | 'only-title' of #embed.sidebar, but got: " + sidebar)
  }
  let headings = query(selector(heading).before(here()))
  let headings_len = headings.len()

  let last-heading-level = type => {
    if headings_len > 0 {
      let level = headings.at(headings_len - 1).level
      if type == "child" {
        level + 1
      } else if type == "peer" {
        level
      } else {
        level
      }
    } else { 0 }
  }
  let heading-level = last-heading-level(heading-level)
  html.tag(
    "embed",
    slug: str(slug),
    open: to-str(open),
    sidebar: sidebar,
    heading_level: str(heading-level),
    ..attrs,
  )[]
}


// MetaContent

/// Creates a get-metacontent rewrite in HTML.
///   in some typsite HTML config, you can use `{meta-key}` to get the meta content.
/// 
/// - meta-key (str):
///     The key for the meta content, which can be used to retrieve or set specific metadata 
/// - from (str): "$self" | "parent" | article slug
///     The source from which the meta content is retrieved or set.
///     If "parent", it will retrieve the meta content from the parent article.
///     If "$self", it will retrieve the meta content from the current article.
/// -> get-metacontent rewrite ~> HTML element of the metacontent
#let get-metacontent(meta-key, from: "$self") = context {
  if target() == "html" {
    box(html.elem("metacontent", attrs: ("get": meta-key, from: from))[])
  } else {
    content
  }
}


/// Creates a metacontent rewrite in HTML.
///
/// - meta-key (str):
///     The key for the meta content, which can be used to set specific metadata. 
/// - content (content):
///     The content to be placed inside the metacontent element.
///     This content will be used as the value for the meta key.
/// -> set-metacontent rewrite ~> none
#let metacontent(meta-key, content) = context {
  if target() == "html" {
    html.elem("metacontent", attrs: ("set": meta-key), content)
  } else {
    content
  }
}

// Default metacontent(s)

/// Set title metacontent in HTML.
///   in some typsite HTML config, you can use `{title}` to get this content.
/// 
/// - content (content):
///     The content to be placed inside the title metacontent element.
///     Can contain complicated content, such as HTML elements.
///     But those tags do not have a pretty display in the browser title bar, thus you need page-title.
/// -> set-metacontent(title) ~> none
#let title(content) = metacontent("title", content)


/// Set page-title metacontent in HTML.
///   in some typsite HTML config, you can use `{page-title}` to get this content.
/// 
/// - content (content):
///     The content to be placed inside the page-title metacontent element.
///     This content is used to set the title of the page in the browser tab, do not use complicated content such as HTML tags.
/// -> set-metacontent(page-title) ~> none
#let page-title(content) = metacontent("page-title", content)


/// Set taxon metacontent in HTML.
///   in some typsite HTML config, you can use `{taxon}` to get this content.
/// 
/// - content (content):
///     The content to be placed inside the taxon metacontent element.
///     This content is used to set the taxon of the article, which can be used for categorization or classification.
/// -> set-metacontent(taxon) ~> none
#let taxon(content) = metacontent("taxon", content)

/// Set author metacontent in HTML.
///   in some typsite HTML config, you can use `{author}` to get this content.
/// 
/// - content (content):
///     The content to be placed inside the author metacontent element.
///     This content is used to set the author of the article, which can be a string or structured content.
/// -> set-metacontent(author) ~> none
#let date(content) = metacontent("date", content)

/// Set author metacontent in HTML.
///   in some typsite HTML config, you can use `{author}` to get this
///   
/// - content (content):
///     The content to be placed inside the author metacontent element.
///     This content is used to set the author of the article, which can be a string or structured content.
/// -> set-metacontent(author) ~> none
#let author(content) = metacontent("author", content)

// MetaOption

/// Set metaoption.
/// 
/// - key (str):
///     The key for the meta option, which can be used to set specific metadata options.
/// - value (str):
///     The value for the meta option, which can be a string or structured content.
/// - content (content):
///     The content to be placed inside the metaoption element.
/// -> set-metaoption tag ~> none
#let metaoption(key, value, content) = context {
  if target() == "html" {
    html.tag(
      "metaoption",
      key: key,
      value: value,
      ..attrs,
    )[]
  }
}



/// Set metaoption of heading-numbering 
///
/// - type (str): "none" | "bullet" | "roman" | "alphabet"
///     The type of heading numbering to be applied to the article.
///       - "none" means no numbering
///       - "bullet" means bullet points, i.e. "1.2.3"
///       - "roman" means Roman numerals, i.e. "I. II. III."
///       - "alphabet" means alphabetical numbering, i.e. "A.B.C."
///     This will be used to control the numbering style of headings in the article.
/// -> set-metaoption heading-numbering tag ~> none
#let heading-numbering(type) = {
  if type != "none" and type != "bullet" and type != "roman" and type != "alphabet" {
    panic("Expect 'none' | 'bullet' | 'roman' | \"alhpabet\" of heading-numbering in metaoption, but got: " + type)
  }
  metaoption("heading-numbering", type)
}


/// Set sidebar metaoption.
/// 
/// - type (str): "none" | "full" | "only-embed"
///    The type of sidebar to be applied to the article.
///      - "none" means no sidebar
///      - "full" means a full sidebar with all content
///      - "only-embed" means a sidebar that only contains embed(s)
///    This will be used to control the sidebar display in the article.
/// -> set-metaoption sidebar tag ~> none
#let sidebar(type) = {
  if type != "none" and type != "full" and type != "only-embed" and type != "only_embed" {
    panic("Expect 'none' | 'full' | 'only-embed' of sidebar in metaoption, but got: " + type)
  }
  if type == "none" {
    return metacontent("sidebar", [false])
  }
  metaoption("sidebar", type)
}

// MetaGraph

/// Set metagraph
///   This is used to store metadata in a graph-like structure.
/// 
/// - key (str):
///     The key for the metagraph, which can be used to reference specific metadata.
/// - attrs (..):
///     Additional attributes to be applied to the metagraph element.
///     Values will be converted to string using `to-str` function.
/// -> set-metagraph tag ~> none
#let metagraph(key, ..attrs) = context {
  if target() == "html" {
    html.tag(
      "metagraph",
      key: key,
      ..attrs,
    )[]
  }
}

/// Set parent metagraph
///  This is used to set the parent of the current article in the metagraph.
/// 
/// - slug (str):
///    The slug of the parent article, which can be used to reference the parent article in the metagraph.
/// -> set-metagraph parent tag ~> none
#let parent(slug) = metagraph("parent", slug: slug)


// Other


/// Creates an auto-sized SVG style in HTML.
/// 
/// - scale (ratio):
///     The scale factor for the SVG, which determines how the SVG content is scaled.
///     i.e., if scale is 100%, the SVG will be displayed at its original size.
/// - content (content):
///     The content to be placed inside the auto-sized SVG element.
/// -> auto-sized-svg style(if with svg in its content) ~> HTML svg
///       with the following attributes:
///         - viewBox: 0, 0, 100%, 100%
///         - width: _ * scale
///         - height: _ * scale
#let auto-sized-svg(scale, content) = html.span(class: "auto-sized-svg", scale: to-str([#scale]), content)


#let inline-content = state("inline-content", false)

/// Creates an inline-scaled content in HTML.
///   This is used to inline the content as svg, with a scale factor.
/// - scale (ratio):
///     The scale factor for the content, which determines how the content is scaled.
///     i.e., if scale is 100%, the content will be displayed at its original
/// -> inline-scaled content ~> HTML svg (auto-sized)
#let inline(scale: 100%, content) = context {
  let content = std.scale(scale, origin: left + top, content)
  if target() != "html" {
    return content
  }
  let size = measure(content)
  let width = size.width * scale
  let height = size.height * scale
  let width = if width == 0pt { auto } else { width }
  let height = if height == 0pt { auto } else { height }
  let content = [
    #inline-content.update(true)
    #auto-sized-svg(scale, html.frame(content))
    #inline-content.update(false)
  ]
  content
}

