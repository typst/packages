// Base stylesheet for the HTML app shell.
#let base-styles = ```css
:root {
  --sidebar-w: 300px;
  --header-h: 58px;
  --app-h: 100vh;
  --radius-sm: 4px;
  --radius: 8px;
  --radius-lg: 12px;
  --ease: cubic-bezier(.32, .72, 0, 1);
  --dur: .28s;
  color-scheme: light;
}

:root[data-theme="default"],
:root[data-theme="paper"],
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
  min-height: var(--header-h);
  padding: 19px 20px 14px;
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
  padding: calc(9px + env(safe-area-inset-top)) 24px 9px;
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
.table-block:fullscreen thead th,
.table-block.is-faux thead th {
  position: sticky;
  top: 0;
  z-index: 1;
}

.table-block.is-faux {
  position: fixed;
  z-index: 1000;
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin: 0;
  padding: calc(16px + env(safe-area-inset-top)) calc(16px + env(safe-area-inset-right))
    calc(16px + env(safe-area-inset-bottom)) calc(16px + env(safe-area-inset-left));
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
  .sidebar-head {
    min-height: calc(var(--header-h) + 1px + env(safe-area-inset-top));
    padding-top: calc(9px + env(safe-area-inset-top));
    padding-bottom: 9px;
  }
  .topbar {
    height: calc(var(--header-h) + 1px + env(safe-area-inset-top));
    padding-right: 12px;
    padding-left: 12px;
    overflow: hidden;
    transition:
      height var(--dur) var(--ease),
      padding var(--dur) var(--ease),
      opacity .2s,
      border-bottom-width var(--dur) var(--ease),
      visibility 0s;
  }
  /* On small screens the topbar is only shown at the very top of the
     document, so the content gets the full viewport while scrolling. */
  .main.topbar-hidden .topbar {
    height: 0;
    min-height: 0;
    padding-top: 0;
    padding-bottom: 0;
    border-bottom-width: 0;
    opacity: 0;
    visibility: hidden;
    transition:
      height var(--dur) var(--ease),
      padding var(--dur) var(--ease),
      opacity .2s,
      border-bottom-width var(--dur) var(--ease),
      visibility 0s var(--dur);
  }
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
```.text
