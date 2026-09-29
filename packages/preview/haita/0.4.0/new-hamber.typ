// Default theme "New Hamber"

#let realize(label, fn) = {
  let c = state("__realize-label+a-bunch-of-entropy", none)
  {
    show html.elem.where(tag: "a"): elem => c.update(href => elem.attrs.href)
    link(label)[]
  }
  context {
    fn(c.get())
  }
}

#let inline-svg(list) = {
  for child in list {
    if "tag" in child and child.tag != "" {
      html.elem(
        child.tag,
        attrs: child.attrs,
        inline-svg(child.children),
      )
    }
  }
}

#let update-elem(elem, state: none) = {
  let classes = elem.fields().attrs.at("class", default: ())
  if type(classes) == str {
    classes = classes.split(" ")
  }
  classes = classes.map(it => (it, none)).to-dict()
  state.update(it => it + classes)
  elem
}

#let page-classes = state("__new_hamber page classes", (:))
#let a11y-skip-classes = {
  "absolute left-4 top-0 -translate-y-full"
  " focus:translate-y-4 focus-visible:translate-y-4"
  " z-50 bg-white dark:bg-zinc-700 px-4 py-2"
  " text-black dark:text-white"
}

#let summary-renderer(current-tree, current-chapter) = for it in current-tree {
  let is-current-page = "page-label" in it and it.page-label == current-chapter.page-label
  html.li({
    if it.kind == "chapter" {
      {
        show html.elem.where(tag: "a"): set html.elem(attrs: if is-current-page {
          (autofocus: "", aria-current: "page", id: "toc-current-page")
        } else {
          (class: "toc-entry-other-page")
        })
        std.link(it.page-label, it.title)
      }
      if is-current-page {
        html.a(href: "#haita-main-content", class: a11y-skip-classes)[Skip to main content]
      }
    } else {
      if it.content.func() == divider {
        html.hr(class: "my-3 border-neutral-300 dark:border-zinc-600")
      } else if it.content.func() == heading {
        html.h2(class: "font-bold p-2", it.content.body)
      } else {
        html.div(class: "p-2 prose prose-neutral prose-sm dark:prose-invert leading-normal", it.content)
      }
    }
    if "children" in it and it.children.len() > 0 {
      html.ol(
        class: "ml-3 border-neutral-300 dark:border-zinc-600 border-l col-start-2 col-span-2",
        summary-renderer(it.children, current-chapter),
      )
    }
  })
}

#let flatten-tree(tree) = {
  let out = ()
  for it in tree {
    let base = it
    if "children" in base {
      let _ = base.remove("children")
      out.push(base)
      out += flatten-tree(it.children)
    } else {
      out.push(base)
    }
  }
  out
}

// Helper method for making O(1) lookups
#let generate-dict(arr) = {
  let dict = (:)
  for (idx, it) in arr.enumerate() {
    if "page-label" not in it {
      continue
    }
    dict.insert(str(it.page-label), idx)
  }
  dict
}

#let copy-btn(copy-class) = html.button(
  title: "Copy",
  class: {
    copy-class
    " absolute right-2 top-2 p-1 z-10 not-prose"
    " text-md" // controls the icon size
    " border border-neutral-300 bg-white text-neutral-600"
    " opacity-0 group-hover:opacity-100 transition-opacity"
    " hover:bg-neutral-100"
    " dark:border-transparent dark:bg-zinc-800 dark:text-neutral-300 dark:hover:bg-zinc-700"
  },
  {
    html.div(class: "clipboard", inline-svg(xml("assets/clipboard.svg")))
    html.div(class: "check hidden", inline-svg(xml("assets/check.svg")))
  },
)


#let with-footnote-section(body) = {
  let footnote-state = state("page-footnote-state", ())
  footnote-state.update(()) //

  show footnote: it => context {
    let idx = footnote-state.get().len() + 1
    footnote-state.update(f => (..f, it))
    html.sup(html.a(id: "footnote-back-" + str(idx), href: "#footnote-" + str(idx), str(idx)))
  }

  body

  context {
    let footnote-state = footnote-state.get()
    if footnote-state.len() > 0 {
      divider()
      let items = footnote-state
        .enumerate()
        .map(((i, footnote)) => {
          html.li(
            id: "footnote-" + str(i + 1),
            [#footnote.body #html.a(
                class: "no-underline hover:underline",
                href: "#footnote-back-" + str(i + 1),
                sym.arrow.l.hook,
              )],
          )
        })
      html.section(class: "text-sm", html.ol(items.join()))
    }
  }
}

