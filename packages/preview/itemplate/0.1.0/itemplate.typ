#let itemplate(
  title: "Document",
  lang: "en",
  body,
) = {
  html.html(lang: lang, {
    html.head({
      html.meta(
        charset: "utf-8",
      )

      html.meta(
        name: "viewport",
        content: "width=device-width, initial-scale=1.0",
      )

      html.title(title)

      html.script(
        type: "importmap",
        ```json
        {
          "imports": {
            "three": "https://cdn.jsdelivr.net/npm/three@0.185.1/build/three.module.js",
            "three/addons/": "https://cdn.jsdelivr.net/npm/three@0.185.1/examples/jsm/"
          }
        }
        ```.text,
      )

      html.script(
        ```js
        MathJax = {
          loader: {
            load: ['input/asciimath', "input/mml", 'output/chtml', 'ui/menu']
          }
        };
        ```.text,
      )

      html.script(src: "https://unpkg.com/mathjax@4/startup.js", defer: true)

      html.link(rel: "stylesheet", href: "https://unpkg.com/@hexiongwu1995/itemplate/icon_font/iconfont.css")

      html.link(rel: "stylesheet", href: "https://unpkg.com/@hexiongwu1995/itemplate/styles/style.css")
      // html.link(rel: "stylesheet", href: "./assets/styles/style.css")

      html.script(src: "https://unpkg.com/@hexiongwu1995/itemplate/scripts/script.js", defer: true)
      // html.script(src: "./assets/scripts/script.js", defer: true)
    })
    html.body({
      html.div(class: ("container",), {
        html.aside({
          html.span(class: ("aside-title-large-screen",), "Table of Contents")
          html.span(class: ("aside-title-small-screen",), title)
          html.div(class: ("function-panel",), {
            html.span(class: ("iconfont", "icon-Numbering"), {
              html.span(class: "numbering-text")[Numbering Titles]
            })
            html.span(class: ("iconfont", "icon-expand-all"), {
              html.span(class: "expand-all-text")[Expand All]
            })
          })
          html.nav({
            html.ol(id: "toc-root")[]
          })
          html.div(id: "resize-handle")[]
        })
        html.div(class: ("overlay",))[]
        html.main({
          html.header({
            html.span(class: ("header-left",), {
              html.span(class: ("iconfont", "icon-Aside"))[]
              html.span(class: ("iconfont", "icon-menu3"))[]
            })
            html.span(class: ("header-middle",), title)
            html.span(class: ("header-right",), {
              html.a(class: ("iconfont-home",), {
                html.span(class: ("iconfont", "icon-home"))[]
              })
              html.a(class: ("iconfont-github",), {
                html.span(class: ("iconfont", "icon-github"))[]
              })
              html.a(class: ("iconfont-print",), {
                html.span(class: ("iconfont", "icon-print"))[]
              })
              html.a(class: ("iconfont-paintbrush",), {
                html.span(class: ("iconfont", "icon-paintbrush"))[]
              })
            })
          })
          html.article({
            body
          })
        })
      })
    })
  })
}
