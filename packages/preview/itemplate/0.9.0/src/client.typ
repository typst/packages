// Client-side scripts injected into the HTML shell.
#let prepaint-script = ```js
try {
  if (localStorage.getItem("itemplate:sidebar-open") === "0") {
    document.documentElement.classList.add("sidebar-preclosed");
  }
  var savedTheme = localStorage.getItem("itemplate:theme");
  if (savedTheme === "default" || savedTheme === "paper" || savedTheme === "dark" || savedTheme === "green") {
    document.documentElement.dataset.theme = savedTheme;
  }
} catch (error) {}
```.text

#let client-script = ```js
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

/* Theme switching: default → paper → green → dark. The default theme is
   used until the reader selects another theme. */

const themeToggle = document.getElementById("theme-toggle");
const themeColorMeta = document.querySelector('meta[name="theme-color"]');
const themeOrder = ["default", "paper", "green", "dark"];
const themeNames = {
  default: ui.themeDefault,
  paper: ui.themePaper,
  green: ui.themeGreen,
  dark: ui.themeDark,
};

function effectiveTheme() {
  return docEl.dataset.theme || "default";
}

function syncThemeButton() {
  if (!themeToggle) return;
  const name = themeNames[effectiveTheme()] || themeNames.default;
  const label = ui.themeCurrent.replace("{name}", name);
  themeToggle.setAttribute("aria-label", label);
  themeToggle.setAttribute("title", label);
}

function syncThemeColor() {
  if (!themeColorMeta) return;
  const bg = getComputedStyle(docEl).getPropertyValue("--bg").trim();
  if (bg) themeColorMeta.setAttribute("content", bg);
}

if (themeToggle) {
  themeToggle.addEventListener("click", () => {
    const next = themeOrder[(themeOrder.indexOf(effectiveTheme()) + 1) % themeOrder.length];
    docEl.dataset.theme = next;
    store("itemplate:theme", next);
    syncThemeButton();
    syncThemeColor();
  });
  syncThemeButton();
  syncThemeColor();
}

/* Mobile: show the topbar only at the top of the document, so the content
   keeps the full viewport once the reader starts scrolling. */

function syncTopbar() {
  if (!mainEl || !content) return;
  mainEl.classList.toggle("topbar-hidden", isMobile() && content.scrollTop > 0);
}

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
  syncTopbar();
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
  content.addEventListener("scroll", syncTopbar, { passive: true });
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
window.addEventListener("resize", syncTopbar);
collectHeadings();
scheduleActiveHeading();
syncTopbar();

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
let fullscreenBlock = null;

function setFauxDialog(block, active) {
  if (!block) return;
  if (active) {
    block.setAttribute("role", "dialog");
    block.setAttribute("aria-modal", "true");
  } else {
    block.removeAttribute("role");
    block.removeAttribute("aria-modal");
  }
}

function focusTableControl(block, selector) {
  if (!block) return;
  const target = block.querySelector(selector);
  if (target) requestAnimationFrame(() => target.focus());
}

function fauxFocusables() {
  if (!fauxBlock) return [];
  return Array.from(
    fauxBlock.querySelectorAll('button:not([disabled]), [href], [tabindex]:not([tabindex="-1"])')
  ).filter((element) => element.getClientRects().length > 0);
}

function trapFauxFocus(event) {
  if (!fauxBlock || event.key !== "Tab") return;
  const items = fauxFocusables();
  if (!items.length) return;
  const first = items[0];
  const last = items[items.length - 1];
  if (!fauxBlock.contains(document.activeElement)) {
    event.preventDefault();
    first.focus();
  } else if (event.shiftKey && document.activeElement === first) {
    event.preventDefault();
    last.focus();
  } else if (!event.shiftKey && document.activeElement === last) {
    event.preventDefault();
    first.focus();
  }
}

function refreshTable(block) {
  const scroller = block.querySelector(".table-scroll");
  if (!scroller) return;
  const overflow = scroller.scrollWidth > scroller.clientWidth + 1;
  block.dataset.overflow = overflow ? "true" : "false";
  // A region that cannot scroll should not add an empty tab stop.
  scroller.tabIndex = overflow ? 0 : -1;
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
  fullscreenBlock = block;
  if (document.fullscreenEnabled && block.requestFullscreen) {
    try {
      await block.requestFullscreen();
      block.classList.add("is-fullscreen");
      focusTableControl(block, ".table-exit");
      if (screen.orientation && screen.orientation.lock) {
        try { await screen.orientation.lock("landscape"); } catch (error) {}
      }
      return;
    } catch (error) {
      fullscreenBlock = null;
    }
  }

  fauxBlock = block;
  block.classList.add("is-faux");
  setFauxDialog(block, true);
  updateFauxRotation();
  docEl.classList.add("table-locked");
  focusTableControl(block, ".table-exit");
}

function exitTableFullscreen() {
  if (document.fullscreenElement && document.exitFullscreen) {
    document.exitFullscreen();
    return;
  }
  if (fauxBlock) {
    const block = fauxBlock;
    fauxBlock = null;
    block.classList.remove("is-faux", "is-rotated");
    setFauxDialog(block, false);
    docEl.classList.remove("table-locked");
    focusTableControl(block, ".table-expand");
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
window.addEventListener("resize", () => {
  refreshAllTables();
  updateFauxRotation();
});
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
    fullscreenBlock = element;
    focusTableControl(element, ".table-exit");
  } else {
    if (screen.orientation && screen.orientation.unlock) {
      try { screen.orientation.unlock(); } catch (error) {}
    }
    if (fullscreenBlock) {
      focusTableControl(fullscreenBlock, ".table-expand");
      fullscreenBlock = null;
    }
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

// A system gesture or another touch interrupting the drag must snap
// the drawer back to its committed state instead of leaving an
// inline offset behind.
document.addEventListener("touchcancel", () => {
  if (!touchState) return;
  touchState = null;
  if (sidebar) sidebar.classList.remove("dragging");
  clearDrawerOffset();
}, { passive: true });

/* Keyboard */

document.addEventListener("keydown", (event) => {
  if (fauxBlock) trapFauxFocus(event);
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
    window.removeEventListener("pointercancel", stopResize);
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
    window.addEventListener("pointercancel", stopResize);
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
```.text
