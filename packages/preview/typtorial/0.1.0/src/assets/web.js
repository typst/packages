{
  const root = document.documentElement;
  const key = "tutorial-theme";
  try {
    const saved = localStorage.getItem(key);
    if (saved) root.dataset.theme = saved;
  } catch {}

  const toggle = () => {
    const dark = root.dataset.theme
      ? root.dataset.theme === "dark"
      : matchMedia("(prefers-color-scheme: dark)").matches;
    root.dataset.theme = dark ? "light" : "dark";
    try {
      localStorage.setItem(key, root.dataset.theme);
    } catch {}
  };
  for (const button of document.querySelectorAll(".theme-toggle")) button.addEventListener("click", toggle);
}

// Buttons in the text share the source of the one in the header.
{
  const source = document.querySelector("header .download");
  const download = () => {
    const link = document.createElement("a");
    link.href = URL.createObjectURL(new Blob([source.dataset.source], { type: "text/plain" }));
    link.download = source.dataset.name;
    link.click();
    URL.revokeObjectURL(link.href);
  };
  if (source) for (const button of document.querySelectorAll(".download")) button.addEventListener("click", download);
}

// Pinned code panel: the step in the middle of the screen decides which code is visible.
{
  const panel = document.createElement("div");
  panel.className = "panel";
  document.querySelector("main").before(panel);
  document.documentElement.classList.add("pinned");

  // Title and abstract pages count as sections too; during them no code is shown.
  const sections = [...document.querySelectorAll(".intro, .step")];
  const activate = (active) => {
    for (const section of sections) section.classList.toggle("active", section === active);
    panel.classList.toggle("hidden", !active.classList.contains("step") || active.classList.contains("no-code"));
  };
  if (sections.length > 0) activate(sections[0]);

  const observer = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) if (entry.isIntersecting) activate(entry.target);
    },
    { rootMargin: "-50% 0px -50% 0px" },
  );
  for (const section of sections) observer.observe(section);

  // Arrow keys: one step forward or back. Presses during the scroll count from its target.
  let target = null;
  let settle;
  addEventListener("scroll", () => {
    clearTimeout(settle);
    settle = setTimeout(() => (target = null), 150);
  });
  addEventListener("keydown", (event) => {
    const step = { ArrowRight: 1, ArrowLeft: -1 }[event.key];
    if (!step || event.defaultPrevented || event.altKey || event.ctrlKey || event.metaKey || event.shiftKey) return;
    if (event.target.closest("input, textarea, select, [contenteditable]")) return;
    const from = target ?? sections.findIndex((section) => section.classList.contains("active"));
    const to = Math.min(Math.max(from + step, 0), sections.length - 1);
    if (to === from) return;
    event.preventDefault();
    target = to;
    sections[to].scrollIntoView();
  });
}

// Tabs: only the selected code block is shown. Without the script all stay visible.
for (const tabs of document.querySelectorAll(".tabs")) {
  const buttons = [...tabs.querySelectorAll(".tab")];
  const panels = [...tabs.querySelectorAll(".tab-panel")];

  // The copy buttons move into the row of the tab bar, only the selected one is shown.
  const bar = tabs.querySelector(".tab-bar");
  const head = document.createElement("div");
  head.className = "tab-head";
  const copy = document.createElement("div");
  copy.className = "tab-copy";
  bar.before(head);
  head.append(bar, copy);
  const copies = panels.map((panel) => panel.querySelector(".block > p"));
  copy.append(...copies.filter(Boolean));

  const select = (index) => {
    buttons.forEach((button, i) => button.setAttribute("aria-selected", i === index));
    panels.forEach((panel, i) => (panel.hidden = i !== index));
    copies.forEach((item, i) => item && (item.hidden = i !== index));
  };
  buttons.forEach((button, i) => button.addEventListener("click", () => select(i)));
  select(0);
  tabs.classList.add("ready");

  // Tabs that do not fit next to the copy button get a row of their own below it and
  // scroll sideways if they still do not fit.
  const fit = () => {
    head.classList.remove("stacked");
    if (bar.scrollWidth > bar.clientWidth) head.classList.add("stacked");
  };
  new ResizeObserver(fit).observe(head);
}

document.addEventListener("click", async (event) => {
  const button = event.target.closest("button[data-code]");
  if (!button) return;

  const code = button.dataset.code;
  try {
    await navigator.clipboard.writeText(code);
  } catch {
    // Without clipboard access (e.g. a locally opened file) copy via a text area.
    const area = document.createElement("textarea");
    area.value = code;
    document.body.append(area);
    area.select();
    document.execCommand("copy");
    area.remove();
  }

  button.textContent = button.dataset.copied;
  button.classList.add("copied");
  setTimeout(() => {
    button.textContent = button.dataset.copy;
    button.classList.remove("copied");
  }, 1500);
});