#let with-fancy-raw(it) = if target() != "html" {
  it
} else if it.lang == "typm-copy" {
  import html: div
  div(class: "relative group", title: it.text, {
    copy-btn("copy-math-btn")
    // the div here is to prevent Typst from creating a p for the copy-btn
    div(math.equation(block: true, eval(it.text, mode: "math")))
  })
} else {
  import html: div, pre, span
  // add some custom display rules and add line counting
  let code-fn = html.elem.with(
    "code",
    attrs: if it.lang != none { (data-lang: it.lang) } else { (:) },
  )
  div(class: "relative group", {
    copy-btn("copy-code-btn")
    pre(code-fn(for line in it.lines {
      span(class: "line", line)
      linebreak()
    }))
  })
}


#let footer-renderer(
  final-tree,
  current,
  footer-content,
) = html.footer(
  class: "mt-8 grid grid-cols-1 md:grid-cols-[1fr_1fr] gap-4",
  {
    // TODO: change this to dictionary based
    let flattened = flatten-tree(final-tree).filter(it => it.kind == "chapter")
    let indexed = generate-dict(flattened)
    let current-idx = indexed.at(str(current.page-label))
    if current-idx == none {
      return
    }
    let link-classes = {
      "border-1 border-neutral-300 dark:border-transparent dark:bg-zinc-800 hover:bg-neutral-500/30 hover:shadow-xs"
      " [&>a]:no-underline [&>a]:block [&>a]:w-full [&>a]:h-full [&>a]:p-4"
    }
    if current-idx > 0 {
      let info = flattened.at(current-idx - 1)
      html.div(
        class: link-classes,
        link(info.page-label, info.title),
      )
    }
    if current-idx < flattened.len() - 1 {
      let info = flattened.at(current-idx + 1)
      html.div(
        class: "md:col-start-2 text-right " + link-classes,
        link(info.page-label, info.title),
      )
    }
    html.span(class: "md:col-span-2 text-xs text-center", footer-content)
  },
)

