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
  html.div(
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
        html.div(class: "p-2 prose prose-neutral prose-sm dark:prose-invert", it.content)
      }
    }
      + if "children" in it and it.children.len() > 0 {
        html.div(
          class: "ml-3 border-neutral-300 dark:border-zinc-600 border-l col-start-2 col-span-2",
          summary-renderer(it.children, current-chapter),
        )
      },
  )
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
    let link-classes = "[&>a]:no-underline border-1 border-neutral-300 dark:border-transparent dark:bg-zinc-800 hover:bg-neutral-500/30 hover:shadow-xs [&>a]:block [&>a]:w-full [&>a]:h-full [&>a]:p-4 "
    if current-idx == none {
      return
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
  let footnote-state = state(str(it.page-label) + " Footnote State", ())
  // discard auto generated footnote entries since we manually display them
  show footnote: ftn => span(class: "footnote", {
    let ftn-len = footnote-state.get().len()
    let source-label = std.label(str(it.page-label) + "--source-label-" + str(ftn-len))
    let target-label = std.label(str(it.page-label) + "--target-label-" + str(ftn-len))
    footnote-state.update(state => (
      state
        + (
          (
            source-label: source-label,
            target-label: target-label,
            content: ftn.body,
          ),
        )
    ))
    [#std.super(std.link(target-label, str(ftn-len + 1))) #source-label]
    span(
      class: "footnote-popup prose prose-neutral !prose-invert prose-sm text-white",
      ftn.body,
    )
  })

  show raw.where(block: true): it => {
    let code-fn = elem.with(
      "code",
      attrs: if it.lang != none { (data-lang: it.lang) } else { (:) },
    )
    div(class: "relative group", {
      elem("button", attrs: (
        class: {
          "absolute right-2 top-2 px-2 py-1 z-10"
          " text-xs font-medium"
          " border border-neutral-300 bg-white text-neutral-600"
          " opacity-0 group-hover:opacity-100 transition-opacity"
          " hover:bg-neutral-100"
          " dark:border-transparent dark:bg-zinc-800 dark:text-neutral-300 dark:hover:bg-zinc-700"
        },
        onclick: ```js
        const text = this.nextElementSibling.querySelector('code').textContent;
        const done = () => {
          this.textContent = 'Copied!';
          setTimeout(() => { this.textContent = 'Copy'; }, 2000);
        };
        if (navigator.clipboard) {
          navigator.clipboard.writeText(text).then(done).catch(console.error);
        } else {
          const input = document.createElement('textarea');
          input.value = text;
          input.style.position = 'fixed';
          input.style.top = '0';
          input.style.left = '0';
          input.style.opacity = '0';
          input.setAttribute('readonly', '');
          document.body.appendChild(input);
          input.select();
          document.execCommand('copy');
          document.body.removeChild(input);
          done();
        }
        ```.text,
      ))[Copy]
      pre(code-fn(for line in it.lines {
        span(class: "line", line)
        linebreak()
      }))
    })
  }

  div(class: "group", {
    div(class: "relative", {
      input(
        class: {
          "z-10 fixed md:hidden"
          " peer appearance-none"
          " left-0 top-1/2 w-8 h-20"
          " -translate-y-1/2"
          " checked:translate-y-0 checked:translate-x-72 checked:top-0"
          " checked:w-full checked:h-full"
        },
        type: "checkbox",
      )
      div(class: {
        "flex items-center justify-center"
        " z-5 fixed top-1/2 w-8 h-20"
        " border-r border-t border-b border-neutral-300"
        " bg-neutral-100 text-neutral-400"
        " dark:border-transparent dark:bg-zinc-700"
        " rounded-r-sm shadow-sm"
        " md:hidden -translate-y-1/2 peer-checked:translate-x-72"
        " transition-transform text-3xl"
      })[|||]
    })
    nav(
      id: "main-toc",
      class: {
        "dark:text-white w-72 z-10 flex fixed left-0 top-0 h-full"
        " -translate-x-full shadow-sm md:shadow-none"
        " group-has-[:checked]:translate-x-0 md:translate-x-0 flex-col"
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
        div(
          class: {
            "border-neutral-300 dark:border-transparent overflow-x-auto "
            {
              "block border-y px-2 py-1"
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
  })

  // only let pagefind index the article
  let main-content = elem(
    "article",
    attrs: (
      id: "haita-main-content",
      class: {
        "p-3 sm:p-6 md:p-8 min-w-full"
        " prose prose-neutral dark:prose-invert leading-normal"
        " prose-pre:bg-neutral-100 prose-pre:text-neutral-900"
        " prose-pre:border prose-pre:border-neutral-300"
        " dark:prose-pre:!bg-black dark:prose-pre:!text-neutral-100"
        " dark:prose-pre:!border-transparent"
        " prose-pre:rounded-none"
        " prose-a:decoration-1 prose-a:underline-offset-4"
        " prose-a:hover:decoration-3"
      },
      data-pagefind-body: "",
    ),
    {
      it.content
      // footnote
      let final = footnote-state.final()
      if final.len() > 0 {
        divider()
        let items = final.map(it => enum.item[
          #it.content #it.target-label
          #span(class: "*:no-underline hover:underline ml-4", std.link(it.source-label)[↗])
        ])
        section(class: "text-sm text-neutral-500", std.enum(..items))
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
            li(std.link(label, query(label).at(0).body))
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
  canonical-url,
  chapter,
  bottom-content: none,
  // defaults to 1pt -> 1px
  width-px: 1200,
  height-px: 630,
  ppi: 144,
) = {
  let image-path = "/" + chapter.path.join("/") + "_summary.png"
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
      og-property("image", content: canonical-url + image-path)
      og-property("image:type", content: "image/png")
      og-property("image:width", content: str(width-px))
      og-property("image:height", content: str(height-px))
      html.meta(name: "twitter:card", content: "summary_large_image")
      html.meta(name: "twitter:image", content: canonical-url + image-path)
    },
  )
}

#let html-renderer(
  tree,
  lang: "en",
  root: (),
  title: "",
  canonical-url: "",
  summary-image-renderer: none,
  footer-content: [
    Powered by #link("https://github.com/wensimehrp/haita")[Haita]. Made in Vancouver with love.
  ],
  extra-css: none,
  extra-head-content: none,
  sidebar-image: html.a(
    href: "https://en.wikipedia.org/wiki/File:Sea_Otter_(Enhydra_lutris)_(25169790524)_crop.jpg",
    html.img(
      class: "w-full h-45 object-cover object-top",
      src: "https://upload.wikimedia.org/wikipedia/commons/0/02/Sea_Otter_%28Enhydra_lutris%29_%2825169790524%29_crop.jpg",
    ),
  ),
  pagefind-enabled: false,
  ..args,
) = {
  // first generate the tailwind preflight
  let site-title = title
  import "@preview/typhoon:0.1.2"
  import "fonts/fonts.typ": font-css, font-files
  let stylesheet-path = "/" + (root, "styles.css").flatten().join("/")
  font-files(root.join("/")).join()
  [
    #asset(
      stylesheet-path,
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
        read("styles/footnote.css")
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
      #if type(summary-image-renderer) == function { summary-image-renderer(it).document }
      #document(page-path-str, html.html(lang: lang, {
        import html: *
        head({
          // Chore
          meta(charset: "utf-8")
          meta(name: "viewport", content: "width=device-width, initial-scale=1")
          title(it.title)
          link(rel: "canonical", href: canonical-url + page-path-str)
          // TODO: finish description here
          meta(name: "description", content: "...")
          // Styles
          realize(<styles>, href => link(rel: "stylesheet", href: href))
          extra-head-content
          // Open Graph SEO
          import "lib.typ": to-string
          og-property("title", content: to-string("" + it.title))
          og-property("description", content: to-string("" + [...]))
          og-property("type", content: "website")
          og-property("url", content: canonical-url + page-path-str)
          og-property("site_name", content: site-title)
          if type(summary-image-renderer) == function {
            summary-image-renderer(it).og-properties
          }
          // Twitter SEO
          meta(name: "twitter:title", content: to-string("" + it.title))
          meta(name: "twitter:domain", content: canonical-url.replace(regex("https?://"), ""))
          meta(name: "twitter:description", content: "...")
          if pagefind-enabled {
            let link-path = "/" + (root + ("pagefind", "pagefind-component-ui.css")).join("/")
            let script-path = "/" + (root + ("pagefind", "pagefind-component-ui.js")).join("/")
            link(href: link-path, rel: "stylesheet")
            script(src: script-path, type: "module")
          }
        })
        body(class: "dark:bg-zinc-900", {
          if pagefind-enabled {
            elem("pagefind-config", attrs: (
              bundle-path: "/" + (root + ("pagefind",)).join("/") + "/",
              base-url: "/",
            ))
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


#let paged-renderer(tree, root: (), ..args) = [
  #document(root.join("/") + "/doc.pdf", for it in flatten-tree(tree) {
    it.content
  }) <doc.pdf>
]
