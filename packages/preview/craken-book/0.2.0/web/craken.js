// Captain Craken — Paper/Lantern switch. Follows the system setting until the
// reader picks one; the choice is remembered in this browser only.
(function () {
  var root = document.documentElement, key = "craken-theme";
  try { var saved = localStorage.getItem(key); if (saved) root.dataset.theme = saved; } catch (e) {}
  function current() {
    return root.dataset.theme || (matchMedia("(prefers-color-scheme: dark)").matches ? "lantern" : "paper");
  }
  function label() {
    var b = document.querySelector(".ck-theme-toggle");
    if (b) b.lastChild.textContent = current() === "lantern" ? "Paper" : "Lantern";
  }
  document.addEventListener("click", function (e) {
    if (!e.target.closest(".ck-theme-toggle")) return;
    var next = current() === "lantern" ? "paper" : "lantern";
    root.dataset.theme = next;
    try { localStorage.setItem(key, next); } catch (e) {}
    label();
  });
  // Brackets around short things keep their text size: Typst marks every
  // bracket stretchy, and browsers then reach for a bigger glyph.
  function tidyMath() {
    var tall = "mfrac, munder, mover, munderover, mtable, msqrt, mroot";
    document.querySelectorAll("math mrow > mo").forEach(function (mo) {
      if ("()[]{}|‖⟨⟩⌊⌋⌈⌉".indexOf(mo.textContent.trim()) < 0) return;
      if (!mo.parentElement.querySelector(tall)) mo.setAttribute("stretchy", "false");
    });
  }
  document.addEventListener("DOMContentLoaded", function () { label(); tidyMath(); });
})();
