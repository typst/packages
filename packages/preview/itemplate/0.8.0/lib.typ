// itemplate — a modern academic HTML documentation template for Typst.
// Compile with: typst compile --features html --format html your-file.typ

// ---------------------------------------------------------------------------
// Theme
// ---------------------------------------------------------------------------

// Light theme. Palette and typography follow the Claudette Typora theme:
// warm paper, a single terracotta accent, serif headings, hairline rules.
#let default-theme = (
  bg: "#faf9f5",
  surface: "#f5f4ed",
  "surface-strong": "#ece9df",
  ink: "#141413",
  "ink-muted": "#73726c",
  "ink-faint": "#b0aea5",
  line: "rgba(31, 30, 29, 0.12)",
  "line-strong": "rgba(31, 30, 29, 0.22)",
  accent: "#d97757",
  "accent-soft": "rgba(217, 119, 87, 0.10)",
  "accent-ink": "#c6613f",
  "sidebar-bg": "#f2f0e9",
  "header-bg": "rgba(250, 249, 245, 0.86)",
  "code-bg": "#f5f4ed",
  selection: "rgba(235, 201, 183, 0.55)",
  overlay: "rgba(20, 20, 19, 0.32)",
  "font-ui": "\"Inter\", \"Source Sans 3\", \"Segoe UI\", \"PingFang SC\", \"Microsoft YaHei\", \"Noto Sans SC\", system-ui, sans-serif",
  "font-serif": "\"Source Serif 4\", \"Source Serif Pro\", Charter, Georgia, \"Noto Serif SC\", \"Source Han Serif SC\", \"Songti SC\", serif",
  "font-mono": "\"JetBrains Mono\", \"Maple Mono NF CN\", \"Cascadia Code\", \"SF Mono\", Consolas, monospace",
  "font-math": "\"STIX Two Math\", \"NewComputerModernMath\", \"Latin Modern Math\", math",
)

// Light green theme. Same structure as the default light theme, with a
// sage-green accent and a slightly green-tinted paper.
#let default-green-theme = (
  bg: "#f6f9f3",
  surface: "#eef4ea",
  "surface-strong": "#e1ebdb",
  ink: "#17241a",
  "ink-muted": "#66735f",
  "ink-faint": "#aab6a3",
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
  "ink-faint": "#8b8a80",
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

#let theme-to-css(theme, selector: ":root") = {
  let declarations = theme
    .pairs()
    .map(((name, value)) => {
      let css-value = if type(value) == color { value.to-hex() } else { str(value) }
      "  --" + name + ": " + css-value + ";"
    })
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
    "theme-light": "Light",
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
    "theme-light": "浅色",
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

