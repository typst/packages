// itemplate — a modern academic HTML documentation template for Typst.
// Compile with: typst compile --features html --format html your-file.typ

#import "src/styles.typ": base-styles
#import "src/client.typ": client-script, prepaint-script

// ---------------------------------------------------------------------------
// Theme
// ---------------------------------------------------------------------------

// Default theme. Palette follows the light theme used by the typst.ts
// cookery documentation: a white page, soft gray surfaces, and a blue
// accent for links and interactive elements.
// Renamed to `default-theme-base` so the `default-theme` parameter name is
// free for per-theme overrides (the parameter shadows module scope).
#let default-theme-base = (
  bg: "#ffffff",
  surface: "#fafafa",
  "surface-strong": "#e6e6e6",
  ink: "#000000",
  "ink-muted": "#5f5f5f",
  "ink-faint": "#6f6f6f",
  line: "rgba(0, 0, 0, 0.12)",
  "line-strong": "rgba(0, 0, 0, 0.24)",
  accent: "#20609f",
  "accent-soft": "rgba(32, 96, 159, 0.10)",
  "accent-ink": "#1a4f83",
  "sidebar-bg": "#fafafa",
  "header-bg": "rgba(255, 255, 255, 0.86)",
  "code-bg": "#f5f5f5",
  selection: "rgba(125, 185, 222, 0.63)",
  overlay: "rgba(0, 0, 0, 0.32)",
  "font-ui": "\"Inter\", \"Source Sans 3\", \"Segoe UI\", \"PingFang SC\", \"Microsoft YaHei\", \"Noto Sans SC\", system-ui, sans-serif",
  "font-serif": "\"Source Serif 4\", \"Source Serif Pro\", Charter, Georgia, \"Noto Serif SC\", \"Source Han Serif SC\", \"Songti SC\", serif",
  "font-mono": "\"JetBrains Mono\", \"Maple Mono NF CN\", \"Cascadia Code\", \"SF Mono\", Consolas, monospace",
  "font-math": "\"STIX Two Math\", \"NewComputerModernMath\", \"Latin Modern Math\", math",
)

// Paper theme. Palette and typography follow the Claudette Typora theme:
// warm paper, a single terracotta accent, serif headings, hairline rules.
#let default-paper-theme = (
  bg: "#faf9f5",
  surface: "#f5f4ed",
  "surface-strong": "#ece9df",
  ink: "#141413",
  "ink-muted": "#6b6a63",
  "ink-faint": "#6f6d66",
  line: "rgba(31, 30, 29, 0.12)",
  "line-strong": "rgba(31, 30, 29, 0.22)",
  accent: "#d97757",
  "accent-soft": "rgba(217, 119, 87, 0.10)",
  "accent-ink": "#a94e30",
  "sidebar-bg": "#f2f0e9",
  "header-bg": "rgba(250, 249, 245, 0.86)",
  "code-bg": "#f5f4ed",
  selection: "rgba(235, 201, 183, 0.55)",
  overlay: "rgba(20, 20, 19, 0.32)",
)

// Green theme. Same structure as the paper theme, with a
// sage-green accent and a slightly green-tinted paper.
#let default-green-theme = (
  bg: "#f6f9f3",
  surface: "#eef4ea",
  "surface-strong": "#e1ebdb",
  ink: "#17241a",
  "ink-muted": "#5f6b58",
  "ink-faint": "#64705d",
  line: "rgba(23, 36, 26, 0.12)",
  "line-strong": "rgba(23, 36, 26, 0.22)",
  accent: "#4d8f5f",
  "accent-soft": "rgba(77, 143, 95, 0.10)",
  "accent-ink": "#3d7550",
  "sidebar-bg": "#eff5ea",
  "header-bg": "rgba(246, 249, 243, 0.86)",
  "code-bg": "#eef4ea",
  selection: "rgba(178, 214, 182, 0.55)",
  overlay: "rgba(18, 30, 22, 0.32)",
)

