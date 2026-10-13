// Script for the website output of typtorial

// Color scheme: follows the system until the button is used; the choice is remembered.
{
  const root = document.documentElement;
  const key = "tutorial-theme";
  try {
    const saved = localStorage.getItem(key);
    if (saved) root.dataset.theme = saved;
  } catch {}

  document.querySelector(".theme-toggle")?.addEventListener("click", () => {
    const dark = root.dataset.theme
      ? root.dataset.theme === "dark"
      : matchMedia("(prefers-color-scheme: dark)").matches;
    root.dataset.theme = dark ? "light" : "dark";
    try {
      localStorage.setItem(key, root.dataset.theme);
    } catch {}
  });
}

// Download button: offers the tutorial's source file as it was when the page was built.
document.querySelector(".download")?.addEventListener("click", (event) => {
  const button = event.currentTarget;
  const link = document.createElement("a");
  link.href = URL.createObjectURL(new Blob([button.dataset.source], { type: "text/plain" }));
  link.download = button.dataset.name;
  link.click();
  URL.revokeObjectURL(link.href);
});

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
}

// Copy buttons: copy the code exactly as written in the source file.
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
