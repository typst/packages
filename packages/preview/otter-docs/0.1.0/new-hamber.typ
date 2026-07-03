// Default theme "New Hamber"

#let summary-renderer(current-tree, current-chapter) = for it in current-tree {
  html.div(
    class: "w-full relative"
      + if "page-label" in it and it.page-label == current-chapter.page-label {
        " border-y border-neutral-300 dark:border-transparent dark:bg-zinc-600 "
      },
    if it.kind == "chapter" {
      html.div(
        class: if it.page-label == current-chapter.page-label { "bg-white dark:bg-zinc-600 " }
          + "block w-full px-2 py-1 hover:bg-neutral-500/30".split(" ").map(it => "[&>a]:" + it).join(" "),
        std.link(it.page-label, it.title),
      )
      if it.page-label == current-chapter.page-label and it.headings.len() > 0 {
        html.div(
          class: "border-y border-neutral-300 dark:border-transparent bg-white dark:bg-zinc-700 "
            + "px-2 py-1 block hover:bg-neutral-500/30".split(" ").map(it => "[&>a]:" + it).join(" "),
          for label in it.headings {
            std.link(label, query(label).at(0).body)
          },
        )
      }
    } else if it.kind == "separator" {
      html.div(class: "w-full bg-neutral-300 dark:bg-zinc-600 h-[1px] my-3")
    } else {
      html.div(class: "p-2 font-bold", it.content)
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

#let internal-html-renderer(final-tree, it, footer-content, sidebar-image) = html.body(class: "dark:bg-zinc-900", {
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
      class: "footnote-popup",
      ftn.body,
    )
  })

  input(class: "z-10 fixed peer md:hidden top-4 left-4 checked:translate-x-72 transition-transform", type: "checkbox")
  nav(
    class: "dark:text-white w-72 z-10 flex fixed left-0 top-0 h-full -translate-x-full shadow-sm md:shadow-none peer-checked:translate-x-0 md:translate-x-0 flex-col border-r border-neutral-300 dark:border-transparent bg-neutral-100 dark:bg-zinc-800 transition-transform",
    {
      sidebar-image
      div(
        class: "border-t border-neutral-300 dark:border-transparent overflow-x-auto",
        {
          summary-renderer(final-tree, it)
        },
      )
    },
  )
  article(
    class: "p-3 sm:p-6 md:p-8 max-w-[52rem] md:ml-72 prose prose-neutral dark:prose-invert leading-normal prose-pre:rounded-none",
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
})

#let update-elem(elem, state: none) = {
  let classes = elem.fields().attrs.at("class", default: ())
  if type(classes) == str {
    classes = classes.split(" ")
  }
  classes = classes.map(it => (it, none)).to-dict()
  state.update(it => it + classes)
  elem
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
    Powered by #link("https://github.com/wensimehrp/otter-docs")[Otter Docs]. Made in Vancouver with love.
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
  ..args,
) = {
  // first generate the tailwind preflight
  let site-title = title
  import "@preview/typhoon:0.1.2"
  let stylesheet-path = "/" + (root, "styles.css").flatten().join("/")
  let page-classes = state("__new_hamber page classes", (:))
  asset(
    stylesheet-path,
    typhoon._plugin.generate(bytes(page-classes.final().keys().join(" ", default: "")), cbor.encode((
      preflight: (full: (font_family_sans: "Cabin")),
    )))
      + bytes("\n")
      + read("footnote.css", encoding: none)
      + bytes("\n")
      + read("math.css", encoding: none)
      + bytes("\n")
      + bytes(extra-css + ""),
  )
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
          link(rel: "stylesheet", href: stylesheet-path)
          extra-head-content
          style(
            "@import url('https://fonts.googleapis.com/css2?family=Cabin:ital,wght@0,400..700;1,400..700&family=STIX+Two+Math&display=swap');",
          )
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
        })
        internal-html-renderer(tree, it, footer-content, sidebar-image)
      })) #it.page-label
    ],
  )
}


#let paged-renderer(tree, root: (), ..args) = [#document(root.join("/") + "/doc.pdf", for it in flatten-tree(tree) {
  it.content
}) <doc.pdf>]