#let internal-html-renderer(
  final-tree,
  it,
  footer-content,
  sidebar-image,
  pagefind-enabled,
) = {
  import html: *

  // sidebar generation
  input(
    class: {
      "z-10 fixed md:hidden"
      " peer appearance-none"
      " left-0 w-8 h-20"
      " checked:translate-y-0 checked:translate-x-72 checked:top-0"
      " checked:w-full checked:h-full"
    },
    type: "checkbox",
  )
  div(class: {
    "flex items-center justify-center"
    " z-5 fixed w-8 h-20"
    " border-r border-b border-neutral-300"
    " bg-neutral-100 text-neutral-400"
    " dark:border-transparent dark:bg-zinc-700"
    " rounded-br-sm shadow-sm"
    " md:hidden peer-checked:translate-x-72"
    " transition-transform text-3xl"
  })[|||]
  nav(
    id: "main-toc",
    class: {
      "dark:text-white w-72 z-10 flex fixed left-0 top-0 h-full"
      " -translate-x-full shadow-sm md:shadow-none"
      " peer-checked:translate-x-0 md:translate-x-0 flex-col"
      " border-r border-neutral-300 dark:border-transparent bg-neutral-100"
      " dark:bg-zinc-800 transition-transform"
    },
    {
      sidebar-image
      if pagefind-enabled {
        elem("pagefind-modal-trigger", attrs: (class: "flex shrink-0 bg-white dark:bg-black h-9"), noscript(
          class: "m-auto text-sm text-black dark:text-white",
        )[
          Enable JS for search support
        ])
        elem("pagefind-modal")
      }
      ol(
        class: {
          "block border-neutral-300 dark:border-transparent overflow-x-auto "
          {
            "block border-y px-2 py-1 transition-shadow"
            " border-neutral-300 bg-white"
            " dark:border-transparent dark:bg-zinc-700"
          }
            .split(" ")
            .map(cls => "[&_a[autofocus]]:" + cls)
            .join(" ")
          " "
          {
            "block border-y px-2 py-1"
            " border-transparent"
            " hover:bg-neutral-200 dark:hover:bg-zinc-700"
          }
            .split(" ")
            .map(cls => "[&_a.toc-entry-other-page]:" + cls)
            .join(" ")
        },
        summary-renderer(final-tree, it),
      )
    },
  )

  let main-content = elem(
    "article",
    attrs: (
      // only let pagefind index the article
      id: "haita-main-content",
      class: {
        "p-3 sm:p-6 md:p-8 min-w-full mt-20 md:mt-0"
        " prose prose-neutral dark:prose-invert leading-normal"
        " prose-pre:bg-neutral-100 prose-pre:text-neutral-900"
        " prose-pre:border prose-pre:border-neutral-300"
        " dark:prose-pre:!bg-black dark:prose-pre:!text-neutral-100"
        " dark:prose-pre:!border-transparent"
        " prose-pre:rounded-none"
        " prose-a:decoration-1 prose-a:underline-offset-4"
        " prose-a:hover:decoration-3"
        " prose-a:break-words"
      },
      data-pagefind-body: "",
    ),
    {
      // fix math scrolling
      {
        let div-fn = div.with(class: "overflow-x-auto w-full overflow-y-hidden [&>:first-child]:mx-auto py-1")
        show math.equation.where(block: true).or(frame): it => if target() == "html" {
          div-fn(it)
        } else {
          it
        }
        import "lib.typ": to-string
        show heading: h => elem("h" + str(h.level + 1), to-string(h.body))
        show raw.where(block: true): with-fancy-raw
        show: with-footnote-section
        it.content
      }
      // footer
      footer-renderer(final-tree, it, footer-content)
    },
  )

  div(class: "grid xl:grid-cols-[1fr_14rem] md:ml-72 max-w-[64rem]", {
    a(href: "#toc-current-page", class: a11y-skip-classes)[Skip to current page in TOC]
    main-content
    // on page toc
    nav(class: "hidden xl:block right-0 top-0 h-fit sticky pt-5 dark:text-white leading-tight", {
      h2(class: "font-bold")[On this page]
      ul(
        class: {
          "border-l border-neutral-300 dark:border-zinc-600 pl-3"
          " [&>li]:my-3"
          " [&>li>a]:block [&>li>a]:hover:underline [&>li>a]:decoration-2 [&>li>a]:underline-offset-4"
        },
        if it.headings.len() == 0 {
          emph[This page does not contain any headings.]
        } else {
          for label in it.headings {
            let query-result = query(label).first()
            let body = if query-result.func() == metadata {
              query-result.value.body
            } else if query-result.func() == heading {
              query-result.body
            }
            li(std.link(label, body))
          }
        },
      )
    })
  })
}

#let og-property(type, ..args) = html.elem("meta", attrs: (property: "og:" + type, ..args.named()))

#let recursive-html-renderer(final-tree, current-tree, chapter-generator: none) = for it in current-tree {
  if it.kind == "chapter" {
    chapter-generator(it)
  }
  recursive-html-renderer(
    final-tree,
    it.at("children", default: ()),
    chapter-generator: chapter-generator,
  )
}

#let summary-image-renderer(
  site-title,
  chapter,
  base-url: none,
  bottom-content: none,
  // defaults to 1pt -> 1px
  width-px: 1200,
  height-px: 630,
  ppi: 144,
) = {
  let image-path = "/" + chapter.path.join("/") + "_summary.png"
  let image-url = if base-url == none { chapter.path.last() + "_summary.png" } else { base-url + image-path }
  (
    document: document(
      image-path,
      page(
        width: width-px / ppi * 1in,
        height: height-px / ppi * 1in,
        fill: gradient.linear(white, white, green.mix(navy), angle: 45deg).sharp(16).repeat(1),
      )[
        #set text(size: 24pt)
        #text(site-title)\
        #text(size: 2em, chapter.title)

        #place(bottom, bottom-content)
      ],
    ),
    og-properties: {
      og-property("image", content: image-url)
      og-property("image:type", content: "image/png")
      og-property("image:width", content: str(width-px))
      og-property("image:height", content: str(height-px))
      html.meta(name: "twitter:card", content: "summary_large_image")
      html.meta(name: "twitter:image", content: image-url)
    },
  )
}