// Dark theme tokens from Claudette Dark.
#let default-dark-theme = (
  bg: "#262625",
  surface: "#2c2c2a",
  "surface-strong": "#34332e",
  ink: "#f2f0e9",
  "ink-muted": "#b8b6a9",
  "ink-faint": "#95948a",
  line: "rgba(255, 255, 255, 0.10)",
  "line-strong": "rgba(255, 255, 255, 0.20)",
  accent: "#d97757",
  "accent-soft": "rgba(217, 119, 87, 0.14)",
  "accent-ink": "#e6906f",
  "sidebar-bg": "#1f1f1e",
  "header-bg": "rgba(38, 38, 37, 0.86)",
  "code-bg": "#2c2c2a",
  selection: "rgba(217, 119, 87, 0.35)",
  overlay: "rgba(0, 0, 0, 0.56)",
)

// Converts a theme token to a CSS color string. Both raw CSS strings and
// Typst colors are accepted.
#let theme-value(value) = if type(value) == color { value.to-hex() } else { str(value) }

#let theme-to-css(theme, selector: ":root") = {
  let declarations = theme
    .pairs()
    .map(((name, value)) => "  --" + name + ": " + theme-value(value) + ";")
  selector + " {\n" + declarations.join("\n") + "\n}"
}

// ---------------------------------------------------------------------------
// Interface strings
// ---------------------------------------------------------------------------

#let ui-strings = (
  en: (
    "toc-label": "CONTENTS",
    "toc-nav-label": "Table of contents",
    "toc-empty": "No sections yet",
    "toc-expand": "Expand subsection",
    "toc-collapse": "Collapse subsection",
    "table-region": "Table, horizontally scrollable",
    "table-expand": "View table fullscreen",
    "table-exit": "Exit fullscreen",
    "skip-content": "Skip to content",
    "sidebar-label": "Document contents",
    "sidebar-close": "Close contents",
    "sidebar-expand": "Expand contents",
    "sidebar-collapse": "Collapse contents",
    "sidebar-resize": "Resize contents",
    "theme-toggle": "Toggle theme",
    "theme-current": "Toggle theme (current: {name})",
    "theme-default": "Default",
    "theme-paper": "Paper",
    "theme-green": "Green",
    "theme-dark": "Dark",
  ),
  zh: (
    "toc-label": "目录",
    "toc-nav-label": "目录",
    "toc-empty": "暂无目录",
    "toc-expand": "展开子目录",
    "toc-collapse": "折叠子目录",
    "table-region": "表格，可横向滚动",
    "table-expand": "全屏查看表格",
    "table-exit": "退出全屏",
    "skip-content": "跳到正文",
    "sidebar-label": "文档目录",
    "sidebar-close": "关闭目录",
    "sidebar-expand": "展开目录",
    "sidebar-collapse": "收起目录",
    "sidebar-resize": "调整目录宽度",
    "theme-toggle": "切换主题",
    "theme-current": "切换主题（当前：{name}）",
    "theme-default": "默认",
    "theme-paper": "纸张",
    "theme-green": "浅绿",
    "theme-dark": "深色",
  ),
)

// UI labels fall back to English for languages without a translation.
#let resolve-ui-strings(lang) = {
  let base = ui-strings.en
  if lang.starts-with("zh") { base + ui-strings.zh } else { base }
}

// ---------------------------------------------------------------------------
// Import map
// ---------------------------------------------------------------------------

// Defaults used when `import-map` is `auto`. Pass `import-map: (:)` to emit
// no import map, or merge your own entries into this dictionary.
#let default-import-map = (
  "three": "https://cdn.jsdelivr.net/npm/three@0.185.1/build/three.module.js",
  "three/addons/": "https://cdn.jsdelivr.net/npm/three@0.185.1/examples/jsm/",
  "cannon-es": "https://cdn.jsdelivr.net/npm/cannon-es@0.20.0/dist/cannon-es.js",
  "fundamental-physical-constants": "https://unpkg.com/fundamental-physical-constants/FundamentalPhysicalConstants.js",
  "plotly": "https://cdn.jsdelivr.net/npm/plotly.js-dist-min@4.3.0/+esm",
  "echarts": "https://cdn.jsdelivr.net/npm/echarts@5.5.1/dist/echarts.esm.min.js",
  "echarts-gl": "https://cdn.jsdelivr.net/npm/echarts-gl@2.0.9/dist/echarts-gl.min.js",
)

