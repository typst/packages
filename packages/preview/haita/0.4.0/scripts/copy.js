function copyCode(text) {
  const done = () => {
    const clipboard = this.querySelector(".clipboard");
    const check = this.querySelector(".check");
    clipboard.classList.add("hidden");
    check.classList.remove("hidden");
    setTimeout(() => {
      clipboard.classList.remove("hidden");
      check.classList.add("hidden");
    }, 2000);
  };

  if (navigator.clipboard) {
    navigator.clipboard.writeText(text).then(done).catch(console.error);
  } else {
    const input = document.createElement("textarea");
    input.value = text;
    input.style.position = "fixed";
    input.style.top = "0";
    input.style.left = "0";
    input.style.opacity = "0";
    input.setAttribute("readonly", "");
    document.body.appendChild(input);
    input.select();
    document.execCommand("copy");
    document.body.removeChild(input);
    done();
  }
}

document.querySelectorAll(".copy-code-btn").forEach((btn) => {
  const text = btn.nextElementSibling.querySelector("code").textContent;
  btn.addEventListener("click", () => copyCode.call(btn, text));
});

document.querySelectorAll(".copy-math-btn").forEach((btn) => {
  const text = btn.parentElement.title;
  btn.addEventListener("click", () => copyCode.call(btn, text));
});