/// _New Hamber_'s HTML renderer.
#let html-renderer(
  /// The content tree
  tree,
  /// The language of the book
  lang: "en",
  /// The title of the book
  title: "",
  /// The base URL
  base-url: none,
  /// The summary image renderer
  summary-image-renderer: none,
  /// The footer is displayed on each page. Controls the footer's content.
  /// -> content
  footer-content: [
    Powered by #link("https://github.com/wensimehrp/haita")[Haita]. Made in Vancouver with love.
  ],
  /// Extra content to put into the global stylesheet
  /// -> none | str
  extra-css: none,
  /// Extra content to put into `head`
  /// -> none | content
  extra-head-content: none,
  /// The image of the navigation sidebar
  /// -> content
  sidebar-image: html.a(
    href: "https://en.wikipedia.org/wiki/File:Sea_Otter_(Enhydra_lutris)_(25169790524)_crop.jpg",
    html.img(
      class: "w-full h-45 object-cover object-top",
      src: "https://upload.wikimedia.org/wikipedia/commons/0/02/Sea_Otter_%28Enhydra_lutris%29_%2825169790524%29_crop.jpg",
    ),
  ),
  /// The favicon of the site. Currently only SVG is supported.
  /// -> content | none
  favicon: asset("favicon.svg", read("assets/favicon.svg")),
  /// Whether or not to enable #link(<pagefind-integration>)[pagefind integration]
  /// -> bool
  pagefind-enabled: false,
  ..args,
) = {
  // first generate the tailwind preflight
  let site-title = title
  import "@preview/typhoon:0.1.2"
  import "fonts/fonts.typ": font-css, font-files
  font-files().join()
  [
    #asset("/scripts/copy.js", read("scripts/copy.js")) <copy-js>
    #if favicon != none [
      #favicon <favicon-svg>
    ]
    #asset(
      "/styles.css",
      {
        read("styles/styles.css")
        str(typhoon._plugin.generate(bytes(page-classes.final().keys().join(" ", default: "")), cbor.encode((
          preflight: (
            full: (
              font_family_sans: "Lato",
              font_family_mono: "Roboto Mono",
            ),
          ),
        ))))
        read("styles/math.css")
        read("styles/code-lines.css")
        extra-css
        if pagefind-enabled {
          read("styles/pagefind.css")
        }
        font-css
      },
    ) <styles>
  ]
  // then generate html files
  show html.elem: update-elem.with(state: page-classes)
  recursive-html-renderer(
    tree,
    tree,
    chapter-generator: it => [
      #let page-path-str = "/" + it.path.join("/") + ".html"
      #let page-url = if base-url != none { base-url + page-path-str }
      #let up = ("..",) * (it.path.len() - 1)
      #let pagefind-path = (up + ("pagefind",)).join("/")
      #let summary-image = if type(summary-image-renderer) == function {
        summary-image-renderer(it, base-url: base-url)
      }
      #if summary-image != none { summary-image.document }
      #document(page-path-str, html.html(lang: lang, {
        import html: *
        head({
          // Chore
          meta(charset: "utf-8")
          meta(name: "viewport", content: "width=device-width, initial-scale=1")
          title(it.title)
          if page-url != none { link(rel: "canonical", href: page-url) }
          // TODO: finish description here
          meta(name: "description", content: "...")
          // Styles
          if favicon != none {
            realize(<favicon-svg>, href => link(rel: "icon", href: href, type: "image/svg+xml"))
          }
          realize(<styles>, href => link(rel: "stylesheet", href: href))
          realize(<copy-js>, href => script(src: href, defer: true))
          extra-head-content
          // Open Graph SEO
          import "lib.typ": to-string
          og-property("title", content: to-string("" + it.title))
          og-property("description", content: to-string("" + [...]))
          og-property("type", content: "website")
          if page-url != none { og-property("url", content: page-url) }
          og-property("site_name", content: site-title)
          if summary-image != none { summary-image.og-properties }
          // Twitter SEO
          meta(name: "twitter:title", content: to-string("" + it.title))
          if base-url != none {
            meta(name: "twitter:domain", content: base-url.replace(regex("^\w+://"), "").split("/").first())
          }
          meta(name: "twitter:description", content: "...")
          if pagefind-enabled {
            let link-path = (pagefind-path, "pagefind-component-ui.css").join("/")
            let script-path = (pagefind-path, "pagefind-component-ui.js").join("/")
            link(href: link-path, rel: "stylesheet")
            script(src: script-path, type: "module")
          }
        })
        body(class: "dark:bg-zinc-900", {
          if pagefind-enabled {
            elem("pagefind-config")
            elem("script", {
              "document.querySelector('pagefind-config').setAttribute("
              "'bundle-path', new URL('" + pagefind-path + "/', document.baseURI).pathname)"
            })
          }
          internal-html-renderer(
            tree,
            it,
            footer-content,
            sidebar-image,
            pagefind-enabled,
          )
        })
      })) #it.page-label
    ],
  )
}