// Single source of truth for heading anchors, shared by the TOC and headings.
#let heading-id(nums) = "sec-" + nums.map(str).join("-")

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
  doc-author: "Author",
  lang: "en",
  theme: (:),
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
  context if target() == "html" {
    let resolved-theme = default-theme + theme
    let resolved-green-theme = default-theme + default-green-theme + theme
    let resolved-dark-theme = default-theme + default-dark-theme + dark-theme
    let resolved-import-map = if import-map == auto { default-import-map } else { import-map }
    // Headings need a numbering pattern for the heading counter to advance.
    // When numbers are hidden, use an internal pattern so anchors stay unique.
    let internal-heading-numbering = if heading-numbering == none { "1.1.1" } else { heading-numbering }
    let show-heading-numbers = heading-numbering != none
    let s = resolve-ui-strings(lang)
    let toc-label = s.at("toc-label")

    // Compile-time TOC. query(heading) sees the whole document, including
    // headings that appear after this sidebar in the DOM.
    let headings = query(heading)
    let toc = if headings.len() == 0 {
      html.elem("p", attrs: (class: "toc-empty"), s.at("toc-empty"))
    } else {
      let items = headings.map(h => {
        let nums = counter(heading).at(h.location())
        (
          level: h.level,
          body: h.body,
          num: if show-heading-numbers and h.numbering != none {
            numbering(h.numbering, ..nums)
          } else {
            none
          },
          id: heading-id(nums),
        )
      })
      let (root, _) = build-toc-level(items, 0, 0, s)
      root
    }

    set heading(numbering: internal-heading-numbering)

    show heading: it => {
      if target() == "html" or target() == "bundle" {
        context {
          let nums = counter(heading).get()
          let id = heading-id(nums)
          let num = if show-heading-numbers and it.numbering != none {
            counter(heading).display(it.numbering)
          } else {
            none
          }
          html.elem("h" + str(it.level + 1), attrs: (id: id), {
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
      themeLight: s.at("theme-light"),
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
        html.meta(name: "theme-color", content: resolved-theme.bg, media: "(prefers-color-scheme: light)")
        html.meta(name: "theme-color", content: resolved-dark-theme.bg, media: "(prefers-color-scheme: dark)")
        if doc-author != "" {
          html.meta(name: "author", content: doc-author)
        }
        html.title(doc-title)

        // Apply the saved sidebar state and theme before first paint to
        // avoid a flash.
        html.script(
          ```js
          try {
            if (localStorage.getItem("itemplate:sidebar-open") === "0") {
              document.documentElement.classList.add("sidebar-preclosed");
            }
            var savedTheme = localStorage.getItem("itemplate:theme");
            if (savedTheme === "light" || savedTheme === "dark" || savedTheme === "green") {
              document.documentElement.dataset.theme = savedTheme;
            }
          } catch (error) {}
          ```.text,
        )

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
        html.style(theme-to-css(resolved-green-theme, selector: ":root[data-theme='green']"))
        html.style(theme-to-css(resolved-dark-theme, selector: ":root[data-theme='dark']"))
        html.style(
          "@media (prefers-color-scheme: dark) {\n"
          + theme-to-css(resolved-dark-theme, selector: ":root:not([data-theme])")
          + "\n}",
        )

        html.style(
          ```css
          :root {
            --sidebar-w: 300px;
            --header-h: 64px;
            --app-h: 100vh;
            --radius-sm: 4px;
            --radius: 8px;
            --radius-lg: 12px;
            --ease: cubic-bezier(.32, .72, 0, 1);
            --dur: .28s;
            color-scheme: light dark;
          }

          :root[data-theme="light"],
          :root[data-theme="green"] { color-scheme: light; }
          :root[data-theme="dark"] { color-scheme: dark; }

          @supports (height: 100dvh) {
            :root { --app-h: 100dvh; }
          }

          *,
          *::before,
          *::after { box-sizing: border-box; }

          html { -webkit-text-size-adjust: 100%; text-size-adjust: 100%; }

          body {
            margin: 0;
            background: var(--bg);
            color: var(--ink);
            font-family: var(--font-ui);
            font-size: 1.0625rem;
            line-height: 1.7;
            -webkit-font-smoothing: antialiased;
            text-rendering: optimizeLegibility;
          }

          ::selection { background: var(--selection); color: inherit; }

          a {
            color: inherit;
            text-decoration: none;
            border-bottom: 1px solid var(--line-strong);
            transition: color .15s, border-color .15s;
          }
          a:hover { color: var(--accent-ink); border-bottom-color: var(--accent-ink); }

          :focus-visible { outline: 2px solid var(--accent); outline-offset: 3px; }

          .skip-link {
            position: fixed;
            top: -80px;
            left: 16px;
            z-index: 100;
            padding: 10px 14px;
            border: 1px solid var(--line);
            border-radius: var(--radius);
            background: var(--surface);
            color: var(--ink);
            font-size: .875rem;
            transition: top .2s var(--ease);
          }
          .skip-link:focus { top: calc(12px + env(safe-area-inset-top)); }

          /* -----------------------------------------------------------------
             App shell
             ----------------------------------------------------------------- */

          .shell {
            display: grid;
            grid-template-columns: var(--sidebar-w) minmax(0, 1fr);
            height: var(--app-h);
            overflow: hidden;
            transition: grid-template-columns var(--dur) var(--ease);
          }
          .shell[data-sidebar="closed"] { --sidebar-w: 0px; }
          .shell[data-sidebar="closed"] .sidebar { border-right-color: transparent; }
          html.sidebar-preclosed .shell { --sidebar-w: 0px; }
          html.sidebar-preclosed .sidebar { border-right-color: transparent; }
          .shell.resizing { transition: none; }

          /* Sidebar */

          .sidebar {
            position: relative;
            display: flex;
            flex-direction: column;
            min-width: 0;
            height: var(--app-h);
            padding-top: env(safe-area-inset-top);
            border-right: 1px solid var(--line);
            background: var(--sidebar-bg);
            overflow: hidden;
          }

          .sidebar-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            padding: 20px 20px 14px;
            border-bottom: 1px solid var(--line);
          }
          .sidebar-heading { display: flex; flex-direction: column; gap: 2px; min-width: 0; }
          .sidebar-title {
            font-family: var(--font-serif);
            font-size: 1.125rem;
            font-weight: 400;
            line-height: 1.3;
          }

          .toc-nav {
            flex: 1;
            min-height: 0;
            padding: 12px 10px 20px;
            overflow-y: auto;
            overscroll-behavior: contain;
            scrollbar-width: thin;
            scrollbar-color: var(--line) transparent;
          }

          .toc-root, .toc-sub { margin: 0; padding: 0; list-style: none; }
          .toc-sub { margin-left: 13px; padding-left: 9px; border-left: 1px solid var(--line); }
          .toc-item { position: relative; }
          .toc-row { display: flex; align-items: center; gap: 2px; border-radius: var(--radius-sm); }
          .toc-row:hover { background: var(--surface); }
          .toc-row.is-active { background: var(--accent-soft); }
          .toc-row.is-active .toc-link { color: var(--accent-ink); font-weight: 500; }
          .toc-row.is-active .toc-num { color: var(--accent); }
          .toc-row.is-active .toc-toggle { color: var(--accent-ink); }
          .toc-row.is-active .toc-toggle:hover { background: transparent; }

          .toc-link {
            display: flex;
            flex: 1;
            align-items: baseline;
            gap: 8px;
            min-width: 0;
            padding: 7px 8px;
            border-bottom: 0;
            border-radius: var(--radius-sm);
            color: var(--ink-muted);
            font-size: .875rem;
            line-height: 1.5;
            transition: color .15s;
          }
          .toc-link:hover { color: var(--ink); }

          .toc-num {
            flex: none;
            min-width: 2.1em;
            color: var(--ink-muted);
            font-size: .75rem;
            font-variant-numeric: tabular-nums;
          }
          .toc-text { min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

          .toc-toggle {
            display: grid;
            flex: none;
            place-items: center;
            width: 28px;
            height: 28px;
            padding: 0;
            border: 0;
            border-radius: var(--radius-sm);
            background: transparent;
            color: var(--ink-muted);
            cursor: pointer;
          }
          .toc-toggle:hover { background: var(--surface); color: var(--ink); }

          .chevron {
            width: 7px;
            height: 7px;
            margin-top: -3px;
            border-right: 1.5px solid currentColor;
            border-bottom: 1.5px solid currentColor;
            transform: rotate(45deg);
            transition: transform .2s var(--ease);
          }
          .toc-toggle[aria-expanded="false"] .chevron { margin-top: 0; transform: rotate(-45deg); }
          .toc-item[data-collapsed="true"] > .toc-sub { display: none; }

          .toc-empty { margin: 8px 10px; color: var(--ink-muted); font-size: .875rem; }

          .sidebar-foot {
            display: flex;
            flex-direction: column;
            gap: 2px;
            padding: 14px 20px calc(16px + env(safe-area-inset-bottom));
            border-top: 1px solid var(--line);
            color: var(--ink-muted);
            font-size: .75rem;
          }
          .sidebar-foot-title {
            overflow: hidden;
            color: var(--ink);
            font-size: .8125rem;
            font-weight: 500;
            text-overflow: ellipsis;
            white-space: nowrap;
          }

          .resize-handle {
            position: absolute;
            top: 0;
            right: -3px;
            z-index: 6;
            width: 6px;
            height: 100%;
            background: transparent;
            cursor: col-resize;
          }
          .resize-handle::after {
            content: "";
            position: absolute;
            top: 0;
            left: 2px;
            width: 2px;
            height: 100%;
            background: var(--accent);
            opacity: 0;
            transition: opacity .15s;
          }
          .resize-handle:hover::after,
          .shell.resizing .resize-handle::after { opacity: .6; }

          /* Main column */

          .main {
            display: grid;
            grid-template-rows: auto minmax(0, 1fr);
            min-width: 0;
            height: var(--app-h);
          }

          .topbar {
            position: relative;
            z-index: 20;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            min-height: calc(var(--header-h) + env(safe-area-inset-top));
            padding: calc(10px + env(safe-area-inset-top)) 24px 10px;
            border-bottom: 1px solid var(--line);
            background: var(--header-bg);
            backdrop-filter: blur(14px);
            -webkit-backdrop-filter: blur(14px);
          }
          .topbar-left { display: flex; align-items: center; gap: 12px; min-width: 0; }
          .topbar-right { display: flex; align-items: center; gap: 8px; }

          /* 文档标题在 header 内水平居中，左右留出按钮与安全间距 */
          .doc-heading {
            position: absolute;
            top: 50%;
            right: 70px;
            left: 70px;
            display: flex;
            justify-content: center;
            min-width: 0;
            line-height: 1.2;
            transform: translateY(-50%);
          }
          .doc-title {
            max-width: 100%;
            min-width: 0;
            margin: 0;
            overflow: hidden;
            color: var(--ink);
            font-family: var(--font-serif);
            font-size: 1.125rem;
            font-weight: 400;
            text-align: center;
            text-overflow: ellipsis;
            white-space: nowrap;
          }

          .icon-btn {
            display: grid;
            place-items: center;
            width: 38px;
            height: 38px;
            padding: 0;
            border: 1px solid var(--line);
            border-radius: 999px;
            background: var(--surface);
            color: var(--ink);
            cursor: pointer;
            transition: background .15s, border-color .15s, color .15s;
          }
          .icon-btn:hover { border-color: var(--accent); background: var(--bg); color: var(--accent-ink); }

          .icon-menu { position: relative; width: 16px; height: 1.5px; border-radius: 2px; background: currentColor; }
          .icon-menu::before,
          .icon-menu::after {
            content: "";
            position: absolute;
            left: 0;
            width: 16px;
            height: 1.5px;
            border-radius: 2px;
            background: currentColor;
          }
          .icon-menu::before { top: -5px; }
          .icon-menu::after { top: 5px; }

          .icon-theme {
            position: relative;
            width: 16px;
            height: 16px;
            overflow: hidden;
            border: 1.5px solid currentColor;
            border-radius: 50%;
          }
          .icon-theme::after {
            content: "";
            position: absolute;
            top: 0;
            right: 0;
            bottom: 0;
            width: 50%;
            background: currentColor;
          }

          .icon-close { position: relative; width: 14px; height: 14px; }
          .icon-close::before,
          .icon-close::after {
            content: "";
            position: absolute;
            top: 6px;
            left: 0;
            width: 14px;
            height: 1.5px;
            border-radius: 2px;
            background: currentColor;
          }
          .icon-close::before { transform: rotate(45deg); }
          .icon-close::after { transform: rotate(-45deg); }

          .mobile-only { display: none; }

          /* Content */

          .content {
            min-height: 0;
            overflow-x: hidden;
            overflow-y: auto;
            overscroll-behavior-y: contain;
            scroll-behavior: smooth;
            scrollbar-width: thin;
            scrollbar-color: var(--line) transparent;
          }
          .content::-webkit-scrollbar { width: 10px; }
          .content::-webkit-scrollbar-track { background: transparent; }
          .content::-webkit-scrollbar-thumb {
            border: 3px solid var(--bg);
            border-radius: 999px;
            background: var(--line);
          }

          .article {
            width: min(100%, 1000px);
            margin: 0 auto;
            padding: 56px 32px 140px;
          }

          .article h2,
          .article h3,
          .article h4,
          .article h5,
          .article h6 {
            margin: 2em 0 .65em;
            color: var(--ink);
            font-family: var(--font-serif);
            font-weight: 400;
            line-height: 1.3;
            letter-spacing: -.005em;
            scroll-margin-top: 10px;
          }
          .article h2 {
            font-size: clamp(1.5rem, 1.3rem + .8vw, 1.75rem);
            line-height: 1.2;
          }
          .article h3 { font-size: 1.375rem; }
          .article h4 { font-size: 1.125rem; }
          .article h5,
          .article h6 { font-size: 1rem; }
          .article :is(h2, h3, h4, h5, h6):first-child { margin-top: 0; }

          .article .h-num {
            display: inline-block;
            margin-right: .5em;
            color: var(--ink-faint);
            font-family: var(--font-serif);
            font-size: inherit;
            font-weight: 400;
            font-variant-numeric: tabular-nums;
            letter-spacing: .01em;
          }

          .article p { margin: 0 0 1.15em; }
          .article strong { font-weight: 600; }
          .article ul,
          .article ol { margin: 0 0 1.15em; padding-left: 1.5em; }
          .article li + li { margin-top: .3em; }
          .article li::marker { color: var(--ink-muted); }

          .article blockquote {
            margin: 1.6em 0;
            padding: 1em 1.25em;
            border-left: 2px solid var(--accent);
            border-radius: 0 var(--radius) var(--radius) 0;
            background: var(--surface);
            color: var(--ink-muted);
            font-family: var(--font-serif);
            font-size: 1.0625em;
          }
          .article blockquote p { margin: 0 0 .7em; }
          .article blockquote p:last-child { margin-bottom: 0; }

          .article hr { margin: 2.5rem 0; border: 0; border-top: 1px solid var(--line); }

          .article code {
            padding: .12em .35em;
            border-radius: var(--radius-sm);
            background: var(--surface-strong);
            font-family: var(--font-mono);
            font-size: .875em;
          }
          .article pre {
            margin: 1.4em 0;
            padding: 1rem 1.25rem;
            overflow-x: auto;
            border: 1px solid var(--line);
            border-radius: var(--radius-lg);
            background: var(--code-bg);
            scrollbar-width: thin;
          }
          .article pre code {
            padding: 0;
            background: none;
            color: var(--ink-muted);
            font-size: .875rem;
            line-height: 1.6;
          }

          .article img {
            display: block;
            max-width: 100%;
            height: auto;
            margin: 1.5em auto;
            border-radius: var(--radius);
          }
          .article figure { margin: 2em 0; }
          .article figcaption {
            margin-top: .7em;
            color: var(--ink-muted);
            font-size: .8125rem;
            text-align: center;
          }
          .article .svg-graph { margin: 2em 0; }
          .article .svg-graph > svg { display: block; width: 100%; height: auto; }

          .article math { font-family: var(--font-math); font-size: 1em; }
          .article math[display="block"] {
            padding: .25em 0;
            overflow-x: auto;
            overflow-y: hidden;
            scrollbar-width: thin;
            scrollbar-color: var(--line) transparent;
          }

          /* Tables */

          .table-block { position: relative; margin: 1.6em 0; }

          .table-scroll {
            overflow-x: auto;
            overflow-y: hidden;
            overscroll-behavior-x: contain;
            border: 1px solid var(--line);
            border-radius: var(--radius);
            scrollbar-width: thin;
            scrollbar-color: var(--line) transparent;
            -webkit-overflow-scrolling: touch;
          }
          .table-scroll::-webkit-scrollbar { height: 8px; }
          .table-scroll::-webkit-scrollbar-track { background: transparent; }
          .table-scroll::-webkit-scrollbar-thumb {
            border: 2px solid var(--bg);
            border-radius: 999px;
            background: var(--line);
          }

          .table-scroll table {
            width: 100%;
            margin: 0;
            border-collapse: collapse;
            font-size: .9375rem;
          }
          .table-scroll th,
          .table-scroll td {
            padding: .6em .9em;
            border-bottom: 1px solid var(--line);
            text-align: left;
            vertical-align: top;
          }
          .table-scroll th {
            border-bottom: 1px solid var(--line);
            background: var(--surface);
            color: var(--ink);
            font-weight: 600;
            white-space: nowrap;
          }
          .table-scroll td { min-width: 6em; white-space: normal; overflow-wrap: break-word; }
          .table-scroll tr:last-child td { border-bottom: 0; }

          .table-block::after {
            content: "";
            position: absolute;
            top: 1px;
            right: 1px;
            bottom: 1px;
            z-index: 2;
            width: 44px;
            border-radius: 0 var(--radius) var(--radius) 0;
            background: linear-gradient(90deg, transparent, var(--bg));
            opacity: 0;
            pointer-events: none;
            transition: opacity .2s;
          }
          .table-block[data-overflow="true"][data-at-end="false"]::after { opacity: 1; }

          .table-expand {
            position: absolute;
            right: 10px;
            bottom: 10px;
            z-index: 3;
            display: none;
            place-items: center;
            width: 40px;
            height: 40px;
            padding: 0;
            border: 1px solid var(--line);
            border-radius: 999px;
            background: var(--bg);
            color: var(--ink);
            box-shadow: 0 4px 16px rgb(0 0 0 / 12%);
            cursor: pointer;
          }
          .table-block[data-overflow="true"] .table-expand { display: grid; }

          /* 触屏设备滑动即可滚动，隐藏横向滚动条；鼠标设备保留滚动条作为可滚动提示 */
          @media (hover: none) and (pointer: coarse) {
            .article pre,
            .article math[display="block"],
            .table-scroll {
              scrollbar-width: none;
              -ms-overflow-style: none;
            }
            .article pre::-webkit-scrollbar,
            .article math[display="block"]::-webkit-scrollbar,
            .table-scroll::-webkit-scrollbar { display: none; }
          }

          @media (hover: hover) and (min-width: 1001px) {
            .table-expand { opacity: 0; transition: opacity .15s; }
            .table-block:hover .table-expand,
            .table-expand:focus-visible { opacity: 1; }
          }

          .icon-expand { position: relative; width: 14px; height: 14px; }
          .icon-expand::before,
          .icon-expand::after {
            content: "";
            position: absolute;
            width: 6px;
            height: 6px;
            border-color: currentColor;
            border-style: solid;
          }
          .icon-expand::before { top: 0; right: 0; border-width: 1.5px 1.5px 0 0; }
          .icon-expand::after { bottom: 0; left: 0; border-width: 0 0 1.5px 1.5px; }

          .table-exit {
            position: absolute;
            top: 10px;
            right: 10px;
            z-index: 4;
            display: none;
            place-items: center;
            width: 36px;
            height: 36px;
            padding: 0;
            border: 1px solid var(--line);
            border-radius: 999px;
            background: var(--bg);
            color: var(--ink);
            font-size: 1.25rem;
            line-height: 1;
            cursor: pointer;
          }
          .table-block.is-fullscreen .table-exit,
          .table-block.is-faux .table-exit { display: grid; }
          .table-block.is-fullscreen .table-expand,
          .table-block.is-faux .table-expand { display: none; }
          .table-block.is-fullscreen::after,
          .table-block.is-faux::after { display: none; }

          @media (pointer: coarse) {
            .table-expand,
            .table-exit { width: 44px; height: 44px; }
          }

          .table-block:fullscreen {
            display: flex;
            flex-direction: column;
            gap: 12px;
            width: 100%;
            height: 100%;
            margin: 0;
            padding: calc(16px + env(safe-area-inset-top)) calc(16px + env(safe-area-inset-right))
              calc(16px + env(safe-area-inset-bottom)) calc(16px + env(safe-area-inset-left));
            border-radius: 0;
            background: var(--bg);
          }
          .table-block:fullscreen::backdrop { background: var(--bg); }
          .table-block:fullscreen .table-scroll { flex: 1; height: auto; overflow: auto; }

          .table-block.is-faux {
            position: fixed;
            z-index: 1000;
            display: flex;
            flex-direction: column;
            gap: 12px;
            margin: 0;
            padding: 16px;
            border-radius: 0;
            background: var(--bg);
            box-shadow: 0 0 0 100vmax var(--bg);
          }
          .table-block.is-faux .table-scroll { flex: 1; height: auto; overflow: auto; }
          .table-block.is-faux:not(.is-rotated) { inset: 0; width: auto; height: auto; }
          .table-block.is-faux.is-rotated {
            top: 0;
            left: 100vw;
            width: 100vh;
            height: 100vw;
            transform: rotate(90deg);
            transform-origin: top left;
          }
          @supports (height: 100dvh) {
            .table-block.is-faux.is-rotated { width: 100dvh; height: 100dvw; }
          }

          html.table-locked,
          html.table-locked body,
          html.drawer-open,
          html.drawer-open body { overflow: hidden; }

          /* -----------------------------------------------------------------
             Mobile drawer
             ----------------------------------------------------------------- */

          @media (max-width: 1000px) {
            .shell { grid-template-columns: minmax(0, 1fr); }
            .shell[data-sidebar="closed"] { --sidebar-w: 300px; }

            .sidebar {
              position: fixed;
              top: 0;
              bottom: 0;
              left: 0;
              z-index: 40;
              width: min(84vw, 320px);
              height: var(--app-h);
              border-right: 1px solid var(--line);
              transform: translateX(var(--drawer-x, -100%));
              transition: transform var(--dur) var(--ease);
            }
            .shell[data-drawer="open"] .sidebar { --drawer-x: 0px; }
            .sidebar.dragging { transition: none; }

            .overlay {
              position: fixed;
              inset: 0;
              z-index: 30;
              background: var(--overlay);
              opacity: 0;
              pointer-events: none;
              transition: opacity var(--dur);
            }
            .shell[data-drawer="open"] .overlay { opacity: 1; pointer-events: auto; }

            .mobile-only { display: grid; }
            .resize-handle { display: none; }
            .topbar { padding-right: 12px; padding-left: 12px; }
            .icon-btn { width: 40px; height: 40px; }
            .article { padding: 36px 20px 110px; }
          }

          @media (min-width: 1001px) {
            .overlay { display: none; }
          }

          /* lil-gui (Three.js debug panel) */

          .lil-gui.root {
            position: absolute;
            top: 8px;
            right: 8px;
            z-index: 10;
            width: min(25%, 250px);
          }
          .lil-gui {
            --background-color: var(--surface);
            --title-background-color: var(--surface-strong);
            --title-text-color: var(--ink);
            --widget-color: var(--surface-strong);
            --hover-color: var(--surface-strong);
            --text-color: var(--ink);
            --string-color: var(--accent-ink);
            --number-color: var(--ink);
          }
          @media (max-width: 1000px) {
            .lil-gui.root { display: none; }
          }

          /* -----------------------------------------------------------------
             Print & motion
             ----------------------------------------------------------------- */

          @media print {
            .sidebar,
            .topbar,
            .overlay,
            .resize-handle,
            .skip-link,
            .table-expand,
            .table-exit { display: none !important; }

            .shell { display: block; height: auto; overflow: visible; }
            .main { display: block; height: auto; }
            .content { overflow: visible; }
            .article { width: auto; max-width: none; padding: 0; }
            .table-scroll { overflow: visible; }
            .table-scroll table { min-width: 0; font-size: .85em; }
            .table-block { break-inside: avoid; }
            .table-block::after { display: none; }
            a { color: inherit; border-bottom: 0; }
          }

          @media (prefers-reduced-motion: reduce) {
            *,
            *::before,
            *::after {
              scroll-behavior: auto !important;
              transition-duration: .01ms !important;
              animation-duration: .01ms !important;
              animation-iteration-count: 1 !important;
            }
          }
          ```.text,
        )

        html.script(
          type: "module",
          "const ui = " + json.encode(ui) + ";\n" + ```js
          const mq = window.matchMedia("(max-width: 1000px)");
          const docEl = document.documentElement;
          const shell = document.querySelector(".shell");
          const sidebar = document.getElementById("sidebar");
          const mainEl = document.querySelector(".main");
          const overlay = document.querySelector(".overlay");
          const content = document.getElementById("content");
          const toggle = document.getElementById("sidebar-toggle");
          const closeBtn = document.getElementById("sidebar-close");
          const resizeHandle = document.querySelector(".resize-handle");
          const tocRoot = document.getElementById("toc-root");

          const isMobile = () => mq.matches;

          function store(key, value) {
            try { localStorage.setItem(key, value); } catch (error) {}
          }

          function read(key) {
            try { return localStorage.getItem(key); } catch (error) { return null; }
          }

          /* Theme switching: light → green → dark */

          const themeToggle = document.getElementById("theme-toggle");
          const themeQuery = window.matchMedia("(prefers-color-scheme: dark)");
          const themeOrder = ["light", "green", "dark"];
          const themeNames = {
            light: ui.themeLight,
            green: ui.themeGreen,
            dark: ui.themeDark,
          };

          function effectiveTheme() {
            return docEl.dataset.theme || (themeQuery.matches ? "dark" : "light");
          }

          function syncThemeButton() {
            if (!themeToggle) return;
            const name = themeNames[effectiveTheme()] || themeNames.light;
            const label = ui.themeCurrent.replace("{name}", name);
            themeToggle.setAttribute("aria-label", label);
            themeToggle.setAttribute("title", label);
          }

          if (themeToggle) {
            themeToggle.addEventListener("click", () => {
              const next = themeOrder[(themeOrder.indexOf(effectiveTheme()) + 1) % themeOrder.length];
              docEl.dataset.theme = next;
              store("itemplate:theme", next);
              syncThemeButton();
            });
            syncThemeButton();
          }

          themeQuery.addEventListener("change", syncThemeButton);

          function sidebarIsOpen() {
            if (!shell) return false;
            return isMobile()
              ? shell.dataset.drawer === "open"
              : shell.dataset.sidebar !== "closed";
          }

          function syncSidebarA11y() {
            const open = sidebarIsOpen();
            if (toggle) {
              toggle.setAttribute("aria-expanded", open ? "true" : "false");
              toggle.setAttribute("aria-label", open ? ui.sidebarCollapse : ui.sidebarExpand);
            }
            if (sidebar) {
              sidebar.inert = !open;
              if (open) sidebar.removeAttribute("inert");
              else sidebar.setAttribute("inert", "");
            }
            if (mainEl) {
              const trap = isMobile() && open;
              mainEl.inert = trap;
              if (trap) mainEl.setAttribute("inert", "");
              else mainEl.removeAttribute("inert");
            }
          }

          function clearDrawerOffset() {
            if (!sidebar) return;
            requestAnimationFrame(() => sidebar.style.removeProperty("--drawer-x"));
          }

          function setDrawer(open, focus) {
            if (!isMobile() || !shell) return;
            shell.dataset.drawer = open ? "open" : "closed";
            docEl.classList.toggle("drawer-open", open);
            syncSidebarA11y();
            clearDrawerOffset();
            if (open && focus && closeBtn) requestAnimationFrame(() => closeBtn.focus());
            if (!open && focus && toggle) requestAnimationFrame(() => toggle.focus());
          }

          function setDesktopSidebar(open) {
            if (!shell) return;
            shell.dataset.sidebar = open ? "open" : "closed";
            store("itemplate:sidebar-open", open ? "1" : "0");
            syncSidebarA11y();
          }

          function toggleSidebar() {
            if (!shell) return;
            if (isMobile()) setDrawer(shell.dataset.drawer !== "open", true);
            else setDesktopSidebar(shell.dataset.sidebar === "closed");
          }

          if (shell) {
            shell.dataset.drawer = "closed";
            shell.dataset.sidebar = read("itemplate:sidebar-open") === "0" ? "closed" : "open";
            docEl.classList.remove("sidebar-preclosed");
            const savedWidth = Number(read("itemplate:sidebar-width"));
            if (savedWidth >= 240 && savedWidth <= 420) {
              docEl.style.setProperty("--sidebar-w", savedWidth + "px");
            }
            syncSidebarA11y();
          }

          if (toggle) toggle.addEventListener("click", toggleSidebar);
          if (closeBtn) closeBtn.addEventListener("click", () => setDrawer(false, true));
          if (overlay) overlay.addEventListener("click", () => setDrawer(false));

          mq.addEventListener("change", () => {
            if (!shell) return;
            shell.dataset.drawer = "closed";
            docEl.classList.remove("drawer-open");
            syncSidebarA11y();
            requestAnimationFrame(refreshAllTables);
          });

          /* TOC: collapse/expand + active section */

          const tocLinks = new Map();
          if (tocRoot) {
            tocRoot.querySelectorAll(".toc-link").forEach((link) => {
              const href = link.getAttribute("href") || "";
              if (href.startsWith("#")) tocLinks.set(href.slice(1), link);
            });

            tocRoot.addEventListener("click", (event) => {
              if (!(event.target instanceof Element)) return;

              const toggleBtn = event.target.closest(".toc-toggle");
              if (toggleBtn) {
                event.preventDefault();
                const item = toggleBtn.closest(".toc-item");
                if (!item) return;
                setItemCollapsed(item, item.dataset.collapsed !== "true");
                return;
              }

              const link = event.target.closest(".toc-link");
              if (link) {
                const href = link.getAttribute("href") || "";
                if (href.startsWith("#")) {
                  // 锁定 scrollspy，避免平滑滚动途中高亮跳到中间标题
                  lockSpy(href.slice(1));
                  setActiveLink(href.slice(1));
                }
                if (isMobile()) setDrawer(false);
              }
            });
          }

          let headings = [];
          let activeId = "";
          let scheduled = false;
          // 点击目录后，平滑滚动期间暂停 scrollspy 的高亮更新
          let spyLocked = false;
          let spyTargetId = "";
          let spySettleTimer = 0;

          function collectHeadings() {
            const article = document.querySelector(".article");
            headings = article
              ? Array.from(article.querySelectorAll("h2[id^='sec-'], h3[id^='sec-'], h4[id^='sec-'], h5[id^='sec-'], h6[id^='sec-']"))
              : [];
          }

          function setItemCollapsed(item, collapsed) {
            item.dataset.collapsed = collapsed ? "true" : "false";
            const btn = item.querySelector(":scope > .toc-row > .toc-toggle");
            if (!btn) return;
            btn.setAttribute("aria-expanded", collapsed ? "false" : "true");
            btn.setAttribute("aria-label", collapsed ? ui.tocExpand : ui.tocCollapse);
          }

          function expandAncestors(link) {
            let item = link.closest(".toc-item");
            item = item && item.parentElement ? item.parentElement.closest(".toc-item") : null;
            while (item) {
              if (item.dataset.collapsed === "true") setItemCollapsed(item, false);
              item = item.parentElement ? item.parentElement.closest(".toc-item") : null;
            }
          }

          // 手风琴式目录：只展开当前标题所在的路径，折叠其它已展开的分支
          function syncTocTree(link) {
            const item = link.closest(".toc-item");
            if (!item) return;
            expandAncestors(link);
            tocRoot.querySelectorAll('.toc-item[data-collapsed="false"]').forEach((other) => {
              if (!other.contains(item)) setItemCollapsed(other, true);
            });
          }

          function scrollTocLinkIntoView(link) {
            const nav = link.closest(".toc-nav");
            if (!nav) return;
            const linkRect = link.getBoundingClientRect();
            const navRect = nav.getBoundingClientRect();
            const pad = 8;
            if (linkRect.top < navRect.top + pad) {
              nav.scrollTop -= navRect.top + pad - linkRect.top;
            } else if (linkRect.bottom > navRect.bottom - pad) {
              nav.scrollTop += linkRect.bottom - (navRect.bottom - pad);
            }
          }

          // 高亮当前标题；目录树跟随滚动，展开当前路径并折叠其它分支
          function setActiveLink(id) {
            if (!id) return;
            const link = tocLinks.get(id);
            if (!link) return;

            if (id !== activeId) {
              activeId = id;
              tocLinks.forEach((other, lid) => {
                const active = lid === id;
                other.classList.toggle("is-active", active);
                const row = other.closest(".toc-row");
                if (row) row.classList.toggle("is-active", active);
                if (active) other.setAttribute("aria-current", "location");
                else other.removeAttribute("aria-current");
              });
              syncTocTree(link);
            }

            scrollTocLinkIntoView(link);
          }

          function lockSpy(id) {
            spyLocked = true;
            spyTargetId = id;
            clearTimeout(spySettleTimer);
            // 兜底：目标无法滚动到顶部（如页面末尾）时也要恢复 scrollspy
            spySettleTimer = setTimeout(releaseSpy, 1600);
          }

          // 目标标题是否已抵达 header 下方的落点（scroll-margin-top: 10px）
          function spyReachedTarget() {
            if (!spyTargetId) return true;
            const target = document.getElementById(spyTargetId);
            if (!target) return true;
            const topbar = document.querySelector(".topbar");
            const headerH = topbar ? topbar.getBoundingClientRect().height : 64;
            const top = target.getBoundingClientRect().top;
            return top >= headerH - 1 && top <= headerH + 20;
          }

          function releaseSpy() {
            clearTimeout(spySettleTimer);
            spySettleTimer = 0;
            if (!spyLocked) return;
            spyLocked = false;

            const id = spyTargetId;
            spyTargetId = "";
            const target = id ? document.getElementById(id) : null;
            if (target) {
              const topbar = document.querySelector(".topbar");
              const headerH = topbar ? topbar.getBoundingClientRect().height : 64;
              const rect = target.getBoundingClientRect();
              // 目标仍在视口内（页面末尾无法滚到顶部）则保持高亮
              if (rect.top < window.innerHeight && rect.bottom > headerH) {
                setActiveLink(id);
                return;
              }
            }
            updateActiveHeading();
          }

          function updateActiveHeading() {
            scheduled = false;
            if (spyLocked) return;
            if (!headings.length) return;
            const topbar = document.querySelector(".topbar");
            // 判定线：header 底部下方 10px，与 scroll-margin-top 一致
            const offset = (topbar ? topbar.getBoundingClientRect().height : 64) + 10;
            let current = headings[0];
            for (const heading of headings) {
              // +1px 容差，避免落点处的浮点误差导致高亮回退
              if (heading.getBoundingClientRect().top <= offset + 1) current = heading;
              else break;
            }
            if (current) setActiveLink(current.id);
          }

          function scheduleActiveHeading() {
            if (scheduled) return;
            scheduled = true;
            requestAnimationFrame(updateActiveHeading);
          }

          if (content) {
            content.addEventListener("scroll", () => {
              if (spyLocked) {
                // 平滑滚动途中锁定高亮，抵达目标落点后立即恢复 scrollspy
                if (spyReachedTarget()) releaseSpy();
                return;
              }
              scheduleActiveHeading();
            }, { passive: true });
            content.addEventListener("scrollend", releaseSpy, { passive: true });
            // 用户主动滚动时立即交还控制权，避免高亮长时间冻结
            ["wheel", "touchstart"].forEach((type) => {
              content.addEventListener(type, () => {
                if (spyLocked) releaseSpy();
              }, { passive: true });
            });
          }
          window.addEventListener("resize", scheduleActiveHeading);
          collectHeadings();
          scheduleActiveHeading();

          if (location.hash.length > 1) {
            const id = location.hash.slice(1);
            const link = tocLinks.get(id);
            if (link) setActiveLink(id);
            lockSpy(id);
            requestAnimationFrame(() => {
              const target = document.getElementById(id);
              if (target) target.scrollIntoView({ block: "start" });
            });
          }

          /* Tables: overflow detection + fullscreen */

          let fauxBlock = null;

          function refreshTable(block) {
            const scroller = block.querySelector(".table-scroll");
            if (!scroller) return;
            const overflow = scroller.scrollWidth > scroller.clientWidth + 1;
            block.dataset.overflow = overflow ? "true" : "false";
            const atEnd = scroller.scrollLeft + scroller.clientWidth >= scroller.scrollWidth - 2;
            block.dataset.atEnd = atEnd ? "true" : "false";
          }

          function refreshAllTables() {
            document.querySelectorAll(".table-block").forEach(refreshTable);
          }

          function updateFauxRotation() {
            if (!fauxBlock) return;
            fauxBlock.classList.toggle("is-rotated", window.innerHeight > window.innerWidth);
          }

          async function enterTableFullscreen(block) {
            if (document.fullscreenEnabled && block.requestFullscreen) {
              try {
                await block.requestFullscreen();
                block.classList.add("is-fullscreen");
                if (screen.orientation && screen.orientation.lock) {
                  try { await screen.orientation.lock("landscape"); } catch (error) {}
                }
                return;
              } catch (error) {}
            }

            fauxBlock = block;
            block.classList.add("is-faux");
            updateFauxRotation();
            docEl.classList.add("table-locked");
          }

          function exitTableFullscreen() {
            if (document.fullscreenElement && document.exitFullscreen) {
              document.exitFullscreen();
              return;
            }
            if (fauxBlock) {
              fauxBlock.classList.remove("is-faux", "is-rotated");
              fauxBlock = null;
              docEl.classList.remove("table-locked");
            }
          }

          function initTable(block) {
            const scroller = block.querySelector(".table-scroll");
            const expand = block.querySelector(".table-expand");
            const exit = block.querySelector(".table-exit");
            if (!scroller) return;

            scroller.addEventListener("scroll", () => refreshTable(block), { passive: true });
            if (window.ResizeObserver) {
              new ResizeObserver(() => refreshTable(block)).observe(scroller);
            }
            if (expand) expand.addEventListener("click", () => enterTableFullscreen(block));
            if (exit) exit.addEventListener("click", exitTableFullscreen);
            refreshTable(block);
          }

          document.querySelectorAll(".table-block").forEach(initTable);
          refreshAllTables();
          window.addEventListener("resize", refreshAllTables);
          window.addEventListener("orientationchange", updateFauxRotation);
          if (document.fonts && document.fonts.ready) {
            document.fonts.ready.then(refreshAllTables).catch(() => {});
          }

          document.addEventListener("fullscreenchange", () => {
            const element = document.fullscreenElement;
            document.querySelectorAll(".table-block.is-fullscreen").forEach((block) => {
              if (block !== element) block.classList.remove("is-fullscreen");
            });
            if (element && element.classList && element.classList.contains("table-block")) {
              element.classList.add("is-fullscreen");
            } else if (screen.orientation && screen.orientation.unlock) {
              try { screen.orientation.unlock(); } catch (error) {}
            }
          });

          /* Touch drawer: swipe right to open, swipe left to close */

          function isInScrollableArea(target) {
            let element = target instanceof Element ? target : null;
            while (element && element !== document.body) {
              if (element.classList && (element.classList.contains("table-scroll") || element.tagName === "CANVAS")) {
                return true;
              }
              const style = getComputedStyle(element);
              const overflowX = style.overflowX;
              if (
                (overflowX === "auto" || overflowX === "scroll" || overflowX === "overlay")
                && element.scrollWidth > element.clientWidth + 1
              ) {
                return true;
              }
              element = element.parentElement;
            }
            return false;
          }

          let touchState = null;

          document.addEventListener("touchstart", (event) => {
            if (!isMobile() || !shell || event.touches.length !== 1 || fauxBlock) return;
            const touch = event.touches[0];
            const open = shell.dataset.drawer === "open";

            if (open) {
              const target = event.target;
              if (!(target instanceof Element) || !(target.closest(".sidebar") || target.closest(".overlay"))) {
                return;
              }
            } else if (isInScrollableArea(event.target)) {
              return;
            }

            touchState = {
              x: touch.clientX,
              y: touch.clientY,
              lastX: touch.clientX,
              startTime: performance.now(),
              open: open,
              width: sidebar ? sidebar.getBoundingClientRect().width : 300,
              dragging: false,
            };
          }, { passive: true });

          document.addEventListener("touchmove", (event) => {
            if (!touchState || event.touches.length !== 1) return;
            const touch = event.touches[0];
            const dx = touch.clientX - touchState.x;
            const dy = touch.clientY - touchState.y;

            if (!touchState.dragging) {
              if (Math.abs(dx) < 8 && Math.abs(dy) < 8) return;
              // 竖向滚动、或收起状态下向左滑：交给页面自身处理
              if (Math.abs(dy) >= Math.abs(dx) || (!touchState.open && dx < 0)) {
                touchState = null;
                return;
              }
              touchState.dragging = true;
              if (sidebar) sidebar.classList.add("dragging");
            }

            event.preventDefault();
            const base = touchState.open ? 0 : -touchState.width;
            const x = Math.max(-touchState.width, Math.min(0, base + dx));
            if (sidebar) sidebar.style.setProperty("--drawer-x", x + "px");
            touchState.lastX = touch.clientX;
          }, { passive: false });

          document.addEventListener("touchend", () => {
            if (!touchState) return;
            const state = touchState;
            touchState = null;
            if (!state.dragging) return;
            if (sidebar) sidebar.classList.remove("dragging");

            const dx = state.lastX - state.x;
            const duration = Math.max(1, performance.now() - state.startTime);
            const velocity = dx / duration;
            const shouldOpen = state.open
              ? !(dx < -state.width * 0.3 || velocity < -0.35)
              : (dx > state.width * 0.3 || velocity > 0.35);

            if (!shell) return;
            shell.dataset.drawer = shouldOpen ? "open" : "closed";
            docEl.classList.toggle("drawer-open", shouldOpen);
            syncSidebarA11y();
            clearDrawerOffset();
          });

          /* Keyboard */

          document.addEventListener("keydown", (event) => {
            if (event.key !== "Escape") return;
            if (isMobile() && shell && shell.dataset.drawer === "open") {
              setDrawer(false, true);
            } else if (fauxBlock) {
              exitTableFullscreen();
            }
          });

          /* Desktop sidebar resizing */

          if (resizeHandle) {
            let resizing = false;
            let startX = 0;
            let startWidth = 0;

            const onPointerMove = (event) => {
              if (!resizing) return;
              const width = Math.min(420, Math.max(240, startWidth + event.clientX - startX));
              docEl.style.setProperty("--sidebar-w", width + "px");
            };

            const stopResize = (event) => {
              if (!resizing) return;
              resizing = false;
              if (shell) shell.classList.remove("resizing");
              if (resizeHandle.hasPointerCapture && resizeHandle.hasPointerCapture(event.pointerId)) {
                resizeHandle.releasePointerCapture(event.pointerId);
              }
              window.removeEventListener("pointermove", onPointerMove);
              window.removeEventListener("pointerup", stopResize);
              const width = sidebar ? sidebar.getBoundingClientRect().width : 300;
              store("itemplate:sidebar-width", String(Math.round(width)));
            };

            resizeHandle.addEventListener("pointerdown", (event) => {
              if (isMobile()) return;
              event.preventDefault();
              resizing = true;
              startX = event.clientX;
              startWidth = sidebar ? sidebar.getBoundingClientRect().width : 300;
              if (shell) {
                shell.dataset.sidebar = "open";
                shell.classList.add("resizing");
              }
              if (resizeHandle.setPointerCapture) resizeHandle.setPointerCapture(event.pointerId);
              window.addEventListener("pointermove", onPointerMove);
              window.addEventListener("pointerup", stopResize);
            });

            resizeHandle.addEventListener("keydown", (event) => {
              if (isMobile()) return;
              if (event.key !== "ArrowLeft" && event.key !== "ArrowRight") return;
              event.preventDefault();
              const current = sidebar ? sidebar.getBoundingClientRect().width : 300;
              const next = Math.min(420, Math.max(240, current + (event.key === "ArrowRight" ? 16 : -16)));
              docEl.style.setProperty("--sidebar-w", next + "px");
              store("itemplate:sidebar-width", String(next));
            });
          }
          ```.text,
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