// ---------------------------------------------------------------------------
// Compile-time table of contents
// ---------------------------------------------------------------------------

// Heading anchors are derived from document order instead of the heading
// counter. Unnumbered headings and counter resets therefore cannot produce
// duplicate IDs, and anchors stay unique even when numbering is hidden.
#let heading-id(index) = "sec-" + str(index + 1)

// Builds a nested <ol> from a flat heading list. `parent-level` is the level
// of the enclosing TOC entry (0 for the root), so any heading deeper than the
// parent is consumed as a child. This keeps all headings when levels skip.
#let build-toc-level(items, start, parent-level, strings, depth: 1) = {
  let lis = ()
  let i = start
  while i < items.len() and items.at(i).level > parent-level {
    let item = items.at(i)
    let child = none
    let next-i = i + 1
    if next-i < items.len() and items.at(next-i).level > item.level {
      let (sub, ni) = build-toc-level(
        items,
        next-i,
        item.level,
        strings,
        depth: depth + 1,
      )
      child = sub
      next-i = ni
    }

    let link = html.elem("a", attrs: (class: "toc-link", href: "#" + item.id), {
      if item.num != none {
        html.elem("span", attrs: (class: "toc-num"), item.num)
      }
      html.elem("span", attrs: (class: "toc-text"), item.body)
    })

    let row = html.elem("div", attrs: (class: "toc-row"), {
      link
      if child != none {
        html.elem("button", attrs: (
          class: "toc-toggle",
          type: "button",
          "aria-expanded": "false",
          "aria-label": strings.at("toc-expand"),
        ), {
          html.elem("span", attrs: (class: "chevron"))
        })
      }
    })

    let body = row
    if child != none { body = body + child }

    lis.push(html.elem("li", attrs: (
      class: "toc-item",
      "data-level": str(item.level),
      ..(if child != none { ("data-collapsed": "true") } else { (:) }),
    ), body))
    i = next-i
  }

  let ol = if depth == 1 {
    html.elem("ol", attrs: (class: "toc-root", id: "toc-root", "data-depth": "1"), lis.join())
  } else {
    html.elem("ol", attrs: (class: "toc-sub", "data-depth": str(depth)), lis.join())
  }
  (ol, i)
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let itemplate(
  doc-title: "Document",
  doc-author: "",
  lang: "en",
  // Per-theme override dictionaries. Each one affects only the named theme,
  // so changing e.g. paper's `bg`/`sidebar-bg` does not touch default, green,
  // or dark. There is intentionally no shared `theme` parameter: paper and
  // green have very different color styles, so a single shared palette is
  // hard to tune consistently.
  default-theme: (:),
  paper-theme: (:),
  green-theme: (:),
  dark-theme: (:),
  // Heading numbering used by the document. A `#set heading(numbering: ...)`
  // placed after the show rule still takes precedence. Pass `none` to hide
  // numbers while keeping stable heading anchors.
  heading-numbering: "1.1.1",
  // `auto` emits `default-import-map`; a dictionary replaces it. Merge your
  // own entries with `default-import-map + (...)`, or use `(:)` to disable.
  import-map: auto,
  body,
) = {
  // Applies to HTML and PDF alike. Later document-level set rules still win.
  set heading(numbering: heading-numbering)

  context if target() == "html" {
    let resolved-theme = default-theme-base + default-theme
    let resolved-paper-theme = default-theme-base + default-paper-theme + paper-theme
    let resolved-green-theme = default-theme-base + default-green-theme + green-theme
    let resolved-dark-theme = default-theme-base + default-dark-theme + dark-theme
    let resolved-import-map = if import-map == auto { default-import-map } else { import-map }
    let s = resolve-ui-strings(lang)
    let toc-label = s.at("toc-label")

    // Compile-time TOC. query(heading) sees the whole document, including
    // headings that appear after this sidebar in the DOM. Headings with
    // `outlined: false` are kept in the document but omitted from the TOC.
    let headings = query(heading)
    let toc-headings = headings.enumerate().filter(((_, h)) => h.outlined)
    let toc = if toc-headings.len() == 0 {
      html.elem("p", attrs: (class: "toc-empty"), s.at("toc-empty"))
    } else {
      let items = toc-headings.map(((index, h)) => {
        let nums = counter(heading).at(h.location())
        (
          level: h.level,
          body: h.body,
          num: if h.numbering != none {
            numbering(h.numbering, ..nums)
          } else {
            none
          },
          id: heading-id(index),
        )
      })
      let (root, _) = build-toc-level(items, 0, 0, s)
      root
    }

    show heading: it => {
      if target() == "html" or target() == "bundle" {
        context {
          let index = none
          for (i, h) in headings.enumerate() {
            if h.location() == it.location() { index = i }
          }
          let id = if index != none { heading-id(index) } else { "sec-unknown" }
          let num = if it.numbering != none {
            counter(heading).display(it.numbering)
          } else {
            none
          }
          let html-level = calc.min(it.level + 1, 6)
          let level-attrs = if it.level + 1 > 6 { ("aria-level": str(it.level + 1)) } else { (:) }
          html.elem("h" + str(html-level), attrs: (id: id, ..level-attrs), {
            if num != none {
              html.elem("span", attrs: (class: "h-num"), num)
            }
            html.elem("span", attrs: (class: "h-text"), it.body)
          })
        }
      } else {
        it
      }
    }

    // Wrap tables so they can scroll horizontally without touching the page.
    show table: it => {
      if target() == "html" or target() == "bundle" {
        html.elem("div", attrs: (class: "table-block"), {
          html.elem("div", attrs: (
            class: "table-scroll",
            tabindex: "0",
            role: "region",
            "aria-label": s.at("table-region"),
          ), it)
          html.elem("button", attrs: (
            class: "table-expand",
            type: "button",
            "aria-label": s.at("table-expand"),
          ), {
            html.elem("span", attrs: (class: "icon-expand"))
          })
          html.elem("button", attrs: (
            class: "table-exit",
            type: "button",
            "aria-label": s.at("table-exit"),
          ), "×")
        })
      } else {
        it
      }
    }

    // Strings consumed by the client-side script. Keep these plain strings so
    // they can be embedded as JSON.
    let ui = (
      themeDefault: s.at("theme-default"),
      themePaper: s.at("theme-paper"),
      themeGreen: s.at("theme-green"),
      themeDark: s.at("theme-dark"),
      themeCurrent: s.at("theme-current"),
      tocExpand: s.at("toc-expand"),
      tocCollapse: s.at("toc-collapse"),
      sidebarExpand: s.at("sidebar-expand"),
      sidebarCollapse: s.at("sidebar-collapse"),
    )

    html.html(lang: lang, {
      html.head({
        html.meta(charset: "utf-8")
        html.meta(name: "viewport", content: "width=device-width, initial-scale=1.0, viewport-fit=cover")
        html.meta(name: "color-scheme", content: "light dark")
        html.meta(name: "theme-color", content: theme-value(resolved-theme.bg))
        if doc-author != "" {
          html.meta(name: "author", content: doc-author)
        }
        html.title(doc-title)

        // Apply the saved sidebar state and theme before first paint to
        // avoid a flash.
        html.script(prepaint-script)

        // Math web font: STIX Two Math (OFL 1.1, Tiro Typeworks / STI Pub),
        // served by the official Google Fonts CDN instead of GitHub Pages.
        // The `.cn` endpoints are Google's China-accessible domains; the
        // returned CSS references font files on fonts.gstatic.cn.
        // If Google Fonts is unreachable, `--font-math` falls back to locally
        // installed New Computer Modern Math / Latin Modern Math.
        html.link(rel: "preconnect", href: "https://fonts.googleapis.cn")
        html.link(rel: "preconnect", href: "https://fonts.gstatic.cn", crossorigin: "anonymous")
        html.link(
          rel: "stylesheet",
          href: "https://fonts.googleapis.cn/css2?family=STIX+Two+Math&display=swap",
        )

        if resolved-import-map.len() > 0 {
          html.script(
            type: "importmap",
            json.encode((imports: resolved-import-map)),
          )
        }

        html.style(theme-to-css(resolved-theme))
        html.style(theme-to-css(resolved-paper-theme, selector: ":root[data-theme='paper']"))
        html.style(theme-to-css(resolved-green-theme, selector: ":root[data-theme='green']"))
        html.style(theme-to-css(resolved-dark-theme, selector: ":root[data-theme='dark']"))

        html.style(base-styles)

        html.script(
          type: "module",
          "const ui = " + json.encode(ui) + ";\n" + client-script,
        )
      })

      html.body({
        html.elem("a", attrs: (class: "skip-link", href: "#content"), s.at("skip-content"))

        html.elem("div", attrs: (class: "shell"), {
          html.elem("aside", attrs: (
            id: "sidebar",
            class: "sidebar",
            "aria-label": s.at("sidebar-label"),
          ), {
            html.elem("div", attrs: (class: "sidebar-head"), {
              html.elem("div", attrs: (class: "sidebar-heading"), {
                html.elem("span", attrs: (class: "sidebar-title"), toc-label)
              })
              html.elem("button", attrs: (
                id: "sidebar-close",
                class: "icon-btn mobile-only",
                type: "button",
                "aria-label": s.at("sidebar-close"),
              ), {
                html.elem("span", attrs: (class: "icon-close"))
              })
            })

            html.elem("nav", attrs: (class: "toc-nav", "aria-label": s.at("toc-nav-label")), toc)

            html.elem("div", attrs: (class: "sidebar-foot"), {
              html.elem("span", attrs: (class: "sidebar-foot-title"), doc-title)
              if doc-author != "" {
                html.elem("span", attrs: (class: "sidebar-foot-author"), doc-author)
              }
            })

            html.elem("div", attrs: (
              class: "resize-handle",
              role: "separator",
              "aria-orientation": "vertical",
              "aria-label": s.at("sidebar-resize"),
              tabindex: "0",
            ))
          })

          html.elem("div", attrs: (class: "overlay", "aria-hidden": "true"))

          html.elem("div", attrs: (class: "main"), {
            html.elem("header", attrs: (class: "topbar"), {
              html.elem("div", attrs: (class: "topbar-left"), {
                html.elem("button", attrs: (
                  id: "sidebar-toggle",
                  class: "icon-btn",
                  type: "button",
                  "aria-label": s.at("sidebar-collapse"),
                  "aria-controls": "sidebar",
                  "aria-expanded": "true",
                ), {
                  html.elem("span", attrs: (class: "icon-menu"))
                })

                html.elem("div", attrs: (class: "doc-heading"), {
                  html.elem("h1", attrs: (class: "doc-title"), doc-title)
                })
              })

              html.elem("div", attrs: (class: "topbar-right"), {
                html.elem("button", attrs: (
                  id: "theme-toggle",
                  class: "icon-btn",
                  type: "button",
                  title: s.at("theme-toggle"),
                  "aria-label": s.at("theme-toggle"),
                ), {
                  html.elem("span", attrs: (class: "icon-theme"))
                })
              })
            })

            html.elem("main", attrs: (id: "content", class: "content", tabindex: "-1"), {
              html.elem("article", attrs: (class: "article"), body)
            })
          })
        })
      })
    })
  } else if target() == "bundle" {
    panic("bundle export is not supported by itemplate, please export the document to html instead")
  } else {
    body
  }
}
