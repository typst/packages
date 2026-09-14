const CODE_BLOCK_SELECTOR = ".expressive-code";
const COPY_BUTTON_SELECTOR = ".copy-button";

const selectCodeBlocks = () =>
  Array.from(document.querySelectorAll(CODE_BLOCK_SELECTOR));

const extractCodeText = (codeBlock) =>
  Array.from(codeBlock.querySelectorAll(".ec-line .code"))
    .map((line) => {
      const indent = line.dataset.indent ?? "";
      const content = line.textContent
        .replace(/\u00a0/g, " ")
        .replace(/\u200b/gi, "");
      return indent + content;
    })
    .join("\n");

const fallbackCopy = (text) => {
  const textarea = document.createElement("textarea");
  textarea.value = text;
  textarea.setAttribute("readonly", "true");
  textarea.style.position = "absolute";
  textarea.style.left = "-9999px";
  document.body.appendChild(textarea);
  textarea.select();
  /** @type {any} */ (document).execCommand("copy");
  document.body.removeChild(textarea);
};

const setStateWithTimeout = (button, state, delay = 1600) => {
  button.dataset.state = state;
  if (state === "copied") {
    setTimeout(() => {
      if (button.dataset.state === "copied") {
        button.dataset.state = "idle";
      }
    }, delay);
  }
};

const bindCopyButton = (codeBlock) => {
  if (!codeBlock || codeBlock.dataset.copyBound === "true") return;

  const copyButton = codeBlock.querySelector(COPY_BUTTON_SELECTOR);
  if (!copyButton) return;

  codeBlock.dataset.copyBound = "true";

  const copyHandler = async () => {
    const code = extractCodeText(codeBlock);

    try {
      if (navigator.clipboard?.writeText) {
        await navigator.clipboard.writeText(code);
      } else {
        fallbackCopy(code);
      }
      setStateWithTimeout(copyButton, "copied");
    } catch (error) {
      try {
        fallbackCopy(code);
        setStateWithTimeout(copyButton, "copied");
      } catch (fallbackError) {
        setStateWithTimeout(copyButton, "error", 2200);
      }
    }
  };

  const resetHandler = () => {
    if (copyButton.dataset.state === "copied") {
      copyButton.dataset.state = "idle";
    }
  };

  copyButton.addEventListener("click", copyHandler);
  copyButton.addEventListener("blur", resetHandler);
  copyButton.addEventListener("mouseleave", resetHandler);
};

selectCodeBlocks().forEach(bindCopyButton);

const observer = new MutationObserver((mutations) => {
  for (const mutation of mutations) {
    mutation.addedNodes.forEach((node) => {
      if (!(node instanceof HTMLElement)) return;
      if (node.matches?.(CODE_BLOCK_SELECTOR)) {
        bindCopyButton(node);
      } else {
        node
          .querySelectorAll?.(CODE_BLOCK_SELECTOR)
          .forEach((block) => bindCopyButton(block));
      }
    });
  }
});

observer.observe(document.documentElement, {
  childList: true,
  subtree: true,
});