/// _New Hamber_'s Paged (PDF, PNG, SVG) renderer.
#let paged-renderer(
  tree,
  /// The title of the documentation
  /// -> str
  title: "",
  /// A brief explanation about the document
  /// -> content
  description: [],
  /// The author(s) of the document
  /// -> array
  authors: (),
  /// The language of the document.
  /// -> str
  lang: "en",
  /// The date format used
  date-format: auto,
  ..args,
) = [
  #set text(font: "Lato", lang: if lang == auto { "en" } else { lang })
  #show math.equation: set text(font: "Lete Sans Math")
  #set document(author: authors)
  #page(align(right + horizon)[
    #block(below: 1em, text(size: 32pt, strong(title)))
    #set text(size: 15pt)
    #description
    #v(2em)
    #authors.join[, ]\
    #datetime.today().display(date-format)
  ])
  // empty page for alignment
  #page[]
  #show std.title: t => {
    pagebreak(weak: true)
    hide(text(size: 0cm, heading(level: 1, t.body)))
    box(inset: (bottom: 2em), width: 1fr, align(right)[
      #text(size: 14pt)[Chapter #numbering("1", counter(heading).get().first() + 1)]\
      #text(size: 32pt, t.body)
    ])
  }
  #set heading(offset: 1, numbering: "1.")
  #show raw.where(block: true): it => if it.lang == "typm-copy" {
    math.equation(block: true, eval(it.text, mode: "math"))
  } else {
    grid(
      columns: (auto, 1fr),
      fill: luma(98%),
      inset: (x: .5em, y: .3em),
      grid.header[][],
      ..for line in it.lines {
        (
          grid.cell(align: right, [#line.number]),
          grid.cell(align: left, line.body),
        )
      },
      grid.footer[][],
    )
  }
  #set par(justify: true, justification-limits: (tracking: (min: -0.01em, max: 0.02em)))
  #show link: underline.with(offset: .2em, stroke: 1.3pt)
  #show link: it => if type(it.dest) == label [
    #it #super(numbering("1.", ..counter(heading).at(it.dest)))
  ] else {
    it
  }
  #set page(
    footer: context box(inset: (y: .5em), stroke: (top: .6pt), {
      let pagenum = counter(page).get().first()
      let page-numbering = numbering(page.numbering, pagenum)
      let current-heading = query(selector(heading.where(level: 1)).before(here())).last(default: none)
      let current-numbering = counter(heading).get().first()
      let current-heading = if current-heading == none { none } else {
        numbering("1.", current-numbering) + [ ]
        current-heading.body
      }
      if calc.even(pagenum) {
        page-numbering
        h(1fr)
        upper(strong(current-heading))
      } else {
        upper(strong(current-heading))
        h(1fr)
        page-numbering
      }
    }),
  )
  #counter(page).update(1)
  #set page(numbering: "i")
  #outline(depth: 2)
  #set page(numbering: "1")
  #for it in flatten-tree(tree).filter(it => it.kind == "chapter") {
    it.content
  }
]
